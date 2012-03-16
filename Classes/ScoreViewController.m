//
//  ScoreViewController.m
//  Phototime
//
//  Created by Peter Shih on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScoreViewController.h"
#import "ScoreCell.h"
#import "LeaderboardCell.h"

@interface ScoreViewController ()

@property (nonatomic, copy) NSDictionary *dictionary;
@property (nonatomic, retain) UIImage *image;

@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;

@end

@implementation ScoreViewController

@synthesize
dictionary = _dictionary,
image = _image,


leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton;


- (id)initWithDictionary:(NSDictionary *)dictionary image:(UIImage *)image {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.dictionary = dictionary;
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
    self.dictionary = nil;
    self.image = nil;
    [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [self loadDataSource];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper"]];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self setupHeader];
    
    [self setupTableViewWithFrame:CGRectMake(0.0, self.headerView.bottom, self.view.width, self.view.height - self.headerView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleSingleLine separatorColor:[UIColor lightGrayColor]];
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)setupHeader {
    // Setup perma header
    self.headerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 44)] autorelease];
    
    self.leftButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(leftAction)];
    [self.leftButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonLeftBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"IconHomeWhite"] forState:UIControlStateNormal];
    
    self.centerButton = [UIButton buttonWithFrame:CGRectMake(44, 0, self.headerView.width - 88, 44) andStyle:@"navigationTitleLabel" target:self action:@selector(centerAction)];
    [self.centerButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonCenterBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.centerButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.centerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
    [self.centerButton setTitle:@"All Set!" forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    self.rightButton.userInteractionEnabled = NO;
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
}

#pragma mark - State Machine
- (void)loadDataSource {
    [super loadDataSource];
    
    NSMutableArray *items = [NSMutableArray array];
    
    // Section 1 is Score Reasons
    NSDictionary *reasons = [self.dictionary objectForKey:@"reasons"];
    [self.sectionTitles addObject:[reasons objectForKey:@"description"]];
    [items addObject:[reasons objectForKey:@"items"]];
    
    // Section 2 is Leaderboard
    NSDictionary *leaderboard = [self.dictionary objectForKey:@"leaderboard"];
    [self.sectionTitles addObject:[leaderboard objectForKey:@"description"]];
    [items addObject:[leaderboard objectForKey:@"items"]];
    
    self.items = items;
    [self.tableView reloadData];
    [self dataSourceDidLoad];
}

- (void)dataSourceDidLoad {
    [super dataSourceDidLoad];
}

#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [ScoreCell class];
            break;
        case 1:
            return [LeaderboardCell class];
            break;
        default:
            return [PSCell class];
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 29.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *title = [self.sectionTitles objectAtIndex:section];
    
    UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 29.0)] autorelease];
    v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BGTableSection"]];
    
    UILabel *l = [UILabel labelWithText:title style:@"sectionTitleLabel"];
    l.frame = CGRectInset(v.bounds, 8, 0);
    [v addSubview:l];
    
    return v;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeight];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
}

@end
