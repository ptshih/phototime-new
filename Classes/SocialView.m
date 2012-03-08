//
//  SocialView.m
//  Phototime
//
//  Created by Peter on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SocialView.h"

#define kMargin 4.0

@interface SocialView ()

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, retain) UIImageView *likeImageView;
@property (nonatomic, retain) UIImageView *commentImageView;
@property (nonatomic, retain) UILabel *likeLabel;
@property (nonatomic, retain) UILabel *commentLabel;

@end

@implementation SocialView

@synthesize
contentView = _contentView,
likeImageView = _likeImageView,
commentImageView = _commentImageView,
likeLabel = _likeLabel,
commentLabel = _commentLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xC4CDE0];
        
        self.contentView = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        [self addSubview:self.contentView];
        
        self.likeImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconLikeMini"]] autorelease];
        [self.contentView addSubview:self.likeImageView];
        
        self.commentImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconCommentMini"]] autorelease];
        [self.contentView addSubview:self.commentImageView];
        
        self.likeLabel = [UILabel labelWithText:nil style:@"metaLabel"];
        [self.contentView addSubview:self.likeLabel];
        
        self.commentLabel = [UILabel labelWithText:nil style:@"metaLabel"];
        [self.contentView addSubview:self.commentLabel];
    }
    return self;
}

- (void)dealloc {
    self.contentView = nil;
    self.likeImageView = nil;
    self.commentImageView = nil;
    self.likeLabel = nil;
    self.commentLabel = nil;
    [super dealloc];
}

- (void)prepareForReuse {
    self.likeLabel.text = nil;
    self.commentLabel.text = nil;
}

- (void)loadWithLikes:(NSUInteger)likes comments:(NSUInteger)comments {
    NSString *likeString = (likes == 1) ? [NSString stringWithFormat:@"%d like", likes] : [NSString stringWithFormat:@"%d likes", likes];
    NSString *commentString = (comments == 1) ? [NSString stringWithFormat:@"%d comment", comments] : [NSString stringWithFormat:@"%d comments", comments];
    
    self.likeLabel.text = likeString;
    self.commentLabel.text = commentString;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat top = 0.0;
    CGFloat left = 0.0;
    CGSize labelSize = CGSizeZero;
    
    self.likeImageView.frame = CGRectMake(left, top, 14, 14);
    
    left = self.likeImageView.right + kMargin / 2;
    
    labelSize = [PSStyleSheet sizeForText:self.likeLabel.text width:self.width style:@"metaLabel"];
    self.likeLabel.frame = CGRectMake(left, top, labelSize.width, 14);
    
    left = self.likeLabel.right + kMargin;
    
    self.commentImageView.frame = CGRectMake(left, top, 14, 14);
    
    left = self.commentImageView.right + kMargin / 2;
    
    labelSize = [PSStyleSheet sizeForText:self.commentLabel.text width:self.width style:@"metaLabel"];
    self.commentLabel.frame = CGRectMake(left, top, labelSize.width, 14);
    
    left = self.commentLabel.right;
    
    CGFloat width = kMargin * 2 + 14 + 14 + self.likeLabel.width + self.commentLabel.width;
    self.contentView.frame = CGRectMake(floorf((self.width - width) / 2), kMargin, left, self.height);
}

@end
