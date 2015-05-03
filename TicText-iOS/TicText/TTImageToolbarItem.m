//
//  TTImageToolbarItem.m
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTImageToolbarItem.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <TSMessages/TSMessage.h>
#import <PureLayout/PureLayout.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define scaledSize 150

@interface TTImageToolbarItem ()

@property (nonatomic) NSMutableArray *imagesFromCameraRoll;

@end

@implementation TTImageToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"PhotoIcon"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"PhotoIconSelected"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"PhotoIconSelected"] forState:UIControlStateHighlighted];
        
        self.scrollingImagePickerView = [[TTScrollingImagePickerView alloc] init];
        self.scrollingImagePickerView.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (UIView *)contentView {
    return self.scrollingImagePickerView;
}

#pragma mark - TTScrollingImagePickerViewDataSource

- (NSMutableArray *)imagesFromCameraRollForImagePickerView {
    return self.imagesFromCameraRoll;
}

@end
