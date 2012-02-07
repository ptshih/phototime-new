// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to User.m instead.

#import "_User.h"

const struct UserAttributes UserAttributes = {
	.id = @"id",
	.name = @"name",
	.status = @"status",
};

const struct UserRelationships UserRelationships = {
};

const struct UserFetchedProperties UserFetchedProperties = {
};

@implementation UserID
@end

@implementation _User

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"User";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"User" inManagedObjectContext:moc_];
}

- (UserID*)objectID {
	return (UserID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"statusValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"status"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic id;






@dynamic name;






@dynamic status;



- (short)statusValue {
	NSNumber *result = [self status];
	return [result shortValue];
}

- (void)setStatusValue:(short)value_ {
	[self setStatus:[NSNumber numberWithShort:value_]];
}

- (short)primitiveStatusValue {
	NSNumber *result = [self primitiveStatus];
	return [result shortValue];
}

- (void)setPrimitiveStatusValue:(short)value_ {
	[self setPrimitiveStatus:[NSNumber numberWithShort:value_]];
}









@end
