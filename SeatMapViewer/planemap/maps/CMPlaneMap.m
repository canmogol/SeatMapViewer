//
//  CMPlaneMap.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 27/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import "CMPlaneMap.h"

@implementation CMPlaneMap

@synthesize unitWidth, unitHeight, scaleFactor, planeMapDelegate, imagesAndDescription;

- (id)initWithScaleFactor:(float)scale
{
    self = [super init];
    if (self) {
        scaleFactor = scale;
        unitHeight = 30*scaleFactor;
        unitWidth = 65*scaleFactor;
        imagesAndDescription = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(UIView*)planeMapFromXmlData:(NSData*) content withPlaneMapDelegate:(id)planeMapDelegate withScaleFactor:(float)scale{
    CMPlaneMap* cmp = [[CMPlaneMap alloc] initWithScaleFactor:scale];
    [cmp setPlaneMapDelegate:planeMapDelegate];
    
    // create a plane map view
    UIView* planeMapView = [[UIView alloc] init];
    [planeMapView setBackgroundColor:[UIColor grayColor]];
    [planeMapView setBackgroundColor:[UIColor whiteColor]];
    planeMapView.layer.borderColor = [UIColor blackColor].CGColor;
    planeMapView.layer.borderWidth = 1.0f;
    
    // create forward cabin map view
    ForwardCabinMap* forwardCabinMap = [[ForwardCabinMap alloc] init];
    UIView* forwardCabinMapView = [cmp forwardCabinMapToView:forwardCabinMap];
    
    // create seat map view
    SeatMap* seatMap = [cmp xmlDataToSeatMap:content];
    UIView* seatMapView = [cmp seatMapToView: seatMap];
    
    // create aft cabin map view
    AftCabinMap* aftCabinMap = [[AftCabinMap alloc] init];
    UIView* aftCabinMapView = [cmp aftCabinMapToView:aftCabinMap];
    
    // create explanation view
    UIView* explanationView = [cmp explanationView];
    
    // set aft and forward cabin views' width and height
    aftCabinMapView.frame = CGRectMake(0, 0, [cmp unitWidth]*5, seatMapView.frame.size.height);
    seatMapView.frame = CGRectMake(aftCabinMapView.frame.size.width, 0, seatMapView.frame.size.width+6, seatMapView.frame.size.height);
    forwardCabinMapView.frame = CGRectMake((aftCabinMapView.frame.size.width+seatMapView.frame.size.width), 0, [cmp unitWidth]*5, seatMapView.frame.size.height);
    explanationView.frame = CGRectMake(
                                       ((aftCabinMapView.frame.size.width+seatMapView.frame.size.width+forwardCabinMapView.frame.size.width)/2)/*width of the plane map*/
                                       - (explanationView.frame.size.width/2)
                                       ,
                                       seatMapView.frame.size.height,
                                       explanationView.frame.size.width,
                                       explanationView.frame.size.height);
    
    // set width and height of the plane map view to sum of its sub views
    planeMapView.frame = CGRectMake(0, 0,
                                    forwardCabinMapView.frame.size.width +
                                    seatMapView.frame.size.width +
                                    aftCabinMapView.frame.size.width
                                    ,
                                    seatMapView.frame.size.height +
                                    explanationView.frame.size.height
                                    );
    
    // add sub views to plane map view
    [planeMapView addSubview:forwardCabinMapView];
    [planeMapView addSubview:seatMapView];
    [planeMapView addSubview:aftCabinMapView];
    [planeMapView addSubview:explanationView];
    
    // return plane map view
    return planeMapView;
}

-(SeatMap*)xmlDataToSeatMap:(NSData*) content{
    SeatMap* seatMap = [[SeatMap alloc] init];
    @try {
        // parse xml to create SeatMap
        // SeatMap object will be used to create seat map view
        seatMap = [[[XmlToSeatMap alloc] init] parseXml: content];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception: %@", exception);
    }
    return seatMap;
}

-(UIView*)seatMapToView:(SeatMap*)seatMap{
    
    // will return this map
    UIView* seatMapView = [[UIView alloc] init];
    
    // if there is no seat map row return empty view
    if([[seatMap seatMapRows] count] == 0){
        return seatMapView;
    }
    
    // if there is no cabin elements return empty view
    SeatMapRow* smr = [[seatMap seatMapRows] objectAtIndex:0];
    if([[smr cabinElements] count] == 0){
        return seatMapView;
    }
    
    /*
     seats  corridors
     <6     1
     >6     2
     */
    int numberOfCorridors = 1;
    int corridors[2] = { ceil([[seatMap columnKeys] count]/2) , -1};
    if([[seatMap columnKeys] count]>6){
        numberOfCorridors = 2;
        corridors[0] = 3;
        corridors[1] = [[seatMap columnKeys] count]-3;
    }
    
    // unit example 60x34
    // calculate the width and height of the view
    int width = [[seatMap seatMapRows] count] * unitWidth;
    // +4 = 1top column number, 1bottom column number, 1top exit/wing, 1 bottom exit/wing
    int height = ([[seatMap columnKeys] count]+(4+numberOfCorridors)) * unitHeight;
    
    seatMapView.frame = CGRectMake(0, 0, width, height);
    seatMapView.layer.borderColor = [UIColor blackColor].CGColor;
    seatMapView.layer.borderWidth = 1.0f;
    
    for(int i = 0 ; i<[[seatMap seatMapRows] count];i++){
        int shift = 0;
        SeatMapRow* seatMapRow = [[seatMap seatMapRows] objectAtIndex:i];
        UILabel* seatMapRowNumberView = [[UILabel alloc] init];
        NSString* seatRowNumberText = [[NSString alloc] initWithFormat:@"%@",[seatMapRow rowNumber]];
        [seatMapRowNumberView setText:seatRowNumberText];
        seatMapRowNumberView.frame = CGRectMake((width-((i+1)*unitWidth))+(unitWidth/3), 0, unitWidth, unitHeight);
        seatMapRowNumberView.font = [UIFont systemFontOfSize:18*scaleFactor];
        [seatMapView addSubview:seatMapRowNumberView];
        
        int j=0;
        for(;j<[[seatMapRow cabinElements] count];j++){
            CabinElement* cabinElement = [[seatMapRow cabinElements] objectAtIndex:j];
            UIView* cabinElementView = [self createCabinElement: cabinElement atRow:j];
            cabinElementView.frame = CGRectMake(width-((i+1)*unitWidth), ((j+1)*unitHeight)+shift, unitWidth, unitHeight);
            [seatMapView addSubview:cabinElementView];
            if(j==corridors[0] || j == corridors[1]){
                shift = shift + unitHeight;
            }
        }
        
        seatMapRowNumberView = [[UILabel alloc] init];
        seatRowNumberText = [[NSString alloc] initWithFormat:@"%@",[seatMapRow rowNumber]];
        [seatMapRowNumberView setText:seatRowNumberText];
        seatMapRowNumberView.frame = CGRectMake((width-((i+1)*unitWidth))+(unitWidth/3), ((j+1)*unitHeight)+shift, unitWidth, unitHeight);
        seatMapRowNumberView.font = [UIFont systemFontOfSize:18*scaleFactor];
        [seatMapView addSubview:seatMapRowNumberView];
        
    }
    
    return seatMapView;
}

-(UIView*)createCabinElement:(CabinElement*)cabinElement atRow: (int)row{
    
    // create a cabin view element, this is a button actually, see its implementation for details
    UICabinView* cabinElementView = [[UICabinView alloc] init];
    [cabinElementView setCabinElement: cabinElement];
    [cabinElementView setPlaneMapDelegate: planeMapDelegate];
    [cabinElementView addTarget:nil action:@selector(onTouch) forControlEvents:UIControlEventTouchUpInside];
    
    @try {
        // each cabin view is one unit size
        cabinElementView.frame = CGRectMake(0, 0, unitWidth, unitHeight);
        
        // image and imageView are placeholders for each cabin element's visual components
        UIImage* image;
        UIImageView* imageView;
        if([[[cabinElement type] lowercaseString] isEqualToString:@"seat"]){
            Seat* seat = [cabinElement seat];
            // [seat seatType] => CHECKED_IN,UNUSABLE,AVAILABLE,LEAST_PREFERABLE etc.
            NSString* imageName = [[NSString alloc] initWithFormat:@"sm_%@.png",[[seat seatType] lowercaseString]];
            [imagesAndDescription setObject:[[seat seatType] lowercaseString] forKey:imageName];
            image = [UIImage imageNamed:imageName];
        }else{
            // EXIT, WING, BLANK etc.
            NSString* imageName;
            if([[[cabinElement type] lowercaseString] isEqualToString:@"exit"]){
                if(row == 0){
                    imageName = @"sm_exit_begin.png";
                }else{
                    imageName = @"sm_exit_end.png";
                }
            }else{
                imageName = [[NSString alloc] initWithFormat:@"sm_%@.png",[[cabinElement type] lowercaseString]];
                [imagesAndDescription setObject:[[cabinElement type] lowercaseString] forKey:imageName];
            }
            image = [UIImage imageNamed:imageName];
        }
        
        // if the image does not exists use the "unknown image"
        if(image.size.width <= 0 || image.size.height<=0){
            image = [UIImage imageNamed:@"sm_unknown_parameter.png"];
        }
        
        // scale image if necessary
        if(image.size.width!=unitWidth || image.size.height!=unitHeight){
            image = [self resizeWithUnit:image];
        }
        
        // set the image to image view and add image view to cabin element
        imageView = [[UIImageView alloc] initWithImage:image];
        [cabinElementView addSubview: imageView];
        
        // set the handicapped like attributes to cabin element if needed, this is an example how to do it
        if([[[[[cabinElement seat] properties] handyCap] lowercaseString] isEqualToString:@"true"]){
            // handicapped image
            UIImage *propertyImage = [UIImage imageNamed:@"sm_handicapped.png"];
            // scale image if necessary
            if(propertyImage.size.width!=unitWidth || propertyImage.size.height!=unitHeight){
                propertyImage = [self resizeWithUnit:propertyImage];
            }
            [cabinElementView addSubview: [[UIImageView alloc] initWithImage:propertyImage]];
            [imagesAndDescription setObject:@"Handicapped" forKey:@"sm_handicapped.png"];
        }
        
        // if this cabin element is a seat and the seat has a seatnumber than add it to cabin view
        if([[cabinElement seat] seatNumber]!=nil){
            UILabel* seatNumberLabel = [[UILabel alloc] init];
            seatNumberLabel.frame = CGRectMake(unitWidth/3, 0, unitWidth, unitHeight);
            NSString* seatNumber = [[NSString alloc] initWithFormat:@"%@", [[[cabinElement seat] seatNumber] substringFromIndex:2]];
            [seatNumberLabel setText:seatNumber];
            seatNumberLabel.font = [UIFont systemFontOfSize:18*scaleFactor];
            [cabinElementView addSubview:seatNumberLabel];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"exception while creating cabin element: %@", exception);
    }
    return cabinElementView;
}

-(UIImage*)resizeWithUnit:(UIImage*)image{
    CGSize scaledSize = CGSizeMake(unitWidth, unitHeight);
    UIGraphicsBeginImageContextWithOptions( scaledSize, NO, 0.0 );
    CGRect scaledImageRect = CGRectMake( 0.0, 0.0, scaledSize.width, scaledSize.height );
    [image drawInRect:scaledImageRect];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIView*)forwardCabinMapToView:(ForwardCabinMap*)forwardCabinMap{
    // this is a placeholder, this also should be created from some datasource!
    UIView* forwardCabinMapView = [[UIView alloc] init];
    UIColor* forwardCabinColor = [UIColor colorWithRed:66.0f/255.0f green:79.0f/255.0f blue:255.0f/255.0f alpha:0.2f];
    [forwardCabinMapView setBackgroundColor:forwardCabinColor];
    forwardCabinMapView.layer.borderColor = [UIColor blackColor].CGColor;
    forwardCabinMapView.layer.borderWidth = 1.0f;
    
    UILabel* titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"Forward Cabin Map"];
    titleLabel.frame = CGRectMake(unitWidth, unitHeight, unitWidth*3, unitHeight);
    titleLabel.font = [UIFont systemFontOfSize:18*scaleFactor];
    [forwardCabinMapView addSubview:titleLabel];
    
    return forwardCabinMapView;
}

-(UIView*)aftCabinMapToView:(AftCabinMap*)aftCabinMap{
    // this is a placeholder, this also should be created from some datasource!
    UIView* aftCabinMapToView =  [[UIView alloc] init];
    UIColor* aftCabinColor = [UIColor colorWithRed:66.0f/255.0f green:79.0f/255.0f blue:255.0f/255.0f alpha:0.4f];
    [aftCabinMapToView setBackgroundColor: aftCabinColor];
    aftCabinMapToView.layer.borderColor = [UIColor blackColor].CGColor;
    aftCabinMapToView.layer.borderWidth = 1.0f;
    
    UILabel* titleLabel = [[UILabel alloc] init];
    [titleLabel setText:@"Aft Cabin Map"];
    titleLabel.frame = CGRectMake(unitWidth, unitHeight, unitWidth*3, unitHeight);
    titleLabel.font = [UIFont systemFontOfSize:18*scaleFactor];
    [aftCabinMapToView addSubview:titleLabel];
    
    return aftCabinMapToView;
}

-(UIView*)explanationView{
    // this shows the explanations of UI elements
    UIView* explanationView =  [[UIView alloc] init];
    UIColor* explanationCabinColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:0.1f];
    [explanationView setBackgroundColor: explanationCabinColor];
    
    NSEnumerator* keys = [imagesAndDescription keyEnumerator];
    NSString* imageFileName;
    UIImage* image;
    UIImageView* imageView;
    int x=0;
    int y=0;
    while((imageFileName = [keys nextObject])){
        image = [UIImage imageNamed:imageFileName];
        if(image.size.width <= 0 || image.size.height<=0){
            image = [UIImage imageNamed:@"sm_unknown_parameter.png"];
        }
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(x*(unitWidth) + (x*unitWidth*2), y*unitHeight, unitWidth, unitHeight);
        [explanationView addSubview: imageView];
        
        NSString* title = [imagesAndDescription valueForKey:imageFileName];
        UILabel* titleLabel = [[UILabel alloc] init];
        titleLabel.frame = CGRectMake((x+1)*(unitWidth) + (x*unitWidth*2), y*unitHeight, (x*unitWidth)+unitWidth*3, unitHeight);
        [titleLabel setText:title];
        titleLabel.font = [UIFont systemFontOfSize:18*scaleFactor];
        [explanationView addSubview:titleLabel];
        
        x++;
        if((x%5)==0){
            x=0;
            y++;
        }
    }
    
    explanationView.frame = CGRectMake(0, 0, 16*unitWidth, (y+1)*unitHeight);
    
    return explanationView;
}



@end
