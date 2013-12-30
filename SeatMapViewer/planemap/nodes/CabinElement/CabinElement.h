#import <Foundation/Foundation.h>
#import "Seat.h"


@interface CabinElement : NSObject

@property (nonatomic,retain) NSString * parent;
@property (nonatomic,retain) Seat * seat;
@property (nonatomic,retain) NSString * type;

@end