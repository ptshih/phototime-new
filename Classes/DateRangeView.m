//
//  DateRangeView.m
//  Phototime
//
//  Created by Peter on 2/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DateRangeView.h"

@implementation DateRangeView

@synthesize
pickerView = _pickerView,
tableView = _tableView,
months = _months,
years = _years,
selectedKey = _selectedKey;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundPaper.jpg"]];
        // popover frame is 288 x 352

        self.tableView = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 180) style:UITableViewStyleGrouped] autorelease];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.scrollEnabled = NO;
        [self addSubview:self.tableView];
        [self.tableView reloadData];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone]; // preselect START date
        
        // UIPickerView allowed heights: 162 180 216
        self.pickerView = [[[UIPickerView alloc] initWithFrame:CGRectMake(0, self.height - 180, self.width, 180)] autorelease];
        self.pickerView.dataSource = self;
        self.pickerView.delegate = self;
        self.pickerView.showsSelectionIndicator = YES;
        [self addSubview:self.pickerView];
        
        // Months and Years
        self.months = [NSArray arrayWithObjects:@"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December", nil];
        self.years = [NSArray arrayWithObjects:@"2007", @"2008", @"2009", @"2010", @"2011", @"2012", nil];
        
        self.selectedKey = @"start";
        
        NSInteger monthIndex = 0;
        NSInteger yearIndex = 0;
        monthIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@MonthIndex", self.selectedKey]];
        yearIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@YearIndex", self.selectedKey]];
        
        [self.pickerView selectRow:monthIndex inComponent:0 animated:NO];
        [self.pickerView selectRow:yearIndex inComponent:1 animated:NO];
        
        UITableViewCell *cell = nil;
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [self.months objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"startMonthIndex"]], [self.years objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"startYearIndex"]]];
        
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [self.months objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"endMonthIndex"]], [self.years objectAtIndex:[[NSUserDefaults standardUserDefaults] integerForKey:@"endYearIndex"]]];
    }
    return self;
}

- (void)dealloc {
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    self.pickerView.delegate = nil;
    self.pickerView.dataSource = nil;
    
    self.tableView = nil;
    self.pickerView = nil;
    
    self.months = nil;
    self.years = nil;
    self.selectedKey = nil;
    [super dealloc];
}

#pragma mark - UIPickerView
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (component) {
        case 0:
            return [self.months count];
            break;
        case 1:
            return [self.years count];
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title = nil;
    switch (component) {
        case 0:
            // month
            title = [self.months objectAtIndex:row];
            break;
        case 1:
            // year
            title = [self.years objectAtIndex:row];
            break;
        default:
            title = @"Error";
            break;
    }
    return title;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSInteger tableRow = ([self.selectedKey isEqualToString:@"start"]) ? 0 : 1;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:tableRow inSection:0]];
    
    switch (component) {
        case 0:
            // month
            [[NSUserDefaults standardUserDefaults] setInteger:row forKey:[NSString stringWithFormat:@"%@MonthIndex", self.selectedKey]];
            break;
        case 1:
            // year
            [[NSUserDefaults standardUserDefaults] setInteger:row forKey:[NSString stringWithFormat:@"%@YearIndex", self.selectedKey]];
            break;
        default:
            break;
    }
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", [self.pickerView.delegate pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:0] forComponent:0], [self.pickerView.delegate pickerView:self.pickerView titleForRow:[self.pickerView selectedRowInComponent:1] forComponent:1]];
}


#pragma mark - UITableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Choose a start and end date for your Timeline.";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class cellClass = [UITableViewCell class];
    UITableViewCell *cell = nil;
    NSString *reuseIdentifier = @"UITableViewCellBase";
    
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if(cell == nil) { 
        cell = [[[cellClass alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier] autorelease];
    }

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Start";
            cell.detailTextLabel.text = @"INF";
            break;
        case 1:
            cell.textLabel.text = @"End";
            cell.detailTextLabel.text = @"Now";
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger monthIndex = 0;
    NSInteger yearIndex = 0;
    switch (indexPath.row) {
        case 0: {
            self.selectedKey = @"start";
            break;
        }
        case 1: {
            self.selectedKey = @"end";
            break;
        }
        default:
            break;
    }
    
    monthIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@MonthIndex", self.selectedKey]];
    yearIndex = [[NSUserDefaults standardUserDefaults] integerForKey:[NSString stringWithFormat:@"%@YearIndex", self.selectedKey]];
    
    [self.pickerView selectRow:monthIndex inComponent:0 animated:YES];
    [self.pickerView selectRow:yearIndex inComponent:1 animated:YES];
}

@end
