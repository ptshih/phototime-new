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
- (UIView *)baseBackgroundView {
    UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]] autorelease];
    return bgView;
}

- (UIView *)rowBackgroundViewForIndexPath:(NSIndexPath *)indexPath selected:(BOOL)selected {
    UIImageView *backgroundView = nil;
    if (!selected) {
        backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundCellLeather.png"]] autorelease];
        backgroundView.autoresizingMask = ~UIViewAutoresizingNone;
    }
    return backgroundView;
}

#pragma mark - View
//- (void)loadView {
//  UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0.0, 44.0, 260.0, 416.0)] autorelease];
//  [self setView:view];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    self.tableView.scrollsToTop = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self loadDataSource];
    }];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupTableViewWithFrame:CGRectMake(0.0, self.headerView.height, self.view.width, self.view.height - self.headerView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleNone separatorColor:[UIColor lightGrayColor]];
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
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
    [fr setResultType:NSDictionaryResultType];
    return [fr autorelease];
}

// Subclass MAY OPTIONALLY implement
- (NSString *)frcCacheName {
    return nil;
}

- (NSPredicate *)fetchPredicate {
//    return [NSPredicate predicateWithFormat:@"ownerId = %@", ];
}

- (NSArray *)fetchSortDescriptors {
    return nil;
}

#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        default:
            return [PSCell class];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    id object = [self.frc objectAtIndexPath:indexPath];
}

@end
