//
//  MapAnnotation.m
//  DynastyTravel
//
//  Created by HengHong Lee on 30/11/11.
//  Copyright (c) 2011 Psyched!. All rights reserved.
//

#import "Annote.h"

@implementation Annote
@synthesize coordinate,title,subtitle,companyId;


- (id) initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString*)titlestring subtitle:(NSString*)subtitlestring
{
    self = [super init];
	
    NSLog(@"init with coordinate");
    coordinate = coord;
    NSLog(@"%.2f,%.2f",coordinate.latitude,coordinate.longitude);
    title =titlestring;
    subtitle =subtitlestring;
    return self;
}


-(void)dealloc
{
    [super dealloc];
}
@end
