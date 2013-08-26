//
//  TwitterClient.h
//  Tweater
//
//  Created by Hyungjun Kim on 8/23/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterClientDelegate

@required
- (void)didReceiveNewStreamingTweet:(id)tweet;
- (void)didSignIn;

@end


@interface TwitterClient : NSObject <UIActionSheetDelegate, NSURLConnectionDataDelegate>

+ (TwitterClient *)sharedInstance;

- (BOOL)hasCurrentAccount;
- (void)startStreamWithTerm:(NSString *)queryTerm;
- (void)stopStream;
- (void)requestPermissionsFromViewController:(UIViewController*)viewController;
- (void)logout;

@property (nonatomic, weak) id <TwitterClientDelegate> delegate;

@end