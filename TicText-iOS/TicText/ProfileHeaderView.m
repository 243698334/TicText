//
//  ProfileHeaderView.m
//  TicText
//
//  Created by Jack Arendt on 4/24/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//
//  ProfileHeaderView shows the user's name and profile picture
//  scrolling the tableview to a negative content offset brings
//  up a larger version of the image, and the original picture
//  and name disappear the farther down you scroll

#import "ProfileHeaderView.h"

@interface ProfileHeaderView () {
    CGFloat originalHeight;
}
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIImageView *profileImageView;
@property (nonatomic, strong) UIImageView *backgroundImageView;
@end

@implementation ProfileHeaderView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        originalHeight = self.bounds.size.height;
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.alpha = 0;
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.backgroundImageView];
        
        CGFloat diameter = self.bounds.size.height/2;
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 - diameter/2, self.bounds.size.height * 0.1, diameter, diameter)];
        self.profileImageView.layer.cornerRadius = diameter/2;
        self.profileImageView.clipsToBounds = YES;
        [self addSubview:self.profileImageView];
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.backgroundImageView.alpha = 0;
        self.backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        self.backgroundImageView.clipsToBounds = YES;
        [self addSubview:self.backgroundImageView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, self.profileImageView.frame.origin.y + self.profileImageView.bounds.size.height + 10, self.bounds.size.width - 20, 30)];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.minimumScaleFactor = 0.5;
        self.nameLabel.adjustsFontSizeToFitWidth = YES;
        self.nameLabel.font = [UIFont systemFontOfSize:0.0666 * self.bounds.size.width];
        [self addSubview:self.nameLabel];
        
        TTUser *user = [TTUser currentUser];
        self.nameLabel.text = user.displayName;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            PFFile *file = [user profilePicture];
            NSData *data = [file getData];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(file && data){
                    self.profileImageView.image = [UIImage imageWithData:data];
                    self.backgroundImageView.image = [UIImage imageWithData:data];
                }
            });
        });

    }
    return self;
}


-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    CGFloat difference = frame.size.height - originalHeight;
    
    if(difference < 0) {
        return;
    }
    
    if(self.profileImageView && self.nameLabel && self.backgroundImageView) {
        CGFloat diameter = self.bounds.size.height/2;
        self.profileImageView.bounds = CGRectMake(0, 0, (originalHeight/2) * (originalHeight/2)/(frame.size.height/2), (originalHeight/2) * (originalHeight/2)/(frame.size.height/2));
        self.profileImageView.center = CGPointMake(self.bounds.size.width/2, 0.1 * self.bounds.size.height + diameter/2);
        self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.height/2;
        self.nameLabel.frame = CGRectMake(10, self.profileImageView.frame.origin.y + self.profileImageView.bounds.size.height + 10, self.bounds.size.width - 20, 30);
        CGFloat newWidth = self.bounds.size.width * (frame.size.height/originalHeight);
        self.backgroundImageView.frame = CGRectMake(self.bounds.size.width/2 - newWidth/2, 0, newWidth, frame.size.height);
        self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    }

    self.profileImageView.alpha = 1 - 2*(difference/100);
    self.nameLabel.alpha = 1 - 2*(difference/100);
    self.backgroundImageView.alpha = difference/100;
}

/**
 * Refreshes the view after something on TTUser is changed 
 *
 **/

-(void)refreshValues {
    TTUser *user = [TTUser currentUser];
    self.nameLabel.text = user.displayName;
    __block NSData *data;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
    dispatch_async(queue, ^{
        data = [user profilePicture];
        dispatch_sync(dispatch_get_main_queue(), ^{
            if(data){
                self.profileImageView.image = [UIImage imageWithData:data];
                self.backgroundImageView.image = [UIImage imageWithData:data];
            }
        });
    });
}



@end
