//
//  RouteDetailViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteObject.h"
#import "SBJSON.h"
#import "ProfileViewController.h"
#import "SendUserViewController.h"
#import <MapKit/MapKit.h>
#import "MapViewController.h"
#import "FriendTaggerViewController.h"
#import "GymViewController.h"
#import "GradientButton.h"
@interface RouteDetailViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,PF_FBRequestDelegate,UIScrollViewDelegate,UIAlertViewDelegate,TaggerDelegate,UIActionSheetDelegate>
{
    int likecount;
    BOOL facebookliked;
    UIAlertView* dislikealert; 
    UIAlertView* facebookalert;
    UIAlertView* flagalert;
    int currentAPICall;
}
-(void)getFacebookRouteDetails;
-(void)checksendstatus;
- (IBAction)showUsers:(UIButton*)sender;
@property (retain, nonatomic) IBOutlet UIView *topView;
@property (retain, nonatomic) IBOutlet UIView *btmView;
@property (retain, nonatomic) IBOutlet UIView *mapContainer;
@property (retain, nonatomic) IBOutlet UIView *approvalView;
@property (retain, nonatomic) IBOutlet UIButton *outdateButton;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (retain, nonatomic) IBOutlet UIButton *unoutdateButton;
@property (retain, nonatomic) IBOutlet UIButton *postButton;
@property (retain, nonatomic) IBOutlet MKMapView *routeMapView;
@property (retain, nonatomic) IBOutlet UIProgressView *progressBar;
@property (retain, nonatomic) IBOutlet UILabel *routeLocationLabel;
@property (retain, nonatomic) IBOutlet UIImageView *pinImageView;
@property (retain, nonatomic) IBOutlet UILabel *unavailableLabel;
@property (retain, nonatomic) IBOutlet UIImageView *routeImageView;
@property (retain, nonatomic) IBOutlet UIImageView *UserImageView;
@property (retain, nonatomic) IBOutlet UILabel *usernameLabel;
@property (retain, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (retain, nonatomic) IBOutlet UITableView *commentsTable;
@property (retain, nonatomic) IBOutlet UILabel *likeCountLabel;
@property (retain, nonatomic) NSMutableArray* commentsArray;
@property (retain, nonatomic) NSMutableArray* queryArray;
@property (retain, nonatomic) NSMutableArray* savedArray;
@property (retain, nonatomic) IBOutlet UILabel *viewCountLabel;
@property (retain, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (retain, nonatomic) RouteObject* routeObject;
@property (retain, nonatomic) NSData* rawImageData;
@property (retain, nonatomic) IBOutlet UITextField *commentTextField;
@property (retain, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (retain, nonatomic) IBOutlet UIButton *likeButton;
@property (retain, nonatomic) IBOutlet UIButton *flashbutton;
@property (retain, nonatomic) IBOutlet UIButton *sentbutton;
@property (retain, nonatomic) IBOutlet UIButton *projbutton;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UILabel *flashCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *sendCountLabel;
@property (retain, nonatomic) IBOutlet UILabel *projectCountLabel;
@property (retain, nonatomic) GradientButton *approveButton;
@property (retain, nonatomic) GradientButton *disapproveButton;

-(void)getImageIfUnavailable;
-(void)LikeOperation:(NSInteger)likecount;
@end
