//
//  TimelineCell.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCell.h"

@class PSCachedImageView;

@interface TimelineCell : PSCell

@property (nonatomic, retain) NSMutableArray *imageDicts;
@property (nonatomic, retain) NSMutableArray *imageViews;
@property (nonatomic, retain) NSMutableArray *profileViews;
@property (nonatomic, assign) CGFloat profileIconSize;

- (PSCachedImageView *)dequeueImageViewWithURL:(NSURL *)URL;

@end
