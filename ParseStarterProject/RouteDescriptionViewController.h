//
//  RouteDescriptionViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 21/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTaggerViewController.h"
@protocol RouteDescriptionDelegate;
@interface RouteDescriptionViewController : UIViewController<UITextViewDelegate,TaggerDelegate>
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (retain,nonatomic) id<RouteDescriptionDelegate> delegate;
@property (retain,nonatomic) NSString* descriptionText;
@property (retain,nonatomic) NSMutableArray* taggedFriends;
@property (retain, nonatomic) IBOutlet UIButton *instructionButton;
@end

@protocol RouteDescriptionDelegate <NSObject>
-(void)DescriptionDidReturnWithText:(NSString*)text andTaggedUsers:(NSMutableArray*)taggedFriends;

@end
