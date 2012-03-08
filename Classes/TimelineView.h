//
//  TimelineView.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@class PSCachedImageView;

@interface TimelineView : PSView

@property (nonatomic, assign) UIViewController *presentingController;
@property (nonatomic, retain) id object;
@property (nonatomic, retain) PSCachedImageView *imageView;
@property (nonatomic, retain) PSCachedImageView *profileView;
@property (nonatomic, retain) UILabel *nameLabel;

- (void)prepareForReuse;
- (void)fillViewWithObject:(id)object;
- (void)fillViewWithObject:(id)object presentingController:(UIViewController *)presentingController;
+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth;

@end
