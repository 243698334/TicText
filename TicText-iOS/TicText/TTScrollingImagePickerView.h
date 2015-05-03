//
//  TTScrollingImagePickerView
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTScrollingImagePickerView;

@protocol TTScrollingImagePickerViewDelegate <NSObject>

- (void)needLoadMoreImagesForScrollingImagePicker:(TTScrollingImagePickerView *)scrollingImagePickerView ;

@end

@interface TTScrollingImagePickerView : UIView

@property (nonatomic, assign) id<TTScrollingImagePickerViewDelegate> delegate;

- (void)setImages:(NSArray *)images;

@end
