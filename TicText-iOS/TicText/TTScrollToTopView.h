//
//  ScrollToTopView.h
//  AdjustingSectionHeader
//
//  Created by Jack Arendt on 3/14/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTScrollToTopViewDelegate <NSObject>

-(void)unreadButtonPressed;

@end

@interface TTScrollToTopView : UIView

@property (nonatomic) NSInteger unreadMessages;
@property id<TTScrollToTopViewDelegate> delegate;
-(void)setTableVisible:(BOOL)visible;
@end
