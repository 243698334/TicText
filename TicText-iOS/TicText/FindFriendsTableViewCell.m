//
//  FindFriendsTableViewCell.m
//  TicText
//
//  Created by Jack Arendt on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "FindFriendsTableViewCell.h"

@interface FindFriendsTableViewCell () {
    CGFloat height;
    CGFloat width;
}

@property (nonatomic, strong) UIImageView *firstImageView;
@property (nonatomic, strong) UIImageView *secondImageView;
@property (nonatomic, strong) UIImageView *thirdImageView;


@end

@implementation FindFriendsTableViewCell

- (void)awakeFromNib {
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        self.firstImageView = [[UIImageView alloc] init];
        self.secondImageView = [[UIImageView alloc] init];
        self.thirdImageView = [[UIImageView alloc] init];
        
        [self addSubview: self.firstImageView];
        [self addSubview:self.secondImageView];
        [self addSubview:self.thirdImageView];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFriends:(NSArray *)friends {
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    if(friends.count == 0) {
        return;
    }
    
    else if(friends.count == 1) {
        [self setupOneFriend:friends];
        [self.firstImageView setHidden:NO];
        [self.secondImageView setHidden:YES];
        [self.thirdImageView setHidden:YES];
    }
    
    else if(friends.count == 2) {
        [self setupTwoFriends:friends];
        [self.firstImageView setHidden:NO];
        [self.secondImageView setHidden:NO];
        [self.thirdImageView setHidden:YES];
    }
    else if(friends.count == 3) {
        [self setupThreeFriends:friends];
        [self.firstImageView setHidden:NO];
        [self.secondImageView setHidden:NO];
        [self.thirdImageView setHidden:NO];
    }
}

-(void)setupOneFriend:(NSArray *)friends {
    UIImage *_firstImage = friends[0];
    CGFloat xFirstOrigin = width/2 - height/2;
    [self addImage:self.firstImageView image:_firstImage offset:xFirstOrigin];
}

-(void)setupTwoFriends:(NSArray *)friends {
    UIImage *_firstImage = friends[0];
    UIImage *_secondImage = friends[1];
    
    CGFloat xFirstOrigin = width/3 - height/2;
    CGFloat xSecondOrigin = 2*width/3 - height/2;
    
    [self addImage:self.firstImageView image:_firstImage offset:xFirstOrigin];
    [self addImage:self.secondImageView image:_secondImage offset:xSecondOrigin];
}

-(void)setupThreeFriends:(NSArray *)friends {
    UIImage *_firstImage = friends[0];
    UIImage *_secondImage = friends[1];
    UIImage *_thirdImage = friends[2];
    
    CGFloat xFirstOrigin = width/6 - height/2;
    CGFloat xSecondOrigin = width/2 - height/2;
    CGFloat xThirdOrigin = 5*width/6 - height/2;
    
    [self addImage:self.firstImageView image:_firstImage offset:xFirstOrigin];
    [self addImage:self.secondImageView image:_secondImage offset:xSecondOrigin];
    [self addImage:self.thirdImageView image:_thirdImage offset:xThirdOrigin];
}

-(void)addImage:(UIImageView *)iv image:(UIImage *)image offset:(CGFloat)xOff {
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = height/2;
    iv.image = image;
    iv.frame = CGRectMake(xOff, 0, height, height);
}

@end
