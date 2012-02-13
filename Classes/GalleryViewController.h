//
//  GalleryViewController.h
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"
#import "PSCollectionView.h"

@interface GalleryViewController : PSViewController <PSCollectionViewDelegate, PSCollectionViewDataSource>

@property (nonatomic, retain) PSCollectionView *collectionView;
@property (nonatomic, retain) NSMutableArray *assets;

@end
