//
//  GalleryViewController.h
//  Phototime
//
//  Created by Peter on 2/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"
#import "PSGalleryView.h"

@interface GalleryViewController : PSViewController <PSGalleryViewDelegate, PSGalleryViewDataSource>

@property (nonatomic, retain) PSGalleryView *galleryView;
@property (nonatomic, retain) NSMutableArray *assets;

@end
