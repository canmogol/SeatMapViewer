//
//  UICabinView.h
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 27/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CabinElement.h"
#import "CMPlaneMapDelegate.h"

@interface UICabinView : UIButton

@property (nonatomic, retain) CabinElement* cabinElement;
@property (weak) id <CMPlaneMapDelegate> planeMapDelegate;

-(void)onTouch;

@end