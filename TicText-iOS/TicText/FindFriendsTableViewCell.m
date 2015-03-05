//
//  FindFriendsTableViewCell.m
//  TicText
//
//  Created by Jack Arendt on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "FindFriendsTableViewCell.h"
#define kStockProfileImage @"profile"

@interface FindFriendsTableViewCell () {
    CGFloat height;
    CGFloat width;
}

@property (nonatomic, strong)   NSMutableArray *pictures;
@property (nonatomic)           NSInteger numPictures;

@end

@implementation FindFriendsTableViewCell

- (void)awakeFromNib {
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self) {
        self.pictures = [[NSMutableArray alloc] initWithObjects:[[UIImageView alloc] init], [[UIImageView alloc] init], [[UIImageView alloc] init], nil];
        
        self.backgroundColor = [UIColor clearColor];
        [self addSubview: self.pictures[0]];
        [self addSubview:self.pictures[1]];
        [self addSubview:self.pictures[2]];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setNumberOfFriendsInRow:(NSInteger)num {
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    self.numPictures = num;
    if(num == 0) {
        return;
    }
    
    else if(num == 1) {
        [self setupOneFriend];
        [self.pictures[0] setHidden:NO];
        [self.pictures[1] setHidden:YES];
        [self.pictures[2] setHidden:YES];
    }
    
    else if(num == 2) {
        [self setupTwoFriends];
        [self.pictures[0] setHidden:NO];
        [self.pictures[1] setHidden:NO];
        [self.pictures[2] setHidden:YES];
    }
    else if(num == 3) {
        [self setupThreeFriends];
        [self.pictures[0] setHidden:NO];
        [self.pictures[1] setHidden:NO];
        [self.pictures[2] setHidden:NO];
    }

}

-(void)setFriends:(NSMutableArray *)friends {
    if(friends.count <= 0) {
        return;
    }

    [self setFriends:friends index:0];
    
}

-(void)setFriends:(NSMutableArray *)friends index:(NSInteger)index {
    if(friends.count <= 0) {
        return;
    }
    
    TTUser *friend = [friends objectAtIndex:0];
    [friend fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *err) {
        if(!err) {
            TTUser *user = (TTUser *)object;
            __block NSData *data;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                data = [user profilePicture];
                dispatch_sync(dispatch_get_main_queue(), ^{
                     ((UIImageView *)self.pictures[index]).image = [UIImage imageWithData:data];
                });
            });
            
            [friends removeObjectAtIndex:0];
            [self setFriends:friends index:index+1];
        }
    }];

}

-(void)setupOneFriend {
    CGFloat xFirstOrigin = width/2 - height/2;
    [self addImage:self.pictures[0] image:[UIImage imageNamed:kStockProfileImage] offset:xFirstOrigin];
}

-(void)setupTwoFriends {
    
    CGFloat xFirstOrigin = width/3 - height/2;
    CGFloat xSecondOrigin = 2*width/3 - height/2;
    
    [self addImage:self.pictures[0] image:[UIImage imageNamed:kStockProfileImage] offset:xFirstOrigin];
    [self addImage:self.pictures[1] image:[UIImage imageNamed:kStockProfileImage] offset:xSecondOrigin];
}

-(void)setupThreeFriends {
    CGFloat xFirstOrigin = width/6 - height/2;
    CGFloat xSecondOrigin = width/2 - height/2;
    CGFloat xThirdOrigin = 5*width/6 - height/2;
    
    [self addImage:self.pictures[0] image:[UIImage imageNamed:kStockProfileImage] offset:xFirstOrigin];
    [self addImage:self.pictures[1] image:[UIImage imageNamed:kStockProfileImage] offset:xSecondOrigin];
    [self addImage:self.pictures[2] image:[UIImage imageNamed:kStockProfileImage] offset:xThirdOrigin];
}

-(void)addImage:(UIImageView *)iv image:(UIImage *)image offset:(CGFloat)xOff {
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = height/2;
    iv.image = image;
    iv.frame = CGRectMake(xOff, 0, height, height);
}

@end
