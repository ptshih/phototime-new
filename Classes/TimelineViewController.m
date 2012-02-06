//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineCell.h"
#import "CameraViewController.h"
#import "PreviewViewController.h"
#import "AFNetworking.h"

#import "Photo.h"
#import "Timeline.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>

@implementation TimelineViewController (CameraDelegateMethods)

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self.psNavigationController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    // Handle a still image capture
    if (CFStringCompare((CFStringRef)mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        
        PreviewViewController *pvc = nil;
        
        // First check if image was taken from camera or library
        if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
            // Taken with camera
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSDictionary *metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
            pvc = [[PreviewViewController alloc] initWithImage:image metadata:metadata];
        } else {
            // Picked from library
            UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
            NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
            if (assetURL) {
                pvc = [[PreviewViewController alloc] initWithImage:image assetURL:assetURL];
            }
        }
        
        if (pvc) {
            pvc.psNavigationController = self.psNavigationController;
            [picker pushViewController:pvc animated:YES];
            [pvc release];
        } else {
            [self.psNavigationController popViewControllerAnimated:YES];
        }
    } else {
        [self.psNavigationController popViewControllerAnimated:YES];
    }
}

@end

@interface TimelineViewController (Private)

- (void)snap;

- (void)loadFromRemote;
- (void)loadFromSavedPhotos;

@end

@implementation TimelineViewController

@synthesize
timeline = _timeline,
leftButton = _leftButton,
rightButton = _rightButton,
shouldFetch = _shouldFetch;

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
        self.shouldFetch = YES;
    }
    return self;
}

- (void)viewDidUnload {
    // Views
    [super viewDidUnload];
}

- (void)dealloc {
    
    // Views
    [super dealloc];
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
//    [self setupHeader];
    [self setupSubviews];
    
    [self setupPullRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [self loadDataSource];
    }
}

#pragma mark - Config Subviews
- (void)setupHeader {
    static CGFloat margin = 10.0;
    UIImageView *headerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)];
    headerView.userInteractionEnabled = YES;
    [headerView setImage:[UIImage stretchableImageNamed:@"BackgroundNavigationBar" withLeftCapWidth:0.0 topCapWidth:1.0]];
    
    UIButton *leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(test)];
    [leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"IconBackGray"] forState:UIControlStateHighlighted];
    [headerView addSubview:leftButton];
    
    UILabel *titleLabel = [UILabel labelWithText:@"Timeline" style:@"navigationTitleLabel"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    UIButton *rightButton = [UIButton buttonWithFrame:CGRectMake(headerView.width - 28.0 - margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(snap)];
    [rightButton setImage:[UIImage imageNamed:@"IconCameraBlack"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"IconCameraGray"] forState:UIControlStateHighlighted];
    [headerView addSubview:rightButton];
    
    [self setHeaderView:headerView];
    [headerView release];
}

- (void)setupSubviews {
    [self setupTableViewWithFrame:CGRectMake(0.0, self.headerView.height, self.view.width, self.view.height - self.headerView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
    
    // Setup perma left/right buttons
    static CGFloat margin = 10.0;
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(test)];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackBlack"] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconBackGray"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.tableView.width - 28.0 - margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(snap)];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraBlack"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraGray"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.rightButton];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    static CGFloat top = 6.0;
    if ([object isEqual:self.tableView]) {
        CGPoint contentOffset = self.tableView.contentOffset;
        CGFloat y = contentOffset.y;
        if (y < 0) {
            self.leftButton.top = top - y;
            self.rightButton.top = top - y;
        } else {
            self.leftButton.top = top;
            self.rightButton.top = top;
        }
    }
}

#pragma mark - Actions
- (void)test {
    BOOL sb = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:!sb];
}

- (void)snap {
    UIActionSheet *as = nil;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        as = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo", @"Choose From Library", nil] autorelease];
    } else {
        as = [[[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Choose From Library", nil] autorelease];
    }
    [as showInView:[APP_DELEGATE window]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex) return;
    //  CameraViewController *cvc = [[CameraViewController alloc] initWithNibName:nil bundle:nil];
    //  [self.psNavigationController pushViewController:cvc animated:YES];
    //  [cvc release];
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        if (buttonIndex == 0) {
            sourceType = UIImagePickerControllerSourceTypeCamera;
        }
    }
    
    //  [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeImage];
    [self.psNavigationController pushViewController:imagePicker animated:YES];
    [imagePicker release];
}

#pragma mark - Core Data
- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:[Photo entityInManagedObjectContext:self.moc]];
    [fr setPredicate:[self fetchPredicate]];
    [fr setSortDescriptors:[self fetchSortDescriptors]];
    [fr setReturnsObjectsAsFaults:NO];
    [fr setResultType:NSDictionaryResultType];
    return [fr autorelease];
}

