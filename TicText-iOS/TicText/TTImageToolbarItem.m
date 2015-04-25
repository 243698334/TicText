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
                        [images addObject:[self squareImageFromImage:image scaledToSize:350]];
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

- (UIImage *)squareImageFromImage:(UIImage *)image scaledToSize:(CGFloat)newSize {
    CGAffineTransform scaleTransform;
    CGPoint origin;
    
    if (image.size.width > image.size.height) {
        CGFloat scaleRatio = newSize / image.size.height;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(-(image.size.width - image.size.height) / 2.0f, 0);
    } else {
        CGFloat scaleRatio = newSize / image.size.width;
        scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2.0f);
    }
    
    CGSize size = CGSizeMake(newSize, newSize);
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
    } else {
        UIGraphicsBeginImageContext(size);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, scaleTransform);
    
    [image drawAtPoint:origin];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
