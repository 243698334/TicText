//
//  CustomMessageCell.h
//  TicText
//
//  Created by Georgy Petukhov on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "JSQMessagesCollectionViewCell.h"

@interface CustomMessageCell : JSQMessagesCollectionViewCell

@property (weak, nonatomic) UIView *extraView;

- (void)setExtraView:(UIView *)someView;
- (void)removeExtraView;

@end
