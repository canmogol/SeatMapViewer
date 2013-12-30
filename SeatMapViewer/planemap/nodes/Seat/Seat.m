#import "Seat.h"


@implementation Seat

@synthesize parent,properties,isOccupied,seatNumber,seatType;

- (id)init
{
    self = [super init];
    if (self) {
        parent = @"CabinElement";
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"<Seat, isOccupied: %@, seatNumber: %@, seatType: %@, properties: %@>",
            [self isOccupied], [self seatNumber], [self seatType], [self properties]];
}

@end

