//
//  TimelineView.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineView.h"
#import "PSCachedImageView.h"

#define MARGIN 4.0
#define PROFILE_SIZE 20.0
#define SOCIAL_SIZE 22.0

@interface TimelineView ()

@property (nonatomic, retain) TTTAttributedLabel *actionLabel;

@end

@implementation TimelineView

@synthesize
presentingController = _presentingController,
object = _object,
imageView = _imageView,
actionLabel = _actionLabel;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        UIImage *shadowImage = [[UIImage imageNamed:@"Shadow"] stretchableImageWithLeftCapWidth:3 topCapHeight:3];
        UIImageView *shadowView = [[[UIImageView alloc] initWithImage:shadowImage] autorelease];
        shadowView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        shadowView.frame = CGRectInset(self.bounds, -1, -2);
        [self addSubview:shadowView];
        
        self.imageView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
        self.imageView.shouldAnimate = YES;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        // Must set to 0 lines and word wrap line break mode
        self.actionLabel = [[[TTTAttributedLabel alloc] initWithFrame:CGRectZero] autorelease];
        [PSStyleSheet applyStyle:@"attributedLabelRegular" forLabel:self.actionLabel];
        [self addSubview:self.actionLabel];
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    self.imageView = nil;
    self.actionLabel = nil;

    [super dealloc];
}

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
    self.actionLabel.text = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
//    CGFloat right = self.width - MARGIN;
    
    NSDictionary *original = [self.object objectForKey:@"original"];
    
    CGFloat objectWidth = [[original objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[original objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top = self.imageView.bottom + MARGIN;
    
    
    CGSize labelSize = [PSStyleSheet sizeForText:self.actionLabel.text width:width style:@"attributedLabelRegular"];
    self.actionLabel.top = top;
    self.actionLabel.left = left;
    self.actionLabel.width = width;
    self.actionLabel.height = labelSize.height;
}

- (void)fillViewWithObject:(id)object {
    [self fillViewWithObject:object presentingController:nil];
}

- (void)fillViewWithObject:(id)object presentingController:(UIViewController *)presentingController {
    self.presentingController = presentingController;
    self.object = object;
    
    NSDictionary *original = [self.object objectForKey:@"original"];
    NSDictionary *thumbnail = [self.object objectForKey:@"thumbnail"];
    NSDictionary *user = [self.object objectForKey:@"user"];
    NSDictionary *location = [self.object objectForKey:@"location"];
    NSNumber *createdAt = [self.object objectForKey:@"createdAt"];
    NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:[createdAt doubleValue]];
    NSString *createdString = [[PSDateFormatter sharedDateFormatter] shortRelativeStringFromDate:createdDate];
    NSString *attribution = nil;
    if ([self.object objectForKey:@"fbPhotoId"]) {
        attribution = @" via Facebook";
    } else if ([self.object objectForKey:@"igPhotoId"]) {
        attribution = @" via Instagram";
    } else {
        attribution = @" via Phototime";
    }
    NSString *locationText = nil;
    if ([location notNull] && [[location objectForKey:@"name"] notNull]) {
        locationText = [NSString stringWithFormat:@" @ %@", [location objectForKey:@"name"]];
    } else {
        locationText = @"";
    }
    
    NSString *userName = [user objectForKey:@"name"];
    NSString *caption = [self.object objectForKey:@"caption"];
    
    NSString *captionText = [caption notNull] ? caption : @"a photo";
    NSString *actionText = [NSString stringWithFormat:@"%@ took %@ %@%@%@", userName, captionText, createdString, locationText, attribution];
    
    // Setup Image
    self.imageView.originalURL = [NSURL URLWithString:[original objectForKey:@"url"]];
    self.imageView.thumbnailURL = [NSURL URLWithString:[thumbnail objectForKey:@"url"]];
    [self.imageView loadImageWithURL:self.imageView.thumbnailURL cacheType:PSURLCacheTypePermanent];
    
    // Setup Label
    [self.actionLabel setText:actionText afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange userNameRange = [[mutableAttributedString string] rangeOfString:userName options:NSCaseInsensitiveSearch];
        NSRange captionRange = [[mutableAttributedString string] rangeOfString:captionText options:NSCaseInsensitiveSearch];
        NSRange attributionRange = [[mutableAttributedString string] rangeOfString:attribution options:NSCaseInsensitiveSearch];
        
        // Color
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:userNameRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:captionRange];
        [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x70695A] CGColor] range:attributionRange];
        
        if ([location notNull] && [[location objectForKey:@"name"] notNull]) {
            NSRange locationRange = [[mutableAttributedString string] rangeOfString:[location objectForKey:@"name"] options:NSCaseInsensitiveSearch];
            
            [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[[UIColor colorWithRGBHex:0x3B5998] CGColor] range:locationRange];
        }
        
        return mutableAttributedString;
    }];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    NSDictionary *original = [object objectForKey:@"original"];
//    NSDictionary *thumbnail = [object objectForKey:@"thumbnail"];
    NSDictionary *user = [object objectForKey:@"user"];
    NSDictionary *location = [object objectForKey:@"location"];
    NSNumber *createdAt = [object objectForKey:@"createdAt"];
    NSDate *createdDate = [NSDate dateWithTimeIntervalSince1970:[createdAt doubleValue]];
    NSString *createdString = [[PSDateFormatter sharedDateFormatter] shortRelativeStringFromDate:createdDate];
    NSString *attribution = nil;
    if ([object objectForKey:@"fbPhotoId"]) {
        attribution = @" via Facebook";
    } else if ([object objectForKey:@"igPhotoId"]) {
        attribution = @" via Instagram";
    } else {
        attribution = @" via Phototime";
    }
    NSString *locationText = nil;
    if ([location notNull] && [[location objectForKey:@"name"] notNull]) {
        locationText = [NSString stringWithFormat:@" @ %@", [location objectForKey:@"name"]];
    } else {
        locationText = @"";
    }
    
    NSString *userName = [user objectForKey:@"name"];
    NSString *caption = [object objectForKey:@"caption"];
    
    NSString *captionText = [caption notNull] ? caption : @"a photo";
    NSString *actionText = [NSString stringWithFormat:@"%@ took %@ %@%@%@", userName, captionText, createdString, locationText, attribution];
    
    height += MARGIN;
    
    // Image
    CGFloat objectWidth = [[original objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[original objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    // Label
    CGSize labelSize = [PSStyleSheet sizeForText:actionText width:width style:@"attributedLabelRegular"];
    height += labelSize.height;
    
    height += MARGIN;
    
    return height;
}

@end
