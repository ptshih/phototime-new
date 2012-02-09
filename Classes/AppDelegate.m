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
#import "Timeline.h"

static NSMutableDictionary *_captionsCache;

@interface AppDelegate (Private)

+ (void)setupDefaults;

@end

@implementation AppDelegate

@synthesize
window = _window,
navigationController = _navigationController;

+ (void)initialize {
    [self setupDefaults];
    _captionsCache = [[NSMutableDictionary alloc] init];
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
- (NSMutableDictionary *)captionsCache {
    return _captionsCache;
}

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
    
    // PSFacebookCenter
    [PSFacebookCenter defaultCenter];
    
    // Set application stylesheet
    [PSStyleSheet setStyleSheet:@"PSStyleSheet"];
    
    // Start Reachability
    [PSReachabilityCenter defaultCenter];
    
    // PSLocationCenter set default behavior
    [[PSLocationCenter defaultCenter] setShouldMonitorSignificantChange:YES];
    [[PSLocationCenter defaultCenter] setShouldDisableAfterLocationFix:NO];
    [[PSLocationCenter defaultCenter] getMyLocation]; // start it
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    [self.window makeKeyAndVisible];
    self.window.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.jpg"]];
    
    // Setup initial view controller based on authentication
    // @"4f2b65e2e4b024f14205b3ad"
    
    NSString *fbId = [[NSUserDefaults standardUserDefaults] objectForKey:@"fbId"];
    Timeline *t = nil;
    NSFetchRequest *fr = [[[NSFetchRequest alloc] initWithEntityName:[Timeline entityName]] autorelease];
    [fr setEntity:[Timeline entityInManagedObjectContext:[PSCoreDataStack mainThreadContext]]];
    [fr setPredicate:[NSPredicate predicateWithFormat:@"ownerId = %@", fbId]];
    [fr setReturnsObjectsAsFaults:NO];
    NSArray *results = [[PSCoreDataStack mainThreadContext] executeFetchRequest:fr error:nil];
    if (results && [results count] > 0) {
        t = [results lastObject];
    }
    
    id controller = nil;
    if ([[PSFacebookCenter defaultCenter] isLoggedIn] && t) {
        // Test insert
#warning THIS IS A TEST
        controller = [[[TimelineViewController alloc] initWithTimeline:t] autorelease];
    } else {
        controller = [[[WelcomeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    
    self.navigationController = [[[PSNavigationController alloc] initWithRootViewController:controller] autorelease];
    self.window.rootViewController = self.navigationController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationSuspended object:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationBackgrounded object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationForegrounded object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationResumed object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RELEASE_SAFELY(_navigationController);
    [_window release];
    [super dealloc];
}

@end
