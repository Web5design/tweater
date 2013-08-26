//
//  SignInViewController.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/25/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "SignInViewController.h"

#import "DesignUtil.h"
#import "TwitterClient.h"


@implementation SignInViewController
{
	UIButton *_signInButton;
	UILabel *_titleLabel;
}

#pragma mark - Presentation/Initialization

- (void)loadView
{
	[super loadView];
	
	//Main View
	CGRect windowFrame = UIScreen.mainScreen.applicationFrame;
	self.view = [[UIView alloc] initWithFrame:windowFrame];
	self.view.backgroundColor = [DesignUtil YellowOrangePastelColor];
	
	//Title Label
	CGRect titleLabelFrame = CGRectMake(30, 100, windowFrame.size.width - 60, 60);
	_titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	_titleLabel.backgroundColor = [UIColor clearColor];
	_titleLabel.font = [UIFont boldSystemFontOfSize:50.0];
	_titleLabel.textColor = [UIColor whiteColor];
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	_titleLabel.text = @"Tweater";
	[self.view addSubview:_titleLabel];
	
	//Sign In Button
	CGRect signInButtonFrame = CGRectMake(30, windowFrame.size.height - 140, windowFrame.size.width - 60, 44);
	_signInButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	_signInButton.frame = signInButtonFrame;
	[_signInButton setTitle:@"Twitter Sign In" forState:UIControlStateNormal];
	_signInButton.titleLabel.textAlignment = NSTextAlignmentCenter;
	_signInButton.titleLabel.textColor = [UIColor grayColor];
	[self.view addSubview:_signInButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Add SignIn Button Target
	[_signInButton addTarget:self action:@selector(requestTwitterPermission) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Twitter Sign In

- (void)requestTwitterPermission
{
	[TwitterClient.sharedInstance requestPermissionsFromViewController:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
