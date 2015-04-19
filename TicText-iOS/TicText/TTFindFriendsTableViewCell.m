//
//  FindFriendsTableViewCell.m
//  TicText
//
//  Created by Jack Arendt on 2/19/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTFindFriendsTableViewCell.h"
#define kStockProfileImage @"profile"
#define kCellWidth self.bounds.size.width
#define kCellHeight self.bounds.size.height

@interface TTFindFriendsTableViewCell () {
    CGFloat height;
    CGFloat width;
}

@property (nonatomic, strong)   NSMutableArray *pictures;
@property (nonatomic)           NSInteger numPictures;

@end

@implementation TTFindFriendsTableViewCell

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
    [self setFriends:friends imageIndex:0];
}

-(void)setFriends:(NSMutableArray *)friends imageIndex:(NSInteger)imageIndex {
    if(friends.count <= 0) {
        return;
    }
    
    [[friends objectAtIndex:0] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *err) {
        if(!err) {
            TTUser *user = (TTUser *)object;
            __block NSData *data;
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
            dispatch_async(queue, ^{
                data = [user profilePicture];
                dispatch_sync(dispatch_get_main_queue(), ^{
                    if(data){
                        ((UIImageView *)self.pictures[imageIndex]).image = [UIImage imageWithData:data];
                    }
                });
            });
            
            [friends removeObjectAtIndex:0];
            [self setFriends:friends imageIndex:imageIndex+1];
        }
    }];
    
}

#pragma mark - view creators
-(void)setNumberOfFriendsInRow:(NSInteger)num {
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
        [offsets addObject:[NSNumber numberWithFloat:kCellWidth/2 - kCellHeight/2]];
    }
    else if(self.numPictures == 2) {
        [offsets addObject:[NSNumber numberWithFloat:kCellWidth/3 - kCellHeight/2]];
        [offsets addObject:[NSNumber numberWithFloat:2*kCellWidth/3 - kCellHeight/2]];
    }
    else if(self.numPictures == 3) {
        [offsets addObject:[NSNumber numberWithFloat:kCellWidth/6 - kCellHeight/2]];
        [offsets addObject:[NSNumber numberWithFloat:kCellWidth/2 - kCellHeight/2]];
        [offsets addObject:[NSNumber numberWithFloat:5*kCellWidth/6 - kCellHeight/2]];
    }
    
    for (int i = 0; i<offsets.count; i++) {
        [self addImage:self.pictures[i] image:[UIImage imageNamed:kStockProfileImage] offset:[offsets[i] floatValue]];
        [self.pictures[i] setHidden:NO];
    }
}

-(void)addImage:(UIImageView *)iv image:(UIImage *)image offset:(CGFloat)xOff {
    iv.clipsToBounds = YES;
    iv.layer.cornerRadius = kCellHeight/2;
    iv.image = image;
    iv.frame = CGRectMake(xOff, 0, kCellHeight, kCellHeight);
}

@end
