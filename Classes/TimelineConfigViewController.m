//
//  TimelineConfigViewController.m
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimelineConfigViewController.h"
#import "UserCell.h"

@interface TimelineConfigViewController ()

- (void)addMember:(id)member;
- (void)removeMember:(id)member;

@end

@implementation TimelineConfigViewController

@synthesize
timelineId = _timelineId,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton;

#pragma mark - Init

- (id)initWithTimelineId:(NSString *)timelineId {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.timelineId = timelineId;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    self.timelineId = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadDataSource];
    
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[[[UIAlertView alloc] initWithTitle:@"What is this?" message:@"By adding friends to your timeline, their photos will also show up when viewing your timeline." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupHeader];
    [self setupTableViewWithFrame:CGRectMake(0.0, 44.0, self.view.width, self.view.height - 44.0) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleSingleLine separatorColor:[UIColor lightGrayColor]];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockLeft" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconHeartBlack"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"timelineTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockCenter" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.centerButton setTitle:@"Timeline Members" forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockRight" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconNextBlack"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timelineConfig#sendLove"];
    
    UIAlertView *av = [[[UIAlertView alloc] initWithTitle:@"Send Love" message:@"Your love makes us work harder. Rate our app now?" delegate:self cancelButtonTitle:@"No, Thanks" otherButtonTitles:@"Okay", nil] autorelease];
    [av show];
}

- (void)centerAction {
    
}

- (void)rightAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionLeft animated:YES];
}

#pragma mark - State Machine
- (void)beginRefresh {
    [super beginRefresh];
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
}

- (void)endRefresh {
    [super endRefresh];
    [SVProgressHUD dismiss];
}

- (void)loadDataSource {
    [super loadDataSource];
 
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/members", API_BASE_URL, self.timelineId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypeSession usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        if (error) {
            [self dataSourceDidError];
        } else {
            // Parse JSON
            id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
            if (!JSON) {
                // invalid json
                [self dataSourceDidError];
            } else {
                // Check for our own success codes
                id metaCode = [JSON objectForKey:@"code"];
                if (!metaCode || [metaCode integerValue] != 200) {
                    [self dataSourceDidError];
                } else {
                    // Success
                    NSDictionary *members = [[JSON objectForKey:@"data"] objectForKey:@"members"];
                    NSArray *inTimeline = [members objectForKey:@"inTimeline"];
                    NSArray *notInTimeline = [members objectForKey:@"notInTimeline"];
                    //            NSArray *onPhototime = [members objectForKey:@"onPhototime"];
                    //            NSArray *notOnPhototime = [members objectForKey:@"notOnPhototime"];
                    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                    
                    // Section 1
                    //    ortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortBy ascending:ascending]]
                    [items addObject:inTimeline];
                    [self.sectionTitles addObject:@"People in Timeline"];
                    
                    // Section 2
                    [items addObject:notInTimeline];
                    [self.sectionTitles addObject:@"People not in Timeline"];
                    
                    // Section 3
                    //            [items addObject:onPhototime];
                    //            [blockSelf.sectionTitles addObject:@"People on Phototime"];
                    //            
                    // Section 4
                    //            [items addObject:notOnPhototime];
                    //            [blockSelf.sectionTitles addObject:@"People not on Phototime"];
                    
                    [self dataSourceShouldLoadObjects:items animated:NO];
                    [self dataSourceDidLoad];
                }
            }
        }
    }];
    
}

#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [UserCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeight];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
    
    // Configure accessoryView
    if (indexPath.section == 0 || indexPath.section == 1) {
        UIButton *accessoryButton = [UIButton buttonWithFrame:CGRectMake(8, 8, 32, 32) andStyle:nil target:self action:@selector(accessoryButtonTapped:withEvent:)];
        UIImage *accessoryImage = nil;
        if (indexPath.section == 0) {
            accessoryImage = [UIImage imageNamed:@"IconMinusBlack"];
        } else if (indexPath.section == 1) {
            accessoryImage = [UIImage imageNamed:@"IconPlusBlack"];
        }
        [accessoryButton setImage:accessoryImage forState:UIControlStateNormal];
        
        UITableViewCell *aCell = (UITableViewCell *)cell;
        aCell.accessoryView = accessoryButton;
    } else {
        UITableViewCell *aCell = (UITableViewCell *)cell;
        aCell.accessoryView = nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (indexPath.section == 0) {
        // Tell server to remove member, freeze UI
        [self removeMember:object];
    } else if (indexPath.section == 1) {
        // Tell server to add member
        [self addMember:object];
    }
}

- (void)addMember:(id)member {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timelineConfig#addMember"];
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Adding %@", [member objectForKey:@"name"]] maskType:SVProgressHUDMaskTypeGradient];
    
    // Setup the network request
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/addUser/%@", API_BASE_URL, self.timelineId, [member objectForKey:@"id"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
            [SVProgressHUD dismissWithError:@"Error"];
        } else {
            // We got an HTTP OK code, start reading the response
            [[NSNotificationCenter defaultCenter] postNotificationName:kTimelineShouldRefreshOnAppear object:nil];
            [SVProgressHUD dismissWithSuccess:@"Success"];
            [self loadDataSource];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD dismissWithError:@"Error"];
    }];
    [op start];
}

- (void)removeMember:(id)member {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timelineConfig#removeMember"];
    
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Removing %@", [member objectForKey:@"name"]] maskType:SVProgressHUDMaskTypeGradient];
    
    // Setup the network request
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/removeUser/%@", API_BASE_URL, self.timelineId, [member objectForKey:@"id"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
            [SVProgressHUD dismissWithError:@"Error"];
        } else {
            // We got an HTTP OK code, start reading the response
            [[NSNotificationCenter defaultCenter] postNotificationName:kTimelineShouldRefreshOnAppear object:nil];
            [SVProgressHUD dismissWithSuccess:@"Success"];
            [self loadDataSource];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [SVProgressHUD dismissWithError:@"Error"];
    }];
    [op start];
}

#pragma mark - Action
- (void)accessoryButtonTapped:(UIButton *)button withEvent:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView: self.tableView]];
    if (!indexPath) return;
    
    if (self.tableView.delegate && [self.tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.cancelButtonIndex == buttonIndex) return;
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timelineConfig#loveSent"];
    
    [Appirater rateApp];
}

@end
