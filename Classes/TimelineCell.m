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

#define TL_THUMB_SIZE 96.0
#define TL_THUMB_MARGIN 8.0
#define TL_MARGIN 8.0

static NSMutableSet *__reusableImageViews = nil;

@implementation TimelineCell

@synthesize
object = _object,
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
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.imageDicts = [NSMutableArray arrayWithCapacity:1];
        self.imageViews = [NSMutableArray arrayWithCapacity:1];
        self.profileViews = [NSMutableArray arrayWithCapacity:1];
        self.profileIconSize = 32.0;
    }
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(_object);
    RELEASE_SAFELY(_imageDicts);
    RELEASE_SAFELY(_imageViews);
    RELEASE_SAFELY(_profileViews);
    
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.profileViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.profileViews makeObjectsPerformSelector:@selector(prepareForReuse)];
    [self.profileViews removeAllObjects];
    
    [self.imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.imageViews makeObjectsPerformSelector:@selector(prepareForReuse)];
    [__reusableImageViews addObjectsFromArray:self.imageViews];
    [self.imageViews removeAllObjects];
    
    [self.imageDicts removeAllObjects];
}

- (PSCachedImageView *)dequeueImageViewWithURL:(NSURL *)URL {
    PSCachedImageView *iv = [[[__reusableImageViews anyObject] retain] autorelease];
    if (!iv) {
        iv = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        iv.contentMode = UIViewContentModeScaleAspectFill;
        iv.clipsToBounds = YES;
        iv.userInteractionEnabled = YES;
        iv.shouldAnimate = YES;
    } else {
        if ([iv.gestureRecognizers count] > 0) {
            [iv.gestureRecognizers enumerateObjectsUsingBlock:^(UIGestureRecognizer *gr, NSUInteger idx, BOOL *stop) {
                [iv removeGestureRecognizer:gr];
            }];
        }
        [__reusableImageViews removeObject:iv];
    }
    [iv loadImageWithURL:URL];
    return iv;
}

+ (CGFloat)rowHeightForObject:(id)object atIndexPath:(NSIndexPath *)indexPath forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSArray *photos = (NSArray *)object;
    NSInteger numPhotos = [photos count];
    
    CGFloat height = 0.0;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - TL_MARGIN * 2;
    
    // Top Margin
    height += TL_THUMB_MARGIN / 2;
    
    if (numPhotos == 1) {
        // Special case, row is not first row but only 1 photo
        if (indexPath.row != 0) {
            height += TL_THUMB_SIZE;
        } else {
            height += floorf(width * 0.5);
        }
    } else {
        height += TL_THUMB_SIZE;
    }
    
    // Bottom Margin
    height += TL_THUMB_MARGIN / 2;
    
//    NSLog(@"numPhotos: %d, calc height: %f", numPhotos, height);
    
    return height;
}

- (void)tableView:(UITableView *)tableView fillCellWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
    self.object = object;
    self.indexPath = indexPath;
    
    // Fill Data
    NSArray *photos = (NSArray *)object;
    NSInteger numPhotos = [photos count];
    [self.imageDicts addObjectsFromArray:photos];
    
    self.profileIconSize = (numPhotos > 1) ? 32.0 : 32.0;

    [self.imageDicts enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        NSURL *sourceURL = [NSURL URLWithString:[dict objectForKey:@"source"]];
        NSURL *thumbnailURL = [NSURL URLWithString:[dict objectForKey:@"picture"]];
        NSURL *URL = (numPhotos > 1) ? thumbnailURL : sourceURL;
        PSCachedImageView *iv = [self dequeueImageViewWithURL:URL];
        [iv setOriginalURL:sourceURL];
        [iv setThumbnailURL:thumbnailURL];
        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)] autorelease];
        [iv addGestureRecognizer:gr];
        iv.layer.borderWidth = 0.0;
        iv.layer.borderColor = nil;
        [self.contentView addSubview:iv];
        [self.imageViews addObject:iv];
        
        // Add profile view
        PSCachedImageView *pv = [self dequeueImageViewWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[dict objectForKey:@"fbFrom"] objectForKey:@"id"]]]];
        // TODO
        // Detect (using flipboard's method) if pixel contrast is dark/light and choose black/white border
        pv.layer.borderWidth = 1.0;
        pv.layer.borderColor = [RGBACOLOR(255, 255, 255, 1.0) CGColor];
        [iv addSubview:pv];
        [self.profileViews addObject:pv];
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Read object
    NSArray *photos = (NSArray *)self.object;
    NSInteger numPhotos = [photos count];
    
    // Layout
    CGFloat left = TL_MARGIN;
    CGFloat top = TL_THUMB_MARGIN / 2;
    CGFloat width = self.contentView.width - TL_MARGIN * 2;
    
    CGFloat photoWidth = 0.0;
    CGFloat photoHeight = TL_THUMB_SIZE;
    switch (numPhotos) {
        case 1:
            photoWidth = width;
            // Special case, row is not first row but only 1 photo
            if (self.indexPath.row != 0) {
                photoHeight = TL_THUMB_SIZE;
            } else {
                photoHeight = floorf(width * 0.5);
            }
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
    
    [self.imageViews enumerateObjectsUsingBlock:^(UIImageView *iv, NSUInteger idx, BOOL *stop) {
        iv.frame = CGRectMake(left + idx * (TL_THUMB_MARGIN + photoWidth), top, photoWidth, photoHeight);
        
        // Add profile view
        UIImageView *pv = [self.profileViews objectAtIndex:idx];
        pv.frame = CGRectMake(iv.width - self.profileIconSize + 1, iv.height - self.profileIconSize + 1, self.profileIconSize, self.profileIconSize);
    }];
    
//    top += TL_THUMB_SIZE;
//    
//    top += TL_THUMB_MARGIN / 2;
}

#pragma mark - Zoom
- (void)zoom:(UITapGestureRecognizer *)gestureRecognizer {
    static BOOL isZooming;
    
    // If the image hasn't loaded, don't allow zoom
    PSCachedImageView *imageView = (PSCachedImageView *)gestureRecognizer.view;
    if (!imageView.image) return;
    
    // If already zooming, don't rezoom
    if (isZooming) return;
    else isZooming = YES;
    
    // make sure to zoom the full res image here
    NSURL *originalURL = imageView.originalURL;
    UIActivityIndicatorViewStyle oldStyle = imageView.loadingIndicator.activityIndicatorViewStyle;
    imageView.loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [imageView.loadingIndicator startAnimating];
    
    [[PSURLCache sharedCache] loadURL:originalURL cacheType:PSURLCacheTypePermanent usingCache:YES completionBlock:^(NSData *cachedData, NSURL *cachedURL, BOOL isCached, NSError *error) {
        [imageView.loadingIndicator stopAnimating];
        imageView.loadingIndicator.activityIndicatorViewStyle = oldStyle;
        isZooming = NO;
        
        if (!error) {
            UIImage *sourceImage = [UIImage imageWithData:cachedData];
            if (sourceImage) {
                UIViewContentMode contentMode = imageView.contentMode;
                PSZoomView *zoomView = [[[PSZoomView alloc] initWithImage:sourceImage contentMode:contentMode] autorelease];
                CGRect imageRect = [self.contentView convertRect:imageView.frame toView:self];
                [zoomView showInRect:[self convertRect:imageRect toView:nil]];
            }
        }
    }];
}

@end
