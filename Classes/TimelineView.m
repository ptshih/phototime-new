//
//  TimelineView.m
//  OSnap
//
//  Created by Peter Shih on 12/28/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "TimelineView.h"
#import "PSCachedImageView.h"
#import "PhotoDetailViewController.h"

#define MARGIN 4.0
#define PROFILE_SIZE 20.0
#define SOCIAL_SIZE 20.0

@implementation TimelineView

@synthesize
presentingController = _presentingController,
object = _object,
imageView = _imageView,
profileView = _profileView,
nameLabel = _nameLabel,
socialButton = _socialButton;

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
        
//        self.profileView = [[[PSCachedImageView alloc] initWithFrame:CGRectZero] autorelease];
//        self.profileView.shouldAnimate = YES;
//        self.profileView.clipsToBounds = YES;
//        [self addSubview:self.profileView];
        
        self.nameLabel = [UILabel labelWithStyle:@"subtitleLabel"];
        self.nameLabel.textAlignment = UITextAlignmentCenter;
        [self addSubview:self.nameLabel];
        
        self.socialButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.socialButton.backgroundColor = RGBACOLOR(200, 200, 200, 1.0);
        [PSStyleSheet applyStyle:@"metaLabel" forButton:self.socialButton];
        [self.socialButton addTarget:self action:@selector(pushSocial:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.socialButton];
    }
    return self;
}

- (void)dealloc {
    self.object = nil;
    self.imageView = nil;
//    self.profileView = nil;
    self.nameLabel = nil;
    self.socialButton = nil;

    [super dealloc];
}

- (void)pushSocial:(UIButton *)sender {
    PhotoDetailViewController *vc = [[[PhotoDetailViewController alloc] initWithDictionary:self.object] autorelease];
    [(PSNavigationController *)self.presentingController.parentViewController pushViewController:vc animated:YES];
}

- (void)prepareForReuse {
    [self.imageView prepareForReuse];
//    [self.profileView prepareForReuse];
    self.nameLabel.text = nil;
    [self.socialButton setTitle:@"" forState:UIControlStateNormal];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    CGFloat width = self.width - MARGIN * 2;
    CGFloat top = MARGIN;
    CGFloat left = MARGIN;
//    CGFloat right = self.width - MARGIN;
    
    CGFloat objectWidth = [[self.object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[self.object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    self.imageView.frame = CGRectMake(left, top, width, scaledHeight);
    
    top = self.imageView.bottom + MARGIN;
    
//    self.profileView.frame = CGRectMake(left, top, PROFILE_SIZE, PROFILE_SIZE);
//    
//    left += self.profileView.width + MARGIN;
//    width -= self.profileView.width + MARGIN;
    
    CGSize labelSize = [PSStyleSheet sizeForText:self.nameLabel.text width:width style:@"subtitleLabel"];
    self.nameLabel.top = top;
    self.nameLabel.left = left;
    self.nameLabel.width = width;
    self.nameLabel.height = labelSize.height;
    
    top = self.nameLabel.bottom + MARGIN;
    
    self.socialButton.frame = CGRectMake(left, top, width, SOCIAL_SIZE);
//    [self.socialButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
//    [self.socialButton setContentEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
}

- (void)fillViewWithObject:(id)object {
    [self fillViewWithObject:object presentingController:nil];
}

- (void)fillViewWithObject:(id)object presentingController:(UIViewController *)presentingController {
    self.presentingController = presentingController;
    self.object = object;
    
    [self.imageView setOriginalURL:[NSURL URLWithString:[self.object objectForKey:@"source"]]];
    [self.imageView setThumbnailURL:[NSURL URLWithString:[self.object objectForKey:@"picture"]]];
    [self.imageView loadImageWithURL:[NSURL URLWithString:[self.object objectForKey:@"picture"]] cacheType:PSURLCacheTypePermanent];
    
//    NSURL *profileURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture", [[self.object objectForKey:@"fbFrom"] objectForKey:@"id"]]];
//    [self.profileView loadImageWithURL:profileURL cacheType:PSURLCacheTypePermanent];
    
    NSString *displayName = nil;
    NSString *name = [[object objectForKey:@"fbFrom"] objectForKey:@"name"];
    if (0) {
        NSArray *nameComponents = [name componentsSeparatedByString:@" "];
        NSString *firstName = [nameComponents objectAtIndex:0];
        NSString *lastName = [nameComponents lastObject];
        displayName = [NSString stringWithFormat:@"%@ %@.", firstName, [lastName substringToIndex:1]];
    } else {
        displayName = [NSString stringWithFormat:@"%@", name];
    }
    
    self.nameLabel.text = displayName;
    
    NSInteger likeCount = 0;
    NSInteger commentCount = 0;
    if ([[self.object objectForKey:@"likes"] notNull]) {
        NSArray *likes = [[self.object objectForKey:@"likes"] objectForKey:@"data"];
        likeCount = [likes count];
    }
    if ([[self.object objectForKey:@"comments"] notNull]) {
        NSArray *comments = [[self.object objectForKey:@"comments"] objectForKey:@"data"];
        commentCount = [comments count];
    }
    [self.socialButton setTitle:[NSString stringWithFormat:@"%d Likes %d Comments", likeCount, commentCount] forState:UIControlStateNormal];
}

+ (CGFloat)heightForViewWithObject:(id)object inColumnWidth:(CGFloat)columnWidth {
    CGFloat height = 0.0;
    CGFloat width = columnWidth - MARGIN * 2;
    
    height += MARGIN;
    
    CGFloat objectWidth = [[object objectForKey:@"width"] floatValue];
    CGFloat objectHeight = [[object objectForKey:@"height"] floatValue];
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / width));
    height += scaledHeight;
    
    height += MARGIN;
    
    NSString *displayName = nil;
    NSString *name = [[object objectForKey:@"fbFrom"] objectForKey:@"name"];
    if (0) {
        NSArray *nameComponents = [name componentsSeparatedByString:@" "];
        NSString *firstName = [nameComponents objectAtIndex:0];
        NSString *lastName = [nameComponents lastObject];
        displayName = [NSString stringWithFormat:@"%@ %@.", firstName, [lastName substringToIndex:1]];
    } else {
        displayName = [NSString stringWithFormat:@"%@", name];
    }
    
//    width -= PROFILE_SIZE + MARGIN;
    
    CGSize labelSize = [PSStyleSheet sizeForText:displayName width:width style:@"subtitleLabel"];
    height += labelSize.height;
    
    height += MARGIN;
    
    height += SOCIAL_SIZE;
    
    height += MARGIN;
    
//MAX(height, PROFILE_SIZE + MARGIN * 2);
    return height;
}

@end
