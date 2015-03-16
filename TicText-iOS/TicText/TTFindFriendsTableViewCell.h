//
//  FindFriendsTableViewCell.h
//  TicText
//
//  Created by Jack Arendt on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTFindFriendsTableViewCell : UITableViewCell


//Function to set the view for the cell by adding the profile pictures of each
//of the user's friends who are also on facebook
-(void)setFriends:(NSArray *)friends;

@end
