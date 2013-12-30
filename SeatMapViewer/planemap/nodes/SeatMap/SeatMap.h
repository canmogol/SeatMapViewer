#import <Foundation/Foundation.h>


@interface SeatMap : NSObject

@property (nonatomic,retain) NSString * parent;
@property (nonatomic,retain) NSMutableArray * seatMapRows;
@property (nonatomic,retain) NSMutableArray * columnKeys;
@property (nonatomic,retain) NSNumber * rowStartingIndex;
@property (nonatomic,retain) NSNumber * cabinConfig;
@property (nonatomic,retain) NSNumber * cabinType;
@property (nonatomic,retain) NSNumber * craftType;


@end