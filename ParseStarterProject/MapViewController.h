//
//  MapViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 10/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <CoreLocation/CoreLocation.h>
@interface MapViewController : UIViewController<MKMapViewDelegate>
@property (nonatomic,retain)PFGeoPoint* geopoint;
@property (nonatomic,retain) NSString* gymName;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;
@end
