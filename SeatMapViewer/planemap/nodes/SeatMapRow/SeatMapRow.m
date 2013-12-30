#import "SeatMapRow.h"


@implementation SeatMapRow

@synthesize parent,cabinElements,rowNumber;

- (id)init
{
    self = [super init];
    if (self) {
        cabinElements = [[NSMutableArray alloc] init];
        parent = @"SeatMap";
    }
    return self;
}

@end

