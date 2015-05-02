//
//  TTNewTicsDropdownButtonsView.h
//  TicText
//
//  Created by Kevin Yufei Chen on 5/1/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTNewTicsDropdownButtonsViewDelegate <NSObject>

- (void)newTicsDropdownButtonsViewDidTapBackButton;

- (void)newTicsDropdownButtonsViewDidTapClearAllExpiredTicsButton;

@end

@interface TTNewTicsDropdownButtonsView : UIView

@property (nonatomic, assign) BOOL isShowingTicsFromSameSender;
@property (nonatomic, assign) id<TTNewTicsDropdownButtonsViewDelegate> delegate;

- (void)updateFrames;

@end
