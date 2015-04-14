//
//  TTUnreadMessagesView.h
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TTUnreadTicsViewDelegate <NSObject>

-(void)unreadMessagesdidSwipe:(id)unreadView;
-(NSInteger)numberOfUnreadMessages;
-(NSString *)timeStampForMessageAtIndex:(NSInteger)index;
@end

@interface TTUnreadTicsView : UIView <UITableViewDataSource, UITableViewDelegate>

- (void)reloadData;

@property id<TTUnreadTicsViewDelegate> delegate;
@end
