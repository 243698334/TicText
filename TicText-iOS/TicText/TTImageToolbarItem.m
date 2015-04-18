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

@implementation TTImageToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"MeTabBarIcon"] forState:UIControlStateNormal];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (UIView *)contentView {
    self.scrollingImagePickerView = [[TTScrollingImagePickerView alloc] init];
    self.scrollingImagePickerView.backgroundColor = [UIColor whiteColor];
    
    NSMutableArray *images = [NSMutableArray array];
    [[[ALAssetsLibrary alloc] init] enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
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
        [TSMessage showNotificationWithTitle:@"Permission Denied" subtitle:@"Please allow TicText to access your Camera Roll." type:TSMessageNotificationTypeError];
    }];
    return self.scrollingImagePickerView;
}

@end
