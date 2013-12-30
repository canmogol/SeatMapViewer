//
//  XmlToSeatMap.h
//  XmlToSeatMap
//
//  Created by Ali Can MOGOL on 24/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportModelsHeader.h"

@interface XmlToSeatMap : NSObject  <NSXMLParserDelegate>

@property (nonatomic, retain) NSString* currentElement;
@property (nonatomic, retain) NSMutableArray* objects;
@property (nonatomic, retain) NSObject* currentObject;
@property (nonatomic, retain) NSObject* parentObject;


- (SeatMap*)parseXml:(NSData* )contentData;

@end
