//
//  CMElement.h
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMElement : NSObject

@property (nonatomic,retain) NSString* x;
@property (nonatomic,retain) NSString* y;
@property (nonatomic,retain) NSString* abb;
@property (nonatomic,retain) NSString* desc;
@property (nonatomic,retain) NSString* type;
@property (nonatomic,retain) NSString* disabled;
@property (nonatomic,retain) NSMutableDictionary* properties;

@end
