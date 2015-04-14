//
//  TTContactTableViewCell.m
//  TicText
//
//  Created by Jack Arendt on 4/14/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTContactTableViewCell.h"

@interface TTContactTableViewCell ()
@end

@implementation TTContactTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.profileImageView = [[UIImageView alloc] init];
        self.nameLabel = [[UILabel alloc] init];
        self.createTicButtton = [[UIButton alloc] init];
        
        [self.createTicButtton setImage:[UIImage imageNamed:@"TicsTabBarIcon"] forState:UIControlStateNormal];
        [self.createTicButtton setImage:[UIImage imageNamed:@"TicsTabBarIconSelected"] forState:UIControlStateHighlighted];
        
        [self addSubview:self.profileImageView];
        [self addSubview:self.nameLabel];
        [self addSubview:self.createTicButtton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

-(void)setUser:(TTUser *)user {
    //Set frame and text of nameLabel
    self.nameLabel.frame = CGRectMake(35 + self.profileImageView.bounds.size.width, 0, self.bounds.size.width - 150, self.bounds.size.height);
    self.nameLabel.text = user.displayName;
    
    self.createTicButtton.frame = CGRectMake(self.bounds.size.width - 40 , 7, self.bounds.size.height - 14, self.bounds.size.height - 14);
    
    
    //Set frame of profile Image View
    self.profileImageView.frame = CGRectMake(15, 5, self.bounds.size.height - 10, self.bounds.size.height - 10);
    self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.size.height/2;
    self.profileImageView.clipsToBounds = YES;
    
    //if the profile picture needs to be loaded from parse, it does so here
    //if not, it fetches it from the cache and puts it in the main view
    [user fetchInBackgroundWithBlock:^(PFObject *object, NSError *err) {
        TTUser *user = (TTUser *)object;
        __block NSData *data;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        dispatch_async(queue, ^{
            data = [user profilePicture];
            dispatch_sync(dispatch_get_main_queue(), ^{
                if(data){
                    self.profileImageView.image = [UIImage imageWithData:data];
                }
            });
        });
    }];
}

@end
