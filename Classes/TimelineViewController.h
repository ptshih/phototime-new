//
//  TimelineViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCoreDataTableViewController.h"

@class Timeline;

@interface TimelineViewController : PSCoreDataTableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) Timeline *timeline;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *rightButton;

- (id)initWithTimeline:(Timeline *)timeline;


@end