- (NSPredicate *)fetchPredicate {
    // [NSArray arrayWithObjects:@"548430564", @"13704812", @"2602152", nil]
    NSArray *members = [self.timeline.members componentsSeparatedByString:@","];
    return [[NSPredicate predicateWithFormat:@"ownerId IN $members"]            
            predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:members forKey:@"members"]];
}

- (NSArray *)fetchSortDescriptors {
    return [NSArray arrayWithObjects:
            [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO],
            nil];
}

- (NSString *)sectionNameKeyPath {
    return @"dateString";
}

#pragma mark - State Machine
- (BOOL)dataIsAvailable {
    return YES;
}

- (void)fetchDataSource {
    if (self.shouldFetch) {
        self.shouldFetch = NO;
    } else {
        return;
    }
    
    // We always refetch from the core data store first
    NSManagedObjectContext *childContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
    [childContext setParentContext:self.moc];
    
    [childContext performBlock:^{
        NSError *fetchError = nil;
        NSArray *fetchedEntities = [childContext executeFetchRequest:self.fetchRequest error:&fetchError];
        
        NSMutableArray *items = [NSMutableArray array];
        
        // After the fetch, we want to split the entities by date (ignoring time)
        // [fetchedEntities valueForKeyPath:@"@distinctUnionOfObjects.formattedDate"]
        [_sectionTitles addObjectsFromArray:[fetchedEntities valueForKeyPath:@"@distinctUnionOfObjects.formattedDate"]];
        
        __block NSString *lastDate = nil;
        [fetchedEntities enumerateObjectsUsingBlock:^(NSDictionary *entity, NSUInteger idx, BOOL *stop) {
            NSString *currentDate = [entity objectForKey:@"formattedDate"];
            if ([currentDate isEqualToString:lastDate]) {
                // Add to existing section
                [[[[items lastObject] lastObject] objectForKey:@"photos"] addObject:entity];
            } else {
                // Create a new section
                lastDate = currentDate;
                NSMutableArray *section = [NSMutableArray array];
                NSMutableDictionary *row = [NSMutableDictionary dictionary];
                [row setObject:currentDate forKey:@"formattedDate"];
                [row setObject:[NSMutableArray array] forKey:@"photos"];
                [[row objectForKey:@"photos"] addObject:entity];
                [section addObject:row];
                [items addObject:section];
            }
        }];
        
        [childContext.parentContext performBlock:^{
            [self dataSourceShouldLoadObjects:items shouldAnimate:NO];
        }];
    }];
}

