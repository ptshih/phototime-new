//
//  TimelineCell.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCell.h"

@class PSCachedImageView;

@interface TimelineCell : PSCell {
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
}

@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *imageViews;
@property (nonatomic, retain) NSMutableArray *profileViews;

@property (nonatomic, retain) PSCachedImageView *topImageView;
@property (nonatomic, retain) UIImageView *topLineView;
@property (nonatomic, retain) UIImageView *bottomLineView;

- (PSCachedImageView *)dequeueImageViewWithURL:(NSURL *)URL;

@end
