//
//  MapAnnotationView.h
//  DynastyTravel
//
//  Created by HengHong Lee on 30/11/11.
//  Copyright (c) 2011 Psyched!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Annote.h"
@interface AnnoteView : MKPinAnnotationView 
//@property (nonatomic, assign) UIImage* image;
@property (nonatomic, assign) MKMapView *map;
@property (nonatomic, assign) Annote *theAnnotation;

- (id)initWithAnnotation:(id <MKAnnotation>)annotation;
@end
