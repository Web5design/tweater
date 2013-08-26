//
//  CoreFunctions.h
//  Tweater
//
//  Created by Hyungjun Kim on 8/23/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import <Foundation/Foundation.h>

void runOnMainQueueSync(void (^block)(void));
void runOnMainQueueAsync(void (^block)(void));
