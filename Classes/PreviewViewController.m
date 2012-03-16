//
//  PreviewViewController.m
//  OSnap
//
//  Created by Peter Shih on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import "PreviewViewController.h"
#import "ScoreViewController.h"

@interface PreviewViewController ()

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, assign) UIImageView *headerImageView;

@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;

@property (nonatomic, assign) UIView *containerView;
@property (nonatomic, assign) UIImageView *imageView;

@end

@implementation PreviewViewController

@synthesize
image = _image,
headerImageView = _headerImageView,

leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,

containerView = _containerView,
imageView = _imageView;

- (id)initWithImage:(UIImage *)image {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.image = image;
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
    self.image = nil;

    [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"preview#load"];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupHeader];
    
    self.containerView = [[[UIView alloc] initWithFrame:CGRectMake(8, 8 + self.headerView.height, self.view.width - 16, self.view.height - 16 - self.headerView.height)] autorelease];
    self.containerView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.containerView.layer.shadowOffset = CGSizeMake(0.0, 2.0);
    self.containerView.layer.shadowRadius = 3;
    self.containerView.layer.shadowOpacity = 1.0;
    self.containerView.layer.masksToBounds = NO;
    [self.view addSubview:self.containerView];
    
    self.imageView = [[[UIImageView alloc] initWithFrame:CGRectInset(self.containerView.bounds, 8, 8)] autorelease];
    CGFloat photoWidth = self.image.size.width;
    CGFloat photoHeight = self.image.size.height;
    CGFloat scaledHeight = floorf(photoHeight / (photoWidth / self.imageView.width));
    self.imageView.height = MIN(scaledHeight, self.imageView.height);
    self.imageView.backgroundColor = RGBCOLOR(200, 200, 200);
    [self.imageView setImage:self.image];
    [self.containerView addSubview:self.imageView];
    
    
    // Table Header
//    UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 160.0)] autorelease];
//    
//    CGFloat scaledHeight = floorf(self.image.size.height / (self.image.size.width / tableHeaderView.width));
//    self.headerImageView = [[[UIImageView alloc] initWithImage:self.image] autorelease];
//    self.headerImageView.width = tableHeaderView.width;
//    self.headerImageView.height = scaledHeight;
//    self.headerImageView.top = -1 * (self.headerImageView.height - tableHeaderView.height);
//    [self.tableView addSubview:self.headerImageView];
//    [self.tableView sendSubviewToBack:self.headerImageView];
//    self.tableView.tableHeaderView = tableHeaderView;
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackWhite"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:@"Add This Photo" forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [PSStyleSheet applyStyle:@"navigationButton" forButton:self.rightButton];
    [self.rightButton setTitle:@"Send" forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
}

- (void)rightAction {    
    if (!self.image) return;
    
    // Show Score Screen
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *reasons = [NSMutableDictionary dictionary];
    [reasons setObject:@"Nice Photo! You earned 8 points!" forKey:@"description"];
    NSMutableArray *reasonsItems = [NSMutableArray array];
    [reasonsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Every photo counts", @"reason", @"1", @"point", nil]];
    [reasonsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"First of the day", @"reason", @"3", @"point", nil]];
    [reasonsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"You tagged a Venue", @"reason", @"3", @"point", nil]];
    [reasonsItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"You included your location", @"reason", @"1", @"point", nil]];
    [reasons setObject:reasonsItems forKey:@"items"];
    [data setObject:reasons forKey:@"reasons"];
    
    NSMutableDictionary *leaderboard = [NSMutableDictionary dictionary];
    [leaderboard setObject:@"Leaderboard: You are #3!" forKey:@"description"];
    NSMutableArray *leaderboardItems = [NSMutableArray array];
    [leaderboardItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Peter Shih", @"name", @"160", @"score", nil]];
    [leaderboardItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Peter Shih", @"name", @"160", @"score", nil]];
    [leaderboardItems addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Peter Shih", @"name", @"160", @"score", nil]];
    [leaderboard setObject:leaderboardItems forKey:@"items"];
    [data setObject:leaderboard forKey:@"leaderboard"];
    
    ScoreViewController *vc = [[[ScoreViewController alloc] initWithDictionary:data image:self.image] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
    
    return;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    NSString *accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
    
    // Set parameters
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:accessToken forKey:@"accessToken"];
    
    NSURL *URL = [NSURL URLWithString:API_BASE_URL];
    
    AFHTTPClient *httpClient = [[[AFHTTPClient alloc] initWithBaseURL:URL] autorelease];
    NSData *uploadData = UIImageJPEGRepresentation(self.image, 0.75);
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:[NSString stringWithFormat:@"/users/%@/photos", userId] parameters:parameters constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
        [formData appendPartWithFileData:uploadData name:@"photo" fileName:@"photo.jpg" mimeType:@"image/jpeg"];
    }];
    
    AFHTTPRequestOperation *op = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
    
    [op setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
        NSLog(@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSInteger statusCode = [operation.response statusCode];
        if (statusCode == 200) {
            // success
            id JSON = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *data = [JSON objectForKey:@"data"];
            // Show Score Screen
            ScoreViewController *vc = [[[ScoreViewController alloc] initWithDictionary:data image:self.image] autorelease];
            [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
        } else {
            // Something bad happened
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        // Something bad happened
    }];
    
    NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
    [queue addOperation:op];
}

#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    [super scrollViewDidScroll:scrollView];
//    
//    CGFloat tableHeaderHeight = self.tableView.tableHeaderView.height;
//    
//    CGFloat yOffset = scrollView.contentOffset.y;
//    //    if (yOffset > (tableHeaderHeight * 2)) {
//    //        yOffset = (tableHeaderHeight * 2);
//    //    } else if (yOffset < (-2 * tableHeaderHeight)) {
//    //        yOffset = (-2 * tableHeaderHeight);
//    //    }
//    
//    CGFloat factor = sinf(yOffset / tableHeaderHeight);
//    if (yOffset >= 0) {
//        factor = 0;
//    }
//    self.headerImageView.top = (-1 * (self.headerImageView.height - tableHeaderHeight)) - (factor * 100);
//}

@end
