//
//  GalleryViewController.m
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GalleryViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>

@implementation GalleryViewController

@synthesize
collectionView = _collectionView,
assets = _assets;


#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.assets = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidUnload {
    self.collectionView = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.collectionView = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeader];
    [self setupSubviews];
    
    // Load from ALAssets
    BLOCK_SELF;
    ALAssetsLibrary *library = [[[ALAssetsLibrary alloc] init] autorelease];
    
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
//                    ALAssetRepresentation *rep = result.defaultRepresentation;
                    NSMutableDictionary *assetDict = [NSMutableDictionary dictionary];
                    UIImage *thumbnail = [UIImage imageWithCGImage:result.thumbnail];
                    [assetDict setObject:thumbnail forKey:@"thumbnail"];
                    
                    [blockSelf.assets addObject:assetDict];
                }
            }];
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [blockSelf.collectionView reloadViews];
            }];
        }
    } failureBlock:^(NSError *error) {
        
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[[[UIAlertView alloc] initWithTitle:@"Doesn't Work Yet" message:@"Eventually this will let you choose multiple photos from your Camera Roll to directly upload to Facebook." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease] show];
}

#pragma mark - Config Subviews
- (void)setupHeader {
    UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.userInteractionEnabled = YES;
    
    NSString *title = @"Select Photos";
    
    UILabel *titleLabel = [UILabel labelWithText:title style:@"timelineSectionTitle"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    // Setup perma left/right buttons
    static CGFloat margin = 10.0;
    UIButton *leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 8.0, 28.0, 28.0) andStyle:nil target:self action:@selector(leftAction)];
    [leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateHighlighted];
    [headerView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithFrame:CGRectMake(headerView.width - 28.0 - margin, 8.0, 28.0, 28.0) andStyle:nil target:self action:@selector(rightAction)];
    [rightButton setImage:[UIImage imageNamed:@"IconNextBlack"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"IconNextBlack"] forState:UIControlStateHighlighted];
    [headerView addSubview:rightButton];
    
    [self.view addSubview:headerView];
}

- (void)setupSubviews {
    self.collectionView = [[[PSCollectionView alloc] initWithFrame:CGRectMake(0, 44.0, self.view.width, self.view.height - 44.0)] autorelease];
    self.collectionView.collectionViewDelegate = self;
    self.collectionView.collectionViewDataSource = self;
    self.collectionView.rowHeight = 96.0;
    self.collectionView.numCols = 3;
    [self.view addSubview:self.collectionView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)rightAction {

}

#pragma mark - PSCollectionViewDelegate
- (NSInteger)numberOfViewsInCollectionView:(PSCollectionView *)collectionView {
    return [self.assets count];
}

- (UIView *)collectionView:(PSCollectionView *)collectionView viewAtIndex:(NSInteger)index {
    NSDictionary *assetDict = [self.assets objectAtIndex:index];
    UIView *v = [self.collectionView dequeueReusableView];
    if (!v) {
        v = [[[UIImageView alloc] initWithFrame:CGRectZero] autorelease];
        v.frame = CGRectMake(0, 0, 96, 96);
    }
    [(UIImageView *)v setImage:[assetDict objectForKey:@"thumbnail"]];
    
    return v;

}

@end
