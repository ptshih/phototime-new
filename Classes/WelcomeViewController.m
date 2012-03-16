//
//  WelcomeViewController.m
//  OSnap
//
//  Created by Peter Shih on 11/23/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "WelcomeViewController.h"
#import "TimelineViewController.h"

@interface WelcomeViewController (Private)

- (void)loginIfNecessary;
- (void)loginDidSucceed:(BOOL)animated;
- (void)loginDidNotSucceed;

//- (void)downloadTimelines;

// Notifications
- (void)fbDidBegin;
- (void)fbDidLogin;
- (void)fbDidNotLogin;

/**
 Uploads a FB access token to our server
 */
- (void)uploadAccessToken;
@end

@implementation WelcomeViewController

#pragma mark - Init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidBegin) name:kPSFacebookCenterDialogDidBegin object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin) name:kPSFacebookCenterDialogDidSucceed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin) name:kPSFacebookCenterDialogDidFail object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidBegin object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidFail object:nil];
    [super dealloc];
}

#pragma mark - View Config
//- (UIColor *)baseBackgroundColor {
//    return [UIColor whiteColor];
//}

- (UIView *)baseBackgroundView {
  UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundDarkWood.jpg"]] autorelease];
  return bgView;
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *logo = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LogoLargeWhite"]] autorelease];
    logo.top = 20.0;
    logo.left = 33.0;
    [self.view addSubview:logo];
    
    // Add a login button
    UIButton *loginButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 254, 59) andStyle:nil target:self action:@selector(login)];
    [loginButton setImage:[UIImage imageNamed:@"ButtonFacebook"] forState:UIControlStateNormal];
    [loginButton setImage:[UIImage imageNamed:@"ButtonFacebookHighlighted"] forState:UIControlStateHighlighted];
    loginButton.top = logo.bottom + 20.0;
    loginButton.left = 33.0;
    [self.view addSubview:loginButton];
    
    // Add disclaimer
    UILabel *disclaimer = [UILabel labelWithText:@"We use facebook to find your friends.\r\nWe don't post anything to your timeline." style:@"welcomeDisclaimerLabel"];
    [self.view addSubview:disclaimer];
    CGSize dSize = [disclaimer sizeForLabelInWidth:254];
    disclaimer.width = dSize.width;
    disclaimer.height = dSize.height;
    disclaimer.top = loginButton.bottom + 20.0;
    disclaimer.left = floorf((self.view.width - disclaimer.width) / 2);
    
    UIImageView *postit = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundPostIt"]] autorelease];
    postit.top = disclaimer.bottom + 20.0;
    postit.left = 33.0;
    [self.view addSubview:postit];
    
    UILabel *note = [UILabel labelWithText:@"Discover photos from your friends by choosing a time period.\r\n\r\nPhototime will combine photos from you and your friends to create a shared visual timeline.\r\n\r\nLovingly made in NYC" style:@"welcomeNoteLabel"];
    note.frame = CGRectInset(postit.bounds, 24, 16);
    [postit addSubview:note];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Actions
- (void)login {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"welcome#loginButtonPressed"];
    [self loginIfNecessary];
}

#pragma mark - Notifications
- (void)fbDidBegin {
    [SVProgressHUD showWithStatus:@"Logging in to Facebook" maskType:SVProgressHUDMaskTypeGradient];
}

- (void)fbDidLogin {
    [SVProgressHUD showWithStatus:@"Finding your Photos" maskType:SVProgressHUDMaskTypeGradient];
    // Got fb access token, upload this to our server
    [self uploadAccessToken];
}

- (void)fbDidNotLogin {
    [SVProgressHUD showSuccessWithStatus:@"Facebook Login Cancelled"];
//    [self loginIfNecessary];
}

- (void)uploadAccessToken {
    // Setup the network request
    NSDictionary *me = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbMe"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[PSFacebookCenter defaultCenter] accessToken] forKey:@"fbAccessToken"];
    [parameters setObject:[NSNumber numberWithDouble:[[[PSFacebookCenter defaultCenter] expirationDate] timeIntervalSince1970]] forKey:@"fbExpirationDate"];
    [parameters setObject:[me objectForKey:@"id"] forKey:@"fbId"];
    [parameters setObject:[NSJSONSerialization stringWithJSONObject:me options:NSJSONWritingPrettyPrinted error:nil] forKey:@"fbMe"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users", API_BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
        if ([response statusCode] != 200) {
            // Handle server status codes?
            [self loginDidNotSucceed];
        } else {
            NSDictionary *data = [JSON objectForKey:@"data"];
            NSDictionary *user = [data objectForKey:@"user"];
            NSString *timelineId = [user objectForKey:@"timelineId"];
            [[NSUserDefaults standardUserDefaults] setObject:timelineId forKey:@"timelineId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self loginDidSucceed:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self loginDidNotSucceed];
    }];
    [op start];
}

#pragma mark - Login
- (void)loginIfNecessary {
    if (![[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [[PSFacebookCenter defaultCenter] authorizeBasicPermissions];
    } else {
        [self loginDidSucceed:NO];
    }
}

- (void)loginDidSucceed:(BOOL)animated {
    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"welcome#loginSucceeded"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSucceeded object:nil];
//    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionDown animated:YES];
    [SVProgressHUD dismissWithSuccess:@"Your Timeline is Ready!"];

    
//    if (timelineId) {
//        TimelineViewController *vc = [[[TimelineViewController alloc] initWithTimelineId:timelineId] autorelease];
//        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionDown animated:YES];
//    } else {
//        [self loginDidNotSucceed];
//    }
}

- (void)loginDidNotSucceed {
    [SVProgressHUD dismissWithError:@"Facebook dropped the ball, please try again."];
    [[PSFacebookCenter defaultCenter] logout];
}

@end
