//
//  PSTimelineConfigViewController.h
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTableViewController.h"

@class Timeline;

@interface PSTimelineConfigViewController : PSTableViewController

@property (nonatomic, retain) Timeline *timeline;

- (id)initWithTimeline:(Timeline *)timeline;

@end
