//
//  TTExpirationDomain.m
//  TicText
//
//  Created by Terrence K on 3/16/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationDomain.h"

#define DataSourceKeyTitle @"title"
#define DataSourceKeyMinValue @"minval"
#define DataSourceKeyMaxValue @"maxval"
#define DataSourceKeyValueWidth @"valwidth"

@implementation TTExpirationUnit

@end

@interface TTExpirationDomain ()

@end

@implementation TTExpirationDomain

- (id)init {
    if (self = [super init]) {
        TTExpirationUnit *hourUnit = [[TTExpirationUnit alloc] init];
        hourUnit.title = @"hour";
        hourUnit.minValue = @0;
        hourUnit.maxValue = @23;
        hourUnit.minimumDisplayWidth = @1;
        
        TTExpirationUnit *minuteUnit = [[TTExpirationUnit alloc] init];
        minuteUnit.title = @"minute";
        minuteUnit.minValue = @0;
        minuteUnit.maxValue = @59;
        minuteUnit.minimumDisplayWidth = @2;
        
        TTExpirationUnit *secondUnit = [[TTExpirationUnit alloc] init];
        secondUnit.title = @"second";
        secondUnit.minValue = @0;
        secondUnit.maxValue = @59;
        secondUnit.minimumDisplayWidth = @2;
        
        _expirationUnits = @[hourUnit, minuteUnit, secondUnit];
    }
    return self;
}

+ (TTExpirationDomain *)sharedDomain {
    static dispatch_once_t onceToken;
    static TTExpirationDomain *_sharedInstance;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TTExpirationDomain alloc] init];
    });
    return _sharedInstance;
}

+ (NSArray *)expirationUnits {
    return [[[self sharedDomain] expirationUnits] copy];
}

+ (NSString *)stringForTimeInterval:(NSTimeInterval)interval {
    // Get the system calendar
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    // Create the NSDates
    NSDate *firstDate = [[NSDate alloc] init];
    NSDate *secondDate = [[NSDate alloc] initWithTimeInterval:interval sinceDate:firstDate];
    
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    
    NSDateComponents *conversionInfo = [calendar components:unitFlags
                                                   fromDate:firstDate
                                                     toDate:secondDate
                                                    options:0];
    
    NSString *expirationTimeString = nil;
    NSString *headerString = @"Your Tic will expire";
    
    NSMutableArray *expirationArray = [NSMutableArray array];
    if ([conversionInfo hour] != 0) {
        NSString *hourUnit = ([conversionInfo hour] == 1) ? @"hour" : @"hours";
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", [conversionInfo hour], hourUnit]];
    }
    if ([conversionInfo minute] != 0) {
        NSString *minuteUnit = ([conversionInfo minute] == 1) ? @"min" : @"mins";
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", [conversionInfo minute], minuteUnit]];
    }
    if ([conversionInfo second] != 0) {
        NSString *secondUnit = ([conversionInfo second] == 1) ? @"sec" : @"secs";
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", [conversionInfo second], secondUnit]];
    }
    if (expirationArray.count == 0) {
        expirationTimeString = [NSString stringWithFormat:@"%@ %@", headerString, @"instantly"];
    } else if (expirationArray.count == 2) {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@", headerString, [expirationArray componentsJoinedByString:@" and "]];
    } else {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@", headerString, [expirationArray componentsJoinedByString:@" "]];
    }
    
    return expirationTimeString;
}

+ (void)setUnits:(NSArray *)expirationUnits forExpirationTime:(NSTimeInterval)expirationTime {
    NSInteger weight = 1;
    for (NSInteger i = (NSInteger)expirationUnits.count - 1; i >= 0; i--) {
        TTExpirationUnit *unit = expirationUnits[i];
        
        NSInteger divisor = weight * (unit.maxValue.integerValue + 1);
        
        NSInteger row = ((NSInteger)expirationTime % divisor) / weight;
        expirationTime -= row * weight;
        if (row < unit.minValue.integerValue) {
            row = unit.minValue.integerValue;
        }
        unit.currentValue = [NSNumber numberWithInteger:row];
        
        weight *= unit.maxValue.integerValue + 1;
//        [pickerView selectRow:row inComponent:i animated:NO];
    }
}

+ (NSTimeInterval)expirationTimeFromUnits:(NSArray *)expirationUnits {
    NSInteger weight = 1;
    NSTimeInterval sum = 0;
    for (NSInteger i = (NSInteger)self.expirationUnits.count - 1; i >= 0; i--) {
        TTExpirationUnit *unit = expirationUnits[i];
        
        sum += unit.currentValue.integerValue * weight;
        
        weight *= unit.maxValue.integerValue + 1;
    }
    
    return sum;
}

@end
