//
//  PreviewViewController.m
//  OSnap
//
//  Created by Peter Shih on 1/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreviewViewController.h"
#import "PSLocationCenter.h"
#import "AFNetworking.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/UTCoreTypes.h>

@implementation PreviewViewController

- (id)initWithImage:(UIImage *)image metadata:(NSDictionary *)metadata {
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    _image = [image copy];
    _metadata = [metadata copy];
  }
  return self;
}

- (id)initWithImage:(UIImage *)image assetURL:(NSURL *)assetURL {
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    _image = [image copy];
    _assetURL = [assetURL copy];
  }
  return self;  
}

- (id)initWithAssetURL:(NSURL *)assetURL {
  self = [self initWithNibName:nil bundle:nil];
  if (self) {
    _assetURL = [assetURL copy];
    
    ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset) {
      // Get representation
      ALAssetRepresentation *rep = [asset defaultRepresentation];
      ALAssetOrientation assetOrientation = [rep orientation];
      CGFloat assetScale = [rep scale];
      CGImageRef imageRef = [rep fullResolutionImage];
      _image = [[UIImage imageWithCGImage:imageRef scale:assetScale orientation:(UIImageOrientation)assetOrientation] retain];
      
      // Read metadata from original
      _metadata = [[rep metadata] retain];      
    };
    
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
      NSLog(@"cant get image - %@", [error localizedDescription]);
    };
    
    ALAssetsLibrary *assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    [assetsLibrary assetForURL:assetURL resultBlock:resultBlock failureBlock:failureBlock];
  }
  return self;
}

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
  RELEASE_SAFELY(_image);
  RELEASE_SAFELY(_metadata);
  RELEASE_SAFELY(_assetURL);
  [super dealloc];
}

#pragma mark - View
- (void)viewDidLoad {
  [super viewDidLoad];
  
//  [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
  [[UIApplication sharedApplication] setStatusBarHidden:NO];
  self.navigationController.navigationBarHidden = NO;
  
  self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(post)] autorelease];
  
  // Setup Views
//  [self setupHeader];
//  [self setupFooter];
  [self setupSubviews];
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
- (void)setupSubviews {
  _photoView = [[UIImageView alloc] initWithImage:_image];
  _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
  _photoView.contentMode = UIViewContentModeScaleAspectFit;
  _photoView.frame = _contentView.bounds;
  [self.contentView addSubview:_photoView];
}

#pragma mark - Actions

- (void)post {
  // Check to see if this was taken with the camera, if so save to asset library
  if (!_assetURL) {
    ALAssetsLibrary *assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
    
    if (_metadata) {
      NSMutableDictionary *newMetadata = [NSMutableDictionary dictionaryWithDictionary:_metadata];
      NSDictionary *location = [[PSLocationCenter defaultCenter] exifLocation];
      if ([location count] > 0) {
        [newMetadata setObject:location forKey:(NSString*)kCGImagePropertyGPSDictionary];
      }
    }
    
    [assetsLibrary writeImageToSavedPhotosAlbum:[_image CGImage] metadata:_metadata completionBlock:^(NSURL *assetURL, NSError *error){
      if (assetURL) {
        _assetURL = [assetURL copy];
        [self uploadPhotoWithAssetURL:_assetURL];
      }
    }];
  } else {
    [self uploadPhotoWithAssetURL:_assetURL];
  }
}

#pragma mark - Camera/Photo
- (void)getExifFromData:(NSData *)data {
  CGImageSourceRef ref = CGImageSourceCreateWithData((CFDataRef)data, NULL);
  NSDictionary *dict = (NSDictionary *)CGImageSourceCopyPropertiesAtIndex(ref
                                                                          , 0, NULL);
  NSDictionary *exif = [dict objectForKey:(NSString *)kCGImagePropertyExifDictionary];
  NSDictionary *gps = [dict objectForKey:(NSString *)kCGImagePropertyGPSDictionary];
  NSDictionary *tiff = [dict objectForKey:(NSString *)kCGImagePropertyTIFFDictionary];
  
  NSLog(@"METADATA: %@", dict);
  NSLog(@"Exif: %@", exif);
  NSLog(@"GPS: %@", gps);
  NSLog(@"TIFF: %@", tiff);
}

