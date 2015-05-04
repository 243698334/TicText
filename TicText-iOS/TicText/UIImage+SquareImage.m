//
//  UIImage+SquareImage.m
//  TicText
//
//  Created by Chengkan Huang on 4/28/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "UIImage+SquareImage.h"

@implementation UIImage (SquareImage)

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGFloat)size {
    CGPoint origin = CGPointZero;
    CGFloat scaleRatio = 0;
    
    if (image.size.width > image.size.height) {
        scaleRatio = size / image.size.height;
        origin = CGPointMake(-(image.size.width - image.size.height) / 2, 0);
    } else {
        scaleRatio = size / image.size.width;
        origin = CGPointMake(0, -(image.size.height - image.size.width) / 2);
    }
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size, size), YES, 0);
    
    CGContextConcatCTM(UIGraphicsGetCurrentContext(), scaleTransform);
    [image drawAtPoint:origin];
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

@end
