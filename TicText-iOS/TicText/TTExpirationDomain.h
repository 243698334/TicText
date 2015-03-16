//
//  TTExpirationDomain.h
//  TicText
//
//  Created by Terrence K on 3/16/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

// A bean that contains metadata for expiration components
@interface TTExpirationUnit : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSNumber *minValue;
@property (nonatomic, strong) NSNumber *maxValue;
@property (nonatomic, strong) NSNumber *minimumDisplayWidth;
@property (nonatomic, strong) NSNumber *currentValue;

@end

// Contains data and utility methods to operate on NSTimeIntervals relating to expiration time.
@interface TTExpirationDomain : NSObject

// An array of TTExpirationUnits.
@property (nonatomic, strong, readonly) NSArray *expirationUnits;

// Singleton accessor that's used by class methods for convenience.
+ (TTExpirationDomain *)sharedDomain;

// Convenience accessor that uses the singleton.
+ (NSArray *)expirationUnits;

// Returns a formatted string for |interval|.
+ (NSString *)stringForTimeInterval:(NSTimeInterval)interval;

// Calculates and modifies the default values for each element in |expirationUnits| using the |expirationTime|
+ (void)setUnits:(NSArray *)expirationUnits forExpirationTime:(NSTimeInterval)expirationTime;

// Calculates and returns an NSTimeInterval from an array of TTExpirationUnit
+ (NSTimeInterval)expirationTimeFromUnits:(NSArray *)expirationUnits;

@end


