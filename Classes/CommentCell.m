//
//  CommentCell.m
//  Phototime
//
//  Created by Peter on 3/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentCell.h"

#define MARGIN 8.0
#define PROFILE_SIZE 30.0

@implementation CommentCell

@synthesize
nameLabel = _nameLabel,
timestampLabel = _timestampLabel,
messageLabel = _messageLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.psImageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        [self.contentView addSubview:self.psImageView];
        
        self.nameLabel = [UILabel labelWithStyle:@"titleLabel"];
        [self.contentView addSubview:self.nameLabel];
        
        self.timestampLabel = [UILabel labelWithStyle:@"metaLabel"];
        [self.contentView addSubview:self.timestampLabel];
        
        self.messageLabel = [UILabel labelWithStyle:@"bodyLabel"];
        [self.contentView addSubview:self.messageLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)dealloc {
    self.nameLabel = nil;
    self.timestampLabel = nil;
    self.messageLabel = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text = nil;
    self.timestampLabel.text = nil;
    self.messageLabel.text = nil;
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
    CGFloat left = MARGIN;
    CGFloat top = MARGIN;
    CGFloat width = self.contentView.width - MARGIN * 2;
    CGSize labelSize = CGSizeZero;
    
    // Image
    self.psImageView.frame = CGRectMake(left, top, PROFILE_SIZE, PROFILE_SIZE);
    left = self.psImageView.right + MARGIN;
    width -= self.psImageView.width - MARGIN;
    CGFloat right = self.width - MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:self.timestampLabel.text width:width style:@"metaLabel"];
    self.timestampLabel.frame = CGRectMake(right - labelSize.width, top, labelSize.width, labelSize.height);
    
    labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:(width - self.timestampLabel.width - MARGIN) style:@"titleLabel"];
    self.nameLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
    
    top = self.nameLabel.bottom;
    
    labelSize = [PSStyleSheet sizeForText:self.messageLabel.text width:width style:@"bodyLabel"];
    self.messageLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dict = (NSDictionary *)object;
    NSDictionary *from = [dict objectForKey:@"from"];
    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [from objectForKey:@"id"]]];
    [self.psImageView loadImageWithURL:profileURL];
    self.nameLabel.text = [from objectForKey:@"name"];
    self.timestampLabel.text = [[NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"created_time"] doubleValue]] stringDaysAgo];
    self.messageLabel.text = [dict objectForKey:@"message"];
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSDictionary *dict = (NSDictionary *)object;
    NSDictionary *from = [dict objectForKey:@"from"];
    
    CGFloat height = MARGIN;
    CGFloat width = ([self rowWidthForInterfaceOrientation:interfaceOrientation] - MARGIN * 2);
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:[from objectForKey:@"name"] width:width style:@"titleLabel"];
    height += labelSize.height;
    
    labelSize = [PSStyleSheet sizeForText:[dict objectForKey:@"message"] width:width style:@"bodyLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return MAX(height, PROFILE_SIZE + MARGIN * 2);
}

@end
