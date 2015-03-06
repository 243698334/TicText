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

#pragma mark - load friend images
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
                    if(data){
                        ((UIImageView *)self.pictures[index]).image = [UIImage imageWithData:data];
                    }
                });
            });
            
            [friends removeObjectAtIndex:0];
            [self setFriends:friends index:index+1];
        }
    }];

}

#pragma mark - view creators
-(void)setNumberOfFriendsInRow:(NSInteger)num {
    width = self.bounds.size.width;
    height = self.bounds.size.height;
    self.numPictures = num;
    if(num == 0) {
        return;
    }
    
    [self setupFriends];
}

-(void)setupFriends {
    for(int i = 0; i<self.pictures.count; i++) {
        [self.pictures[i] setHidden:YES]; //initialize images to hidden
    }
    NSMutableArray *offsets = [[NSMutableArray alloc] init];
    if(self.numPictures == 1) { //add constraints
        [offsets addObject:[NSNumber numberWithFloat:width/2 - height/2]];
    }
    else if(self.numPictures == 2) {
        [offsets addObject:[NSNumber numberWithFloat:width/3 - height/2]];
        [offsets addObject:[NSNumber numberWithFloat:2*width/3 - height/2]];
    }
    else if(self.numPictures == 3) {
        [offsets addObject:[NSNumber numberWithFloat:width/6 - height/2]];
        [offsets addObject:[NSNumber numberWithFloat:width/2 - height/2]];
        [offsets addObject:[NSNumber numberWithFloat:5*width/6 - height/2]];
    }
    
    for (int i = 0; i<offsets.count; i++) {
        [self addImage:self.pictures[i] image:[UIImage imageNamed:kStockProfileImage] offset:[offsets[i] floatValue]];
        [self.pictures[i] setHidden:NO];
    }
}

-(void)addImage:(UIImageView *)iv image:(UIImage *)image offset:(CGFloat)xOff {
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = height/2;
    iv.image = image;
    iv.frame = CGRectMake(xOff, 0, height, height);
}

@end
