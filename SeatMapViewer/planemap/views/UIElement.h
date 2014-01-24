//
//  UIElement.h
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMElement.h"
#import "CMPlaneMapDelegate.h"

@interface UIElement : UIButton

+ (UIElement*) selected;
+ (void) setSelected:(UIElement*)val;

@property (nonatomic, retain) CMElement* element;
@property (nonatomic, retain) NSString* viewName;
@property (nonatomic, retain) NSString* abb;
@property (nonatomic, retain) NSString* desc;

@property (weak) id <CMPlaneMapDelegate> planeMapDelegate;


-(void)onTouch;


@end
