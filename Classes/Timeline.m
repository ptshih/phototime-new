#import "Timeline.h"

@implementation Timeline

- (void)updateAttributesWithDictionary:(NSDictionary *)dictionary {
    self.id = [dictionary objectForKey:@"id"];
    self.ownerId = [dictionary objectForKey:@"ownerId"];
    self.members = [[dictionary objectForKey:@"members"] componentsJoinedByString:@","];
    self.lastSynced = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"lastSynced"] doubleValue]];
}

@end
