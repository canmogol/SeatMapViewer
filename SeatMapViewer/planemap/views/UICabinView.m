//
//  UICabinView.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 27/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import "UICabinView.h"

@implementation UICabinView
@synthesize cabinElement, planeMapDelegate;

-(void)onTouch{
    [planeMapDelegate cabinElementTouched: cabinElement];
}


@end
