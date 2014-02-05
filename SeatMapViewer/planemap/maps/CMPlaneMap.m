//
//  CMPlaneMap.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 27/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import "CMPlaneMap.h"

@implementation CMPlaneMap

@synthesize unitWidth, unitHeight, scaleFactor, planeMapDelegate, imagesAndDescription, selectedElements;

- (id)initWithScaleFactor:(float)scale
{
    self = [super init];
    if (self) {
        scaleFactor = scale;
        unitHeight = 65*scaleFactor;
        unitWidth = 65*scaleFactor;
        imagesAndDescription = [[NSMutableDictionary alloc] init];
    }
    return self;
}


+(UIView*)planeMapFromXmlData:(NSData*) content withPlaneMapDelegate:(id)planeMapDelegate withScaleFactor:(float)scale withSelectedElements:(NSArray*) selectedElements{
    CMPlaneMap* cmp = [[CMPlaneMap alloc] initWithScaleFactor:scale];
    [cmp setPlaneMapDelegate:planeMapDelegate];
    [cmp setSelectedElements:selectedElements];
    
    // create a plane map view
    UIView* planeMapView = [[UIView alloc] init];
    [planeMapView setBackgroundColor:[UIColor grayColor]];
    [planeMapView setBackgroundColor:[UIColor whiteColor]];
    planeMapView.layer.borderColor = [UIColor blackColor].CGColor;
    planeMapView.layer.borderWidth = 1.0f;
    
    // parse the xml to an array of CMView objects
    CMXmlToView* xmlToView = [[CMXmlToView alloc] init];
    NSMutableArray* views = [xmlToView parseXml:content];
    NSMutableArray* attachedViews = [[NSMutableArray alloc] init];
    
    
    for(CMView* v in views){
        // if the view is attached to the bottom of the plane map, add them later
        if([[v attached]isEqualToString:@"true"]){
            [attachedViews addObject:v];
        }else{
            // for each CMView object, create a UIView
            UIView* view = [cmp createUIView: v];
            view.frame = CGRectMake(planeMapView.frame.size.width, 0, view.frame.size.width, view.frame.size.height);
            
            // set the width and height of the plane map view
            float width = planeMapView.frame.size.width + view.frame.size.width;
            float height = MAX(view.frame.origin.y+view.frame.size.height, planeMapView.frame.size.height);
            planeMapView.frame = CGRectMake(0, 0, width, height);
            
            // add eachview to planeMapView
            [planeMapView addSubview:view];
        }
    }
    
    for(CMView* v in attachedViews){
        // for each CMView object, create a UIView
        UIView* view = [cmp createUIView: v];
        view.frame = CGRectMake(0, planeMapView.frame.size.height, view.frame.size.width, view.frame.size.height);
        
        // set the width and height of the plane map view
        float width = MAX(view.frame.origin.x+view.frame.size.width, planeMapView.frame.size.width);
        float height = planeMapView.frame.size.height + view.frame.size.height;
        planeMapView.frame = CGRectMake(0, 0, width, height);
        
        // add eachview to planeMapView
        [planeMapView addSubview:view];
    }
    
    
    // return plane map view
    return planeMapView;
}

-(UIView*) createUIView:(CMView*)cmv{
    UIView* uiv = [[UIView alloc] init];

    for(CMElement* el in [cmv elements]){
        // create a UIElement and set values from CMView
        UIElement* uie = [[UIElement alloc] init];
        [uie addTarget:nil action:@selector(onTouch) forControlEvents:UIControlEventTouchUpInside];
        float x = [[el x] intValue] * unitWidth;
        float y = [[el y] intValue] * unitHeight;
        uie.frame = CGRectMake(x, y, unitWidth, unitHeight);
        if(![[el disabled] isEqualToString:@"true"]){
            [uie setPlaneMapDelegate: planeMapDelegate];
        }
        [uie setViewName: [cmv name]];
        [uie setElement:el];
        [uie setAbb:[el abb]];
        [uie setDesc:[el desc]];
        
        // check if this element is selected
        NSString* selectedCheck = [[NSString alloc] initWithFormat:@"%@,%@,%@", [cmv name], [el x], [el y]];
        if([selectedElements containsObject:selectedCheck]){
            uie.layer.borderColor = [UIColor redColor].CGColor;
            uie.layer.borderWidth = 2.0f;
            [UIElement setSelected:uie];
        }
        
        // set default properties; text, background, border etc.
        if([[el properties] objectForKey:@"lagend-text"]){
            [uie addSubview:[self createLagendLabel: [[el properties] objectForKey:@"lagend-text"]]];
            uie.frame = CGRectMake(x, y, unitWidth*3, unitHeight);
   
        }else if([[el properties] objectForKey:@"text"]){
            [uie addSubview:[self createLabel: [[el properties] objectForKey:@"text"]]];
            
        }else if([[el properties] objectForKey:@"background-color"]){
            [uie setBackgroundColor:[self colorFromHexString: [[el properties] objectForKey:@"background-color"]]];

        }else if([[el properties] objectForKey:@"border-color"]){
            uie.layer.borderColor = [self colorFromHexString: [[el properties] objectForKey:@"border-color"]].CGColor;
            
        }else if([[el properties] objectForKey:@"border-width"]){
            uie.layer.borderWidth = [[[el properties] objectForKey:@"border-width"] floatValue];
            
        }else if([[el properties] objectForKey:@"background-image"]){
            [uie addSubview: [self createImageView: [[el properties] objectForKey:@"background-image"]]];
        }
        
        
        // if CMElement is a seat then there are special images, otherwise there are images corresponding to their types
        if([[el type] isEqualToString:@"seats"]){
            // add the seat abb specific image
            NSString* imageName = [[NSString alloc] initWithFormat:@"%@-seat.png",[[el abb] lowercaseString]];
            [uie addSubview: [self createImageView: imageName]];
            
            // add the seat number
            [uie addSubview:[self createLabel: [[el properties] objectForKey:@"SeatNumber"]]];
            
        }else{
            // create image from type
            NSString* imageName = [[NSString alloc] initWithFormat:@"%@.png",[el type]];
            [uie addSubview: [self createImageView: imageName]];
        }
        // set the size dynamically for uiv
        float width = MAX(uie.frame.origin.x+uie.frame.size.width, uiv.frame.size.width);
        float height = MAX(uie.frame.origin.y+uie.frame.size.height, uiv.frame.size.height);
        uiv.frame = CGRectMake(0, 0, width, height);
        // add this uie to uiv
        [uiv addSubview:uie];
    }
    return uiv;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:0];
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (UIImageView*) createImageView: (NSString*) imageName{
    // create image from image file name
    UIImage* image = [UIImage imageNamed: imageName];
    // scale image if necessary
    if(image.size.width!=unitWidth || image.size.height!=unitHeight){
        image = [self resizeWithUnit:image];
    }
    return [[UIImageView alloc] initWithImage:image];
}

