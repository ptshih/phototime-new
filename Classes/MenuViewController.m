//
//  MenuViewController.m
//  OSnap
//
//  Created by Peter Shih on 11/22/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "MenuViewController.h"
#import "TimelineViewController.h"
#import "Timeline.h"
#import "MenuCell.h"

@implementation MenuViewController

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

//- (UIView *)rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
//    UIImageView *backgroundView = nil;
//    if (!selected) {
//        backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCellLeather.png"]] autorelease];
//        backgroundView.autoresizingMask = ~UIViewAutoresizingNone;
//    }
//    return backgroundView;
//}

#pragma mark - View
//- (void)loadView {
//  UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 260.0, 416.0)] autorelease];
//  [self setView:view];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupHeader];
    [self setupSubviews];
    
    [self loadDataSource];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self loadDataSource];
//    }];
}

#pragma mark - Config Subviews
- (void)setupHeader {
    UIImageView *headerView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44.0)] autorelease];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.userInteractionEnabled = YES;
    
    NSString *title = @"Timelines";
    
    UILabel *titleLabel = [UILabel labelWithText:title style:@"timelineSectionTitle"];
    titleLabel.frame = CGRectMake(0, 0, headerView.width - 80.0, headerView.height);
    titleLabel.center = headerView.center;
    [headerView addSubview:titleLabel];
    
    // Setup perma left/right buttons
    static CGFloat margin = 10.0;
    UIButton *leftButton = [UIButton buttonWithFrame:CGRectMake(margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(leftAction)];
    [leftButton setImage:[UIImage imageNamed:@"IconMore"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"IconMore"] forState:UIControlStateHighlighted];
    [headerView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithFrame:CGRectMake(headerView.width - 28.0 - margin, 6.0, 28.0, 32.0) andStyle:nil target:self action:@selector(rightAction)];
    [rightButton setImage:[UIImage imageNamed:@"IconClockBlack"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"IconClockBlack"] forState:UIControlStateHighlighted];
    [headerView addSubview:rightButton];
    
    self.headerView = headerView;
}

- (void)setupSubviews {
    [self setupTableViewWithFrame:CGRectMake(0.0, self.headerView.height, self.view.width, self.view.height - self.headerView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
}

#pragma mark - Actions
- (void)leftAction {
}

- (void)rightAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionLeft animated:YES];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    NSError *error = nil;
    [self.frc performFetch:&error];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

#pragma mark - Core Data
// Subclass MUST implement
- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fr = [[NSFetchRequest alloc] init];
    [fr setEntity:[Timeline entityInManagedObjectContext:self.moc]];
    [fr setPredicate:[self fetchPredicate]];
    [fr setSortDescriptors:[self fetchSortDescriptors]];
    [fr setReturnsObjectsAsFaults:NO];
    //    [fr setResultType:NSDictionaryResultType];
    return [fr autorelease];
}

// Subclass MAY OPTIONALLY implement
- (NSString *)frcCacheName {
    return @"Menu#Timelines";
}

- (NSPredicate *)fetchPredicate {
    NSDictionary *fbMe = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbMe"];
    NSString *userId = [fbMe objectForKey:@"id"];
    return [NSPredicate predicateWithFormat:@"ownerId = %@", userId];
}

- (NSArray *)fetchSortDescriptors {
    return [NSArray arrayWithObjects:
            [NSSortDescriptor sortDescriptorWithKey:@"lastSynced" ascending:NO],
            nil];
}

#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [MenuCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    id object = [self.frc objectAtIndexPath:indexPath];
    return [cellClass rowHeightForObject:object forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id object = [self.frc objectAtIndexPath:indexPath];
    [cell fillCellWithObject:object];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    id object = [self.frc objectAtIndexPath:indexPath];
    TimelineViewController *tvc = [[[TimelineViewController alloc] initWithTimeline:object] autorelease];
    
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionUp animated:YES];
}

@end
