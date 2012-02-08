//
//  PSTimelineConfigViewController.m
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSTimelineConfigViewController.h"

#import "UserCell.h"

@implementation PSTimelineConfigViewController

#pragma mark - Init
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
    
    NSString *title = @"Timeline Settings";
    
    UILabel *titleLabel = [UILabel labelWithText:title style:@"navigationTitleLabel"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    // Setup perma left/right buttons
    static CGFloat margin = 10.0;
    UIButton *leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(leftAction)];
    [leftButton setImage:[UIImage imageNamed:@"IconClockBlack"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"IconClockBlack"] forState:UIControlStateHighlighted];
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
    [self setupTableViewWithFrame:CGRectMake(0.0, 44.0, self.view.width, self.view.height - 44.0) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
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
                    NSArray *friends = [[results objectForKey:@"data"] objectForKey:@"friends"];
                    NSMutableArray *items = [NSMutableArray arrayWithCapacity:1];
                    
                    // Section 1
                    //    ortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:sortBy ascending:ascending]]
                    NSArray *fbFriends = [friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
                    [items addObject:fbFriends];
                    [self.sectionTitles addObject:@"Friends in Timeline"];
                    
                    // Section 2
                    [items addObject:[NSMutableArray array]];
                    [self.sectionTitles addObject:@"Friends on Phototime"];
                    
                    // Section 3
                    [items addObject:[NSMutableArray array]];
                    [self.sectionTitles addObject:@"Friends on Facebook"];
                    
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
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/friends", API_BASE_URL, fbId]];
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
    [cell fillCellWithObject:object];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [self.sectionTitles objectAtIndex:section];
}

@end
