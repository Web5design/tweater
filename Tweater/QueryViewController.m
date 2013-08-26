//
//  JKViewController.m
//  Tweater
//
//  Created by Hyungjun Kim on 8/22/13.
//  Copyright (c) 2013 Hyungjun Kim. All rights reserved.
//

#import "QueryViewController.h"

#import "CoreFunctions.h"
#import "DesignUtil.h"
#import "SignInViewController.h"
#import "TweetTableCell.h"


static NSString *CellIdentifier = @"TweetCell";
static CGFloat tableRowHeight = 75.0;


@implementation QueryViewController
{
	UISearchBar *_searchBar;
	UITableView *_resultsTable;
	NSMutableArray *_tweetDictsArray;
	NSString *_currentSearchString;
}

#pragma mark - Presentation/Initialization

- (void)loadView
{
	[super loadView];
	
	//Main View
	CGRect windowFrame = UIScreen.mainScreen.applicationFrame;
	self.view = [[UIView alloc] initWithFrame:windowFrame];
	
	//Nav Bar
	UILabel *navBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
	navBarTitleLabel.backgroundColor = [UIColor clearColor];
	navBarTitleLabel.font = [UIFont boldSystemFontOfSize:20.0];
	navBarTitleLabel.textColor = [UIColor lightGrayColor];
	navBarTitleLabel.text = @"Tweater";
	self.navigationItem.titleView = navBarTitleLabel;

	//Nav Bar Right Button
	UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[logoutButton setFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
	[logoutButton addTarget:self action:@selector(logout) forControlEvents:UIControlEventTouchUpInside];
	[logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
	[logoutButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:logoutButton];
	
	//Search Bar View
	CGRect searchBarFrame = CGRectMake(0, 0, windowFrame.size.width, 44);
	_searchBar = [[UISearchBar alloc] initWithFrame:searchBarFrame];
	[self.view addSubview:_searchBar];
	
	//Table View
	CGRect resultsTableFrame = CGRectMake(0, searchBarFrame.size.height, windowFrame.size.width, windowFrame.size.height - searchBarFrame.size.height);
	_resultsTable = [[UITableView alloc] initWithFrame:resultsTableFrame];
	_resultsTable.rowHeight = tableRowHeight;
	[self.view addSubview:_resultsTable];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	//Instantiate Tweets Array For Usage
	_tweetDictsArray = [[NSMutableArray alloc] init];
	
	//Disable TableView User Interaction
	_resultsTable.userInteractionEnabled = NO;
	
	//Set Delegates and Data Sources
	_searchBar.delegate = self;
	_resultsTable.delegate = self;
	_resultsTable.dataSource = self;
	TwitterClient.sharedInstance.delegate = self;
	
	//Display Twitter Sign In
	SignInViewController *signInViewController = [[SignInViewController alloc] init];
	[self presentViewController:signInViewController animated:NO completion:nil];
	
	//Set Empty current search string
	_currentSearchString = @"";
}

#pragma mark - TwitterClientDelegate

- (void)didSignIn
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveNewStreamingTweet:(id)tweet
{
	[_tweetDictsArray addObject:tweet];
	if (_tweetDictsArray.count > 5) {
		[_tweetDictsArray removeObjectAtIndex:0];
	}
	[_resultsTable reloadData];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	searchText = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	if ([searchText hasPrefix:@"@"]) {
		searchBar.text = searchText;
	}
	else if ([searchText isEqualToString:@""] || ![_currentSearchString isEqualToString:searchText]) {
		[self resetTable];
	}
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[_searchBar setShowsCancelButton:NO animated:YES];
	[searchBar resignFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:YES animated:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar setShowsCancelButton:NO animated:YES];
	[TwitterClient.sharedInstance stopStream];
	[TwitterClient.sharedInstance startStreamWithTerm:searchBar.text];
	_currentSearchString = searchBar.text;
	[searchBar resignFirstResponder];
}

#pragma mark = UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
    TweetTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		cell = [[TweetTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell.
	NSDictionary *tweetDict = [_tweetDictsArray objectAtIndex:indexPath.row];
    cell.usernameLabel.text = [@"@" stringByAppendingString:[tweetDict objectForKey:@"username"]];
	cell.tweetLabel.text = [tweetDict objectForKey:@"text"];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return _tweetDictsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return tableRowHeight;
}

#pragma mark - Takedown/Destruction

- (void)logout
{
	_searchBar.text = @"";
	[self resetTable];
	SignInViewController *signInViewController = [[SignInViewController alloc] init];
	[self presentViewController:signInViewController animated:YES completion:nil];
}

- (void)resetTable
{
	[TwitterClient.sharedInstance stopStream];
	_currentSearchString = @"";
	[_tweetDictsArray removeAllObjects];
	[_resultsTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
