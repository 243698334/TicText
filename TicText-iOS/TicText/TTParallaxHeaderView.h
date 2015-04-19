//
//  TTParallaxHeaderView.h
//  TicText
//
//  Created by Kevin Yufei Chen on 4/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTParallaxHeaderView : UIView

- (id)initWithTitle:(NSString *)title image:(UIImage *)image size:(CGSize)size;

- (void)refreshBluredImageView;

- (void)layoutHeaderViewForScrollViewOffset:(CGPoint)offset;

@end
