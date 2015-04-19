//
//  TTUnreadMessagesView.m
//  ConversationDemo
//
//  Created by Jack Arendt on 3/31/15.
//  Copyright (c) 2015 John Arendt. All rights reserved.
//

#import "TTUnreadTicsView.h"
#import "TTConstants.h"

@interface TTUnreadTicsView ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipe;
@end

@implementation TTUnreadTicsView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = kTTUIPurpleColor;
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        self.tableView.clipsToBounds = YES;
        self.tableView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.tableView];
        
        self.swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUp)];
        self.swipe.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:self.swipe];
    }
    return self;
}

- (void)reloadData {
    [self.tableView reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    if(self.delegate) {
        cell.textLabel.text = [self.delegate timeStampForMessageAtIndex:indexPath.row];
    }
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.delegate) {
        return [self.delegate numberOfUnreadMessages];
    }
    return 0;
}

-(void)swipeUp {
    if(self.delegate) {
        [self.delegate unreadMessagesdidSwipe:self];
    }
}

@end
