#import "Photo.h"
#import "NSManagedObject+PSKit.h"

@implementation Photo

- (void)updateAttributesWithDictionary:(NSDictionary *)dictionary {
    self.id = [dictionary objectForKey:@"id"];
    self.ownerId = [[dictionary objectForKey:@"fb_from"] objectForKey:@"id"];
    self.ownerName = [[dictionary objectForKey:@"fb_from"] objectForKey:@"name"];
    self.source = [dictionary objectForKey:@"source"];
    self.picture = [dictionary objectForKey:@"picture"];
    self.width = [dictionary objectForKey:@"width"];
    self.height = [dictionary objectForKey:@"height"];
    self.createdAt = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"created_at"] doubleValue]];
    self.formattedDate = [dictionary objectForKey:@"formatted_date"];
}

- (NSString *)dateString {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:unitFlags fromDate:self.createdAt];
    NSDate *formattedDate = [[NSCalendar currentCalendar] dateFromComponents:components];
    return [formattedDate string];
}

@end
