//
//  TTScrollingImagePickerCell.h
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTScrollingImagePickerCell;
@protocol TTScrollingImagePickerCellDelegate <NSObject>

- (void)didTapSendButtonInScrollingImagePickerCell;

@end

@interface TTScrollingImagePickerCell : UICollectionViewCell

@property (nonatomic, weak) id<TTScrollingImagePickerCellDelegate> delegate;

- (void)setImage:(UIImage *)image;

- (void)showOptionButtons;

- (void)hideOptionButtons;

@end
