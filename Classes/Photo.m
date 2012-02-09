#import "Photo.h"
#import "NSManagedObject+PSKit.h"

@implementation Photo

- (void)updateAttributesWithDictionary:(NSDictionary *)dictionary {
    self.id = [dictionary objectForKey:@"id"];
    self.fbId = [dictionary objectForKey:@"fbId"];
    self.ownerId = [[dictionary objectForKey:@"fbFrom"] objectForKey:@"id"];
    self.ownerName = [[dictionary objectForKey:@"fbFrom"] objectForKey:@"name"];
    self.source = [dictionary objectForKey:@"source"];
    self.picture = [dictionary objectForKey:@"picture"];
    self.width = [dictionary objectForKey:@"width"];
    self.height = [dictionary objectForKey:@"height"];
    self.createdAt = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"createdAt"] doubleValue]];
    self.formattedDate = [dictionary objectForKey:@"formattedDate"];
}

- (NSString *)dateString {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.createdAt];
    NSDate *formattedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    return [formattedDate string];
}

@end
