//
//  CMXmlToView.m
//  SeatMapViewer
//
//  Created by Ali Can MOGOL on 23/01/14.
//  Copyright (c) 2014 Can A. MOGOL. All rights reserved.
//

#import "CMXmlToView.h"

@implementation CMXmlToView

@synthesize currentElement, currentView, views;

- (id)init
{
    self = [super init];
    if (self) {
        views = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSMutableArray*)parseXml:(NSData* )contentData {
    
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:contentData];
    
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    [xmlparser setShouldProcessNamespaces:NO];
    [xmlparser setShouldReportNamespacePrefixes:NO];
    
    BOOL ok = [xmlparser parse];
    if (ok == NO){
        return nil;
    } else {
        currentView = nil;
        currentElement = nil;
        return views;
    }
}


-(void)parserDidStartDocument:(NSXMLParser *)parser {
    //NSLog(@"didStartDocument");
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    //NSLog(@"didEndDocument");
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)content{
    //NSLog(@"foundCharacters: %@", content);
}

-(void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
    namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    
    //NSLog(@"didStartElement: %@", elementName);
    
    if([elementName isEqualToString:@"view"]){
        //NSLog(@"----xml view");
        currentView = [[CMView alloc] init];
        
        // set attributes to current object
        int dictSize = [attributeDict count];
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            NSString* upper = [[key substringToIndex:1] uppercaseString];
            NSString* rest = [key substringFromIndex:1];
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:", upper, rest];
            SEL setterSelector = NSSelectorFromString(setterStr);
            if([currentView respondsToSelector:setterSelector]){
                [currentView performSelector:setterSelector withObject:value];
            }
        }
        [views addObject:currentView];
        
    }else if([elementName isEqualToString:@"element"]){
        //NSLog(@"----xml element");
        currentElement = [[CMElement alloc] init];
        
        // set attributes to current object
        int dictSize = [attributeDict count];
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            NSString* upper = [[key substringToIndex:1] uppercaseString];
            NSString* rest = [key substringFromIndex:1];
            NSString *setterStr = [NSString stringWithFormat:@"set%@%@:", upper, rest];
            SEL setterSelector = NSSelectorFromString(setterStr);
            if([currentElement respondsToSelector:setterSelector]){
                [currentElement performSelector:setterSelector withObject:value];
            }
        }
        [[currentView elements] addObject:currentElement];
        
    }else if([elementName isEqualToString:@"property"]){
        //NSLog(@"----xml property");
        NSString *propertyKey, *propertyValue;
        
        // set attributes to current object
        int dictSize = [attributeDict count];
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
            if([key isEqualToString:@"key"]){
                propertyKey = value;
            }else if([key isEqualToString:@"value"]){
                propertyValue = value;
            }
        }
        [[currentElement properties] setObject:propertyValue forKey:propertyKey];
        
    }else{
        //NSLog(@"WTF? unknown entry in xml, element name: %@", elementName);
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    //NSLog(@"didEndElement: %@", elementName);
}

// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    //NSLog(@"XMLParser parse error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    //NSLog(@"XMLParser vlidation error: %@", [validationError localizedDescription]);
}

@end
