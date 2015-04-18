//
//  TTScrollingImagePickerCell.h
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTScrollingImagePickerCell : UICollectionViewCell

- (void)setImage:(UIImage *)image;

- (void)showOptionButtons;

- (void)hideOptionButtons;

@end
