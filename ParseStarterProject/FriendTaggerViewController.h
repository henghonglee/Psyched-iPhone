//
//  FriendTaggerViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 21/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBfriend.h"
#import <Parse/Parse.h>
@protocol TaggerDelegate;
@interface FriendTaggerViewController : UIViewController <UITextFieldDelegate,UITableViewDelegate,UIAlertViewDelegate,UITableViewDataSource,PF_FBRequestDelegate>
@property (nonatomic, retain) PF_FBRequest *myRequest;
@property (retain,nonatomic) NSMutableArray* friendsArray;
@property (retain,nonatomic) NSMutableArray* FBfriendsArray;
@property (retain,nonatomic) NSMutableArray* recommendArray;
@property (retain, nonatomic) IBOutlet UITextField *taggerTextField;
@property (retain, nonatomic) IBOutlet UITableView *taggerTable;
@property (retain, nonatomic) id<TaggerDelegate> delegate;

@end
@protocol TaggerDelegate <NSObject>

-(void)TaggerDidReturnWithRecommendedArray:(NSMutableArray*)recommendedArray;

@end