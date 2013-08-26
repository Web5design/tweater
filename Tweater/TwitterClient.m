//
//  TwitterClient.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/23/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "TwitterClient.h"

#import "CoreFunctions.h"

#import <Accounts/Accounts.h>
#import <Social/Social.h>


//Shared instance
static TwitterClient *privateSharedInstance;


@implementation TwitterClient
{
	ACAccountStore *_accountStore;
	ACAccountType *_twitterAccountType;
	NSArray *_twitterAccounts;
	ACAccount *_currentAccount;
	NSURL *_apiFilterJSONURL;
	NSURLConnection *_streamConnection;
}

+ (TwitterClient *)sharedInstance
{
	@synchronized(self) {
		if (!privateSharedInstance) {
			privateSharedInstance = [[TwitterClient alloc] init];
		}
		return privateSharedInstance;
	}
}

- (id)init
{
	self = [super init];
	if (self != nil) {
		_accountStore = [[ACAccountStore alloc] init];
		_twitterAccountType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
		_apiFilterJSONURL = [NSURL URLWithString:@"https://stream.twitter.com/1.1/statuses/filter.json"];
	}
	return self;
}

#pragma mark - Permissions

- (void)requestPermissionsFromViewController:(UIViewController*)viewController
{	
	//Ask for Twitter permission and show options
	[_accountStore requestAccessToAccountsWithType:_twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
		if (error.code == 6) {
			NSLog(@"No Twitter account linked to device.");
			runOnMainQueueSync(^{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Oops!" message: @"Please Add a Twitter Account in Your Phone Settings!" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			});
		}
		if (!granted) {
			// The user rejected your request
			NSLog(@"User rejected access to the account.");
		}
		else {
			// Grab the available accounts
			_twitterAccounts = [_accountStore accountsWithAccountType:_twitterAccountType];
			//Present choice if more than 1 account otherwise use account
			if (_twitterAccounts.count > 1) {
				runOnMainQueueSync(^{
					UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose A Twitter Account" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
					for (ACAccount *twitterAccount in _twitterAccounts) {
						[actionSheet addButtonWithTitle:[NSString stringWithString:twitterAccount.username]];
					}
					[actionSheet showInView:viewController.view];
				});
			} else {
				_currentAccount = [_twitterAccounts objectAtIndex:0];
				[self.delegate didSignIn];
			}
		}
	}];
}

- (BOOL)hasCurrentAccount
{
	return !!_currentAccount;
}

- (void)logout
{
	_currentAccount = nil;
}

#pragma mark - Streaming

- (void)startStreamWithTerm:(NSString *)queryTerm
{
	if (!_currentAccount) {
		NSLog(@"Stream called without current account");
		return;
	}
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	[params setObject:@"1" forKey:@"include_entities"];
	[params setObject:@"true" forKey:@"stall_warnings"];
	[params setObject:@"length" forKey:@"delimited"];
	
	//Normalize query term
	queryTerm = [queryTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	queryTerm = [queryTerm stringByReplacingOccurrencesOfString:@"[ ]+"
													 withString:@" "
														options:NSRegularExpressionSearch
														  range:NSMakeRange(0, queryTerm.length)];
	if ([queryTerm hasPrefix:@"@"]) {
		//Do user ID lookup with twitter handle because you can't follow with screenname
		NSString *queryString = [@"?screen_name=" stringByAppendingString:[queryTerm substringFromIndex:1]];
		NSURL *userLookupURL = [NSURL URLWithString:[@"http://api.twitter.com/1.1/users/lookup.json" stringByAppendingString:queryString]];
		SLRequest *userLookupRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:userLookupURL parameters:nil];
		[userLookupRequest setAccount:_currentAccount];
		NSHTTPURLResponse *response = nil;
		NSError *error = nil;
		NSData *responseData = [NSURLConnection sendSynchronousRequest:userLookupRequest.preparedURLRequest returningResponse:&response error:&error];
		
		NSError *lookupError;
        NSDictionary* userDict = [[NSJSONSerialization
							  JSONObjectWithData:responseData
							  
							  options:kNilOptions
							  error:&lookupError] objectAtIndex:0];
		
		[params setObject:[userDict objectForKey:@"id_str"] forKey:@"follow"];
	}
	else {
		queryTerm = [queryTerm stringByReplacingOccurrencesOfString:@" " withString:@", "];
		[params setObject:queryTerm forKey:@"track"];
	}
	[params setObject:@"medium" forKey:@"filter_level"];
	SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:_apiFilterJSONURL parameters:params];
	[request setAccount:_currentAccount];
	NSURLRequest *signedReq = request.preparedURLRequest;
	
	// make the connection, ensuring that it is made on the main runloop
	_streamConnection = [[NSURLConnection alloc] initWithRequest:signedReq delegate:self startImmediately: NO];
	[_streamConnection scheduleInRunLoop:[NSRunLoop mainRunLoop]
												  forMode:NSDefaultRunLoopMode];
	[_streamConnection start];
}

- (void)stopStream
{
	if (_streamConnection) {
		[_streamConnection cancel];
	}
}

#pragma mark - NSURLConnectionDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Streaming API Connection Response Received");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	//Credit to github user: stuartkhall. He/She has a project on github that taught me to do this.
    int bytesExpected = 0;
    NSMutableString* message = nil;
    
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    for (NSString* part in [response componentsSeparatedByString:@"\r\n"]) {
        int length = [part intValue];
        if (length > 0) {
            message = [NSMutableString string];
            bytesExpected = length;
        }
        else if (bytesExpected > 0 && message) {
            if (message.length < bytesExpected) {
                [message appendString:part];
                
                if (message.length < bytesExpected) {
                    [message appendString:@"\r\n"];
                }
                
                if (message.length == bytesExpected) {                    
                    // Alert the delegate
                    if (message) {
						NSDictionary *tweetDict = [NSJSONSerialization JSONObjectWithData:[message dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
						NSDictionary *user = [tweetDict objectForKey:@"user"];
						NSString *username;
						if (user) {
							username = [user objectForKey:@"screen_name"];
						}
						NSString *text = [tweetDict objectForKey:@"text"];
						if (username && text) {
							[self.delegate didReceiveNewStreamingTweet:@{@"username": username, @"text": text}];
						}
                    }
                    // Reset
                    message = nil;
                    bytesExpected = 0;
                }
            }
        }
	}
}

#pragma mark - UIActionSheetDelegate Methods

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	_currentAccount = [_twitterAccounts objectAtIndex:buttonIndex];
	[self.delegate didSignIn];
}

@end
