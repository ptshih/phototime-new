//
//  RootViewController.m
//  OSnap
//
//  Created by Peter Shih on 12/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "PSNavigationController.h"
#import "MenuViewController.h"
#import "LoginViewController.h"

#import "TimelineViewController.h"
#import "Timeline.h"

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
    RELEASE_SAFELY(_psNavigationController);
    [super dealloc];
}

- (void)loadView {
    // Setup the main container view
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = [UIColor blackColor];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = view;
    [view release];
    
    // View Controllers
//    MenuViewController *lvc = [[[MenuViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
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
    
    
    // PS Navigation Controller
    //  UINavigationController *nc = [[[[[NSBundle mainBundle] loadNibNamed:@"PSNavigationController" owner:self options:nil] lastObject] retain] autorelease];
    //  nc.viewControllers = [NSArray arrayWithObject:dvc];
    
    _psNavigationController = [[PSNavigationController alloc] initWithRootViewController:tvc];
    [self.view addSubview:_psNavigationController.view];
    
    
}

- (void)test {
    BOOL sb = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:!sb];
}


//- (void)viewWillAppear:(BOOL)animated
//{
//  [super viewWillAppear:animated];
//  if (!self.childViewControllers) {
//    [_drawerController viewWillAppear:animated];
//  }
//}
//
//- (void)viewDidAppear:(BOOL)animated
//{
//  [super viewDidAppear:animated];
//  if (!self.childViewControllers) {
//    [_drawerController viewDidAppear:animated];
//  }
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//  [super viewWillDisappear:animated];
//  if (!self.childViewControllers) {
//    [_drawerController viewWillDisappear:animated];
//  }
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//  [super viewDidDisappear:animated];
//  if (!self.childViewControllers) {
//    [_drawerController viewDidDisappear:animated];
//  }
//}

@end
