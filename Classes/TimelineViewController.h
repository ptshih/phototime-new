//
//  TimelineViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSTableViewController.h"

@class Timeline;

@interface TimelineViewController : PSTableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *moc;
@property (nonatomic, retain) Timeline *timeline;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *rightButton;
@property (nonatomic, assign) BOOL shouldRefreshOnAppear;

- (id)initWithTimeline:(Timeline *)timeline;


@end
