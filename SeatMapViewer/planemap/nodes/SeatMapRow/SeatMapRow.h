#import <Foundation/Foundation.h>


@interface SeatMapRow : NSObject

@property (nonatomic,retain) NSString * parent;
@property (nonatomic,retain) NSMutableArray * cabinElements;
@property (nonatomic,retain) NSNumber * rowNumber;

@end