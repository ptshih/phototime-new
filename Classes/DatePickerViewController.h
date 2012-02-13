//
//  DatePickerViewController.h
//  Phototime
//
//  Created by Peter on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"

typedef enum {
    PSDatePickerModeFrom = 1,
    PSDatePickerModeTo = 2
} PSDatePickerMode;

@interface DatePickerViewController : PSViewController

@property (nonatomic, assign) PSDatePickerMode mode;
@property (nonatomic, retain) UIDatePicker *datePicker;

- (id)initWithMode:(PSDatePickerMode)mode;

@end
