//
//  RouteLocationViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "MKMapView+ZoomLevel.h"
#import <CoreLocation/CoreLocation.h>
@protocol RouteLocationDelegate;
@interface RouteLocationViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property (retain, nonatomic) IBOutlet UITextField *locationTextField;
@property (retain, nonatomic) IBOutlet UITableView *locationTable;
@property (retain,nonatomic) PFGeoPoint* gpLoc;
@property (retain,nonatomic) id<RouteLocationDelegate> delegate;
@property (retain, nonatomic) IBOutlet MKMapView *routeLocMap;
@property (retain,nonatomic) NSString* locationText;
@property (retain,nonatomic) NSMutableArray* locationArray;

@end

@protocol RouteLocationDelegate <NSObject>
-(void)LocationDidReturnWithText:(NSString*)text;
@end
