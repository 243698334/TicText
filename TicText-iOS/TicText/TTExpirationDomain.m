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
    NSString *stringValue = [NSString stringWithFormat:@"%ld", (long)(self.minValue + index)];
    if (stringValue.length < self.minimumDisplayWidth) {
        return [stringValue stringByPaddingToLength:self.minimumDisplayWidth withString:@"0" startingAtIndex:0];
    } else {
        return stringValue;
    }
}

@end

@interface TTExpirationDomain ()

@property (nonatomic, strong) TTExpirationUnit *hourUnit;
@property (nonatomic, strong) TTExpirationUnit *minuteUnit;
@property (nonatomic, strong) TTExpirationUnit *secondUnit;

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
        self.hourUnit = hourUnit;
        
        TTExpirationUnit *minuteUnit = [[TTExpirationUnit alloc] init];
        minuteUnit.singularTitle = @"minute";
        minuteUnit.pluralTitle = @"minutes";
        minuteUnit.minValue = 0;
        minuteUnit.maxValue = 59;
        minuteUnit.minimumDisplayWidth = 2;
        self.minuteUnit = minuteUnit;
        
        TTExpirationUnit *secondUnit = [[TTExpirationUnit alloc] init];
        secondUnit.singularTitle = @"second";
        secondUnit.pluralTitle = @"seconds";
        secondUnit.minValue = 0;
        secondUnit.maxValue = 59;
        secondUnit.minimumDisplayWidth = 2;
        self.secondUnit = secondUnit;
        
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
        NSString *hourUnit = ([conversionInfo hour] == 1) ? self.sharedDomain.hourUnit.singularTitle : self.sharedDomain.hourUnit.pluralTitle;
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", (long)[conversionInfo hour], hourUnit]];
    }
    if ([conversionInfo minute] != 0) {
        NSString *minuteUnit = ([conversionInfo minute] == 1) ? self.sharedDomain.minuteUnit.singularTitle : self.sharedDomain.minuteUnit.pluralTitle;
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", (long)[conversionInfo minute], minuteUnit]];
    }
    if ([conversionInfo second] != 0) {
        NSString *secondUnit = ([conversionInfo second] == 1) ? self.sharedDomain.secondUnit.singularTitle : self.sharedDomain.secondUnit.pluralTitle;
        [expirationArray addObject:[NSString stringWithFormat:@"%ld %@", (long)[conversionInfo second], secondUnit]];
    }
    if (expirationArray.count == 0) {
        expirationTimeString = [NSString stringWithFormat:@"%@ %@.", headerString, @"instantly"];
    } else if (expirationArray.count == 2) {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@.", headerString, [expirationArray componentsJoinedByString:@" and "]];
    } else {
        expirationTimeString = [NSString stringWithFormat:@"%@ in %@.", headerString, [expirationArray componentsJoinedByString:@" "]];
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
