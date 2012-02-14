//
//  TimelineViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineViewController.h"
#import "TimelineCell.h"

#import "Photo.h"
#import "Timeline.h"

#import "TimelineConfigViewController.h"
#import "GalleryViewController.h"

@interface TimelineViewController (Private)

- (void)snap;

- (void)loadFromRemote;
- (void)refreshOnAppear;
- (void)refetchOnAppear;

@end

@implementation TimelineViewController

@synthesize
moc = _moc,
timeline = _timeline,
leftButton = _leftButton,
rightButton = _rightButton,
shouldRefreshOnAppear = _shouldRefreshOnAppear,
shouldRefetchOnAppear = _shouldRefetchOnAppear;

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
        
        self.shouldRefreshOnAppear = NO;
        self.shouldRefetchOnAppear = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataSource) name:kLoginSucceeded object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshOnAppear) name:kTimelineShouldRefreshOnAppear object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refetchOnAppear) name:kTimelineShouldRefetchOnAppear object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefreshOnAppear object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kTimelineShouldRefetchOnAppear object:nil];
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    RELEASE_SAFELY(_timeline);
    RELEASE_SAFELY(_moc);
    // Views
    [super dealloc];
}

- (void)refreshOnAppear {
    self.shouldRefreshOnAppear = YES;
}

- (void)refetchOnAppear {
    self.shouldRefetchOnAppear = YES;
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
        self.shouldRefetchOnAppear = NO;
        [self reloadDataSource];
    } else if (self.shouldRefetchOnAppear) {
        self.shouldRefetchOnAppear = NO;
        [self loadFromCache];
    }
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupTableViewWithFrame:CGRectMake(0.0, 0.0, self.view.width, self.view.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
    
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease];
    
    // Setup perma left/right buttons
    static CGFloat margin = 8.0;
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 8.0, 28.0, 28.0) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconGearBlack"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.leftButton];
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.tableView.width - 28.0 - margin, 8.0, 28.0, 28.0) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraBlack"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconCameraBlack"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.rightButton];
    
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:0 context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    static CGFloat top = 8.0;
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
    TimelineConfigViewController *vc = [[[TimelineConfigViewController alloc] initWithTimeline:self.timeline] autorelease];
    [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionRight animated:YES];
}

- (void)rightAction {
    GalleryViewController *vc = [[[GalleryViewController alloc] initWithNibName:nil bundle:nil] autorelease];
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
    NSPredicate *membersPredicate = [[NSPredicate predicateWithFormat:@"ownerId IN $members"]            
                                     predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:members forKey:@"members"]];
    
    NSDate *fromDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"fromDate"];
    NSDate *toDate = [NSDate date];
    NSPredicate *datePredicate = [NSPredicate predicateWithFormat:@"(createdAt >= %@) AND (createdAt <= %@)", fromDate, toDate];
    
    NSArray *subpredicates = [NSArray arrayWithObjects:membersPredicate, datePredicate, nil];
    NSPredicate *compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    return compoundPredicate;
}

- (NSArray *)fetchSortDescriptors {
    return [NSArray arrayWithObjects:
            [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO],
            nil];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    [self loadFromRemote];
    [self loadFromCache];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    [self loadFromRemote];
}

#warning NEEDS OPTIMIZING (SLOW)
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
    
    BLOCK_SELF;
    
    // Download remote data
    // Setup the network request
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/timelines/%@/photos", API_BASE_URL, self.timeline.id]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
            [blockSelf dataSourceDidError];
        } else {
            // Create a child context
            NSManagedObjectContext *childContext = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
            [childContext setParentContext:blockSelf.moc];
            
            [childContext performBlock:^{
                NSLog(@"# NSURLConnection Parsing/Serializing on thread: %@", [NSThread currentThread]);
                
                // Serialize to Core Data
                NSDictionary *data = [JSON objectForKey:@"data"];
                NSArray *photos = [data objectForKey:@"photos"];
                if ([photos count] > 0) {
                    [Photo updateOrInsertInManagedObjectContext:childContext entities:photos uniqueKey:@"fbPhotoId"];
                    
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
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [blockSelf loadFromCache];
                    NSLog(@"# NSURLConnection finished on thread: %@", [NSThread currentThread]);
                }];
            }];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [blockSelf dataSourceDidError];
    }];
    [op start];
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
    return [cellClass rowHeightForObject:object atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    //    id object = [self.frc objectAtIndexPath:indexPath];
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
}

@end
