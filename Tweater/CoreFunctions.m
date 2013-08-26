//
//  CoreFunctions.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/23/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "CoreFunctions.h"

void _runOnQueue(void (^block)(void), dispatch_queue_t queue, BOOL sync)
{
	if (sync) {
        dispatch_sync(queue, block);
    } else {
        dispatch_async(queue, block);
	}
}

void _runOnGlobalQueueWithPriority(void (^block)(void), dispatch_queue_priority_t priority, BOOL sync)
{
	dispatch_queue_t queue = dispatch_get_global_queue(priority, 0);
	_runOnQueue(block, queue, sync);
}

void runOnMainQueueSync(void (^block)(void))
{
	_runOnQueue(block, dispatch_get_main_queue(), YES);
}

void runOnMainQueueAsync(void (^block)(void))
{
	_runOnQueue(block, dispatch_get_main_queue(), NO);
}