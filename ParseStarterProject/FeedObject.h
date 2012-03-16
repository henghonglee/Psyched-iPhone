//
//  FeedObject.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 17/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface FeedObject : NSObject
@property(retain,nonatomic) UIImage* senderImage;
@property(retain,nonatomic) PFObject* pfobj;

@end
