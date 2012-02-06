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
#import "LoginViewController.h"
#import "TimelineViewController.h"
#import "MenuViewController.h"
#import "Timeline.h"

static NSMutableDictionary *_captionsCache;

@interface AppDelegate (Private)

+ (void)setupDefaults;

@end

@implementation AppDelegate

@synthesize
window = _window,
navigationController = _navigationController,
drawerController = _drawerController;

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
    
    // Test insert
#warning THIS IS A TEST
    NSDictionary *tDict = [NSDictionary dictionaryWithObjectsAndKeys:@"4f2b65e2e4b024f14205b3ad", @"id", @"548430564", @"ownerId", [NSNumber numberWithInteger:1328495128], @"lastSynced", [NSArray arrayWithObjects:@"548430564",@"13704812",@"2602152", @"6010421", nil], @"members", nil];
    [Timeline updateOrInsertInManagedObjectContext:[PSCoreDataStack mainThreadContext] entity:tDict uniqueKey:@"id"];
    [[PSCoreDataStack mainThreadContext] save:nil];
    
    NSFetchRequest *fr = [[[NSFetchRequest alloc] initWithEntityName:[Timeline entityName]] autorelease];
    [fr setEntity:[Timeline entityInManagedObjectContext:[PSCoreDataStack mainThreadContext]]];
    [fr setPredicate:[NSPredicate predicateWithFormat:@"id = %@", @"4f2b65e2e4b024f14205b3ad"]];
    [fr setReturnsObjectsAsFaults:NO];
    
    Timeline *t = nil;
    NSArray *results = [[PSCoreDataStack mainThreadContext] executeFetchRequest:fr error:nil];
    if (results && [results count] > 0) {
        t = [results lastObject];
    }
    
    TimelineViewController *tvc = [[[TimelineViewController alloc] initWithTimeline:t] autorelease];
    
    self.navigationController = [[[PSNavigationController alloc] initWithRootViewController:tvc] autorelease];
    
//    MenuViewController *mvc = [[[MenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
//    self.drawerController = [[[PSDrawerController alloc] initWithRootViewController:self.navigationController leftViewController:mvc rightViewController:nil] autorelease];
    
    self.window.rootViewController = self.navigationController;
    
    // Login
    if (![[PSFacebookCenter defaultCenter] isLoggedIn]) {
        LoginViewController *lvc = [[LoginViewController alloc] initWithNibName:nil bundle:nil];
        [self.navigationController presentModalViewController:lvc animated:NO];
        [lvc release];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationSuspended object:nil];
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationBackgrounded object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationForegrounded object:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationResumed object:nil];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    RELEASE_SAFELY(_drawerController);
    RELEASE_SAFELY(_navigationController);
    [_window release];
    [super dealloc];
}

@end
