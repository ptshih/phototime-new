//
//  PSTimelineConfigViewController.m
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSTimelineConfigViewController.h"
#import "Timeline.h"
#import "UserCell.h"

@interface PSTimelineConfigViewController ()

- (void)addMember:(id)member;
- (void)removeMember:(id)member;

@end

@implementation PSTimelineConfigViewController

@synthesize
timeline = _timeline;

#pragma mark - Init

- (id)initWithTimeline:(Timeline *)timeline {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.timeline = timeline;
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
    RELEASE_SAFELY(_timeline);
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
    
    [self setupHeader];
    [self setupSubviews];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupHeader {
    UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.userInteractionEnabled = YES;
    
    NSString *title = @"Timeline Members";
    
    UILabel *titleLabel = [UILabel labelWithText:title style:@"navigationTitleLabel"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    // Setup perma left/right buttons
    static CGFloat margin = 10.0;
    UIButton *leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 8.0, 28.0, 28.0) andStyle:nil target:self action:@selector(leftAction)];
    [leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateHighlighted];
    [headerView addSubview:leftButton];
    
//    UIButton *rightButton = [UIButton buttonWithFrame:CGRectMake(headerView.width - 28.0 - margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(rightAction)];
//    [rightButton setImage:[UIImage imageNamed:@"IconCameraBlack"] forState:UIControlStateNormal];
//    [rightButton setImage:[UIImage imageNamed:@"IconCameraGray"] forState:UIControlStateHighlighted];
//    [headerView addSubview:rightButton];
    
    [self.view addSubview:headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)rightAction {
    PSTimelineConfigViewController *vc = [[[PSTimelineConfigViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionLeft animated:YES];
}

- (void)setupSubviews {
    [self setupTableViewWithFrame:CGRectMake(0.0, 44.0, self.view.width, self.view.height - 44.0) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleSingleLine separatorColor:[UIColor lightGrayColor]];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [self beginRefresh];
    
    /**
     Sections:
     Friends in Timeline
     Friends on Phototime
     Friends on Facebook
     */
    
    void (^handlerBlock)(NSURLResponse *response, NSData *data, NSError *error);
    handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"# NSURLConnection completed on thread: %@", [NSThread currentThread]);
        
        // How to check response
        // First check error and data
        if (!error && data) {
            // This is equivalent to the completion block
            // Check the HTTP Status code if available
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = [httpResponse statusCode];
                if (statusCode == 200) {
                    NSLog(@"# NSURLConnection succeeded with statusCode: %d", statusCode);
                    // We got an HTTP OK code, start reading the response
                    id results = [data objectFromJSONData];
                    NSDictionary *members = [[results objectForKey:@"data"] objectForKey:@"members"];
                    NSArray *inTimeline = [members objectForKey:@"inTimeline"];
                    NSArray *notInTimeline = [members objectForKey:@"notInTimeline"];
                    NSArray *onPhototime = [members objectForKey:@"onPhototime"];
                    NSArray *notOnPhototime = [members objectForKey:@"notOnPhototime"];
                    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                    
                    // Section 1
                    //    ortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortBy ascending:ascending]]
                    [items addObject:inTimeline];
                    [self.sectionTitles addObject:@"People in Timeline"];
                    
                    // Section 2
                    [items addObject:notInTimeline];
                    [self.sectionTitles addObject:@"People not in Timeline"];
                    
                    // Section 3
                    [items addObject:onPhototime];
                    [self.sectionTitles addObject:@"People on Phototime"];
                    
                    // Section 4
                    [items addObject:notOnPhototime];
                    [self.sectionTitles addObject:@"People not on Phototime"];
                    
                    NSArray *memberIds = [inTimeline valueForKey:@"id"];
                    self.timeline.members = [memberIds componentsJoinedByString:@","];
                    NSError *error = nil;
                    [self.timeline.managedObjectContext save:&error];
                    
                    [self dataSourceShouldLoadObjects:items animated:NO];
                    [self endRefresh];
                } else {
                    // Failed, read status code
                    [self endRefresh];
                }
            }
        } else {
            [self endRefresh];
        }
    };
    
    // Setup the network request
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/members", API_BASE_URL, self.timeline.id]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
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
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Adding %@", [member objectForKey:@"name"]] maskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    void (^handlerBlock)(NSURLResponse *response, NSData *data, NSError *error);
    handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"# NSURLConnection completed on thread: %@", [NSThread currentThread]);
        
        // How to check response
        // First check error and data
        if (!error && data) {
            // This is equivalent to the completion block
            // Check the HTTP Status code if available
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = [httpResponse statusCode];
                if (statusCode == 200) {
                    NSLog(@"# NSURLConnection succeeded with statusCode: %d", statusCode);
                    // We got an HTTP OK code, start reading the response
                    //                    id results = [data objectFromJSONData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTimelineShouldRefreshOnAppear object:nil];
                    [SVProgressHUD dismissWithSuccess:@"Success"];
                    [self loadDataSource];
                } else {
                    // Failed, read status code
                    [SVProgressHUD dismissWithError:@"Error"];
                }
            }
        } else {
            [SVProgressHUD dismissWithError:@"Error"];
        }
    };
    
    // Setup the network request
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/addUser/%@", API_BASE_URL, self.timeline.id, [member objectForKey:@"id"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
}

- (void)removeMember:(id)member {
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Removing %@", [member objectForKey:@"name"]] maskType:SVProgressHUDMaskTypeGradient networkIndicator:YES];
    
    void (^handlerBlock)(NSURLResponse *response, NSData *data, NSError *error);
    handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"# NSURLConnection completed on thread: %@", [NSThread currentThread]);
        
        // How to check response
        // First check error and data
        if (!error && data) {
            // This is equivalent to the completion block
            // Check the HTTP Status code if available
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = [httpResponse statusCode];
                if (statusCode == 200) {
                    NSLog(@"# NSURLConnection succeeded with statusCode: %d", statusCode);
                    // We got an HTTP OK code, start reading the response
//                    id results = [data objectFromJSONData];
                    [[NSNotificationCenter defaultCenter] postNotificationName:kTimelineShouldRefreshOnAppear object:nil];
                    [SVProgressHUD dismissWithSuccess:@"Success"];
                    [self loadDataSource];
                } else {
                    // Failed, read status code
                    [SVProgressHUD dismissWithError:@"Error"];
                }
            }
        } else {
            [SVProgressHUD dismissWithError:@"Error"];
        }
    };
    
    // Setup the network request
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/removeUser/%@", API_BASE_URL, self.timeline.id, [member objectForKey:@"id"]]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
}

#pragma mark - Action
- (void)accessoryButtonTapped:(UIButton *)button withEvent:(UIEvent *)event {
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView: self.tableView]];
    if (!indexPath) return;
    
    if (self.tableView.delegate && [self.tableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
        [self.tableView.delegate tableView:self.tableView accessoryButtonTappedForRowWithIndexPath:indexPath];
    }
}

@end
