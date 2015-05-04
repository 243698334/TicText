//
//  TTNewTic.m
//  TicText
//
//  Created by Kevin Yufei Chen on 5/3/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTNewTic.h"

@implementation TTNewTic

@dynamic ticId, status, senderUserId, recipientUserId, sendTimestamp, timeLimit;

+ (NSString *)parseClassName {
    return kTTNewTicClassName;
}

+ (void)retrieveNewTicsInBackgroundWithBlock:(void (^)(NSArray *receivedNewTics, NSError *error))completion {
    [PFCloud callFunctionInBackground:kTTTicRetrieveNewTicsFunction withParameters:nil block:^(id object, NSError *error) {
        if (error) {
            if (completion) {
                completion(nil, error);
            }
        } else {
            if (completion) {
                completion(object, nil);
            }
        }
    }];
}

@end
