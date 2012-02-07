//
//  UserCell.m
//  Phototime
//
//  Created by Peter on 2/7/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UserCell.h"

@implementation UserCell

+ (CGFloat)rowHeight {
    return 60.0;
}

- (void)fillCellWithObject:(id)object {
    NSDictionary *dict = (NSDictionary *)object;
//    self.imageView.image =
    self.textLabel.text = [dict objectForKey:@"name"];
    self.detailTextLabel.text = [dict objectForKey:@"id"];
}

@end
