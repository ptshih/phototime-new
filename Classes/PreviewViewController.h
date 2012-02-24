//
//  PreviewViewController.h
//  OSnap
//
//  Created by Peter Shih on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PSViewController.h"

@interface PreviewViewController : PSViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

- (void)uploadPhotoWithData:(NSData *)data width:(CGFloat)width height:(CGFloat)height metadata:(NSDictionary *)metadata;

@end
