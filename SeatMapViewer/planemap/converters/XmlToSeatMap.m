//
//  XmlToSeatMap.m
//  XmlToSeatMap
//
//  Created by Ali Can MOGOL on 24/12/13.
//  Copyright (c) 2013 Can A. MOGOL. All rights reserved.
//

#import "XmlToSeatMap.h"

@implementation XmlToSeatMap

@synthesize currentElement, currentObject, parentObject, objects;

- (id)init
{
    self = [super init];
    if (self) {
        objects = [[NSMutableArray alloc] init];
    }
    return self;
}

- (SeatMap*)parseXml:(NSData* )contentData {
    
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:contentData];
    
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    [xmlparser setShouldProcessNamespaces:NO];
    [xmlparser setShouldReportNamespacePrefixes:NO];
    
    BOOL ok = [xmlparser parse];
    if (ok == NO){
        return nil;
    } else {
        NSObject* seatMap= [objects firstObject];
        objects = nil;
        currentElement = nil;
        parentObject = nil;
        currentObject = nil;
        return (SeatMap*)seatMap;
    }
}


-(void)parserDidStartDocument:(NSXMLParser *)parser {
    //NSLog(@"didStartDocument");
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"didEndDocument");
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)content{
    if(content!=nil && [[content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]>0){
        //NSLog(@"foundCharacters: %@", content);
        
        if([[currentElement substringFromIndex:([currentElement length]-1)] isEqualToString:@"s"]){
            NSString *arrayStr = [NSString stringWithFormat:@"%@%@",
                                  [[currentElement substringToIndex:1] lowercaseString],
                                  [currentElement substringFromIndex:1]
                                  ];
            SEL arraySelector = NSSelectorFromString(arrayStr);
            if([[objects firstObject] respondsToSelector:arraySelector]){
                NSMutableArray* objs = [[objects firstObject] performSelector:arraySelector];
                [objs addObject:content];
            }
        }else{
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:",
                                   [[currentElement substringToIndex:1] uppercaseString],
                                   [currentElement substringFromIndex:1]
                                   ];
            SEL setterSelector = NSSelectorFromString(setterStr);
            if([[objects firstObject] respondsToSelector:setterSelector]){
                [[objects firstObject] performSelector:setterSelector withObject:content];
            }
        }
        
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    //NSLog(@"didStartElement: %@", elementName);
    currentElement = elementName;
    if([elementName isEqualToString:@"ColumnKeys"] || [elementName isEqualToString:@"rowStartingIndex"]){
        //NSLog(@"----didStartElement: %@", elementName);
        return;
    }
    
    //    if(currentObject != nil){
    //        [objects addObject:currentObject];
    //    }
    currentObject = [[NSClassFromString(elementName) alloc] init];
    [objects addObject:currentObject];
    
    // dont do this for first element in stack
    if([objects count] > 2) {
        NSObject* currentObject = [objects lastObject];
        NSString* currentObjectClassName = NSStringFromClass([currentObject class]);//[currentObject class];
        long objectCount = [objects count];
        for(int i=0; i<(objectCount-1); i++){
            NSObject* parentObject = [objects objectAtIndex:i];
            NSString* parentObjectClassName = NSStringFromClass([parentObject class]);//[parentObject className];
            if([currentObjectClassName isEqualToString:parentObjectClassName]){
                // remove all objects starting from current 'i' to last object(without last object)
                while(true){
                    [objects removeObjectAtIndex:i];
                    if([objects objectAtIndex:i] == currentObject){
                        break;
                    }
                }
                break;
            }
        }
    }
    
    // set attributes to current object
    NSEnumerator *attribs = [attributeDict keyEnumerator];
    NSString *key, *value;
    while((key = [attribs nextObject]) != nil) {
        value = [attributeDict objectForKey:key];
        NSString *setterStr = [NSString stringWithFormat:@"set%@:",key];
        SEL setterSelector = NSSelectorFromString(setterStr);
        if([currentObject respondsToSelector:setterSelector]){
            /*
            if([[value lowercaseString] isEqualToString:@"true"]){
                [currentObject performSelector:setterSelector withObject:@TRUE];
            }else if([[value lowercaseString] isEqualToString:@"false"]){
                [currentObject performSelector:setterSelector withObject:false];
            }else{
                [currentObject performSelector:setterSelector withObject:value];
            }
             */
            [currentObject performSelector:setterSelector withObject:value];
            //NSLog(@"currentObject %@",currentObject);
        }
    }
    
    // if there is a parent
    if ([objects count] > 1) {
        // set/add current object to parent object
        NSString *parentSetterStr = [NSString stringWithFormat:@"set%@:", elementName];
        SEL parentSetterSelector = NSSelectorFromString(parentSetterStr);
        
        NSString *getterStr = [NSString stringWithFormat:@"%@%@s",
                               [[elementName substringToIndex:1] lowercaseString],
                               [elementName substringFromIndex:1]
                               ];
        SEL getterSelector = NSSelectorFromString(getterStr);
        
        parentObject = [objects objectAtIndex:([objects count]-2)];
        
        if([parentObject respondsToSelector:parentSetterSelector]){
            [parentObject performSelector:parentSetterSelector withObject:currentObject];
        }else if([parentObject respondsToSelector:getterSelector]){
            NSMutableArray* currentObjects = [parentObject performSelector:getterSelector];
            [currentObjects addObject:currentObject];
        }
    }
    //NSLog(@"parentObject %@",parentObject);
    
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"didEndElement: %@", elementName);
}

// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    //NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}


@end

