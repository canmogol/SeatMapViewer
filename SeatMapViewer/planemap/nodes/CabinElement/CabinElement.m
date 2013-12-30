#import "CabinElement.h"


@implementation CabinElement

@synthesize parent, seat, type;

- (id)init
{
    self = [super init];
    if (self) {
        parent = @"SeatMapRow";
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<CabinElement, type: %@, seat: %@>",
            [self type], [self seat]];
}

@end

