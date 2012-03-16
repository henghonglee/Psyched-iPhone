//
//  RouteObject.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 12/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface RouteObject : NSObject
@property (nonatomic,retain) PFObject* pfobj;
@property (nonatomic,retain) UIImage* retrievedImage;
@property (nonatomic,retain) UIImage* ownerImage;
@property (nonatomic,retain) UIImage* stampImage;
@property (nonatomic) BOOL isLoading;
@end
