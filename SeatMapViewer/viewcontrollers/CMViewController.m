//
//  CMViewController.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 27/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import "CMViewController.h"
#import "XmlToSeatMap.h"
#import <UIKit/UIKit.h>

@interface CMViewController ()
@property (weak, nonatomic) IBOutlet UIScrollView *planeMapView;
@end


@implementation CMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // sample xml data
    // get the content data from somewhere meaningful like a server side operation or a web service,
    // this is only for testing purposes
    NSString *file = [[NSBundle mainBundle] pathForResource:@"plane" ofType:@"xml"];
    NSData* contentData = [[NSData alloc] initWithContentsOfFile:file];
    
    
    
    NSArray* selectedElements = [[NSMutableArray alloc] initWithObjects: @"se2,1,6", @"em1,0,5", @"gl1,1,0", nil];
    
    
    // This is it!
    // this call will create a planeView from the content data
    // and if any of the items tapped on the screen it will send the object to the delegate
    UIView* planeView = [CMPlaneMap planeMapFromXmlData: contentData withPlaneMapDelegate:self withScaleFactor:1.0f withSelectedElements:selectedElements];


    
    // below are visual aids, may be discarded
    // set scroll view's width and height
    self.planeMapView.contentSize = CGSizeMake(planeView.frame.size.width, planeView.frame.size.height);
    // set the scroll view's position to beginning of the plane map
    [[self planeMapView] setContentOffset:CGPointMake(planeView.frame.size.width, 0)];
    // show plane view
    [[self planeMapView] addSubview:planeView];
    [[self planeMapView] setNeedsDisplay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)elementTouched:(id) uiElement{
    UIElement* uie = uiElement;
    NSLog(@"UIElement: %@(%@,%@) %@ %@", uie.viewName, uie.element.x, uie.element.y, uie.abb, uie.desc);
}
@end
