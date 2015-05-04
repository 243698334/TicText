//
//  TTExpirationToolbarItem.h
//  TicText
//
//  Created by Terrence K on 4/13/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTMessagesToolbarItem.h"
#import "TTExpirationPickerController.h"

@interface TTExpirationToolbarItem : TTMessagesToolbarItem <TTExpirationPickerControllerDelegate>

@property (nonatomic, strong) TTExpirationPickerController *pickerController;

@end
