//
//  AddReposTableViewController.m
//  Reposit
//
//  Created by Morgan Chen on 1/3/15.
//  Copyright (c) 2015 Morgan Chen. All rights reserved.
//

#import "AddReposTableViewController.h"
#import "GitHubHelper.h"

@interface AddReposTableViewController ()

@property (nonatomic, readwrite) NSArray *fetchedRepositories;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation AddReposTableViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(refreshRepos) forControlEvents:UIControlEventValueChanged];
    
    self.searchBar.delegate = self;
    self.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.searchBar.text = [GitHubHelper sharedHelper].currentUser;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fetch repos from Github
    [self.refreshControl beginRefreshing];
    NSInteger offset = self.tableView.contentOffset.y-self.refreshControl.frame.size.height;
    [self.tableView setContentOffset:CGPointMake(0, offset) animated:YES];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)viewWillDisappear:(BOOL)animated {
    // save all selected and pop view controller
    NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];
    if (selectedRows.count > 0) {
        for (NSIndexPath *indexPath in selectedRows) {
            [[GitHubHelper sharedHelper] saveRepoFromJSONObject:self.fetchedRepositories[indexPath.row]];
        }
        [[GitHubHelper sharedHelper] saveContext];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - UIRefreshControl

// do not call directly! use [self.refreshControl beginRefreshing instead]
- (void)refreshRepos {
    NSCharacterSet *whiteSpaceAndNewLine = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *userNameTrimmed = [self.searchBar.text stringByTrimmingCharactersInSet:whiteSpaceAndNewLine];
    
    BOOL userNameIsValid = ([userNameTrimmed rangeOfCharacterFromSet:whiteSpaceAndNewLine].location == NSNotFound);
    
    if (userNameIsValid) {
        [[GitHubHelper sharedHelper] publicReposFromUser:self.searchBar.text completion:^(NSArray *repos) {
            self.fetchedRepositories = repos;
            [self.tableView reloadData];
            [self.refreshControl endRefreshing];
        }];
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self.refreshControl beginRefreshing];
    NSInteger offset = self.tableView.contentOffset.y-self.refreshControl.frame.size.height-(self.searchBar.frame.size.height+20);
    [self.tableView setContentOffset:CGPointMake(0, offset) animated:YES];
    [self.refreshControl sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.fetchedRepositories.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddRepoCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.fetchedRepositories[indexPath.row][@"name"]; // use @"full_name" maybe
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.fetchedRepositories.count) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        self.tableView.backgroundView = nil;
    }
    else {
        // display message when table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                          0,
                                                                          self.view.bounds.size.width,
                                                                          self.view.bounds.size.height)];
        messageLabel.text = @"Loading...\n\nIf this message persists, check your internet connection.";
        messageLabel.textColor = [UIColor darkGrayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.font = [UIFont systemFontOfSize:22];
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return 1;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}
*/

@end
