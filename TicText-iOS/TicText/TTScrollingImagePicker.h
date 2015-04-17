//
//  TTScrollingImagePicker.h
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTScrollingImagePicker;

@protocol PHSideScrollingImagePickerDelegate <UIScrollViewDelegate>
@optional
- (void)selectionDidUpdateForPicker:(TTScrollingImagePicker *)picker;
@end

@interface TTScrollingImagePicker : UIView 

@property (nonatomic, weak) id<PHSideScrollingImagePickerDelegate> delegate;
- (void)setImages:(NSArray *)images;

@end
