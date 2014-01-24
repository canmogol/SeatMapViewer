//
//  CMXmlToView.h
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMView.h"
#import "CMElement.h"

@interface CMXmlToView : NSObject <NSXMLParserDelegate>

@property (nonatomic, retain) CMView* currentView;
@property (nonatomic, retain) CMElement* currentElement;
@property (nonatomic, retain) NSMutableArray* views;

- (NSMutableArray*)parseXml:(NSData*)contentData;

@end
