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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidLogin) name:kPSFacebookCenterDialogDidSucceed object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fbDidNotLogin) name:kPSFacebookCenterDialogDidFail object:nil];
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kPSFacebookCenterDialogDidFail object:nil];
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Add a login button
    UIButton *loginButton = [UIButton buttonWithFrame:self.view.bounds andStyle:@"loginButton" target:self action:@selector(login)];
    [loginButton setTitle:@"Login to Facebook" forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Actions
- (void)login {
    [self loginIfNecessary];
}

#pragma mark - Notifications
- (void)fbDidLogin {
    // Got fb access token, upload this to our server
    [self uploadAccessToken];
}

- (void)fbDidNotLogin {
    [self loginIfNecessary];
}

- (void)uploadAccessToken {
    BLOCK_SELF;
    
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
            [blockSelf loginDidNotSucceed];
        } else {
            NSDictionary *data = [JSON objectForKey:@"data"];
            NSDictionary *user = [data objectForKey:@"user"];
            NSString *timelineId = [user objectForKey:@"timelineId"];
            [[NSUserDefaults standardUserDefaults] setObject:timelineId forKey:@"timelineId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [blockSelf loginDidSucceed:YES];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [blockSelf loginDidNotSucceed];
    }];
    [op start];
}

#pragma mark - Login
- (void)loginIfNecessary {
    if (![[PSFacebookCenter defaultCenter] isLoggedIn]) {
        [SVProgressHUD showWithStatus:@"Asking Facebook for permission." maskType:SVProgressHUDMaskTypeGradient];
        [[PSFacebookCenter defaultCenter] authorizeBasicPermissions];
    } else {
        [self loginDidSucceed:NO];
    }
}

- (void)loginDidSucceed:(BOOL)animated {
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSucceeded object:nil];
//    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionDown animated:YES];
    [SVProgressHUD dismissWithSuccess:@"Hurray!"];
    
    NSString *timelineId = [[NSUserDefaults standardUserDefaults] objectForKey:@"timelineId"];
    
    if (timelineId) {
        TimelineViewController *vc = [[[TimelineViewController alloc] initWithTimelineId:timelineId] autorelease];
        [(PSNavigationController *)self.parentViewController pushViewController:vc direction:PSNavigationControllerDirectionDown animated:YES];
    } else {
        [self loginDidNotSucceed];
    }
}

- (void)loginDidNotSucceed {
    [SVProgressHUD dismissWithError:@"Facebook dropped the ball, please try again."];
    [[PSFacebookCenter defaultCenter] logout];
}

//- (void)downloadTimelines {
//    BLOCK_SELF;
//    
//    // Setup the network request
//    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
//    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/users/%@/timelines", API_BASE_URL, fbId]];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"GET" headers:nil parameters:nil];
//    
//    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON){
//        if ([response statusCode] != 200) {
//            // Handle server status codes?
//            [blockSelf loginDidNotSucceed];
//        } else {
//            NSDictionary *timeline = [[[JSON objectForKey:@"data"] objectForKey:@"timelines"] lastObject];
//            
//            NSManagedObjectContext *moc = [[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType] autorelease];
//            [moc setPersistentStoreCoordinator:[PSCoreDataStack persistentStoreCoordinator]];
//            [moc performBlock:^{
//                [Timeline updateOrInsertInManagedObjectContext:moc entity:timeline uniqueKey:@"id"];
//                
//                NSError *error = nil;
//                [moc save:&error];
//                
//                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//                    [blockSelf loginDidSucceed:YES];
//                }];
//            }];
//        }
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//        [blockSelf loginDidNotSucceed];
//    }];
//    [op start];
//}

@end
