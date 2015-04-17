//
//  TTImageToolbarItem.m
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTImageToolbarItem.h"
#import <AssetsLibrary/AssetsLibrary.h>

@implementation TTImageToolbarItem

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setImage:[UIImage imageNamed:@"MeTabBarIcon"] forState:UIControlStateNormal];
        [self.titleLabel setAdjustsFontSizeToFitWidth:YES];
    }
    return self;
}

- (UIView *)contentView {
    self.imagePicker = [[TTScrollingImagePicker alloc] init];
    [self.imagePicker setBackgroundColor:[UIColor whiteColor]];
    
    NSMutableArray *photoArray = [NSMutableArray array];
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    status = ALAuthorizationStatusAuthorized; //how to actually grant this?????
    if (status == ALAuthorizationStatusAuthorized) {
        [assetLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                
                [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    
                    //ALAssetRepresentation holds all the information about the asset being accessed.
                    if (result) {
                        UIImage *image = [UIImage imageWithCGImage:[result thumbnail]];
//                        UIImage *image = [UIImage imageWithCGImage:[[result defaultRepresentation] fullResolutionImage]];
                        [photoArray addObject:image];
                        NSArray *images = [photoArray copy];
                        [self.imagePicker setImages:images];
                    }
                }];
                
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Error Description %@",[error description]);
        }];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission Denied" message:@"Please allow the application to access your photo and videos in settings panel of your device" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
    return self.imagePicker;
//    return [super contentView];
}

@end
