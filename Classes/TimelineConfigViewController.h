//
//  TimelineConfigViewController.h
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PSTableViewController.h"

@interface TimelineConfigViewController : PSTableViewController

@property (nonatomic, copy) NSString *timelineId;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;

- (id)initWithTimelineId:(NSString *)timelineId;

@end
