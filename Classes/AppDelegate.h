//
//  AppDelegate.h
//  OSnap
//
//  Created by Peter Shih on 11/15/11.
//  Copyright (c) 2011 Peter Shih. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) PSNavigationController *navigationController;
@property (nonatomic, retain) PSDrawerController *drawerController;

- (NSMutableDictionary *)captionsCache;

@end