- (void)uploadPhotoWithAssetURL:(NSURL *)assetURL {
  ALAssetsLibraryAssetForURLResultBlock resultBlock = ^(ALAsset *asset) {
    // Read properties
    //    NSString *assetType = [asset valueForProperty:ALAssetPropertyType];
    //    CLLocation *location = [asset valueForProperty:ALAssetPropertyLocation];
    
    // Get representation
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    //    ALAssetOrientation assetOrientation = [rep orientation];
    //    CGFloat assetScale = [rep scale];
    
    // Read metadata from original
    NSDictionary *metadata = [rep metadata];
    NSString *uti = [rep UTI];
    
    // get full res image
    CGImageRef imageRef = [rep fullResolutionImage];
    
    /**
     Scale image
     
     When scaling we don't want to pass in the orientation.
     Raw data is written with EXIF orientation
     
     If we scale with orientation transform, the image will be double-rotated once during scale and another during EXIF rotation
     */
    CGImageRef scaledImageRef = CreateCGImageWithinSize(imageRef, CGSizeMake(720.0, 720.0), UIImageOrientationUp);
    CGFloat scaledWidth = CGImageGetWidth(scaledImageRef);
    CGFloat scaledHeight = CGImageGetHeight(scaledImageRef);
    
    // Make the metadata dictionary mutable so we can add/edit properties to it
    NSMutableDictionary *mutableMetadata = [[metadata mutableCopy] autorelease];
    
    // CGImageProperties
    // We are writing the scaled width and height into cgimage properties
    [mutableMetadata setObject:[NSNumber numberWithFloat:scaledWidth] forKey:(NSString *)kCGImagePropertyPixelWidth];
    [mutableMetadata setObject:[NSNumber numberWithFloat:scaledHeight] forKey:(NSString *)kCGImagePropertyPixelHeight];
    
    // EXIF
    NSMutableDictionary *exifDict = [[[mutableMetadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy] autorelease];
    if(!exifDict) {
      exifDict = [NSMutableDictionary dictionary];
      
      // We are writing the scaled width and height into exif
      [exifDict setObject:[NSNumber numberWithFloat:scaledWidth] forKey:(NSString *)kCGImagePropertyExifPixelXDimension];
      [exifDict setObject:[NSNumber numberWithFloat:scaledHeight] forKey:(NSString *)kCGImagePropertyExifPixelYDimension];
      
      if (exifDict) {
        [mutableMetadata setObject:exifDict forKey:(NSString *)kCGImagePropertyExifDictionary];
      }
    }
    
    // GPS
    NSMutableDictionary *gpsDict = [[[mutableMetadata objectForKey:(NSString *)kCGImagePropertyGPSDictionary] mutableCopy] autorelease];
    if(!gpsDict) {
      gpsDict = [[PSLocationCenter defaultCenter] exifLocation];
      
      if (gpsDict) {
        [mutableMetadata setObject:gpsDict forKey:(NSString *)kCGImagePropertyGPSDictionary];
      }
    }
    
    // Write out the new CGImage with metadata to NSMutableData
    NSMutableData *scaledData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((CFMutableDataRef)scaledData, (CFStringRef)uti, 1, NULL);
    
    // add the image contained in the image source to the destination, overidding the old metadata with our modified metadata
    CGImageDestinationAddImage(destination, scaledImageRef, (CFDictionaryRef)mutableMetadata);
    
    CGImageDestinationFinalize(destination);
    
    [self getExifFromData:scaledData];
    
    [self uploadPhotoWithData:scaledData width:scaledWidth height:scaledHeight metadata:metadata];
    
    
    
    // Read raw data
    //    long long assetSize = rep.size;
    //    uint8_t *buffer = (uint8_t *)malloc(sizeof(uint8_t)*assetSize);
    //    NSError *error = nil;
    //    [rep getBytes:buffer fromOffset:0 length:assetSize error:&error];
    //    if (error) {
    //      NSLog(@"Default Representation getBytes with error: %@", error);
    //    }
    //    NSData *rawData = [NSData dataWithBytesNoCopy:buffer length:assetSize freeWhenDone:YES];
    
    // get full res image
    //    CGImageRef imageRef = [rep fullResolutionImage];
    //    CGImageRef scaledImageRef = CreateCGImageWithinSize(imageRef, CGSizeMake(720.0, 720.0), (UIImageOrientation)assetOrientation);
    //    UIImage *scaledImage = [UIImage imageWithCGImage:imageRef scale:assetScale orientation:(UIImageOrientation)assetOrientation];
    //
    //    CGFloat scaledWidth = CGImageGetWidth(scaledImageRef);
    //    CGFloat scaledHeight = CGImageGetHeight(scaledImageRef);
    
    //    [self getExifFromData:rawData];
    
    //    [self uploadPhotoWithData:rawData];
    
  };
  
  ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
    NSLog(@"cant get image - %@", [error localizedDescription]);
  };
  
  ALAssetsLibrary *assetsLibrary = [[[ALAssetsLibrary alloc] init] autorelease];
  [assetsLibrary assetForURL:assetURL resultBlock:resultBlock failureBlock:failureBlock];
}

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
  AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
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
