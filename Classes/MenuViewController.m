//
//  MenuViewController.m
//  OSnap
//
//  Created by Peter Shih on 11/22/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "MenuViewController.h"

#import "TimelineViewController.h"

#define MARGIN_X 10.0
#define MARGIN_Y 5.0

@implementation MenuViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    _selectedMenuIndexPath = [[NSIndexPath indexPathForRow:0 inSection:0] retain];
  }
  return self;
}

- (void)viewDidUnload {
  [super viewDidUnload];
  RELEASE_SAFELY(_searchField);
}

- (void)dealloc {
  [super dealloc];
  
  RELEASE_SAFELY(_selectedMenuIndexPath);
  
  // Views
  RELEASE_SAFELY(_searchField);
}

#pragma mark - View Config
- (UIView *)baseBackgroundView {
  UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease];
  return bgView;
}

- (UIView *)rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
  UIImageView *backgroundView = nil;
  if (!selected) {
    backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCellLeather.png"]] autorelease];
    backgroundView.autoresizingMask = ~UIViewAutoresizingNone;
  }
  return backgroundView;
}

#pragma mark - View
//- (void)loadView {
//  UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 260.0, 416.0)] autorelease];
//  [self setView:view];
//}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Search
  UIView *searchView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
  searchView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  UIImageView *searchBgView = [[[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"BackgroundSearchBar.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:1]] autorelease];
  searchBgView.autoresizingMask = searchView.autoresizingMask;
  [searchView addSubview:searchBgView];
  
  CGFloat searchWidth = searchView.width - 20;
  _searchField = [[PSSearchField alloc] initWithFrame:CGRectMake(10, 7, searchWidth, 30) style:PSSearchFieldStyleBlack];
  _searchField.delegate = self;
  _searchField.placeholder = @"Search";
//  [_searchField addTarget:self action:@selector(searchTermChanged:) forControlEvents:UIControlEventEditingChanged];
  [searchView addSubview:_searchField];
  
  [self.view addSubview:searchView];
  
  // Add a TableView
  [self setupTableViewWithFrame:CGRectMake(0, searchView.bottom, self.view.width, self.view.height - searchView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:nil];
  
  self.tableView.scrollsToTop = NO;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  [self loadDataSource];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([_searchField isFirstResponder]) {
    [_searchField resignFirstResponder];
  }
}

#pragma mark - State Machine
- (void)loadDataSource {
  [super loadDataSource];
  
  // Prepare Data
  NSDictionary *currentUser = [[NSUserDefaults standardUserDefaults] objectForKey:@"currentUser"];
//  
//  if (!currentUser) {
//    // User has not logged in yet
//    return;
//  }
  
//  NSString *numConnections = [NSString stringWithFormat:@"%@", [currentUser objectForKey:@"numConnections"]];
  
  // Items
  NSMutableArray *items = [NSMutableArray array];
  [_sectionTitles removeAllObjects];
  
  // First section - Profile
  NSMutableArray *first = [NSMutableArray array];
  NSDictionary *home = [NSDictionary dictionaryWithObjectsAndKeys:@"Dashboard", @"title", @"", @"subtitle", nil];
  [first addObject:home];
  [items addObject:first];
  [_sectionTitles addObject:@"Dashboard"];
  
  // Second section
  NSMutableArray *second = [NSMutableArray array];
  NSDictionary *connections = [NSDictionary dictionaryWithObjectsAndKeys:@"Connections", @"title", @"", @"subtitle", nil];
  [second addObject:connections];
  [items addObject:second];
  [_sectionTitles addObject:@"PSCollectionView"];
  
  // Third section
  NSMutableArray *third = [NSMutableArray array];
  NSDictionary *filmview = [NSDictionary dictionaryWithObjectsAndKeys:@"Film", @"title", @"", @"subtitle", nil];
  [third addObject:filmview];
  [items addObject:third];
  [_sectionTitles addObject:@"PSFilmView"];
  
  [self dataSourceShouldLoadObjects:items shouldAnimate:NO];
}

- (void)dataSourceDidLoad {
  [super dataSourceDidLoad];
}

#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
  switch (indexPath.section) {
    default:
      return [PSCell class];
      break;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Class cellClass = [self cellClassAtIndexPath:indexPath];
  return [cellClass rowHeight];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
  NSMutableDictionary *object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  [cell fillCellWithObject:object];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  Class cellClass = [self cellClassAtIndexPath:indexPath];
  id cell = nil;
  NSString *reuseIdentifier = [cellClass reuseIdentifier];
  
  cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
  if(cell == nil) { 
    cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier] autorelease];
    [_cellCache addObject:cell];
  }
  
  [self tableView:tableView configureCell:cell atIndexPath:indexPath];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSInteger section = indexPath.section;
  NSInteger row = indexPath.row;
  
  if (_selectedMenuIndexPath.row == row && _selectedMenuIndexPath.section == section) {
    [self.drawerController slideFromLeft];
    return;
  }
  
  NSMutableDictionary *object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

  // Menu
  id controller = nil;
  
  switch (section) {
    default:
    {
      // Home - Profile
      UINavigationController *nc = [[[NSBundle mainBundle] loadNibNamed:@"PSNavigationController" owner:self options:nil] lastObject];
      TimelineViewController *vc = [[[TimelineViewController alloc] initWithNibName:nil bundle:nil] autorelease];
      nc.viewControllers = [NSArray arrayWithObject:vc];
      controller = nc;
      break;
    }
  }
  
  [self.drawerController setRootViewController:controller];
  [self.drawerController slideFromLeft];
  
  RELEASE_SAFELY(_selectedMenuIndexPath);
  _selectedMenuIndexPath = [[NSIndexPath indexPathForRow:row inSection:section] retain];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  if (section == 0) return nil;
  
  UIView *headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 23)] autorelease];
  headerView.autoresizingMask = ~UIViewAutoresizingNone;
  headerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundSectionHeader.png"]];
  
  UILabel *headerLabel = [[[UILabel alloc] initWithFrame:CGRectMake(MARGIN_X, 0, headerView.width - MARGIN_X * 2, headerView.height)] autorelease];
  [PSStyleSheet applyStyle:@"menuSectionHeader" forLabel:headerLabel];
  headerLabel.backgroundColor = [UIColor clearColor];
  [headerView addSubview:headerLabel];
  
  headerLabel.text = [_sectionTitles objectAtIndex:section];
  
  return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) return 0.0;
  else return 23.0;
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  if (![textField isEditing]) {
    [textField becomeFirstResponder];
  }
  [textField resignFirstResponder];
  
  return YES;
}

@end
