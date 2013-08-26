//
//  JKAppDelegate.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/22/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "AppDelegate.h"

#import "DesignUtil.h"
#import "QueryViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	//Setup Glocal Appearance
	[DesignUtil setupGlobalAppearance];
	
	//Setup RootViewController
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
	UINavigationController *mainNavController = [[UINavigationController alloc] initWithRootViewController:[[QueryViewController alloc] init]];
	self.window.rootViewController = mainNavController;
    [self.window makeKeyAndVisible];
	
	//Animate Splash
	[self animateSplashScreen];
	
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)animateSplashScreen
{
	CGRect windowFrame = UIScreen.mainScreen.applicationFrame;
	
	UIImageView *splashView = [[UIImageView alloc] initWithFrame:UIScreen.mainScreen.applicationFrame];
	splashView.backgroundColor = [DesignUtil YellowOrangePastelColor];
	CGRect titleLabelFrame = CGRectMake(30, windowFrame.size.height/2 - 30, windowFrame.size.width - 60, 60);
	UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
	titleLabel.backgroundColor = [UIColor clearColor];
	titleLabel.font = [UIFont boldSystemFontOfSize:50.0];
	titleLabel.textColor = [UIColor whiteColor];
	titleLabel.textAlignment = NSTextAlignmentCenter;
	titleLabel.text = @"Tweater";
	[splashView addSubview:titleLabel];
	
	[self.window addSubview:splashView];
	[self.window bringSubviewToFront:splashView];
	[UIView animateWithDuration:0.8 delay:3 options:UIViewAnimationOptionCurveEaseInOut animations:^{
		titleLabel.frame = CGRectMake(30, 100, windowFrame.size.width - 60, 60);
	} completion:^(BOOL finished) {
		[splashView removeFromSuperview];
	}];
}

@end
