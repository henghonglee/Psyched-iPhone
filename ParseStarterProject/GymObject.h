//
//  GymObject.h
//  PsychedApp
//
//  Created by HengHong Lee on 19/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface GymObject : NSObject
@property (nonatomic,retain) PFObject* pfobj;
@property (nonatomic,retain) UIImage* thumb; 
@property (nonatomic) BOOL isLoading;
@end
