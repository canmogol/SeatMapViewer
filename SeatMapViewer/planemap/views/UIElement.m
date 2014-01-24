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

static UIElement* selected;
+ (UIElement*) selected {
    @synchronized(self) {
        return selected;
    }
}
+ (void) setSelected:(UIElement*)val {
    @synchronized(self) {
        selected = val;
    }
}

-(void)onTouch{
    if([[element disabled] isEqualToString:@"false"]){
        if([UIElement selected] != nil){
            UIElement* uie = [UIElement selected];
            uie.layer.borderColor = [UIColor whiteColor].CGColor;
            uie.layer.borderWidth = 0.0f;
        }
        [UIElement setSelected:self];
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 2.0f;
    }
    [planeMapDelegate elementTouched: self];
}


@end
