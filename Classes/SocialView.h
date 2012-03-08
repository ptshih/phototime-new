//
//  SocialView.h
//  Phototime
//
//  Created by Peter on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSView.h"

@interface SocialView : PSView

- (void)prepareForReuse;

- (void)loadWithLikes:(NSUInteger)likes comments:(NSUInteger)comments;

@end
