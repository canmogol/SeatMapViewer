//
//  UIElement.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import "UIElement.h"

@implementation UIElement

@synthesize element, viewName, abb, desc, planeMapDelegate;

-(void)onTouch{
    [planeMapDelegate elementTouched: self];
}


@end
