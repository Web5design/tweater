//
//  JKViewController.h
//  Tweater
//
//  Created by Hyungjun Kim on 8/22/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "TwitterClient.h"

#import <UIKit/UIKit.h>

@interface QueryViewController : UITableViewController <UISearchBarDelegate, UITableViewDelegate, TwitterClientDelegate>

@end
