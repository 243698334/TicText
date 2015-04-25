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

@interface TTImageToolbarItem ()

@property (nonatomic, strong) UIButton *imagePickerButton;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL addConstraints;
@end

@implementation TTImageToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"MeTabBarIcon"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"MeTabBarIconSelected"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"MeTabBarIconSelected"] forState:UIControlStateHighlighted];
    }
    return self;
}

- (UIView *)contentView {
    self.scrollingImagePickerView = [[TTScrollingImagePickerView alloc] init];
    self.scrollingImagePickerView.backgroundColor = [UIColor whiteColor];
    
    self.progressHUD = [MBProgressHUD showHUDAddedTo:self.scrollingImagePickerView animated:YES];
    
    NSMutableArray *images = [NSMutableArray array];
    [[[ALAssetsLibrary alloc] init] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                                  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (index < 15) {
                    if (result) {
                        UIImage *image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullScreenImage]];
                        [images addObject:image];
                    }
                } else {
                    *stop = YES;
                    [self.scrollingImagePickerView setImages:images];
                    [self.progressHUD removeFromSuperview];
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        [TSMessage showNotificationWithTitle:@"Permission Denied"
                                    subtitle:@"Please allow TicText to access your Camera Roll."
                                        type:TSMessageNotificationTypeError];
    }];
    
    return self.scrollingImagePickerView;
}

@end
