//
//  GymDetailCell.h
//  PsychedApp
//
//  Created by HengHong Lee on 19/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MKMapView+ZoomLevel.h"
#import <Parse/Parse.h>
@interface GymDetailCell : UITableViewCell
@property (nonatomic,retain) PFObject* pfObject;
@property (nonatomic,retain) NSString* facebookid;
@property (retain, nonatomic) IBOutlet UILabel *routeCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *FollowCountLabel;
@property (retain, nonatomic) UIViewController* owner;
@property (retain, nonatomic) IBOutlet MKMapView *gymMapView;
@property (retain, nonatomic) IBOutlet UILabel *routeCount;
@property (retain, nonatomic) IBOutlet UILabel *likeCount;

@property (retain, nonatomic) IBOutlet UILabel *followingCount;

@end
