//
//  NewsObject.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface NewsObject : NSObject
@property (retain,nonatomic) NSString* newsTitle;
@property (retain,nonatomic) NSString* newsText;
@property (retain,nonatomic) NSString* newsImageURL;
@property (retain,nonatomic) NSString* newsCallbackURL;
@property (retain,nonatomic) UIImage* newsImage;
@property (retain,nonatomic) PFGeoPoint* geoPoint;
@property (retain,nonatomic) NSString* newsId;

@property (nonatomic) double distanceInKm;
@end
