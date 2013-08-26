//
//  DesignUtil.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/25/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "DesignUtil.h"

static UIColor *YellowOrangePastelColor;
static UIColor *LightGrayColor;

@implementation DesignUtil

+ (void)initialize
{
	YellowOrangePastelColor = [UIColor colorWithRed:253.0/255.0 green:198.0/255.0 blue:137.0/255.0 alpha:1.0];
	LightGrayColor = [UIColor colorWithRed:139.0/255.0 green:137.0/255.0 blue:137.0/255.0 alpha:1.0];
}

+ (UIColor *)YellowOrangePastelColor { return YellowOrangePastelColor; }
+ (UIColor *)LightGrayColor { return LightGrayColor; };

+ (void)setupGlobalAppearance
{
	[[UINavigationBar appearance] setTintColor:YellowOrangePastelColor];
	[[UISearchBar appearance] setTintColor:YellowOrangePastelColor];
}

@end
