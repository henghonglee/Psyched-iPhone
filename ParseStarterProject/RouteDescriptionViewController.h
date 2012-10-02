//
//  RouteDescriptionViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 21/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol RouteDescriptionDelegate;
@interface RouteDescriptionViewController : UIViewController<UITextViewDelegate>
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (retain,nonatomic) id<RouteDescriptionDelegate> delegate;
@property (retain,nonatomic) NSString* descriptionText;
@property (retain, nonatomic) IBOutlet UIButton *instructionButton;
@end

@protocol RouteDescriptionDelegate <NSObject>
-(void)DescriptionDidReturnWithText:(NSString*)text;

@end
