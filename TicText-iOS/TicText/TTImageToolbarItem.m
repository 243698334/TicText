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

@interface TTImageToolbarItem ()

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *imagePickerButton;
@property (nonatomic) BOOL addConstraints;
@end

@implementation TTImageToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"MeTabBarIcon"] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"MeTabBarIconSelected"] forState:UIControlStateSelected];
        [self setImage:[UIImage imageNamed:@"MeTabBarIconSelected"] forState:UIControlStateHighlighted];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (UIView *)contentView {
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    
    self.scrollingImagePickerView = [[TTScrollingImagePickerView alloc] init];
    self.scrollingImagePickerView.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *images = [NSMutableArray array];
    [[[ALAssetsLibrary alloc] init] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
                                                  usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (index < 10) {
                    if (result) {
                        // UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
                        UIImage *image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullResolutionImage]];
                        [images addObject:image];
                        [self.scrollingImagePickerView setImages:images];
                    }
                } else {
                    *stop = YES;
                }
            }];
            
        }
    } failureBlock:^(NSError *error) {
        [TSMessage showNotificationWithTitle:@"Permission Denied"
                                    subtitle:@"Please allow TicText to access your Camera Roll."
                                        type:TSMessageNotificationTypeError];
    }];
    
    self.imagePickerButton = [[UIButton alloc] init];
    [self.imagePickerButton setImage:[UIImage imageNamed:@"ImagePickerIcon"] forState:UIControlStateNormal];
    CALayer *imagePickerButtonLayer = self.imagePickerButton.layer;
    [imagePickerButtonLayer setMasksToBounds:YES];
    [imagePickerButtonLayer setCornerRadius:25];
    self.imagePickerButton.backgroundColor = [UIColor colorWithRed:130.0/255.0 green:100.0/255.0 blue:200.0/255.0 alpha:0.8];
    [self.imagePickerButton addTarget:self
                               action:@selector(didTapImagePickerButton)
                     forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.imagePickerButton];
    
    [self.bottomView addSubview:self.scrollingImagePickerView];
//    [self.bottomView bringSubviewToFront:self.imagePickerButton];
    
    return self.scrollingImagePickerView;
}

- (void)updateConstraints {
    if (!self.addConstraints) {
        self.addConstraints = YES;
        [self.imagePickerButton autoPinEdge:ALEdgeBottom toEdge:ALEdgeBottom ofView:self withOffset:-5 relation:NSLayoutRelationEqual];
        [self.imagePickerButton autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self withOffset:5 relation:NSLayoutRelationEqual];
        [self.imagePickerButton autoSetDimension:ALDimensionHeight toSize:50];
        [self.imagePickerButton autoSetDimension:ALDimensionWidth toSize:50];
    }
    [super updateConstraints];
}

- (void)didTapImagePickerButton {
    [self.imagePickerButton removeFromSuperview];
    [[NSNotificationCenter defaultCenter] postNotificationName:kTTScrollingImagePickerDidTapImagePickerButton object:nil];
}

@end
