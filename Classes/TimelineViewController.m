//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "TimelineViewController.h"
#import "PSZoomView.h"
#import "TimelineView.h"
#import "LeaderboardView.h"

#import "PreviewViewController.h"

@interface TimelineViewController ()

@property (nonatomic, retain) UIPopoverController *popover;

- (void)refreshOnAppear;

@end

@implementation TimelineViewController

@synthesize
popover = _popover,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
shouldRefreshOnAppear = _shouldRefreshOnAppear;

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.shouldRefreshOnAppear = NO;
        
        self.items = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnAppear) name:kTimelineShouldRefreshOnAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:kTimelineShouldReload object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataSource) name:UIApplicationWillEnterForegroundNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    self.popover = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.popover = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSucceeded object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefreshOnAppear object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldReload object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];

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
//  UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease];
//  return bgView;
//}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Setup Views
    [self setupSubviews];
    [self setupPullRefresh];
    
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
    self.collectionView.numColsPortrait = 2;
    self.collectionView.numColsLandscape = 3;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
    
    UILabel *emptyLabel = [UILabel labelWithText:@"No Photos Found" style:@"emptyLabel"];
    self.collectionView.emptyView = emptyLabel;
    
    [self.view addSubview:self.collectionView];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGroupWhite"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:@"Phototime" forState:UIControlStateNormal];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraWhite"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
}

- (void)centerAction {
    LeaderboardView *v = [[[LeaderboardView alloc] initWithFrame:CGRectInset(self.view.bounds, 16, 52)] autorelease];
    PSPopoverView *popoverView = [[[PSPopoverView alloc] initWithTitle:@"Leaderboard: Last 7 Days" contentView:v] autorelease];
    popoverView.tag = kLeaderboardViewTag;
    popoverView.delegate = self;
    [popoverView showWithSize:v.frame.size inView:self.view];
}

- (void)rightAction {
    UIActionSheet *as = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil] autorelease];
    
    // Only show "Take Photo" option if device supports it
    BOOL canTakePicture = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (canTakePicture) {
        [as addButtonWithTitle:@"Take Photo"];
    }
    
    [as addButtonWithTitle:@"Choose From Library"];
    [as addButtonWithTitle:@"Cancel"];
    [as setCancelButtonIndex:[as numberOfButtons] - 1];
    
    [as showInView:self.view];
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
    NSLog(@"loading data source with cache: %d", usingCache);
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:accessToken forKey:@"accessToken"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/photos", API_BASE_URL, userId]];
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
                            self.items = [JSON objectForKey:@"data"];
                            [self.collectionView reloadViews];
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
    
    [v fillViewWithObject:item presentingController:self];
    
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
                imageView.image = sourceImage;
                CGRect convertedFrame = [self.view.window convertRect:imageView.frame fromView:imageView.superview];
                [PSZoomView showImage:imageView.image withFrame:convertedFrame inView:self.view.window];
            }
        }
    }];
}

#pragma mark - PSPopoverViewDelegate
- (void)popoverViewDidDismiss:(PSPopoverView *)popoverView {
//    [self reloadDataSource];
}

#pragma mark - Refresh
- (void)beginRefresh {
    [super beginRefresh];
}

- (void)endRefresh {
    [super endRefresh];
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (isDeviceIPad()) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        UIImage *originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
        UIImage *scaledImage = [originalImage imageScaledAndRotated];
        
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            UIImageWriteToSavedPhotosAlbum(originalImage, nil, nil, nil);
        }
        
        PreviewViewController *vc = [[[PreviewViewController alloc] initWithImage:scaledImage] autorelease];
        [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    }
    
    if (isDeviceIPad()) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
        [picker.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
    }
}

#pragma mark - Action Sheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.cancelButtonIndex == buttonIndex) return;
    
    NSString *buttonName = [actionSheet buttonTitleAtIndex:buttonIndex];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if ([buttonName isEqualToString:@"Take Photo"]) {
        sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if ([buttonName isEqualToString:@"Choose From Library"]) {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *vc = [[[UIImagePickerController alloc] init] autorelease];
        vc.delegate = self;
        vc.sourceType = sourceType;
        
        NSArray *availableMediaTypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        if ([availableMediaTypes containsObject:(NSString *)kUTTypeImage]) {
            vc.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
        }
        
        if (isDeviceIPad()) {
            self.popover = [[[UIPopoverController alloc] initWithContentViewController:vc] autorelease];
            self.popover.delegate = self;
            [self.popover presentPopoverFromRect:self.headerView.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        } else {
            [self presentViewController:vc animated:YES completion:^{}];
        }
    }
}

#pragma mark - UIPopoverDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
}

@end
