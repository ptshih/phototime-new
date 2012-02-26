//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "PSZoomView.h"
#import "TimelineView.h"
#import "DateRangeView.h"

#import "TimelineConfigViewController.h"
#import "PreviewViewController.h"

@interface TimelineViewController (Private)

- (void)setDateRange;
- (void)refreshOnAppear;

@end

@implementation TimelineViewController

@synthesize
pvc = _pvc,
timelineId = _timelineId,
startDate = _startDate,
endDate = _endDate,
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
        
        self.items = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnAppear) name:kTimelineShouldRefreshOnAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    self.pvc = nil;
    
    self.startDate = nil;
    self.endDate = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefreshOnAppear object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

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
//    self.tableView.contentOffset = self.contentOffset;
    
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
    [self.view addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease]];
    
    [self setupHeader];
    
    self.collectionView = [[[PSCollectionView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height)] autorelease];
    self.collectionView.delegate = self; // scrollViewDelegate
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.numCols = 3;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
    
    [self.view addSubview:self.collectionView];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockLeft" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"timelineTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockCenter" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self setDateRange];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"ButtonBlockRight" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconClockBlack"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

- (void)setDateRange {
    static NSArray *years = nil;
    years = [[NSArray arrayWithObjects:@"2007", @"2008", @"2009", @"2010", @"2011", @"2012", nil] retain];
    static NSDateComponents *components = nil;
    components = [[NSDateComponents alloc] init];
        
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSInteger startMonthIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"startMonthIndex"];
    NSInteger startYearIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"startYearIndex"];    
    NSInteger endMonthIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"endMonthIndex"];
    NSInteger endYearIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"endYearIndex"];
    
    // Parse
    [components setMonth:startMonthIndex + 1];
    [components setYear:[[years objectAtIndex:startYearIndex] integerValue]];
    self.startDate = [calendar dateFromComponents:components];
    [components setMonth:endMonthIndex + 1];
    [components setYear:[[years objectAtIndex:endYearIndex] integerValue]];
    self.endDate = [calendar dateFromComponents:components];
    
    // Display
    components = [calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.startDate];
    NSString *startString = [NSString stringWithFormat:@"%d/%d", components.month, components.year];
    components = [calendar components:(NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:self.endDate];
    NSString *endString = [NSString stringWithFormat:@"%d/%d", components.month, components.year];
    
    [self.centerButton setTitle:[NSString stringWithFormat:@"%@ - %@", startString, endString] forState:UIControlStateNormal];
}

#pragma mark - Actions
- (void)leftAction {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#config"];
    
    TimelineConfigViewController *vc = [[[TimelineConfigViewController alloc] initWithTimelineId:self.timelineId] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#dateRange"];
    
    DateRangeView *dateRangeView = [[[DateRangeView alloc] initWithFrame:CGRectMake(0, 0, 288, 352)] autorelease];
    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Timeline Dates" contentView:dateRangeView] autorelease];
    popoverView.delegate = self;
    [popoverView show];
}

- (void)rightAction {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#dateRange"];
    
    DateRangeView *dateRangeView = [[[DateRangeView alloc] initWithFrame:CGRectMake(0, 0, 288, 352)] autorelease];
    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Timeline Dates" contentView:dateRangeView] autorelease];
    popoverView.delegate = self;
    [popoverView show];
    
//    if (!self.pvc) {
//        self.pvc = [[[PreviewViewController alloc] initWithNibName:nil bundle:nil] autorelease];
//    }
//    UIImagePickerController *vc = [[[UIImagePickerController alloc] init] autorelease];
//    vc.delegate = self.pvc;
//    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionLeft animated:YES];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    [self loadDataSourceFromRemoteUsingCache:YES];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#load"];
}

- (void)reloadDataSource {
    [super reloadDataSource];

    [self loadDataSourceFromRemoteUsingCache:NO];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"timeline#reload"];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
    [self.collectionView reloadViews];
    
    if ([self dataSourceIsEmpty]) {
        // Show empty view
        
    }
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
}

- (BOOL)dataSourceIsEmpty {
    return ([self.items count] == 0);
}

