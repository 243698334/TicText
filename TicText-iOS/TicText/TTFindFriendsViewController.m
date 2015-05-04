//
//  TTFindFriendsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/15/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTFindFriendsViewController.h"
#import "TTFindFriendsTableViewCell.h"

#define kTableViewCell @"cell"
#define kSections 1

@interface TTFindFriendsViewController () {
    UIImageView *_appIconImageView;
    NSMutableArray *_friends;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *rowArray;
@end

@implementation TTFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupRowArray];
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.view.backgroundColor = kTTUIPurpleColor;
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[TTFindFriendsTableViewCell class] forCellReuseIdentifier:kTableViewCell];
    self.tableView.backgroundColor = kTTUIPurpleColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height * 0.15)];
    headerView.backgroundColor = kTTUIPurpleColor;
    self.tableView.tableHeaderView = headerView;
    
    //gesture recognizer code
    UISwipeGestureRecognizer *swipeRecognizerLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    swipeRecognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeRecognizerLeft];
    
    UISwipeGestureRecognizer *swipeRecognizerRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(showGestureForSwipeRecognizer:)];
    swipeRecognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRecognizerRight ];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIGraphicsBeginImageContextWithOptions([self presentingViewController].view.bounds.size, NO, [UIScreen mainScreen].scale);
    [((UIWindow *)[UIApplication sharedApplication].windows.firstObject).layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *ss = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.screenshot = ss;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.presentingViewController.view.frame];
    iv.image = self.screenshot;
    [self.view addSubview: iv];
    [self.view sendSubviewToBack:iv];
    
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
    imageBackgroundView.backgroundColor = [UIColor clearColor];
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
    [button addTarget:self action:@selector(fadeView) forControlEvents: UIControlEventTouchUpInside];
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
    TTFindFriendsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kTableViewCell forIndexPath:indexPath];
    
    [cell setNumberOfFriendsInRow:((NSArray *)self.rowArray[indexPath.row]).count];
    [cell setFriends:[self.rowArray[indexPath.row] mutableCopy]];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)hideView {
    NSLog(@"hiding the view");
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

-(void)setupRowArray {
    TTUser *_user = [TTUser currentUser];
    //each entry in the row array corresponds to a row in the tableview.
    //each entry in the row array has an array containing user objects
    self.rowArray = [[NSMutableArray alloc] init];
    if(!_user) {
        NSLog(@"no active user");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [_user.privateData fetchIfNeeded]; // @Remark: This fixes the unit tests, but relies on a synchronous call.
    _friends = [[NSMutableArray alloc] initWithArray:_user.privateData.friends];
    
    if (kTTDemoModeEnabled) { // stuff just for testing
        [_friends addObjectsFromArray: _user.privateData.friends];
        [_friends addObjectsFromArray: _user.privateData.friends];
        [_friends addObjectsFromArray: _user.privateData.friends];
        [_friends addObjectsFromArray: _user.privateData.friends];
    }
    
    if(_friends.count == 0) {
        NSLog(@"no friends on tictext :(");
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSInteger counter = 0;
    while (_friends.count > 0) {
        NSInteger next = 3 - counter % 2;
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for(int i = 0; i < next; i++) {
            if ([self canPop]) {
                [arr addObject:[self pop]];
            }
        }
        counter++;
        [self.rowArray addObject:arr];
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

#pragma mark - swipe gesture selector
// Respond to a swipe gesture
- (void)showGestureForSwipeRecognizer:(UISwipeGestureRecognizer *)recognizer {
    int shift = 0;
    
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        shift = -30;
    } else {
        shift = 30;
    }
    self.modalPresentationStyle = UIModalPresentationCurrentContext;
    
    [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
        UIView *view = [self tableView:self.tableView viewForHeaderInSection:0];
        view.alpha = 0;
        self.tableView.alpha = 0;
        self.tableView.transform = CGAffineTransformMakeTranslation(shift, 0);
    } completion:^(BOOL finished){
        [self hideView];
    }];
}

-(void)fadeView {
    [UIView animateKeyframesWithDuration:0.2 delay:0 options:0 animations:^{
        UIView *view = [self tableView:self.tableView viewForHeaderInSection:0];
        view.alpha = 0;
        self.tableView.alpha = 0;
    } completion:^(BOOL finished){
        [self hideView];
    }];
}

@end
