//
//  AppDelegate.m
//  OSnap
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import "AppDelegate.h"
#import "PSReachabilityCenter.h"
#import "PSLocationCenter.h"
#import "WelcomeViewController.h"
#import "TimelineViewController.h"

#import "BWHockeyManager.h"
#import "BWQuincyManager.h"

@interface AppDelegate (Private)

+ (void)setupDefaults;

@end

@implementation AppDelegate

@synthesize
window = _window,
navigationController = _navigationController,
backgroundDate = _backgroundDate,
foregroundDate = _foregroundDate,
shouldReloadInterface = _shouldReloadInterface;

+ (void)initialize {
    [self setupDefaults];
}

#pragma mark - Initial Defaults
+ (void)setupDefaults {
    if ([self class] == [AppDelegate class]) {
        // Setup initial defaults
        NSString *initialDefaultsPath = [[NSBundle mainBundle] pathForResource:@"InitialDefaults" ofType:@"plist"];
        assert(initialDefaultsPath != nil);
        
        NSDictionary *initialDefaults = [NSDictionary dictionaryWithContentsOfFile:initialDefaultsPath];
        assert(initialDefaults != nil);
        
        [[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
        
        //
        // Perform any version migrations here
        //
    }
}

#pragma mark - Global Statics

#pragma mark - Application Lifecycle
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PSFacebookCenter defaultCenter] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Fonts: %@", [UIFont familyNames]);
    
    self.shouldReloadInterface = NO;
    
#ifdef RELEASE
    [[BWHockeyManager sharedHockeyManager] setAppIdentifier:@"4e1669c1ec68aae5f6c0adb8c3c48367"];
    [[BWHockeyManager sharedHockeyManager] setAlwaysShowUpdateReminder:YES];
#endif
    [[BWQuincyManager sharedQuincyManager] setAppIdentifier:@"4e1669c1ec68aae5f6c0adb8c3c48367"];
    
    [[LocalyticsSession sharedLocalyticsSession] startSession:@"64d9fa4fc0bdc5781cea473-cbd5b426-5eb5-11e1-1b60-00a68a4c01fc"];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // PSFacebookCenter
    [PSFacebookCenter defaultCenter];
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Start Reachability
    [PSReachabilityCenter defaultCenter];
    
    // PSLocationCenter set default behavior
//    [[PSLocationCenter defaultCenter] setShouldMonitorSignificantChange:YES];
//    [[PSLocationCenter defaultCenter] setShouldDisableAfterLocationFix:NO];
//    [[PSLocationCenter defaultCenter] getMyLocation]; // start it
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]];
    
    // MOVE THESE TO KEYCHAIN
    // CURRENTLY FORCED IN INITIALDEFAULTS
    id controller = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]) {
        controller = [[[TimelineViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else {
        controller = [[[WelcomeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    self.navigationController = [[[PSNavigationController alloc] initWithRootViewController:controller] autorelease];
    self.window.rootViewController = self.navigationController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    self.backgroundDate = [NSDate date];
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    self.foregroundDate = [NSDate date];
    
    NSTimeInterval secondsBackgrounded = [self.foregroundDate timeIntervalSinceDate:self.backgroundDate];
    // 5 min threshold
    if (secondsBackgrounded > kSecondsBackgroundedUntilStale) {
        self.shouldReloadInterface = YES;
    }
    
    [[LocalyticsSession sharedLocalyticsSession] resume];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    if (self.shouldReloadInterface) {
        self.shouldReloadInterface = NO;
//        [self.navigationController popToRootViewControllerAnimated:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kTimelineShouldReload object:nil];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[LocalyticsSession sharedLocalyticsSession] close];
    [[LocalyticsSession sharedLocalyticsSession] upload];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.backgroundDate = nil;
    self.foregroundDate = nil;
    self.navigationController = nil;
    [_window release];
    [super dealloc];
}

@end
