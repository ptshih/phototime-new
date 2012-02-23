//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "PSZoomView.h"

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
items = _items,
collectionView = _collectionView,
pullRefreshView = _pullRefreshView,
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
        self.fromDate = [NSDate dateWithTimeIntervalSince1970:1287283215];
        self.toDate = [NSDate distantFuture];
        
        self.items = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnAppear) name:kTimelineShouldRefreshOnAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    // Views
    self.pullRefreshView = nil;
    self.collectionView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.fromDate = nil;
    self.toDate = nil;
    self.items = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefreshOnAppear object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    
    // Views
    self.pullRefreshView = nil;
    self.collectionView = nil;
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
//    [self setupPullRefresh];
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
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper.jpg"]];
    
    [self.view addSubview:self.collectionView];
    
    if (self.pullRefreshView == nil) {
        self.pullRefreshView = [[[PSPullRefreshView alloc] initWithFrame:CGRectMake(0.0, 0.0 - 48.0, self.view.frame.size.width, 48.0) style:PSPullRefreshStyleBlack] autorelease];
        self.pullRefreshView.scrollView = self.collectionView;
        self.pullRefreshView.delegate = self;
        [self.collectionView addSubview:self.pullRefreshView];		
    }
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
    [self.collectionView reloadViews];
}

- (void)dataSourceDidError {
    [super dataSourceDidError];
    UIButton *errorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    errorButton.frame = self.collectionView.frame;
    [errorButton addTarget:self action:@selector(reloadAfterError:) forControlEvents:UIControlEventTouchUpInside];
    [errorButton setImage:[UIImage imageNamed:@"NetworkErrorBlack"] forState:UIControlStateNormal];
    [self.view addSubview:errorButton];
}

- (void)reloadAfterError:(UIButton *)button {
    [button removeFromSuperview];
    [self reloadDataSource];
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
    
    [[PSURLCache sharedCache] loadRequest:request cacheType:PSURLCacheTypePermanent usingCache:usingCache completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        if (error) {
            [blockSelf dataSourceDidError];
        } else {
            [[[[NSOperationQueue alloc] init] autorelease] addOperationWithBlock:^{
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
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            NSLog(@"# NSURLConnection finished on thread: %@", [NSThread currentThread]);
                            self.items = [[JSON objectForKey:@"data"] objectForKey:@"photos"];
                            [blockSelf dataSourceDidLoad];
                            
                            // If this is the first load and we loaded cached data, we should refreh from remote now
                            if (!blockSelf.hasLoadedOnce && isCached) {
                                blockSelf.hasLoadedOnce = YES;
                                [blockSelf reloadDataSource];
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
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [self.items count];
}

- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *photo = [self.items objectAtIndex:index];
    UIView *v = [self.collectionView dequeueReusableView];
    if (!v) {
        v = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        v.contentMode = UIViewContentModeScaleAspectFill;
        v.clipsToBounds = YES;
        v.layer.borderWidth = 1.0;
        v.layer.borderColor = [RGBACOLOR(230, 230, 230, 0.8) CGColor];
    }
    v.width = [[photo objectForKey:@"width"] floatValue];
    v.height = [[photo objectForKey:@"height"] floatValue];
    
    [(PSCachedImageView *)v setOriginalURL:[NSURL URLWithString:[photo objectForKey:@"source"]]];
    [(PSCachedImageView *)v setThumbnailURL:[NSURL URLWithString:[photo objectForKey:@"picture"]]];
    [(PSCachedImageView *)v loadImageWithURL:[NSURL URLWithString:[photo objectForKey:@"picture"]] cacheType:PSURLCacheTypePermanent];
    
    return v;

}

- (CGSize)sizeForViewAtIndex:(NSInteger)index {
    NSDictionary *photo = [self.items objectAtIndex:index];
    CGFloat width = [[photo objectForKey:@"width"] floatValue];
    CGFloat height = [[photo objectForKey:@"height"] floatValue];
    
    return CGSizeMake(width, height);
}

- (void)collectionView:(PSCollectionView *)collectionView didSelectView:(UIView *)view atIndex:(NSInteger)index {
    static BOOL isZooming;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = (PSCachedImageView *)view;
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
                CGRect imageRect = [collectionView convertRect:imageView.frame toView:collectionView];
                [zoomView showInRect:[collectionView convertRect:imageRect toView:nil]];
            }
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidEndDragging:scrollView
                                                   willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//    [[PSURLCache sharedCache] suspend];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.pullRefreshView) {
        [self.pullRefreshView pullRefreshScrollViewDidScroll:scrollView];
    }
}

#pragma mark - PSPullRefreshViewDelegate
- (void)pullRefreshViewDidBeginRefreshing:(PSPullRefreshView *)pullRefreshView {
    [self reloadDataSource];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateRefreshing];
}

- (void)endRefresh {
    [super endRefresh];
    [self.pullRefreshView setState:PSPullRefreshStateIdle];
}

@end
