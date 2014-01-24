//
//  CMPlaneMapDelegate.h
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 28/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CMPlaneMapDelegate <NSObject>

@required

-(void)elementTouched:(id) uiElement;

@end
