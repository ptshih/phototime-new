//
//  TimelineCell.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineCell.h"
#import "PSCachedImageView.h"
#import "PSZoomView.h"
#import "Photo.h"

#define TL_THUMB_SIZE 96.0
#define TL_THUMB_MARGIN 6.0
#define TL_MARGIN 10.0

static NSMutableSet *__reusableImageViews = nil;

@implementation TimelineCell

@synthesize
imageDicts = _imageDicts,
imageViews = _imageViews,
profileViews = _profileViews,
profileIconSize = _profileIconSize;

+ (void)initialize {
    __reusableImageViews = [[NSMutableSet alloc] init];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.imageDicts = [NSMutableArray arrayWithCapacity:1];
        self.imageViews = [NSMutableArray arrayWithCapacity:1];
        self.profileViews = [NSMutableArray arrayWithCapacity:1];
        self.profileIconSize = 40.0;
    }
    return self;
}

- (void)dealloc {
    
    RELEASE_SAFELY(_imageDicts);
    RELEASE_SAFELY(_imageViews);
    RELEASE_SAFELY(_profileViews);
    
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.profileViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.profileViews removeAllObjects];
    
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [__reusableImageViews addObjectsFromArray:self.imageViews];
    [self.imageViews removeAllObjects];
    
    [self.imageDicts removeAllObjects];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Here we should format the cell
    // There should always be a featured image on top, and an array of additional images on bottom that follow set guidelines
    // If 2, split then 50/50
    // If 3, split them 33/33/33
    // If > 3, split and fill as necessary in priority order, 3 -> 2 -> 1
    
    /**
     Always have a top image (featured)
     Any additional images will be SQUARE and gridded up below with the following rules:
     - If 1 image, fill entire row
     - If 2 images, split them 50/50
     - If 3 images, split them 33/33/33
     - If > 3 images, fill up to 3 per row and the rest in priority order
     */
}

- (PSCachedImageView *)dequeueImageViewWithURL:(NSURL *)URL {
    PSCachedImageView *iv = [[[__reusableImageViews anyObject] retain] autorelease];
    if (!iv) {
        iv = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv.userInteractionEnabled = YES;
    } else {
        if ([iv.gestureRecognizers count] > 0) {
            [iv.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gr, NSUInteger idx, BOOL *stop) {
                [iv removeGestureRecognizer:gr];
            }];
        }
        [iv unloadImage];
        [__reusableImageViews removeObject:iv];
    }
    [iv loadImageWithURL:URL];
    [self.imageViews addObject:iv];
    return iv;
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSArray *photos = (NSArray *)object;
    NSInteger numPhotos = [photos count];
    
    CGFloat height = 0.0;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - TL_MARGIN * 2;
    
    // Top Margin
    height += TL_THUMB_MARGIN / 2;
    
    if (numPhotos == 1) {
        height += floorf(width * 0.5);
    } else {
        height += TL_THUMB_SIZE;
    }
    
    // Bottom Margin
    height += TL_THUMB_MARGIN / 2;
    
//    NSLog(@"numPhotos: %d, calc height: %f", numPhotos, height);
    
    return height;
}

- (void)fillCellWithObject:(id)object {
    // Fill Data
    NSArray *photos = (NSArray *)object;
    NSInteger numPhotos = [photos count];
    [self.imageDicts addObjectsFromArray:photos];
    
    self.profileIconSize = (numPhotos > 1) ? 30.0 : 40.0;
    
    // Layout
    CGFloat left = TL_MARGIN;
    CGFloat top = TL_THUMB_MARGIN / 2;
    CGFloat width = self.contentView.width - TL_MARGIN * 2;
    
    CGFloat photoWidth = 0.0;
    CGFloat photoHeight = TL_THUMB_SIZE;
    switch (numPhotos) {
        case 1:
            photoWidth = width;
            photoHeight = floorf(width * 0.5);
            break;
        case 2:
            photoWidth = floorf((width - TL_THUMB_MARGIN) / 2);
            break;
        case 3:
            photoWidth = floorf((width - TL_THUMB_MARGIN - TL_THUMB_MARGIN) / 3);
            break;
        default:
            break;
    }

    [self.imageDicts enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        PSCachedImageView *iv = [self dequeueImageViewWithURL:[NSURL URLWithString:[dict objectForKey:@"source"]]];
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)] autorelease];
        [iv addGestureRecognizer:gr];
        iv.layer.borderWidth = 0.0;
        iv.layer.borderColor = nil;
        iv.frame = CGRectMake(left + idx * (TL_THUMB_MARGIN + photoWidth), top, photoWidth, photoHeight);
        [self.contentView addSubview:iv];
        
        // Add profile view
        PSCachedImageView *pv = [self dequeueImageViewWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [dict objectForKey:@"ownerId"]]]];
        pv.frame = CGRectMake(iv.width - self.profileIconSize + 1, iv.height - self.profileIconSize + 1, self.profileIconSize, self.profileIconSize);
        pv.layer.borderWidth = 1.0;
        pv.layer.borderColor = [RGBACOLOR(255, 255, 255, 1.0) CGColor];
        [iv addSubview:pv];
        [self.profileViews addObject:pv];
    }];
    
    top += TL_THUMB_SIZE;
    
    top += TL_THUMB_MARGIN / 2;

    
//    NSLog(@"numPhotos: %d, fill height: %f", numPhotos, top);
}

#pragma mark - Zoom
- (void)zoom:(UITapGestureRecognizer *)gestureRecognizer {
    PSCachedImageView *imageView = (PSCachedImageView *)gestureRecognizer.view;
    if (!imageView.image) return;
    
    UIViewContentMode contentMode = imageView.contentMode;
    PSZoomView *zoomView = [[[PSZoomView alloc] initWithImage:imageView.image contentMode:contentMode] autorelease];
    CGRect imageRect = [self.contentView convertRect:imageView.frame toView:self];
    [zoomView showInRect:[self convertRect:imageRect toView:nil]];
}

@end