- (void)loadDataSource {
    [super loadDataSource];
    
    [self fetchDataSource];
    [self loadFromRemote];
    
    
//    [self loadFromSavedPhotos];
    
    //  NSString *jpegPath = [[NSBundle mainBundle] pathForResource:@"bubbles" ofType:@"jpg"];
    //  NSData *jpegData = [NSData dataWithContentsOfFile:jpegPath];
    
    //  UIImage *jpeg = [UIImage imageWithData:jpegData];
    
    //  CGImageSourceRef ref = CGImageSourceCreateWithData((CFDataRef)jpegData, NULL);
    //  NSDictionary *dict = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(ref
    //                                                                          , 0, NULL);
    //  NSDictionary *exif = [dict objectForKey:(NSString *)kCGImagePropertyExifDictionary];
    //  NSDictionary *gps = [dict objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
    //  
    //  
    //  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"albums" ofType:@"json"];
    //  NSData *fixtureData = [NSData dataWithContentsOfFile:filePath];
    //  NSDictionary *response = [fixtureData objectFromJSONData];
    //
    //  NSArray *items = [response objectForKey:@"data"];
    
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

- (void)loadFromRemote {
    self.shouldFetch = YES;
    
    BLOCK_SELF; // Used for accessing MOC
    
    // This block is called after parsing/serializing and should always called on the main queue
    void (^finishBlock)();
    finishBlock = ^() {
        // Call any UI updates on the main queue
        // By now we can guarantee that our Core Data dataSource is ready
        [self fetchDataSource];
        NSLog(@"# NSURLConnection finishBlock completed on thread: %@", [NSThread currentThread]);
    };
    
    // This block is passed in to NSURLConnection equivalent to a finish block, it is run inside the provided operation queue
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
                    __block id results = nil;
                    
                    // Create a child context
                    NSManagedObjectContext *childContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
                    [childContext setParentContext:blockSelf.moc];
                    
                    // Parse JSON and/or serialize to Core Data
                    [childContext performBlock:^{
                        NSLog(@"# Parsing JSON on thread: %@", [NSThread currentThread]);
                        // Parse JSON if Content-Type is "application/json"
                        NSString *contentType = [[httpResponse allHeaderFields] objectForKey:@"Content-Type"];
                        BOOL isJSON = contentType ? [contentType rangeOfString:@"application/json"].location != NSNotFound : NO;
                        if (isJSON) {
                            NSError *jsonError = nil;
                            results = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
                        } else {
                            results = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
                        }
                        
                        // Serialize to Core Data
                        NSDictionary *data = [results objectForKey:@"data"];
                        NSArray *photos = [data objectForKey:@"photos"];
                        if ([photos count] > 0) {
                            NSLog(@"# Serializing Core Data on thread: %@", [NSThread currentThread]);
                            [Photo updateOrInsertInManagedObjectContext:childContext entities:photos uniqueKey:@"id"];
                            
                            NSError *error = nil;
                            [childContext save:&error];
                            [blockSelf.moc save:nil];
                        }
                        
                        
                        // Make sure to call the finish block on the main queue
                        [[NSOperationQueue mainQueue] addOperationWithBlock:finishBlock];
                    }];
                } else {
                    // Failed, read status code
                    NSLog(@"# NSURLConnection failed with status code: %d", statusCode);
                    [self dataSourceDidError];
                }
            }
        } else {
            // This is equivalent to a connection failure block
            NSLog(@"# NSURLConnection failed with error: %@", error);
            [self dataSourceDidError];
        }
    };
    
    // Setup the network request
    NSDictionary *parameters = [NSDictionary dictionary];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/photos", API_BASE_URL, self.timeline.id]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    // NOTE: We should generally run the completionHandler on the mainQueue. It can optionally be run on any queue if required
    //    NSOperationQueue *backgroundQueue = [[[NSOperationQueue alloc] init] autorelease];
    //    NSOperationQueue *backgroundQueue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
}

