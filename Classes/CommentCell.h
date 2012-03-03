//
//  CommentCell.h
//  Phototime
//
//  Created by Peter on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSCell.h"

@interface CommentCell : PSCell

@property (nonatomic, retain) UILabel *nameLabel;
@property (nonatomic, retain) UILabel *timestampLabel;
@property (nonatomic, retain) UILabel *messageLabel;

@end
