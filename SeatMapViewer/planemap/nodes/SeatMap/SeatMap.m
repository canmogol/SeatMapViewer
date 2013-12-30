#import "SeatMap.h"


@implementation SeatMap

@synthesize parent,seatMapRows,columnKeys,rowStartingIndex,cabinConfig,cabinType,craftType;

- (id)init
{
    self = [super init];
    if (self) {
        seatMapRows = [[NSMutableArray alloc] init];
        columnKeys = [[NSMutableArray alloc] init];
        parent = @"";
    }
    return self;
}

@end

