// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Photo.m instead.

#import "_Photo.h"

const struct PhotoAttributes PhotoAttributes = {
	.createdAt = @"createdAt",
	.formattedDate = @"formattedDate",
	.height = @"height",
	.id = @"id",
	.ownerId = @"ownerId",
	.ownerName = @"ownerName",
	.picture = @"picture",
	.source = @"source",
	.width = @"width",
};

const struct PhotoRelationships PhotoRelationships = {
};

const struct PhotoFetchedProperties PhotoFetchedProperties = {
};

@implementation PhotoID
@end

@implementation _Photo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Photo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:moc_];
}

- (PhotoID*)objectID {
	return (PhotoID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"heightValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"height"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"widthValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"width"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic createdAt;






@dynamic formattedDate;






@dynamic height;



- (int)heightValue {
	NSNumber *result = [self height];
	return [result intValue];
}

- (void)setHeightValue:(int)value_ {
	[self setHeight:[NSNumber numberWithInt:value_]];
}

- (int)primitiveHeightValue {
	NSNumber *result = [self primitiveHeight];
	return [result intValue];
}

- (void)setPrimitiveHeightValue:(int)value_ {
	[self setPrimitiveHeight:[NSNumber numberWithInt:value_]];
}





@dynamic id;






@dynamic ownerId;






@dynamic ownerName;






@dynamic picture;






@dynamic source;






@dynamic width;



- (int)widthValue {
	NSNumber *result = [self width];
	return [result intValue];
}

- (void)setWidthValue:(int)value_ {
	[self setWidth:[NSNumber numberWithInt:value_]];
}

- (int)primitiveWidthValue {
	NSNumber *result = [self primitiveWidth];
	return [result intValue];
}

- (void)setPrimitiveWidthValue:(int)value_ {
	[self setPrimitiveWidth:[NSNumber numberWithInt:value_]];
}









@end