- (void)loadDataSourceFromRemoteUsingCache:(BOOL)usingCache {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSNumber *startTimestamp = [NSNumber numberWithDouble:[self.startDate timeIntervalSince1970]];
    NSNumber *endTimestamp = [NSNumber numberWithDouble:[self.endDate timeIntervalSince1970]];
    [parameters setObject:startTimestamp forKey:@"since"];
    [parameters setObject:endTimestamp forKey:@"until"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/photos", API_BASE_URL, self.timelineId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypePermanent usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        if (error) {
            [self dataSourceDidError];
        } else {
            [[[[NSOperationQueue alloc] init] autorelease] addOperationWithBlock:^{
                // Parse JSON
                id JSON = [NSJSONSerialization JSONObjectWithData:cachedData options:NSJSONReadingMutableContainers error:nil];
                if (!JSON) {
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self dataSourceDidError];
                    }];
                } else {
                    // Check for our own success codes
                    id metaCode = [JSON objectForKey:@"code"];
                    if (!metaCode || [metaCode integerValue] != 200) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [self dataSourceDidError];
                        }];
                    } else {
                        // Success
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"# NSURLConnection finished on thread: %@", [NSThread currentThread]);
                            self.items = [[JSON objectForKey:@"data"] objectForKey:@"photos"];
                            [self dataSourceDidLoad];
                            
                            // If this is the first load and we loaded cached data, we should refreh from remote now
                            if (!self.hasLoadedOnce && isCached) {
                                self.hasLoadedOnce = YES;
                                [self reloadDataSource];
                                NSLog(@"first load, stale cache");
                            }
                        }];
                    }
                }
            }];
        }
    }];
}

#pragma mark - PSCollectionViewDelegate
- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    
    TimelineView *v = (TimelineView *)[self.collectionView dequeueReusableView];
    if (!v) {
        v = [[[TimelineView alloc] initWithFrame:CGRectZero] autorelease];
    }
    
    [v fillViewWithObject:item];
    
    return v;
}

- (CGFloat)heightForViewAtIndex:(NSInteger)index {
    NSDictionary *item = [self.items objectAtIndex:index];
    return [TimelineView heightForViewWithObject:item inColumnWidth:self.collectionView.colWidth];
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(UIView *)view atIndex:(NSInteger)index {
    // ZOOM
    static BOOL isZooming;
    
    TimelineView *timelineView = (TimelineView *)view;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = timelineView.imageView;
    if (!imageView.image) return;
    
    // If already zooming, don't rezoom
    if (isZooming) return;
    else isZooming = YES;
    
    // make sure to zoom the full res image here
    NSURL *originalURL = imageView.originalURL;
    UIActivityIndicatorViewStyle oldStyle = imageView.loadingIndicator.activityIndicatorViewStyle;
    imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView.loadingIndicator startAnimating];
    
    [[PSURLCache sharedCache] loadURL:originalURL cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        [imageView.loadingIndicator stopAnimating];
        imageView.loadingIndicator.activityIndicatorViewStyle = oldStyle;
        isZooming = NO;
        
        if (!error) {
            UIImage *sourceImage = [UIImage imageWithData:cachedData];
            if (sourceImage) {
                UIViewContentMode contentMode = imageView.contentMode;
                PSZoomView *zoomView = [[[PSZoomView alloc] initWithImage:sourceImage contentMode:contentMode] autorelease];
                CGRect imageRect = [timelineView convertRect:imageView.frame toView:collectionView];
                [zoomView showInRect:[collectionView convertRect:imageRect toView:nil]];
            }
        }
    }];
}

#pragma mark - PSPopoverViewDelegate
- (void)popoverViewDidDismiss:(PSPopoverView *)popoverView {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dateRangeDidChange"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dateRangeDidChange"];
        [self setDateRange];
        [self reloadDataSource];
    }
}

#pragma mark - PSErrorViewDelegate
- (void)errorViewDidDismiss:(PSErrorView *)errorView {
    [self reloadDataSource];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
}

- (void)endRefresh {
    [super endRefresh];
    [SVProgressHUD dismiss];
}

@end
