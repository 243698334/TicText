//
//  TTConversation.m
//  TicText
//
//  Created by Kevin Yufei Chen on 3/18/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTConversation.h"

@implementation TTConversation

@dynamic type, userId, recipient, lastTic;

+ (NSString *)parseClassName {
    return kTTConversationClassName;
}

- (NSDate *)lastActivityTimestamp {
    if (self.lastTic == nil) {
        return [NSDate date];
    } else {
        return self.lastTic.status == kTTTicStatusRead ? self.lastTic.receiveTimestamp : self.lastTic.sendTimestamp;
    }
}

@end