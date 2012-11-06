//
//  UserFeed.h
//  PsychedApp
//
//  Created by HengHong on 19/10/12.
//
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@interface UserFeed : NSObject
@property (nonatomic,retain) PFObject* pfobj;
@property (nonatomic,retain) UIImage* senderImage;
@end
