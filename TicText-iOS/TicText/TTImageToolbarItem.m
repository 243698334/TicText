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

#define scaledSize 300

@interface TTImageToolbarItem ()

@property (nonatomic) BOOL addConstraints;

@property (nonatomic) NSMutableArray *imagesFromCameraRoll;

@property (nonatomic, strong) UIButton *imagePickerButton;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation TTImageToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"MeTabBarIcon"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"MeTabBarIconSelected"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"MeTabBarIconSelected"] forState:UIControlStateHighlighted];
        
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
