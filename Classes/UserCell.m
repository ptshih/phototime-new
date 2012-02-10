//
//  UserCell.m
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.psImageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.psImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

+ (CGFloat)rowHeight {
    return 44.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    static CGFloat margin = 5.0;
    
    // Layout
    CGFloat left = margin;
    CGFloat top = margin;
    CGFloat width = self.contentView.width - margin * 2;
    
    // Image
    self.psImageView.frame = CGRectMake(left, top, 34.0, 34.0);
    left = self.psImageView.right + margin;
    width -= self.psImageView.width - margin;
    
    self.textLabel.frame = CGRectMake(left, top, width, 34.0);
    top = self.textLabel.bottom;
    
//    self.detailTextLabel.frame = CGRectMake(left, top, width, 25.0);
//    top = self.detailTextLabel.bottom;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object {
    NSDictionary *dict = (NSDictionary *)object;
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [dict objectForKey:@"id"]]];
    [self.psImageView loadImageWithURL:profileURL];
    self.textLabel.text = [dict objectForKey:@"name"];
    self.detailTextLabel.text = [dict objectForKey:@"id"];
    
//    UIButton *accessoryButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(accessoryButtonTapped:withEvent:)];
//    [accessoryButton setImage:[UIImage imageNamed:@"IconPlusBlack"] forState:UIControlStateNormal];
//    
//    self.accessoryView = accessoryButton;
//    self.parentTableView = tableView;
}

#pragma mark - Action
//- (void)accessoryButtonTapped:(UIButton *)button withEvent:(UIEvent *)event {
//    NSIndexPath * indexPath = [self.parentTableView indexPathForRowAtPoint:[[[event touchesForView:button] anyObject] locationInView: self.parentTableView]];
//    if (!indexPath) return;
//    
//    if (self.parentTableView.delegate && [self.parentTableView.delegate respondsToSelector:@selector(tableView:accessoryButtonTappedForRowWithIndexPath:)]) {
//        [self.parentTableView.delegate tableView:self.parentTableView accessoryButtonTappedForRowWithIndexPath:indexPath];
//    }
//}

@end
