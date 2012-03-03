//
//  UserCell.m
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserCell.h"

#define MARGIN 8.0
#define PROFILE_SIZE 30.0

@implementation UserCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.psImageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.psImageView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [PSStyleSheet applyStyle:@"userNameLabel" forLabel:self.textLabel];
    }
    return self;
}

+ (CGFloat)rowHeight {
    return 46.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
    CGFloat left = MARGIN;
    CGFloat top = MARGIN;
    CGFloat width = self.contentView.width - MARGIN * 2;
    
    // Image
    self.psImageView.frame = CGRectMake(left, top, PROFILE_SIZE, PROFILE_SIZE);
    left = self.psImageView.right + MARGIN;
    width -= self.psImageView.width - MARGIN;
    
    self.textLabel.frame = CGRectMake(left, top, width, PROFILE_SIZE);
//    top = self.textLabel.bottom;
    
//    self.detailTextLabel.frame = CGRectMake(left, top, width, 25.0);
//    top = self.detailTextLabel.bottom;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [dict objectForKey:@"id"]]];
    [self.psImageView loadImageWithURL:profileURL];
    self.textLabel.text = [dict objectForKey:@"name"];
    self.detailTextLabel.text = [dict objectForKey:@"id"];
    
//    UIButton *accessoryButton = [UIButton buttonWithFrame:CGRectMake(0, 0, 44, 44) andStyle:nil target:self action:@selector(accessoryButtonTapped:withEvent:)];
//    [accessoryButton setImage:[UIImage imageNamed:@"IconPlusWhite"] forState:UIControlStateNormal];
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
