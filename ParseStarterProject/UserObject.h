//
//  UserObject.h
//  PsychedApp
//
//  Created by HengHong Lee on 30/3/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface UserObject : NSObject
@property (nonatomic,retain) PFUser* user;
@property (nonatomic,retain) UIImage* userImage;

@end
