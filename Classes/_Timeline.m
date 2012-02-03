// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Timeline.m instead.

#import "_Timeline.h"

const struct TimelineAttributes TimelineAttributes = {
	.id = @"id",
	.lastSynced = @"lastSynced",
	.members = @"members",
	.ownerId = @"ownerId",
};

const struct TimelineRelationships TimelineRelationships = {
};

const struct TimelineFetchedProperties TimelineFetchedProperties = {
};

@implementation TimelineID
@end

@implementation _Timeline

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Timeline" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Timeline";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Timeline" inManagedObjectContext:moc_];
}

- (TimelineID*)objectID {
	return (TimelineID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic id;






@dynamic lastSynced;






@dynamic members;






@dynamic ownerId;










@end
