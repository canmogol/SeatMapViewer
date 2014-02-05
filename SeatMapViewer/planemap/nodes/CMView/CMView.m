//
//  CMView.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import "CMView.h"

@implementation CMView

@synthesize elements, name, desc, attached, lagend;

- (id)init
{
    self = [super init];
    if (self) {
        elements = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