- (void)loadFromSavedPhotos {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate just the photos and videos group by using ALAssetsGroupSavedPhotos.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        if (group) {
            // Within the group enumeration block, filter to enumerate just photos.
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            
            NSMutableArray *items = [NSMutableArray array];
            
            NSMutableArray *photos = [NSMutableArray array];
            
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop){
                if (result) {
                    ALAssetRepresentation *rep = [result defaultRepresentation];
                    
                    NSURL *assetURL = [rep url];
                    // NOTE: it is expensive to read out the metadata!!!
                    //          NSDictionary *metadata = [rep metadata];
                    
#warning debug
                    //          if ([assetURL.absoluteString isEqualToString:@"assets-library://asset/asset.JPG?id=E6292758-C2C3-4077-A7AD-ED11C4BACF7A&ext=JPG"]) {
                    //            NSLog(@"debug");
                    //          }
                    
                    // Read out asset properties
                    //          NSNumber *assetWidth = [metadata objectForKey:(NSString *)kCGImagePropertyPixelWidth];
                    //          NSNumber *assetHeight = [metadata objectForKey:(NSString *)kCGImagePropertyPixelHeight];
                    NSDate *assetDate = [result valueForProperty:ALAssetPropertyDate];
                    CLLocation *assetLocation = [result valueForProperty:ALAssetPropertyLocation];
                    
                    // EXIF Optional
                    //          NSDictionary *exif = [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                    //          NSNumber *exifWidth = nil;
                    //          NSNumber *exifHeight = nil;
                    //          NSMutableString *exifDatetime = nil;
                    //          if (exif) {
                    //            // Width
                    //            exifWidth = [exif objectForKey:(NSString *)kCGImagePropertyExifPixelXDimension];
                    //            exifHeight = [exif objectForKey:(NSString *)kCGImagePropertyExifPixelYDimension];
                    //            
                    //            // Datetime
                    //            NSString *unformattedDateAsString = [exif objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
                    //            if (unformattedDateAsString) {
                    //              exifDatetime = [[unformattedDateAsString mutableCopy] autorelease];
                    //              //make sure the date stored in the metadata is not nil, and contains a meaningful date
                    //              if(exifDatetime && ![exifDatetime isEqualToString:@""] && ![exifDatetime isEqualToString:@"0000:00:00 00:00:00"]) {
                    //                // the date (not the time) part of the string needs to contain dashes, not colons, for NSDate to read it correctly
                    //                [exifDatetime replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, 10)]; //the first 10 characters are the date part
                    //                //the EXIF spec does not allow the time zone to be saved with the date,
                    //                // so we must assume the camera’s clock is set to the same time zone as the computer’s.
                    //                [exifDatetime appendString:@" +0000"];
                    //              }
                    //            }
                    //          }
                    
                    // GPS
                    //          NSDictionary *gps = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
                    //          
                    //          NSString *exifLatitude = nil;
                    //          NSString *exifLongitude = nil;
                    //          if (gps) {
                    //            exifLatitude = [gps objectForKey:(NSString *)kCGImagePropertyGPSLatitude];
                    //            exifLongitude = [gps objectForKey:(NSString *)kCGImagePropertyGPSLongitude];
                    //          }
                    
                    // Build array of PTPhoto based on Assets
                    // Pass into dataSourcedidLoadObjects:
                    NSMutableDictionary *photo = [[NSMutableDictionary alloc] init];
                    [photo setObject:assetURL.absoluteString forKey:@"source"];
                    if (assetDate) [photo setObject:assetDate forKey:@"timestamp"];
                    if (assetLocation) [photo setObject:assetLocation forKey:@"location"];
                    //          if (assetWidth) [photo setObject:assetWidth forKey:@"width"];
                    //          if (assetHeight) [photo setObject:assetHeight forKey:@"height"];
                    
                    //          NSLog(@"Adding photo: %@", photo);
                    [photos addObject:photo];
                    [photo release];
                }        
            }];
            
            NSArray *sortedPhotos = [photos sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]]];
            
            unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
            
            NSDate *currentDate = nil;
            CLLocation *currentLocation = nil;
            for (NSDictionary *photo in sortedPhotos) {
                NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:[photo objectForKey:@"timestamp"]];
                NSDate *photoDate = [[NSCalendar currentCalendar] dateFromComponents:components];
                
                CLLocation *photoLocation = [photo objectForKey:@"location"];
                currentLocation = photoLocation;
                
                // Begin a new day if no currentDate set or if photo date doesn't match
                if (!currentDate || (![currentDate isEqualToDate:photoDate])) {
                    currentDate = photoDate;
                    [items addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:currentDate, @"timestamp", currentLocation, @"location", nil]];
                    [[items lastObject] setObject:[NSMutableArray arrayWithObject:photo] forKey:@"photos"];
                } else {
                    // If photo is still part of current day, add to array
                    [[[items lastObject] objectForKey:@"photos"] addObject:photo];
                }
            }
            
            [self dataSourceShouldLoadObjects:[NSMutableArray arrayWithObject:items] shouldAnimate:NO];
        }
        
    } failureBlock: ^(NSError *error) {
        NSLog(@"No groups");
    }];
    [library release];
}

#pragma mark - TableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.userInteractionEnabled = YES;
    
    UIImageView *hl = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:2 topCapWidth:0]] autorelease];
    hl.frame = CGRectMake(10.0, headerView.height - 1, headerView.width - 20.0, 1.0);
    [headerView addSubview:hl];
    
    NSString *title = [self.items count] > 0 ? [[[self.items objectAtIndex:section] objectAtIndex:0] objectForKey:@"formattedDate"] : @"Timeline";
    
    UILabel *titleLabel = [UILabel labelWithText:title style:@"navigationTitleLabel"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    return headerView;
    
    
    
//    UIView *hv = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, 32.0)] autorelease];
//    hv.backgroundColor = [UIColor whiteColor];
//    
//    CGFloat width = hv.width - 20.0;
//    
//    UILabel *dateLabel = [UILabel labelWithText:[[[self.items objectAtIndex:section] objectAtIndex:0] objectForKey:@"formattedDate"] style:@"timelineTitle"];
//    dateLabel.backgroundColor = [UIColor whiteColor];
//    dateLabel.frame = CGRectMake(10.0, 5.0, width, 20.0);
//    [hv addSubview:dateLabel];
//    
//    UIImageView *hl = [[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:2 topCapWidth:0]];
//    hl.frame = CGRectMake(10.0, hv.height - 1, width, 1.0);
//    [hv addSubview:hl];
//    return hv;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    return [_sectionTitles objectAtIndex:section];
//}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.items count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.items objectAtIndex:section] count];
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
    return [cellClass rowHeightForObject:object forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
//    id object = [self.frc objectAtIndexPath:indexPath];
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
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

@end
