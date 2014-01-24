//
//  CMPlaneMap.h
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 27/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImportModelsHeader.h"
#import "UICabinView.h"
#import "CMPlaneMapDelegate.h"
#import "CMXmlToView.h"
#import "UIElement.h"

@interface CMPlaneMap : NSObject 

@property int unitWidth;
@property int unitHeight;
@property float scaleFactor;
@property (weak) id <CMPlaneMapDelegate> planeMapDelegate;
@property (nonatomic, strong) NSMutableDictionary* imagesAndDescription;
@property (nonatomic, strong) NSArray* selectedElements;

+(UIView*)planeMapFromXmlData:(NSData*) content withPlaneMapDelegate:(id)planeMapDelegate withScaleFactor:(float)scale withSelectedElements:(NSArray*) selectedElements;

@end