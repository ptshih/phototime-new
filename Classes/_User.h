// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.h instead.

#import <CoreData/CoreData.h>
#import "PSManagedObject.h"

extern const struct UserAttributes {
	 NSString *id;
	 NSString *name;
	 NSString *status;
} UserAttributes;

extern const struct UserRelationships {
} UserRelationships;

extern const struct UserFetchedProperties {
} UserFetchedProperties;






@interface UserID : NSManagedObjectID {}
@end

@interface _User : PSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (UserID*)objectID;




@property (nonatomic, retain) NSString *id;


//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *name;


//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSNumber *status;


@property short statusValue;
- (short)statusValue;
- (void)setStatusValue:(short)value_;

//- (BOOL)validateStatus:(id*)value_ error:(NSError**)error_;





@end

@interface _User (CoreDataGeneratedAccessors)

@end

@interface _User (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSNumber*)primitiveStatus;
- (void)setPrimitiveStatus:(NSNumber*)value;

- (short)primitiveStatusValue;
- (void)setPrimitiveStatusValue:(short)value_;




@end
