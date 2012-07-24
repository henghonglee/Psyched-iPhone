//
//  CommentsViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 20/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RouteCommentsDelegate;
@interface CommentsViewController : UIViewController
@property (retain, nonatomic) IBOutlet UITextView *commentsTextView;
@property (retain,nonatomic) id<RouteCommentsDelegate> delegate;
@property (retain,nonatomic) NSString* commentsText;

@end

@protocol RouteCommentsDelegate <NSObject>
-(void)commentsDidReturnWithText:(NSString*)text;
@end