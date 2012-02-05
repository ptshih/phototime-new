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

@synthesize
topImageView = _topImageView,
lineView = _lineView,
hasLayout = _hasLayout;

+ (void)initialize {
    __reusableImageViews = [[NSMutableSet alloc] init];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.hasLayout = NO;
        
        self.topImageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.topImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.topImageView.clipsToBounds = YES;
        self.topImageView.userInteractionEnabled = YES;

        UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)] autorelease];
        [self.topImageView addGestureRecognizer:gr];
        
        _images = [[NSMutableArray arrayWithCapacity:1] retain];
        _imageViews = [[NSMutableArray arrayWithCapacity:1] retain];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [PSStyleSheet applyStyle:@"timelineTitle" forLabel:_titleLabel];
        
        _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [PSStyleSheet applyStyle:@"timelineSubtitle" forLabel:_subtitleLabel];
        
        self.lineView = [[[UIImageView alloc] initWithImage:[UIImage stretchableImageNamed:@"HorizontalLine" withLeftCapWidth:2 topCapWidth:0]] autorelease];
        
        [self.contentView addSubview:self.topImageView];
        [self.contentView addSubview:_titleLabel];
        [self.contentView addSubview:_subtitleLabel];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)dealloc {
    RELEASE_SAFELY(_topImageView);
    RELEASE_SAFELY(_lineView);
    
    RELEASE_SAFELY(_images);
    RELEASE_SAFELY(_imageViews);
    
    RELEASE_SAFELY(_titleLabel);
    RELEASE_SAFELY(_subtitleLabel);
    [super dealloc];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.hasLayout = NO;
    self.topImageView.image = nil;    
    
    [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [__reusableImageViews addObjectsFromArray:_imageViews];
    [_imageViews removeAllObjects];
    
//    [_images removeAllObjects];
    
//    [_imageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        UIImageView *iv = (UIImageView *)obj;
//        [iv.gestureRecognizers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            UIGestureRecognizer *gr = (UIGestureRecognizer *)obj;
//            [iv removeGestureRecognizer:gr];
//        }];
//        [iv removeFromSuperview];
//    }];
    
    
    _titleLabel.text = nil;
    _subtitleLabel.text = nil;
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
        [iv removeGestureRecognizer:[iv.gestureRecognizers lastObject]];
        [iv unloadImage];
        [__reusableImageViews removeObject:iv];
    }
    UITapGestureRecognizer *gr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoom:)] autorelease];
    [iv addGestureRecognizer:gr];
    
    [iv loadImageWithURL:URL];
    return iv;
}

+ (CGFloat)rowHeightForObject:(id)object forInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    NSInteger numImages = [[object objectForKey:@"photos"] count] - 1;
    CGFloat height = 0.0;
    CGFloat width = [[self class] rowWidthForInterfaceOrientation:interfaceOrientation] - TL_MARGIN * 2;
    
    // Top Margin
    height += TL_MARGIN;
    
    // Always account for top image
    height += floorf(width * 0.5);
    height += TL_MARGIN;
    
    // Additional Images
    if (numImages > 0) {
        height += 80.0;
        height += TL_MARGIN;
    }
    
    // Labels
//    height += TL_CAPTION_HEIGHT;
    
    // Line View
    height += 1.0;
    
    // Bottom Margin
//    height += TL_MARGIN;
    
    return height;
}

- (void)fillCellWithObject:(id)object {
    [_images addObjectsFromArray:[object objectForKey:@"photos"]];
    
    // Configure top image
    if ([_images count] > 0) {
        NSDictionary *i = [_images objectAtIndex:0];
        [self.topImageView loadImageWithURL:[NSURL URLWithString:[i objectForKey:@"source"]]];
        [_images removeObjectAtIndex:0];
    }
    
    // Labels
    //  NSDictionary *from = [object objectForKey:@"fb_from"];
    _titleLabel.text = @"Some Title Here";
    _subtitleLabel.text = @"Some Subtitle Here";
//    _titleLabel.text = [[object objectForKey:@"timestamp"] description];
//    _subtitleLabel.text = [[object objectForKey:@"location"] description];
    
    // Setup main content bounds
    // This assumes that contentView is about 300px wide after 10px margins
    //    self.contentView.frame = CGRectMake(TL_MARGIN, TL_MARGIN, self.width - TL_MARGIN * 2, self.height - TL_MARGIN * 2);
    
    // Dimensions
    CGFloat left = TL_MARGIN;
    CGFloat top = TL_MARGIN;
    CGFloat width = self.contentView.width - TL_MARGIN * 2;
    
    // Top Image View (4:3)
    CGFloat topImageWidth = width;
    CGFloat topImageHeight = floorf(width * 0.5);
    self.topImageView.frame = CGRectMake(left, top, topImageWidth, topImageHeight);
    
    top = self.topImageView.bottom + TL_MARGIN;
    
    // Additional Images
    NSInteger numImages = [_images count];
    if (numImages > 0) {
        CGFloat colOffset = left;
        CGFloat rowOffset = top;
        NSInteger numRows = 1;
        while (1) {
            NSDictionary *current = [[[_images objectAtIndex:0] retain] autorelease];
            [_images removeObjectAtIndex:0];
            NSInteger remaining = [_images count];
            
            PSCachedImageView *iv = [self dequeueImageViewWithURL:[NSURL URLWithString:[current objectForKey:@"source"]]];
            
            if (remaining == 0) {
                iv.frame = CGRectMake(colOffset, rowOffset, self.contentView.width - colOffset - TL_MARGIN, 80.0);
            } else {
                iv.frame = CGRectMake(colOffset, rowOffset, 80.0, 80.0);
            }
            colOffset += 80.0 + TL_MARGIN;
            if (colOffset > width) {
                colOffset = 0.0;
                rowOffset += 80.0 + TL_MARGIN;
                numRows++;
            }
            
            [self.contentView addSubview:iv];
            [_imageViews addObject:iv];
            
            if (remaining == 0) break;
        }
        
        top += numRows * 80.0 + TL_MARGIN;
    }
    
    // Labels
//    _titleLabel.frame = CGRectMake(left, top, floorf(width * (2.0 / 4.0)), TL_CAPTION_HEIGHT);
//    _subtitleLabel.frame = CGRectMake(floorf(width * (2.0 / 4.0)), top, floorf(width * (2.0 / 4.0)), TL_CAPTION_HEIGHT);
    
    self.lineView.frame = CGRectMake(left, top, width, 1.0);
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
