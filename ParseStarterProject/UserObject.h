//
//  UserObject.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 30/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface UserObject : NSObject
@property (nonatomic,retain) PFUser* user;
@property (nonatomic,retain) UIImage* userImage;

@end
