//
//  PhotoDetailViewController.m
//  Phototime
//
//  Created by Peter on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "CommentCell.h"
#import "LikeCell.h"

@interface PhotoDetailViewController ()

@end

@implementation PhotoDetailViewController

@synthesize
photo = _photo,
leftButton = _leftButton,
centerButton = _centerButton,
rightButton = _rightButton,
textField = _textField;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.photo = dictionary;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    self.textField = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.textField = nil;
    self.photo = nil;
    [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    
    [self loadDataSource];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor blackColor];
}

#pragma mark - Config Subviews
- (void)setupSubviews {
    [self.view addSubview:[[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundDarkWood.jpg"]] autorelease]];
    
    [self setupHeader];
    [self setupFooter];
    [self setupTableViewWithFrame:CGRectMake(0.0, 44.0, self.view.width, self.view.height - self.headerView.height - self.footerView.height) style:UITableViewStylePlain separatorStyle:UITableViewCellSeparatorStyleSingleLine separatorColor:RGBCOLOR(200, 200, 200)];
    
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self.textField action:@selector(resignFirstResponder)] autorelease];
    [self.tableView addGestureRecognizer:gr];
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
    [self.centerButton setTitle:@"Likes & Comments" forState:UIControlStateNormal];
    self.centerButton.userInteractionEnabled = NO;
    
    self.rightButton = [UIButton buttonWithFrame:CGRectMake(self.headerView.width - 44, 0, 44, 44) andStyle:nil target:self action:@selector(rightAction)];
    [self.rightButton setBackgroundImage:[UIImage stretchableImageNamed:@"NavButtonRightBlack" withLeftCapWidth:9 topCapWidth:0] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"IconThumbsUpWhite"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:self.leftButton];
    [self.headerView addSubview:self.centerButton];
    [self.headerView addSubview:self.rightButton];
    [self.view addSubview:self.headerView];
}

- (void)setupFooter {
    self.footerView = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 44, self.view.width, 44)] autorelease];
    self.footerView.backgroundColor = RGBCOLOR(200, 200, 200);
    
    self.textField = [[[PSTextField alloc] initWithFrame:CGRectZero withInset:CGSizeMake(8, 8   )] autorelease];
    self.textField.background = [[UIImage imageNamed:@"BGTextInput"] stretchableImageWithLeftCapWidth:6.0 topCapHeight:8.0];
    self.textField.frame = CGRectInset(self.footerView.bounds, 8, 4);
    self.textField.delegate = self;
    self.textField.returnKeyType = UIReturnKeySend;
    self.textField.font = [PSStyleSheet fontForStyle:@"commentField"];
    self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.textField.placeholder = @"Write a comment...";
    [self.textField setEnablesReturnKeyAutomatically:YES];
//    [self.textField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.footerView addSubview:self.textField];
    
    [self.view addSubview:self.footerView];
}

#pragma mark - Actions
- (void)leftAction {
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionRight animated:YES];
}

- (void)centerAction {
}

- (void)rightAction {
    // Like
    self.rightButton.enabled = NO;
    [SVProgressHUD showSuccessWithStatus:@"Liking Photo"];
    NSString *fbid = [self.photo objectForKey:@"fbPhotoId"];
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/likes", fbid]];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"] forKey:@"access_token"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        if (error) {
            self.rightButton.enabled = YES;
            [SVProgressHUD dismissWithError:@"Something Bad Happened"];
        } else {
            [SVProgressHUD dismissWithSuccess:@"Photo Liked"];
        }
    }];
}

#pragma mark - State Machine
- (void)beginRefresh {
    [super beginRefresh];
}

- (void)endRefresh {
    [super endRefresh];
}

