//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineCell.h"

#import "TimelineConfigViewController.h"
#import "GalleryViewController.h"

@interface TimelineViewController (Private)

- (void)setDateRange;
- (void)refreshOnAppear;

@end

@implementation TimelineViewController

@synthesize
timelineId = _timelineId,
fromDate = _fromDate,
toDate = _toDate,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
shouldRefreshOnAppear = _shouldRefreshOnAppear;

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
        self.shouldRefreshOnAppear = NO;
        self.fromDate = [NSDate dateWithTimeIntervalSince1970:1327283215];
        self.toDate = [NSDate distantFuture];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnAppear) name:kTimelineShouldRefreshOnAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    // Views
    [super viewDidUnload];
}

- (void)dealloc {
    self.fromDate = nil;
    self.toDate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefreshOnAppear object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Views
    [super dealloc];
}

- (void)refreshOnAppear {
    self.shouldRefreshOnAppear = YES;
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

//- (UIView *)baseBackgroundView {
//  UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCloth.jpg"]] autorelease];
//  return bgView;
//}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup Views
    [self setupSubviews];
    [self setupPullRefresh];
    self.tableView.contentOffset = self.contentOffset;
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.shouldRefreshOnAppear) {
        self.shouldRefreshOnAppear = NO;
        [self reloadDataSource];
    }
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupHeader];
    
    [self setupTableViewWithFrame:CGRectMake(0.0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
    
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockLeft" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"timelineSectionTitle" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockCenter" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self setDateRange];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockRight" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraBlack"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

- (void)setDateRange {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = nil;
    components = [calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.fromDate];
    NSString *fromString = [NSString stringWithFormat:@"%d/%d", components.month, components.year];
    
    NSString *toString = nil;
    NSDate *nowDate = [NSDate date];
    if ([[nowDate earlierDate:self.toDate] isEqualToDate:nowDate]) {
        toString = @"Now";
    } else {
        components = [calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.toDate];
        toString = [NSString stringWithFormat:@"%d/%d", components.month, components.year];
    }
    
    [self.centerButton setTitle:[NSString stringWithFormat:@"%@ - %@", fromString, toString] forState:UIControlStateNormal];
}

#pragma mark - Actions
- (void)leftAction {
    TimelineConfigViewController *vc = [[[TimelineConfigViewController alloc] initWithTimelineId:self.timelineId] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
    
}

- (void)rightAction {
    GalleryViewController *vc = [[[GalleryViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionLeft animated:YES];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
}

- (void)reloadDataSource {
    [super reloadDataSource];

    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
//    for (NSInteger i = 0; i < self.tableView.numberOfSections; i++) {
//        CGPoint point = [self.tableView rectForSection:i].origin;
//        [self.sectionRects setObject:[self.sectionTitles objectAtIndex:i] forKey:NSStringFromCGPoint(point)];
//    }
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    BLOCK_SELF;
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSNumber *fromTimestamp = [NSNumber numberWithDouble:[self.fromDate timeIntervalSince1970]];
    NSNumber *toTimestamp = [NSNumber numberWithDouble:[self.toDate timeIntervalSince1970]];
    [parameters setObject:fromTimestamp forKey:@"since"];
    [parameters setObject:toTimestamp forKey:@"until"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/photos", API_BASE_URL, self.timelineId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        if (error) {
            [self dataSourceDidError];
        } else {
            [[[[NSOperationQueue alloc] init] autorelease] addOperationWithBlock:^{
                id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                
                NSArray *entities = [[JSON objectForKey:@"data"] objectForKey:@"photos"];
                
                NSMutableArray *sectionTitles = [NSMutableArray array];
                NSMutableArray *items = [NSMutableArray array];
                
                __block BOOL isNewSection = NO;
                __block NSInteger i = 0; // counter for photos per row
                __block NSString *lastDate = nil;
                [entities enumerateObjectsUsingBlock:^(NSDictionary *entity, NSUInteger idx, BOOL *stop) {
                    NSString *currentDate = [entity objectForKey:@"formattedDate"];
                    if ([currentDate isEqualToString:lastDate]) {
                        // Add to existing section
                        NSMutableArray *rows = [items lastObject];
                        
                        if (isNewSection || (i == 3)) {
                            i = 0;
                            isNewSection = NO;
                            NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:3];
                            [rows addObject:photos];
                            [photos release];
                        }
                        NSMutableArray *photos = [rows lastObject];
                        [photos addObject:entity];
                        i++;
                    } else {
                        lastDate = currentDate;
                        [sectionTitles addObject:currentDate];
                        
                        // Create a new section
                        NSMutableArray *rows = [[NSMutableArray alloc] init];
                        NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:1];
                        [photos addObject:entity];
                        [rows addObject:photos];
                        [photos release];
                        [items addObject:rows];
                        [rows release];
                        i = 0;
                        isNewSection = YES;
                    }
                }];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    NSLog(@"# NSURLConnection finished on thread: %@", [NSThread currentThread]);
                    blockSelf.sectionTitles = sectionTitles;
                    [blockSelf dataSourceShouldLoadObjects:items animated:NO];
                    [blockSelf dataSourceDidLoad];
                    
                    // If this is the first load and we loaded cached data, we should refreh from remote now
                    if (!self.hasLoadedOnce && isCached) {
                        self.hasLoadedOnce = YES;
                        [self reloadDataSource];
                        NSLog(@"first load, stale cache");
                    }
                }];
            }];
        }
    }];
}

#pragma mark - TableView
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
//    headerView.backgroundColor = [UIColor clearColor];
//    
//    //    NSString *title = [self.items count] > 0 ? [[[self.items objectAtIndex:section] objectAtIndex:0] objectForKey:@"formattedDate"] : @"Timeline";
//    NSString *title = [self.sectionTitles count] > 0 ? [self.sectionTitles objectAtIndex:section] : @"Timeline";
//    
//    UILabel *titleLabel = [UILabel labelWithText:title style:@"timelineSectionTitle"];
//    titleLabel.frame = CGRectMake(0, 0, headerView.width - 88.0, headerView.height);
//    titleLabel.center = headerView.center;
//    [headerView addSubview:titleLabel];
//    
//    return headerView;
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 44.0;
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.items objectAtIndex:section] count];;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [TimelineCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    //    id object = [self.frc objectAtIndexPath:indexPath];
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    return [cellClass rowHeightForObject:object atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    //    id object = [self.frc objectAtIndexPath:indexPath];
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGPoint contentOffset = scrollView.contentOffset;
//    NSLog(@"%@", NSStringFromCGPoint(contentOffset));
//    NSString *sectionTitle = [self.sectionRects objectForKey:NSStringFromCGPoint(contentOffset)];
//    if (sectionTitle) {
//        [self.centerButton setTitle:sectionTitle forState:UIControlStateNormal];
//    }
//}

@end
