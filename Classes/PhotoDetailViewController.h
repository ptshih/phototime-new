//
//  PhotoDetailViewController.h
//  Phototime
//
//  Created by Peter on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSTableViewController.h"

@interface PhotoDetailViewController : PSTableViewController <UITextFieldDelegate>

@property (nonatomic, copy) NSDictionary *photo;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;
@property (nonatomic, retain) PSTextField *textField;

- (id)initWithDictionary:(NSDictionary *)dictionary;

@end
