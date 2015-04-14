//
//  TTContactsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTContactsViewController.h"

#define kContactCellIdentifier @"cell"

@interface TTContactsViewController ()
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@property (nonatomic, strong) NSArray *friends;
@end

@implementation TTContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Contacts";
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[TTContactTableViewCell class] forCellReuseIdentifier:kContactCellIdentifier];
    [self.view addSubview:self.tableView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 150, 44)];
    self.searchBar.placeholder = @"Search Contacts";
    self.searchBar.translucent = NO;
    
    self.searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(willShowSearchBar)];
    
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(willCancelSearch)];
    
    self.navigationItem.rightBarButtonItem = self.searchButton;
    
    NSArray *unsortedFriends = [TTUser currentUser].privateData.friends;
    self.friends= [unsortedFriends sortedArrayUsingComparator:^NSComparisonResult(TTUser *_u1, TTUser *_u2){
        return [_u1.displayName compare:_u2.displayName];
    }];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)willShowSearchBar {
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.rightBarButtonItem = self.cancelButton;
}

-(void)willCancelSearch {
    self.navigationItem.titleView = nil;
    self.navigationItem.rightBarButtonItem = self.searchButton;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friends.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
    cell.user = (TTUser *)self.friends[indexPath.row];
    return cell;
}

@end
