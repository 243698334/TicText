//
//  TTExpirationDomain.m
//  TicText
//
//  Created by Terrence K on 3/16/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTExpirationDomain.h"

@implementation TTExpirationUnit

- (NSString *)stringValueForIndex:(NSInteger)index {
    NSString *format = [NSString stringWithFormat:@"%%0%lud", (unsigned long)self.minimumDisplayWidth];
    return [NSString stringWithFormat:format, self.minValue + index];
}

@end

@implementation TTExpirationDomain

- (id)init {
    if (self = [super init]) {
        TTExpirationUnit *hourUnit = [[TTExpirationUnit alloc] init];
        hourUnit.singularTitle = @"hour";
        hourUnit.pluralTitle = @"hours";
        hourUnit.minValue = 0;
        hourUnit.maxValue = 23;
        hourUnit.minimumDisplayWidth = 1;
        hourUnit.relevantValueFromDateComponentsBlock = ^(NSDateComponents *components) {
            return [components hour];
        };
        
        TTExpirationUnit *minuteUnit = [[TTExpirationUnit alloc] init];
        minuteUnit.singularTitle = @"minute";
        minuteUnit.pluralTitle = @"minutes";
        minuteUnit.minValue = 0;
        minuteUnit.maxValue = 59;
        minuteUnit.minimumDisplayWidth = 2;
        minuteUnit.relevantValueFromDateComponentsBlock = ^(NSDateComponents *components) {
            return [components minute];
        };
        
        TTExpirationUnit *secondUnit = [[TTExpirationUnit alloc] init];
        secondUnit.singularTitle = @"second";
        secondUnit.pluralTitle = @"seconds";
        secondUnit.minValue = 0;
        secondUnit.maxValue = 59;
        secondUnit.minimumDisplayWidth = 2;
        secondUnit.relevantValueFromDateComponentsBlock = ^(NSDateComponents *components) {
            return [components second];
        };
        
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
    for (int i = 0; i < self.sharedDomain.expirationUnits.count; i++) {
        TTExpirationUnit *unit = self.sharedDomain.expirationUnits[i];
        NSInteger relevantValue = unit.relevantValueFromDateComponentsBlock(conversionInfo);
        if (relevantValue != 0) {
            NSString *unitTitle = (relevantValue == 1) ? unit.singularTitle : unit.pluralTitle;
            [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", (long)relevantValue, unitTitle]];
        }
    }

    if (expirationArray.count == 0) {
        expirationTimeString = [NSString stringWithFormat:@"%@ %@.", headerString, @"instantly"];
    } else if (expirationArray.count == 1) {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@.", headerString, [expirationArray lastObject]];
    } else if (expirationArray.count == 2) {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@.", headerString, [expirationArray componentsJoinedByString:@" and "]];
    } else {
        NSMutableArray *stringsExceptLast = [NSMutableArray arrayWithArray:expirationArray];
        NSString *lastString = [stringsExceptLast lastObject];
        [stringsExceptLast removeLastObject];
        NSString *stringsExceptLastString = [stringsExceptLast componentsJoinedByString:@", "];
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@.", headerString, [@[stringsExceptLastString, lastString] componentsJoinedByString:@", and "]];
    }
    
    return expirationTimeString;
}

+ (void)setUnits:(NSArray *)expirationUnits forExpirationTime:(NSTimeInterval)expirationTime {
    NSInteger weight = 1;
    for (NSInteger i = (NSInteger)expirationUnits.count - 1; i >= 0; i--) {
        TTExpirationUnit *unit = expirationUnits[i];
        
        NSInteger divisor = weight * (unit.maxValue + 1);
        
        NSInteger row = ((NSInteger)expirationTime % divisor) / weight;
        expirationTime -= row * weight;
        if (row < unit.minValue) {
            row = unit.minValue;
        }
        unit.currentValue = row;
        
        weight *= unit.maxValue + 1;
    }
}

+ (NSTimeInterval)expirationTimeFromUnits:(NSArray *)expirationUnits {
    NSInteger weight = 1;
    NSTimeInterval sum = 0;
    for (NSInteger i = (NSInteger)self.expirationUnits.count - 1; i >= 0; i--) {
        TTExpirationUnit *unit = expirationUnits[i];
        
        sum += unit.currentValue * weight;
        
        weight *= unit.maxValue + 1;
    }
    
    return sum;
}

@end
