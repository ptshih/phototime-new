//
//  LikeCell.m
//  Phototime
//
//  Created by Peter on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LikeCell.h"
#define MARGIN 8.0

@implementation LikeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [PSStyleSheet applyStyle:@"likesLabel" forLabel:self.textLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
    CGFloat left = MARGIN;
    CGFloat top = MARGIN;
    CGFloat width = self.contentView.width - MARGIN * 2;
    
    CGSize labelSize = [PSStyleSheet sizeForText:self.textLabel.text width:width style:@"likesLabel"];
    self.textLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSString *likesText = (NSString *)object;
    self.textLabel.text = likesText;
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSString *likesText = (NSString *)object;
    
    CGFloat height = MARGIN;
    CGFloat width = ([self rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN * 2);
    
    CGSize labelSize = [PSStyleSheet sizeForText:likesText width:width style:@"likesLabel"];
    
    height += labelSize.height;
    
    height += MARGIN;

    return height;
}

@end
