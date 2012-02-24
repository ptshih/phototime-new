#import <CoreData/CoreData.h>

#import "PSConstants.h"
#import "PSNavigationController.h"

// Vendor imports
#import "PSFacebookCenter.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"
#import "Appirater.h"

#define CORE_DATA_MOM @"Phototime"
#define CORE_DATA_SQL_FILE @"Phototime.sqlite"

/**
 Notifications
 */
#define kLoginSucceeded @"kLoginSucceeded"
#define kTimelineShouldRefreshOnAppear @"kTimelineShouldRefreshOnAppear"

// Facebook APP ID is in PSFacebookCenter.h

// Convenience
#define APP_DRAWER [APP_DELEGATE drawerController]

// Colors
#define CELL_WHITE_COLOR [UIColor whiteColor]
#define CELL_BLACK_COLOR [UIColor blackColor]
#define CELL_BLUE_COLOR RGBCOLOR(45.0,147.0,204.0)

// Custom Colors
#define CELL_BACKGROUND_COLOR CELL_BLACK_COLOR
#define CELL_SELECTED_COLOR CELL_BLUE_COLOR

#if TARGET_IPHONE_SIMULATOR
  #define USE_LOCALHOST
#endif

#define API_LOCALHOST @"http://localhost:5000"
#define API_REMOTE @"http://whiskey.herokuapp.com"

#ifdef USE_LOCALHOST
  #define API_BASE_URL [NSString stringWithFormat:API_LOCALHOST]
#else
  #define API_BASE_URL [NSString stringWithFormat:API_REMOTE]
#endif
