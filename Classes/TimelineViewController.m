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

#import "PSTimelineConfigViewController.h"
#import "MenuViewController.h"

#import "Photo.h"
#import "Timeline.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <CoreLocation/CoreLocation.h>

@implementation TimelineViewController (CameraDelegateMethods)

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [(PSNavigationController *)self.parentViewController popViewControllerAnimated:YES];
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
            [picker pushViewController:pvc animated:YES];
            [pvc release];
        } else {
            [(PSNavigationController *)self.parentViewController popViewControllerAnimated:YES];
        }
    } else {
        [(PSNavigationController *)self.parentViewController popViewControllerAnimated:YES];
    }
}

@end

@interface TimelineViewController (Private)

- (void)snap;

- (void)loadFromRemote;

@end

@implementation TimelineViewController

@synthesize
moc = _moc,
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
        self.moc = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
        [self.moc setPersistentStoreCoordinator:[PSCoreDataStack persistentStoreCoordinator]];
        
        self.shouldFetch = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    // Views
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLoginSucceeded object:nil];
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    RELEASE_SAFELY(_timeline);
    RELEASE_SAFELY(_moc);
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
    [self setupSubviews];
    [self setupPullRefresh];
    self.tableView.contentOffset = self.contentOffset;
    
    // Load
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupTableViewWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
    
    // Setup perma left/right buttons
    static CGFloat margin = 10.0;
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setImage:[UIImage imageNamed:@"IconMore"] forState:UIControlStateNormal];
    //    [self.leftButton setImage:[UIImage imageNamed:@"IconMore"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.tableView.width - 28.0 - margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateHighlighted];
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
- (void)leftAction {
    //    BOOL sb = [UIApplication sharedApplication].statusBarHidden;
    //    [[UIApplication sharedApplication] setStatusBarHidden:!sb];
    MenuViewController *mvc = [[[MenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:mvc direction:PSNavigationControllerDirectionRight animated:YES];
}

- (void)rightAction {
    PSTimelineConfigViewController *vc = [[[PSTimelineConfigViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionLeft animated:YES];
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

#pragma mark - State Machine
- (void)loadDataSource {
    [self loadFromRemote];
    [self loadFromCache];
}

- (void)reloadDataSource {
    if (self.reloading) return;
    [self loadFromRemote];
}

- (void)loadFromCache {
    BLOCK_SELF;
    
    NSManagedObjectContext *childContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
    [childContext setParentContext:self.moc];
    
    [childContext performBlock:^{
        NSError *error = nil;
        NSArray *fetchedEntities = [childContext executeFetchRequest:self.fetchRequest error:&error];
        
        NSMutableArray *sectionTitles = [NSMutableArray array];
        NSMutableArray *items = [NSMutableArray array];
        
        __block BOOL isNewSection = NO;
        __block NSInteger i = 0; // counter for photos per row
        __block NSString *lastDate = nil;
        [fetchedEntities enumerateObjectsUsingBlock:^(NSDictionary *entity, NSUInteger idx, BOOL *stop) {
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
            blockSelf.sectionTitles = sectionTitles;
            [blockSelf dataSourceShouldLoadObjects:items animated:NO];
        }];
    }];
}

- (void)loadFromRemote {
    [self beginRefresh];

    BLOCK_SELF;
    
    void (^finishBlock)();
    finishBlock = ^() {
        [self endRefresh];
        [self loadFromCache];
        NSLog(@"# NSURLConnection finished on thread: %@", [NSThread currentThread]);
    };
    
    void (^failureBlock)();
    failureBlock = ^() {
        [self endRefresh];
        NSLog(@"# NSURLConnection failed on thread: %@", [NSThread currentThread]);
    };
    
    void (^handlerBlock)(NSURLResponse *response, NSData *data, NSError *error);
    handlerBlock = ^(NSURLResponse *response, NSData *data, NSError *error) {
        NSLog(@"# NSURLConnection completed on thread: %@", [NSThread currentThread]);
        
        // First check error and data
        if (!error && data) {
            // Check the HTTP Status code if available
            if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                NSInteger statusCode = [httpResponse statusCode];
                if (statusCode == 200) {
                    // Create a child context
                    NSManagedObjectContext *childContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
                    [childContext setParentContext:blockSelf.moc];
                    
                    [childContext performBlock:^{
                        NSLog(@"# NSURLConnection Parsing/Serializing on thread: %@", [NSThread currentThread]);
                        id results = [self parseData:data httpResponse:httpResponse];
                        
                        // Serialize to Core Data
                        NSDictionary *data = [results objectForKey:@"data"];
                        NSArray *photos = [data objectForKey:@"photos"];
                        if ([photos count] > 0) {
                            [Photo updateOrInsertInManagedObjectContext:childContext entities:photos uniqueKey:@"fbId"];
                            
                            NSError *error = nil;
                            [childContext save:&error];
                            
                            if ([blockSelf.moc hasChanges]) {
                                [blockSelf.moc performBlock:^{
                                    NSError *error = nil;
                                    [blockSelf.moc save:&error];
                                }];
                            }
                        }
                        
                        // Make sure to call the finish block on the main queue
                        [[NSOperationQueue mainQueue] addOperationWithBlock:finishBlock];
                    }];
                } else {
                    // Failed, read status code
                    [[NSOperationQueue mainQueue] addOperationWithBlock:failureBlock];
                }
            }
        } else {
            // This is equivalent to a connection failure block
            [[NSOperationQueue mainQueue] addOperationWithBlock:failureBlock];
        }
    };
    
    // Setup the network request
    NSDictionary *parameters = [NSDictionary dictionary];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/photos", API_BASE_URL, self.timeline.id]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:parameters];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
}


#pragma mark - TableView
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.userInteractionEnabled = YES;
    
    //    NSString *title = [self.items count] > 0 ? [[[self.items objectAtIndex:section] objectAtIndex:0] objectForKey:@"formattedDate"] : @"Timeline";
    NSString *title = [self.sectionTitles count] > 0 ? [self.sectionTitles objectAtIndex:section] : @"Timeline";
    
    UILabel *titleLabel = [UILabel labelWithText:title style:@"timelineSectionTitle"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44.0;
}

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
    return [cellClass rowHeightForObject:object forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    //    id object = [self.frc objectAtIndexPath:indexPath];
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell fillCellWithObject:object];
}

#pragma mark - Blah
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
    [(PSNavigationController *)self.parentViewController pushViewController:imagePicker animated:YES];
    [imagePicker release];
}

@end
