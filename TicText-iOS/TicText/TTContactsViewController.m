//
//  TTContactsViewController.m
//  TicText
//
//  Created by Kevin Yufei Chen on 2/20/15.
//  Copyright (c) 2015 Kevin Yufei Chen. All rights reserved.
//

#import "TTContactsViewController.h"
#import "TTMessagesViewController.h"

#define kContactCellIdentifier @"cell"

@interface TTContactsViewController () {
    BOOL searchActive;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic, strong) UIBarButtonItem *searchButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;

@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSArray *queriedFriends;
@end

@implementation TTContactsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Contacts";
    
    searchActive = NO;
    
    //create new table view and add it to the view
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[TTContactTableViewCell class] forCellReuseIdentifier:kContactCellIdentifier];
    [self.view addSubview:self.tableView];
    
    
    //Allocate Search Bar but DO NOT add it to the view. this ensures it only gets allocated once.
    //If the search bar is pressed then the view is added to self.navigationItem.titleView
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width - 150, 44)];
    self.searchBar.placeholder = @"Search Contacts";
    self.searchBar.delegate = self;
    self.searchBar.translucent = NO;
    
    //Create UIBarButtonItems, only self.searchBar is initially shown, if the search bar is visible
    //Then self.cancelButton is visible instead
    self.searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(willShowSearchBar)];
    self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(willCancelSearch)];
    self.navigationItem.rightBarButtonItem = self.searchButton;
    
    
    //Gets list of friends and sorts them by their first name
    NSArray *unsortedFriends = [TTUser currentUser].privateData.friends;
    self.friends= [unsortedFriends sortedArrayUsingComparator:^NSComparisonResult(TTUser *_u1, TTUser *_u2){
        return [_u1.displayName compare:_u2.displayName];
    }];
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - NavBar Methods
-(void)willShowSearchBar {
    self.navigationItem.titleView = self.searchBar;
    self.navigationItem.rightBarButtonItem = self.cancelButton;
    [self.searchBar becomeFirstResponder];
    searchActive = YES;
    [self.tableView reloadData];
}

-(void)willCancelSearch {
    self.navigationItem.titleView = nil;
    self.navigationItem.rightBarButtonItem = self.searchButton;
    searchActive = NO;
    [self.tableView reloadData];
}

#pragma mark - Table view delegate methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(searchActive) {
        return self.queriedFriends.count; //queried friends
    }
    return self.friends.count;
}

//Creates contact cell and assigns a user to the cell.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTContactTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kContactCellIdentifier forIndexPath:indexPath];
    if (searchActive) {
        cell.user = (TTUser *)self.queriedFriends[indexPath.row]; //queried cells
    }
    else {
        cell.user = (TTUser *)self.friends[indexPath.row]; //regular scrolling cells
    }
    
    //used to create a new tic if the person presses the button
    cell.createTicButtton.tag = indexPath.row;
    [cell.createTicButtton addTarget:self action:@selector(createConversationFromButton:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder]; //hides keyboard to give the user more room to scroll
}

#pragma mark - new Tic method
-(void)createConversationFromButton:(UIButton *)cellButton {
    [self.searchBar resignFirstResponder];
    NSInteger index = cellButton.tag;
    TTUser *friend;
    if (searchActive) {
        friend = self.queriedFriends[index];
    }
    else {
        friend = self.friends[index]; //gets correct friend and pushes the messagesViewController
    }
    TTMessagesViewController *messagesViewController = [TTMessagesViewController messagesViewControllerWithRecipient:friend];
    messagesViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messagesViewController animated:YES];
}


#pragma mark - Search Bar Delegates

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //creates search predicate and searches the display name using the lower case representation of their name
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        TTUser *_u = (TTUser *)evaluatedObject;
        return [_u.displayName.lowercaseString containsString:searchText.lowercaseString];
    }];
    
    self.queriedFriends = [self.friends filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData]; //table reloads after each key stroke
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder]; //hides keyboard, really doesnt do much
}

@end