-(UILabel*) createLabel: (NSString*) text{
    UILabel* textLabel = [[UILabel alloc] init];
    textLabel.frame = CGRectMake(unitWidth/3, 0, unitWidth, unitHeight);
    [textLabel setText:text];
    textLabel.font = [UIFont systemFontOfSize:18*scaleFactor];
    return textLabel;
}

-(UILabel*) createLagendLabel: (NSString*) text{
    UILabel* textLabel = [[UILabel alloc] init];
    textLabel.frame = CGRectMake(unitWidth/3, 0, unitWidth, unitHeight);
    [textLabel setText:text];
    textLabel.frame = CGRectMake(5, 0, unitWidth*3, unitHeight);
    textLabel.font = [UIFont systemFontOfSize:18*scaleFactor];
    return textLabel;
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




/*
-(UIView*) createSeatMapViewWithContent: (NSData*) contentData{
    SeatMap* seatMap = [self xmlDataToSeatMap:contentData];
    return [self seatMapToView: seatMap];
}

-(void) addUIView: (UIView* )uiView toPlaneMapView:(UIView*)planeMapView{
    uiView.frame = CGRectMake(planeMapView.frame.size.width, 0, uiView.frame.size.width, uiView.frame.size.height);
    [planeMapView addSubview:uiView];
    planeMapView.frame = CGRectMake(0, 0, planeMapView.frame.size.width + uiView.frame.size.width, MAX(uiView.frame.size.height, planeMapView.frame.size.height));
    
}


+(UIView*)planeMapFromXmlData2:(NSData*) content withPlaneMapDelegate:(id)planeMapDelegate withScaleFactor:(float)scale{
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
                                       ((aftCabinMapView.frame.size.width+seatMapView.frame.size.width+forwardCabinMapView.frame.size.width)/2)//width of the plane map
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
 */
/*
 CDRM subtype codes
 -------------------
 galley
 lavatory
 cabin
 video_center
 crew_rest
 seats
 emergency_first_aid
 emergency_ditching
 emergency_exit
 emergency_fire
 emergency_lighting_sign
 emergency_miscellaneous
 
 
 <view>
 <element x="0" y="1" abb="G1" desc="GALLEY F-3" type="galley"/>
 <element x="1" y="0" abb="G1" desc="GALLEY F-1" type="galley"/>
 <element x="2" y="3" abb="LA" desc="Lavatory 1A-1C" type="lavatory"/>
 </view>
 
 
 view-cabin
 CA	F/C ZONE
 CB	B/C ZONE
 CC	FRONT E/C ZONE
 CD	REAR E/C ZONE
 CW	WHOLE CABIN
 S1	FR STAIR HOUSE
 S2	RR STAIR HOUSE
 
 view-gls (3,10)
 0,1 G1  GALLEY F-3                  galley
 1,0 G1  GALLEY F-1                  galley
 2,3 LA  Lavatory 1A-1C              lavatory
 view-video_center
 0,3 VC  VIDEO CENTER                video_center
 0,5 CC	CABIN EQUIPMENT CENTER      video_center
 *     view-seats-vip
 view-gls
 *     view-seats-business
 0,0 SF	First Class                 seats
 0,1 SF	First Class                 seats
 view-gls
 *     view-seats-economy
 view-gls
 *     view-seats-economy
 view-gls
 view-cabin
 0,1 S1	FR STAIR HOUSE              cabin
 view-crew_rest
 2,1 CR	CABIN CREW REST             crew_rest
 view-emergency
 0,1 ZA	FIRST AID                   emergency_first_aid
 0,1 ZB	DITCHING                    emergency_ditching
 0,1 ZC	EXIT                        emergency_exit
 0,1 ZD	FIRE                        emergency_fire
 0,1 ZE	LIGHTING SIGN               emergency_lighting_sign
 0,1 ZF	MISCELLANEOUS               emergency_miscellaneous
 
 */


@end
