//
//  RouteDescriptionViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 21/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RouteDescriptionDelegate;
@interface RouteDescriptionViewController : UIViewController<UITextViewDelegate>
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (retain,nonatomic) id<RouteDescriptionDelegate> delegate;
@property (retain,nonatomic) NSString* descriptionText;
@end

@protocol RouteDescriptionDelegate <NSObject>
-(void)DescriptionDidReturnWithText:(NSString*)text;

@end
