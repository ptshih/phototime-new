//
//  PreviewViewController.m
//  OSnap
//
//  Created by Peter Shih on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreviewViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

@implementation PreviewViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
  }
  return self;
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)dealloc {
  [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
}

#pragma mark - View Config
- (UIColor *)baseBackgroundColor {
  return [UIColor blackColor];
}

#pragma mark - Config Subviews

#pragma mark - Actions


#pragma mark - ImagePickerDelegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [(PSNavigationController *)picker.parentViewController popViewControllerAnimated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
}

#pragma mark - Camera/Photo
- (void)uploadPhotoWithData:(NSData *)data width:(CGFloat)width height:(CGFloat)height metadata:(NSDictionary *)metadata {
  // Read out metadata
  // width
  // height
  // datetime
  // gps - lat, lng
  NSNumber *exifWidth = [NSNumber numberWithFloat:width];
  NSNumber *exifHeight = [NSNumber numberWithFloat:height];
  
  NSDictionary *exif = [metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary];
  NSDictionary *gps = [metadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
  
  NSMutableString *exifDatetime = nil;
  if (exif) {
    NSString *unformattedDateAsString = [exif objectForKey:(NSString *)kCGImagePropertyExifDateTimeOriginal];
    
    exifDatetime = [[unformattedDateAsString mutableCopy] autorelease];
    //make sure the date stored in the metadata is not nil, and contains a meaningful date
    if(exifDatetime && ![exifDatetime isEqualToString:@""] && ![exifDatetime isEqualToString:@"0000:00:00 00:00:00"]) {
      // the date (not the time) part of the string needs to contain dashes, not colons, for NSDate to read it correctly
      [exifDatetime replaceOccurrencesOfString:@":" withString:@"-" options:0 range:NSMakeRange(0, 10)]; //the first 10 characters are the date part
      //the EXIF spec does not allow the time zone to be saved with the date,
      // so we must assume the camera’s clock is set to the same time zone as the computer’s.
      [exifDatetime appendString:@" +0000"];
    }
  }
  
  NSString *exifLatitude = nil;
  NSString *exifLongitude = nil;
  if (gps) {
    exifLatitude = [gps objectForKey:(NSString *)kCGImagePropertyGPSLatitude];
    exifLongitude = [gps objectForKey:(NSString *)kCGImagePropertyGPSLongitude];
  }
  
  // Set parameters
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:[NSNumber numberWithBool:YES] forKey:@"hasExif"];
  if (exifDatetime) [params setObject:exifDatetime forKey:@"exifDatetime"];
  if (exifLatitude) [params setObject:exifLatitude forKey:@"exifLatitude"];
  if (exifLongitude) [params setObject:exifLongitude forKey:@"exifLongitude"];
  if (exifWidth) [params setObject:exifWidth forKey:@"exifWidth"];
  if (exifHeight) [params setObject:exifHeight forKey:@"exifHeight"];
  
  // Upload
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/upload", API_BASE_URL]];
  AFHTTPClient *httpClient = [[[AFHTTPClient alloc] initWithBaseURL:url] autorelease];
  NSData *uploadData = data;
  NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST" path:@"/upload" parameters:params constructingBodyWithBlock:^(id <AFMultipartFormData>formData) {
    [formData appendPartWithFileData:uploadData name:@"photo" fileName:@"upload.jpg" mimeType:@"image/jpeg"];
  }];
  
  AFHTTPRequestOperation *op = [[[AFHTTPRequestOperation alloc] initWithRequest:request] autorelease];
  
  [op setUploadProgressBlock:^(NSInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
    NSLog(@"Sent %d of %d bytes", totalBytesWritten, totalBytesExpectedToWrite);
  }];
  
  [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
    NSInteger statusCode = [operation.response statusCode];
    if (statusCode == 200) {
      [(PSNavigationController *)self.parentViewController popViewControllerAnimated:YES];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    // Something bad happened
    [(PSNavigationController *)self.parentViewController popViewControllerAnimated:YES];
  }];
  
  NSOperationQueue *queue = [[[NSOperationQueue alloc] init] autorelease];
  [queue addOperation:op];
}


@end