- (void)loadDataSource {
    [super loadDataSource];
    
    // Setup Table Header
//    if ([[self.photo objectForKey:@"likes"] notNull]) {
//        NSArray *likes = [[self.photo objectForKey:@"likes"] objectForKey:@"data"];
//        NSString *likeNames = [[likes valueForKey:@"name"] componentsJoinedByString:@", "];
//        NSString *likesText = [NSString stringWithFormat:@"%@ like this photo.", likeNames];
//        
//        UILabel *likesLabel = [UILabel labelWithStyle:@"likesLabel"];
//        likesLabel.text = likesText;
//        CGSize labelSize = [PSStyleSheet sizeForText:likesText width:self.tableView.width - 16 style:@"likesLabel"];
//        
//        UIView *tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width, labelSize.height + 16.0)] autorelease];
//        likesLabel.frame = CGRectInset(tableHeaderView.bounds, 8, 8);
//        [tableHeaderView addSubview:likesLabel];
//        self.tableView.tableHeaderView = tableHeaderView;
//    }
    
    NSMutableArray *items = [NSMutableArray array];
    
    NSMutableArray *likes = [NSMutableArray array];
    [self.sectionTitles addObject:@"Likes"];
    if ([[self.photo objectForKey:@"likes"] notNull]) {
        NSArray *fbLikes = [[self.photo objectForKey:@"likes"] objectForKey:@"data"];
        NSString *likeNames = [[fbLikes valueForKey:@"name"] componentsJoinedByString:@", "];
        NSString *likesText = [NSString stringWithFormat:@"%@ like this photo.", likeNames];
        [likes addObject:likesText];
    }
    [items addObject:likes];
    
    NSMutableArray *comments = [NSMutableArray array];
    [self.sectionTitles addObject:@"Comments"];
    if ([[self.photo objectForKey:@"comments"] notNull]) {
        [comments addObjectsFromArray:[[self.photo objectForKey:@"comments"] objectForKey:@"data"]];
    }
    [items addObject:comments];
    
    [self dataSourceShouldLoadObjects:items animated:NO];
    [self dataSourceDidLoad];
//    [self loadDataSourceFromRemoteUsingCache:NO];
}

- (void)reloadDataSource {
    [super reloadDataSource];
    
//    [self loadDataSourceFromRemoteUsingCache:NO];
}

#pragma mark - TableView
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return [LikeCell class];
            break;
        case 1:
            return [CommentCell class];
            break;
        default:
            return [CommentCell class];
            break;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 29.0;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSString *title = [self.sectionTitles objectAtIndex:section];
//    
//    UIView *v = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.width, 29.0)] autorelease];
//    v.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BGTableSection"]];
//    
//    UILabel *l = [UILabel labelWithText:title style:@"sectionTitleLabel"];
//    l.frame = CGRectInset(v.bounds, 8, 0);
//    [v addSubview:l];
//    
//    return v;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    Class cellClass = [self cellClassAtIndexPath:indexPath];
    return [cellClass rowHeightForObject:object atIndexPath:indexPath forInterfaceOrientation:self.interfaceOrientation];
}

- (void)tableView:(UITableView *)tableView configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    id object = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell tableView:tableView fillCellWithObject:object atIndexPath:indexPath];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (![textField isEditing]) {
        [textField becomeFirstResponder];
    }
    
    if ([textField.text length] > 0) {
        // Submit the comment
        [SVProgressHUD showSuccessWithStatus:@"Adding Comment"];
        NSString *fbid = [self.photo objectForKey:@"fbPhotoId"];
        NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/comments", fbid]];
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"fbAccessToken"] forKey:@"access_token"];
        [parameters setObject:textField.text forKey:@"message"];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
            if (error) {
                self.rightButton.enabled = YES;
                [SVProgressHUD dismissWithError:@"Something Bad Happened"];
            } else {
                [SVProgressHUD dismissWithSuccess:@"Comment Added"];
                [textField resignFirstResponder];
                textField.text = nil;
            }
        }];
        return NO;
    } else {
        [textField resignFirstResponder];
        return YES;
    }
}

//- (void)textFieldValueChanged:(UITextField *)textField {
//}


#pragma mark - Keyboard Notifications
- (void)keyboardWillShow:(NSNotification *)notification {
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationOptions animationOptions = animationCurve << 16; // convert
    
    NSValue *frameValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [frameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.tableView.height -= keyboardHeight;
        self.footerView.top -= keyboardHeight;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Get animation info from userInfo
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationOptions animationOptions = animationCurve << 16; // convert
    
    NSValue *frameValue = [[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [frameValue CGRectValue];
    CGFloat keyboardHeight = keyboardFrame.size.height;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        self.tableView.height += keyboardHeight;
        self.footerView.top += keyboardHeight;
    } completion:^(BOOL finished) {
        
    }];
}

@end
