//
//  RootViewController.m
//  Phototime
//
//  Created by Peter Shih on 3/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import "TimelineViewController.h"
#import "WelcomeViewController.h"

@interface RootViewController ()

@end

@implementation RootViewController

- (UIColor *)baseBackgroundColor {
    return [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    id vc = nil;
    
    // NOTE: MOVE TO KEYCHAIN
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] && [[NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"]) {
        vc = [[[TimelineViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    } else {
        vc = [[[WelcomeViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    }
    [(PSNavigationController *)self.parentViewController pushViewController:vc animated:YES];
}

@end
