//
//  ScoreCell.m
//  Phototime
//
//  Created by Peter Shih on 3/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ScoreCell.h"

#define MARGIN 8.0
#define PROFILE_SIZE 30.0

@interface ScoreCell ()

@property (nonatomic, retain) UILabel *reasonLabel;
@property (nonatomic, retain) UILabel *pointLabel;

@end

@implementation ScoreCell

@synthesize
reasonLabel = _reasonLabel,
pointLabel = _pointLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        self.psImageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
//        [self.contentView addSubview:self.psImageView];
        
        self.reasonLabel = [UILabel labelWithStyle:@"titleLabel"];
        [self.contentView addSubview:self.reasonLabel];
        
        self.pointLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        [self.contentView addSubview:self.pointLabel];
    }
    return self;
}

- (void)dealloc {
    self.reasonLabel = nil;
    self.pointLabel = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
//    [self.psImageView prepareForReuse];
    self.reasonLabel.text = nil;
    self.pointLabel.text = nil;
}

+ (CGFloat)rowHeight {
    return 32.0;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Layout
    CGFloat left = MARGIN;
    CGFloat top = MARGIN;
    CGFloat width = self.contentView.width - MARGIN * 2;
    CGFloat right = self.contentView.width - MARGIN;
    CGSize labelSize = CGSizeZero;
    
    labelSize = [PSStyleSheet sizeForText:self.pointLabel.text width:width style:@"subtitleLabel"];
    self.pointLabel.frame = CGRectMake(right - labelSize.width, top, labelSize.width, labelSize.height);
    
    width -= self.pointLabel.width + MARGIN;
    
    labelSize = [PSStyleSheet sizeForText:self.reasonLabel.text width:width style:@"titleLabel"];
    self.reasonLabel.frame = CGRectMake(left, top, labelSize.width, labelSize.height);
}


- (void)tableView:(UITableView *)tableView fillCellWithObject:(NSDictionary *)object atIndexPath:(NSIndexPath *)indexPath {
    self.reasonLabel.text = [object objectForKey:@"reason"];
    self.pointLabel.text = [NSString stringWithFormat:@"+%@", [object objectForKey:@"point"]];
}

@end
