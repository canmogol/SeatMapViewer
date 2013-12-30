#import <Foundation/Foundation.h>
#import "Properties.h"

@interface Seat : NSObject

@property (nonatomic,retain) NSString * parent;
@property (nonatomic,retain) Properties * properties;
@property (nonatomic,retain) NSString * isOccupied;
@property (nonatomic,retain) NSString * seatNumber;
@property (nonatomic,retain) NSString * seatType;

@end