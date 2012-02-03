// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Timeline.h instead.

#import <CoreData/CoreData.h>
#import "PSManagedObject.h"

extern const struct TimelineAttributes {
	 NSString *id;
	 NSString *lastSynced;
	 NSString *members;
	 NSString *ownerId;
} TimelineAttributes;

extern const struct TimelineRelationships {
} TimelineRelationships;

extern const struct TimelineFetchedProperties {
} TimelineFetchedProperties;







@interface TimelineID : NSManagedObjectID {}
@end

@interface _Timeline : PSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (TimelineID*)objectID;




@property (nonatomic, retain) NSString *id;


//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSDate *lastSynced;


//- (BOOL)validateLastSynced:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *members;


//- (BOOL)validateMembers:(id*)value_ error:(NSError**)error_;




@property (nonatomic, retain) NSString *ownerId;


//- (BOOL)validateOwnerId:(id*)value_ error:(NSError**)error_;





@end

@interface _Timeline (CoreDataGeneratedAccessors)

@end

@interface _Timeline (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveId;
- (void)setPrimitiveId:(NSString*)value;




- (NSDate*)primitiveLastSynced;
- (void)setPrimitiveLastSynced:(NSDate*)value;




- (NSString*)primitiveMembers;
- (void)setPrimitiveMembers:(NSString*)value;




- (NSString*)primitiveOwnerId;
- (void)setPrimitiveOwnerId:(NSString*)value;




@end
