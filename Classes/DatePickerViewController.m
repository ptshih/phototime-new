//
//  DatePickerViewController.m
//  Phototime
//
//  Created by Peter on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DatePickerViewController.h"

@implementation DatePickerViewController

@synthesize
mode = _mode,
datePicker = _datePicker;

#pragma mark - Init
- (id)initWithMode:(PSDatePickerMode)mode {
    self = [self initWithNibName:nil bundle:nil];
    if (self) {
        self.mode = mode;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidUnload {
    self.datePicker = nil;
    [super viewDidUnload];
}

- (void)dealloc {
    self.datePicker = nil;
    [super dealloc];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
    return [UIColor whiteColor];
}

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.datePicker = [[[UIDatePicker alloc] init] autorelease];
    [self.datePicker addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
    self.datePicker.center = self.view.center;
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSince1970:1075852800];
    self.datePicker.maximumDate = [NSDate date];
    NSDate *selectedDate = (self.mode == PSDatePickerModeFrom) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"fromDate"] : [[NSUserDefaults standardUserDefaults] objectForKey:@"toDate"];
    self.datePicker.date = selectedDate;
    [self.view addSubview:self.datePicker];
    
    UIButton *fromButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    fromButton.height = 48.0;
    fromButton.width = 280.0;
    fromButton.center = self.view.center;
    fromButton.top = self.datePicker.bottom + 48.0;
    [fromButton addTarget:self action:@selector(finishedPickingDate) forControlEvents:UIControlEventTouchUpInside];
    [fromButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.view addSubview:fromButton];
}

- (void)datePickerChanged:(UIDatePicker *)datePicker {
    NSString *datePickerKey = (self.mode == PSDatePickerModeFrom) ? @"fromDate" : @"toDate";
    [[NSUserDefaults standardUserDefaults] setObject:datePicker.date forKey:datePickerKey];
}

- (void)finishedPickingDate {
    [[NSNotificationCenter defaultCenter] postNotificationName:kTimelineShouldRefetchOnAppear object:nil];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    [(PSNavigationController *)self.parentViewController popViewControllerWithDirection:PSNavigationControllerDirectionUp animated:YES];
    
    [(PSNavigationController *)self.parentViewController popToRootViewControllerAnimated:YES];
}


@end
