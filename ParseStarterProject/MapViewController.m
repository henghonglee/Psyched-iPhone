//
//  MapViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 10/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MapViewController.h"
#import "MKMapView+ZoomLevel.h"
#import "Annote.h"
#import "AnnoteView.h"
@interface MapViewController ()

@end

@implementation MapViewController
@synthesize geopoint;
@synthesize mapView;
@synthesize gymName;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = @"Location";
    CLLocationCoordinate2D locCoord = CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
    
    Annote *dropPin = [[Annote alloc] initWithCoordinate:locCoord title:gymName subtitle:@""];  
    [mapView addAnnotation:dropPin];
    [mapView setCenterCoordinate:locCoord zoomLevel:14 animated:NO];
    [dropPin release];
    // Do any additional setup after loading the view from its nib.
}

-(MKAnnotationView *)mapView:(MKMapView *)__mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[Annote class]]) {
        
        static NSString *annotationIdentifier = @"MapAnnotation";
		AnnoteView *regionView = (AnnoteView*)[__mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];	
		
		if (!regionView) {
			regionView = [[[AnnoteView alloc] initWithAnnotation:annotation] autorelease];
            regionView.map = __mapView;
            // UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
            // regionView.rightCalloutAccessoryView = rightButton;
            
            
		} else {		
            regionView.annotation= annotation;
			regionView.theAnnotation = annotation;
            
            
		}
       
		
		// Update or add the overlay displaying the radius of the region around the annotation.
		
		return regionView;		
	}	
	
	return nil;
}
- (void)viewDidUnload
{
    [self setMapView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [mapView release];
    [super dealloc];
}
@end
