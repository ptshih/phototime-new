//
//  LeaderboardCell.m
//  Phototime
//
//  Created by Peter Shih on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LeaderboardCell.h"

#define MARGIN 8.0
#define PROFILE_SIZE 30.0

@interface LeaderboardCell ()

@property (nonatomic, retain) UIButton *rankButton;

@end

@implementation LeaderboardCell

@synthesize
rankButton = _rankButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.psImageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.psImageView];
        
        self.rankButton = [UIButton buttonWithFrame:CGRectZero andStyle:@"navigationButton" target:nil action:nil];
        self.rankButton.userInteractionEnabled = NO;
        [self.rankButton setBackgroundImage:[UIImage imageNamed:@"IconStar"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.rankButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [PSStyleSheet applyStyle:@"userNameLabel" forLabel:self.textLabel];
    }
    return self;
}

- (void)dealloc {
    self.rankButton = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.psImageView prepareForReuse];
}

+ (CGFloat)rowHeight {
    return 44.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
    CGFloat left = MARGIN;
    CGFloat top = MARGIN;
    CGFloat width = self.contentView.width - MARGIN * 2;
    
    self.rankButton.frame = CGRectMake(left, top, PROFILE_SIZE, PROFILE_SIZE);
    left = self.rankButton.right + MARGIN;
    width -= self.rankButton.width + MARGIN;
    
    // Image
    self.psImageView.frame = CGRectMake(left, top, PROFILE_SIZE, PROFILE_SIZE);
    left = self.psImageView.right + MARGIN;
    width -= self.psImageView.width + MARGIN;
    
    self.textLabel.frame = CGRectMake(left, top, width, PROFILE_SIZE);
    //    top = self.textLabel.bottom;
    
    //    self.detailTextLabel.frame = CGRectMake(left, top, width, 25.0);
    //    top = self.detailTextLabel.bottom;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", @"548430564"]];
    [self.psImageView loadImageWithURL:profileURL];
    self.textLabel.text = @"Peter Shih";
    self.detailTextLabel.text = @"777";
    
    NSInteger row = indexPath.row;
    [self.rankButton setTitle:[NSString stringWithFormat:@"%d", row] forState:UIControlStateNormal];
    
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
