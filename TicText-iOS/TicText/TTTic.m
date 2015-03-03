//
//  TTTic.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTTic.h"

@implementation TTTic

@dynamic status, type, timeLimit, senderUserId, recipientUserId, contentType, content, sendTimestamp, receiveTimestamp;

+ (NSString *)parseClassName {
    return kTTTicClassKey;
}

+ (instancetype)unreadTicWithId:(NSString*)objectId {
    return [super objectWithoutDataWithClassName:kTTTicClassKey objectId:objectId];
}

+ (void)fetchTicInBackgroundWithId:(NSString *)ticId timestamp:(NSDate *)fetchTimestamp completion:(void (^)(TTTic *fetchedTic, NSError *error))completion {
    [PFCloud callFunctionInBackground:kTTTicFetchTicFunction withParameters:@{@"ticId" : ticId, @"fetchTimestamp" : fetchTimestamp} block:^(id object, NSError *error) {
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
