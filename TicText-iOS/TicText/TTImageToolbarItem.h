//
//  TTImageToolbarItem.h
//  TicText
//
//  Created by Chengkan Huang on 4/17/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesToolbarItem.h"
#import "TTScrollingImagePickerView.h"

@interface TTImageToolbarItem : TTMessagesToolbarItem

@property (nonatomic, strong) TTScrollingImagePickerView *scrollingImagePickerView;

@end
