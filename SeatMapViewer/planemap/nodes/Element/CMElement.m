//
//  CMElement.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import "CMElement.h"

@implementation CMElement

@synthesize x,y,abb,desc,type,properties,disabled;

- (id)init
{
    self = [super init];
    if (self) {
        properties = [[NSMutableDictionary alloc] init];
        disabled = @"false";
    }
    return self;
}

@end
