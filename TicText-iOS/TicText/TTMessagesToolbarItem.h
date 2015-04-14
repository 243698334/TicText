//
//  TTMessagesToolbarItem.h
//  TicText
//
//  Created by Terrence K on 4/12/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTMessagesToolbar;
@interface TTMessagesToolbarItem : UIButton

@property (nonatomic, strong) TTMessagesToolbar *toolbar;

- (CGFloat)widthMultiplier;
- (UIView *)contentView;
- (void)buttonOnSelect:(TTMessagesToolbar *)toolbar;
- (void)buttonOnDeselect:(TTMessagesToolbar *)toolbar;
- (BOOL)switchViewOnAction;

@end
