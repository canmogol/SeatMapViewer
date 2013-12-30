#import "Properties.h"


@implementation Properties

@synthesize parent, aisle, basinet, exit, forTransit, handyCap, leastPreferable, nonSmoking, notEnoughSpace, notForInfant, notForMedical, notForYoung, smoking, window;

- (id)init
{
    self = [super init];
    if (self) {
        parent = @"Properties";
    }
    return self;
}

-(NSString *)description {
    NSMutableString * desc = [[NSMutableString alloc] init];
    [desc appendString:@""];
    return [NSString stringWithFormat:@"<Properties, aisle: %@, basinet: %@, exit: %@, forTransit: %@, handyCap: %@, leastPreferable: %@, nonSmoking: %@, notEnoughSpace: %@, notForInfant: %@, notForMedical: %@, notForYoung: %@, smoking: %@, window: %@>",
            aisle, basinet, exit, forTransit, handyCap, leastPreferable, nonSmoking, notEnoughSpace, notForInfant, notForMedical, notForYoung, smoking, window];
}

@end

