//
//  TTTic.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTTic.h"

@implementation TTTic

@dynamic status, type, timeLimit, contentType, content, sendTimestamp, receiveTimestamp, sender, recipient;

+ (NSString *)parseClassName {
    return kTTTicClassName;
}

+ (instancetype)unreadTicWithId:(NSString*)objectId {
    TTTic *unreadTic = [TTTic objectWithoutDataWithClassName:kTTTicClassName objectId:objectId];
    unreadTic.status = kTTTicStatusUnread;
    return unreadTic;
}

+ (void)fetchTicInBackgroundWithId:(NSString *)ticId timestamp:(NSDate *)fetchTimestamp completion:(void (^)(TTTic *fetchedTic, NSError *error))completion {
    [PFCloud callFunctionInBackground:kTTTicFetchTicFunction withParameters:@{kTTTicFetchTicFunctionTicIdParameter : ticId, kTTTicFetchTicFunctionFetchTimestampParameter : fetchTimestamp} block:^(id object, NSError *error) {
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
