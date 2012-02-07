//
//  LoginViewController.m
//  OSnap
//
//  Created by Peter Shih on 11/23/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController (Private)

- (void)loginIfNecessary;
- (void)loginDidSucceed:(BOOL)animated;
- (void)loginDidNotSucceed;

// Notifications
- (void)fbDidLogin;
- (void)fbDidNotLogin;

/**
 Uploads a FB access token to our server
 */
- (void)uploadAccessToken;
@end

@implementation LoginViewController

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
    UIButton *loginButton = [UIButton buttonWithFrame:self.view.bounds andStyle:@"expandButton" target:self action:@selector(login)];
    [loginButton setTitle:@"Login to Facebook" forState:UIControlStateNormal];
    [self.view addSubview:loginButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Add this to main runloop queue
//    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
//        [self loginIfNecessary];
//    }];
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
                    
                    
                    [self loginDidSucceed:YES];
                } else {
                    // Failed, read status code
                    [self loginDidNotSucceed];
                }
            }
        } else {
            [self loginDidNotSucceed];
        }
    };
    
    // Setup the network request
    NSDictionary *me = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbMe"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setObject:[[PSFacebookCenter defaultCenter] accessToken] forKey:@"fbAccessToken"];
    [parameters setObject:[NSNumber numberWithDouble:[[[PSFacebookCenter defaultCenter] expirationDate] timeIntervalSince1970]] forKey:@"fbExpirationDate"];
    [parameters setObject:[me objectForKey:@"id"] forKey:@"fbId"];
    [parameters setObject:[me JSONString] forKey:@"fbMe"];
    
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@/token", API_BASE_URL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL method:@"POST" headers:nil parameters:parameters];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:handlerBlock];
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
    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionDown animated:YES];
}

- (void)loginDidNotSucceed {
    [self loginIfNecessary];
}

@end
