//
//  MapAnnotationView.m
//  DynastyTravel
//
//  Created by Shaun Tan on 30/11/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AnnoteView.h"

@implementation AnnoteView
@synthesize map,theAnnotation;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation {
    static NSString *annotationIdentifier = @"MapAnnotation";
	self = [super initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];	
	
	if (self) {		
		self.canShowCallout	= YES;		
		self.multipleTouchEnabled = NO;
		self.draggable = NO;
		self.animatesDrop = NO;
		self.map = nil;
        self.backgroundColor = [UIColor clearColor];
        
        // UIImage *flagImage = [UIImage imageNamed:@"bluepin.png"];
        // self.image = flagImage;
		theAnnotation = (Annote *)annotation;
		self.pinColor = MKPinAnnotationColorPurple;
		//radiusOverlay = [MKCircle circleWithCenterCoordinate:theAnnotation.coordinate radius:theAnnotation.radius];
		
		//[map addOverlay:radiusOverlay];
	}
	
	return self;	
}

- (void)dealloc {
    
	[super dealloc];
}
@end
