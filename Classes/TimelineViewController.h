//
//  TimelineViewController.h
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSBaseViewController.h"
#import "PSCollectionView.h"
#import "PSPullRefreshView.h"
#import "PSPopoverView.h"

@class PreviewViewController;

@interface TimelineViewController : PSBaseViewController <PSCollectionViewDelegate, PSCollectionViewDataSource, PSPullRefreshViewDelegate, UIScrollViewDelegate, PSPopoverViewDelegate>

@property (nonatomic, retain) PreviewViewController *pvc;
@property (nonatomic, copy) NSString *timelineId;
@property (nonatomic, copy) NSDate *startDate;
@property (nonatomic, copy) NSDate *endDate;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) PSCollectionView *collectionView;
@property (nonatomic, retain) PSPullRefreshView *pullRefreshView;
@property (nonatomic, assign) UIButton *leftButton;
@property (nonatomic, assign) UIButton *centerButton;
@property (nonatomic, assign) UIButton *rightButton;
@property (nonatomic, assign) BOOL shouldRefreshOnAppear;

- (id)initWithTimelineId:(NSString *)timelineId;


@end
