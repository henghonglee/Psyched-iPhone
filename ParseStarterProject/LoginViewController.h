//
//  LoginViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface LoginViewController : UIViewController <PF_FBRequestDelegate>
- (void)apiFQLIMe;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@end
