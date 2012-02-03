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

#define IMAGES_PER_ROW 4

static NSMutableSet *__reusableImageViews = nil;

@implementation TimelineCell

+ (void)initialize {
    __reusableImageViews = [[NSMutableSet alloc] init];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _images = [[NSMutableArray arrayWithCapacity:1] retain];
        _imageViews = [[NSMutableArray arrayWithCapacity:1] retain];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [PSStyleSheet applyStyle:@"timelineTitle" forLabel:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [PSStyleSheet applyStyle:@"timelineSubtitle" forLabel:_subtitleLabel];
        
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subtitleLabel];
    }
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(_images);
    RELEASE_SAFELY(_imageViews);
    
    RELEASE_SAFELY(_titleLabel);
    RELEASE_SAFELY(_subtitleLabel);
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [__reusableImageViews addObjectsFromArray:_imageViews];
    [_imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *iv = (UIImageView *)obj;
        [iv.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIGestureRecognizer *gr = (UIGestureRecognizer *)obj;
            [iv removeGestureRecognizer:gr];
        }];
        [iv removeFromSuperview];
    }];
    [_imageViews removeAllObjects];
    [_images removeAllObjects];
    _titleLabel.text = nil;
    _subtitleLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = CGRectMake(TL_MARGIN, TL_MARGIN, self.width - TL_MARGIN * 2, self.height - TL_MARGIN * 2);
    
    CGFloat width = self.contentView.width;
    CGFloat height = self.contentView.height - TL_CAPTION_HEIGHT - TL_MARGIN;
    
    // Images
    CGFloat iWidth = 0.0;
    CGFloat iSpacing = 0.0;
    NSInteger numImages = [_images count];
    
    CGFloat iHeight = 0.0;
    NSInteger numRows = (([_images count] - 1) / IMAGES_PER_ROW) + 1;
    iHeight = floorf(height / numRows);
    
    if (numImages == 1) {
        iWidth = width;
    } else if (numImages == 2) {
        iWidth = floorf(width / 2.0);
        iSpacing = 4.0;
        iWidth -= 2.0;
        iHeight -= 2.0;
    } else if (numImages == 3) {
        iWidth = floorf(width / 3);
        iSpacing = 3.0;
        iWidth -= 2.0;
        iHeight -= 2.0;
    } else {
        iWidth = floorf(width / 4.0);
        iSpacing = 4.0;
        iWidth -= 3.0;
        iHeight -= 3.0;
    }
    
    // TODO: If not an even multiple of 4, one image will stretch to fill
    //  CGFloat remainder = numRows * IMAGES_PER_ROW - numImages;
    
    [_imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger col = idx % IMAGES_PER_ROW;
        NSInteger row = idx / IMAGES_PER_ROW;
        CGFloat left = col * (iWidth + iSpacing);
        CGFloat top = row * (iHeight + iSpacing);
        
        PSCachedImageView *iv = (PSCachedImageView *)obj;
        iv.frame = CGRectMake(left, top, iWidth, iHeight);
    }];
    
    // Labels
    _titleLabel.frame = CGRectMake(0, height + TL_MARGIN, floorf(width * (2.0 / 4.0)), TL_CAPTION_HEIGHT);
    _subtitleLabel.frame = CGRectMake(floorf(width * (2.0 / 4.0)), height + TL_MARGIN, floorf(width * (2.0 / 4.0)), TL_CAPTION_HEIGHT);
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSArray *images = [object objectForKey:@"photos"];
    NSInteger numImages = [images count];
    NSInteger numRows = ((numImages - 1) / IMAGES_PER_ROW) + 1;
    
    NSLog(@"numImages: %d, numRows: %d", numImages, numRows);
    
    if (numImages == 1) return 160.0 + TL_CAPTION_HEIGHT + TL_MARGIN * 2;
    else return 80.0 * numRows + TL_CAPTION_HEIGHT + TL_MARGIN * 2;
}

- (void)fillCellWithObject:(id)object {
    [_images addObjectsFromArray:[object objectForKey:@"photos"]];
    
    // Here we should format the cell
    // There should always be a featured image on top, and an array of additional images on bottom that follow set guidelines
    // If 2, split then 50/50
    // If 3, split them 33/33/33
    // If > 3, split and fill as necessary in priority order, 3 -> 2 -> 1
    
    
    [_images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {    
        NSString *source = [obj objectForKey:@"source"];
        PSCachedImageView *iv = [[[__reusableImageViews anyObject] retain] autorelease];
        if (!iv) {
            iv = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            iv.userInteractionEnabled = YES;
        } else {
            [__reusableImageViews removeObject:iv];
        }
        [_imageViews addObject:iv];
        [self.contentView addSubview:iv];
        [iv unloadImage];
        [iv loadThumbnailWithURL:[NSURL URLWithString:source]];
        //    [iv loadImageWithURL:[NSURL URLWithString:source]];
        UITapGestureRecognizer *zoomGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)] autorelease];
        [iv addGestureRecognizer:zoomGesture];
    }];
    
    // Labels
    //  NSDictionary *from = [object objectForKey:@"fb_from"];
    _titleLabel.text = [[object objectForKey:@"timestamp"] description];
    _subtitleLabel.text = [[object objectForKey:@"location"] description];
    
}

#pragma mark - Zoom
- (void)zoom:(UITapGestureRecognizer *)gestureRecognizer {
    PSCachedImageView *imageView = (PSCachedImageView *)gestureRecognizer.view;
    UIViewContentMode contentMode = imageView.contentMode;
    PSZoomView *zoomView = [[[PSZoomView alloc] initWithImage:imageView.image contentMode:contentMode] autorelease];
    [zoomView loadFullResolutionWithURL:[imageView url]];
    CGRect imageRect = [self.contentView convertRect:imageView.frame toView:self];
    [zoomView showInRect:[self convertRect:imageRect toView:nil]];
}

@end
