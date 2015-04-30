//
//  UIImage+SquareImage.h
//  TicText
//
//  Created by Chengkan Huang on 4/28/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SquareImage)

+ (UIImage *)squareImageWithImage:(UIImage *)image scaledToSize:(CGFloat)newSize;

@end
