//
//  TTFindFriendsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTFindFriendsViewController.h"
#import "FindFriendsTableViewCell.h"
#import "TTUser.h"

#define kTableViewCell @"cell"
#define kSections 1

@interface TTFindFriendsViewController () {
    UIImageView *_appIconImageView;
    UIColor *_TTPurpleColor;
    NSMutableArray *_friends;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSDictionary *cache;
@property (nonatomic, strong) NSMutableArray *rowArray;
@end

@implementation TTFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRowArray];
    

    self.view.backgroundColor = kTTUIPurpleColor;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[FindFriendsTableViewCell class] forCellReuseIdentifier:kTableViewCell];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];

    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.15)];
    headerView.backgroundColor = _TTPurpleColor;
    self.tableView.tableHeaderView = headerView;
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width * 0.6)];
    header.backgroundColor = kTTUIPurpleColor;
    CGFloat appIconImageViewWidth = self.view.bounds.size.width * 0.8;
    CGFloat appIconImageViewHeight = self.view.bounds.size.width * 0.6;
    CGFloat appIconImageViewOriginX = (self.view.bounds.size.width - appIconImageViewWidth) / 2;
    CGFloat appIconImageViewOriginY = 0;
    _appIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(appIconImageViewOriginX, appIconImageViewOriginY, appIconImageViewWidth, appIconImageViewHeight)];
    _appIconImageView.contentMode = UIViewContentModeScaleAspectFit;
    _appIconImageView.image = [UIImage imageNamed:@"FindFriendsTitle"];
    
    UIView *imageBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0,self.view.bounds.size.width , self.view.bounds.size.width * 0.5)];
    imageBackgroundView.backgroundColor = _TTPurpleColor;
    [header addSubview:imageBackgroundView];
    [header addSubview:_appIconImageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"Continue" forState:UIControlStateNormal];
    [button sizeToFit];
    button.frame = CGRectMake(header.bounds.size.width/2, 200, 80, 30);
    button.center = CGPointMake(header.bounds.size.width/2, 200);
    button.layer.borderWidth = 2.0f;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.cornerRadius = 10;
    button.clipsToBounds = YES;
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [header addSubview:button];
    [button addTarget:self action:@selector(hideView) forControlEvents: UIControlEventTouchUpInside];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return self.view.bounds.size.width * 0.6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 75;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return kSections;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rowArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCell forIndexPath:indexPath];
    
    if(indexPath.row % 2 == 1) {
        [cell setFriends:@[[UIImage imageNamed:@"profile"], [UIImage imageNamed:@"profile"]]];
    }
    
    else if(indexPath.row %2 == 0){
        [cell setFriends:@[[UIImage imageNamed:@"profile"], [UIImage imageNamed:@"profile"], [UIImage imageNamed:@"profile"]]];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)hideView {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

-(void)setupRowArray {
    TTUser *_user = [TTUser currentUser];
    self.rowArray = [[NSMutableArray alloc] init];
    if(!_user) {
        NSLog(@"no active user");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    _friends = [[NSMutableArray alloc] initWithArray:[_user friends]];
    if(!_friends) {
        NSLog(@"no friends on tictext :(");
    }
    
    NSInteger next = 3;
    while (_friends.count > 0) {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int i = 0; i < next; i++) {
            if ([self canPop]) {
                [arr addObject:[self pop]];
            }
        }
        [self.rowArray addObject:arr];
        next = 2;
    }
}

-(BOOL)canPop {
    return (_friends.count > 0);
}

-(TTUser *)pop {
    TTUser *user = [_friends objectAtIndex:0];
    [_friends removeObjectAtIndex:0];
    return user;
}

@end
