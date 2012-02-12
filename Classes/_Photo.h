// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Photo.h instead.

#import <CoreData/CoreData.h>
#import "PSManagedObject.h"

extern const struct PhotoAttributes {
	 NSString *createdAt;
	 NSString *fbPhotoId;
	 NSString *formattedDate;
	 NSString *height;
	 NSString *id;
	 NSString *ownerId;
	 NSString *ownerName;
	 NSString *picture;
	 NSString *source;
	 NSString *width;
} PhotoAttributes;

extern const struct PhotoRelationships {
} PhotoRelationships;

extern const struct PhotoFetchedProperties {
} PhotoFetchedProperties;













@interface PhotoID : NSManagedObjectID {}
@end

@interface _Photo : PSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (PhotoID*)objectID;




@property (nonatomic, retain) NSDate *createdAt;


//- (BOOL)validateCreatedAt:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *fbPhotoId;


//- (BOOL)validateFbPhotoId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *formattedDate;


//- (BOOL)validateFormattedDate:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *height;


@property int heightValue;
- (int)heightValue;
- (void)setHeightValue:(int)value_;

//- (BOOL)validateHeight:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *id;


//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *ownerId;


//- (BOOL)validateOwnerId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *ownerName;


//- (BOOL)validateOwnerName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *picture;


//- (BOOL)validatePicture:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *source;


//- (BOOL)validateSource:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *width;


@property int widthValue;
- (int)widthValue;
- (void)setWidthValue:(int)value_;

//- (BOOL)validateWidth:(id*)value_ error:(NSError**)error_;





@end

@interface _Photo (CoreDataGeneratedAccessors)

@end

@interface _Photo (CoreDataGeneratedPrimitiveAccessors)


- (NSDate*)primitiveCreatedAt;
- (void)setPrimitiveCreatedAt:(NSDate*)value;




- (NSString*)primitiveFbPhotoId;
- (void)setPrimitiveFbPhotoId:(NSString*)value;




- (NSString*)primitiveFormattedDate;
- (void)setPrimitiveFormattedDate:(NSString*)value;




- (NSNumber*)primitiveHeight;
- (void)setPrimitiveHeight:(NSNumber*)value;

- (int)primitiveHeightValue;
- (void)setPrimitiveHeightValue:(int)value_;




- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSString*)primitiveOwnerId;
- (void)setPrimitiveOwnerId:(NSString*)value;




- (NSString*)primitiveOwnerName;
- (void)setPrimitiveOwnerName:(NSString*)value;




- (NSString*)primitivePicture;
- (void)setPrimitivePicture:(NSString*)value;




- (NSString*)primitiveSource;
- (void)setPrimitiveSource:(NSString*)value;




- (NSNumber*)primitiveWidth;
- (void)setPrimitiveWidth:(NSNumber*)value;

- (int)primitiveWidthValue;
- (void)setPrimitiveWidthValue:(int)value_;




@end
