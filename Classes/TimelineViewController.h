//
//  TimelineViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCoreDataTableViewController.h"

@interface TimelineViewController : PSCoreDataTableViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *rightButton;


@end
