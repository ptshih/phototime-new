//
//  DateRangeView.h
//  Phototime
//
//  Created by Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface DateRangeView : PSView <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) UIPickerView *pickerView;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSArray *months;
@property (nonatomic, retain) NSArray *years;
@property (nonatomic, retain) NSString *selectedKey;
@property (nonatomic, assign) NSInteger startMonthIndex;
@property (nonatomic, assign) NSInteger startYearIndex;
@property (nonatomic, assign) NSInteger endMonthIndex;
@property (nonatomic, assign) NSInteger endYearIndex;

@end
