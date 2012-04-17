//
//  CreateRouteViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "MapKit/MapKit.h"
#import <Parse/Parse.h>
#import "FBfriend.h"
#import "MBProgressHUD.h"
#import "RouteDescriptionViewController.h"
#import "RouteLocationViewController.h"
#import "FriendTaggerViewController.h"
@interface CreateRouteViewController : UIViewController<UITextFieldDelegate,UIAlertViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource,PF_FBRequestDelegate,MBProgressHUDDelegate,RouteDescriptionDelegate,TaggerDelegate,RouteLocationDelegate,CLLocationManagerDelegate>
{
    BOOL isPage;
    MBProgressHUD* HUD;
    MBProgressHUD* pagesHUD;
    int arrIndex;
    
    UIPickerView* gympickerView;
    UIActionSheet*gymActionSheet;

    UIPickerView* fbAccountPickerView;
    UIActionSheet* accountActionSheet;

    UITableView* searchTable;
    int currentAPIcall;
    NSString* fbphotoid;
    int difficultyint;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D routeLoc;
    NSString* oldAccessToken;
}


-(void)tagPhoto:(NSString*)photoid withUser:(NSString*)facebookid;
@property (retain,nonatomic) NSArray* accounts;
@property (retain,nonatomic) NSMutableArray* arrayOfAccounts;
@property (retain,nonatomic) UIPickerView* fbAccountPickerView;
@property (retain,nonatomic) UIActionSheet* accountActionSheet;
@property (retain, nonatomic) IBOutlet UIImageView *routeImageView;
@property (retain, nonatomic) NSMutableDictionary* imageMetaData;
@property (retain, nonatomic) IBOutlet MKMapView* routeLocMapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) PF_FBRequest *myRequest;
@property (retain, nonatomic) NSMutableArray* friendsArray;
@property (retain, nonatomic) NSMutableArray* FBfriendsArray;
@property (retain, nonatomic) NSMutableArray* tempArray;
@property (retain, nonatomic) NSMutableArray* recommendArray;
@property (retain, nonatomic) IBOutlet UITextField *difficultyTextField;


@property (retain,nonatomic) NSArray* gymlist;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (retain, nonatomic) IBOutlet UITextField *locationTextField;
@property (retain, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (retain, nonatomic) IBOutlet UIScrollView *scroll;
@property (retain, nonatomic) IBOutlet UITextView *recommendTextView;
@property (retain, nonatomic) UIImage* imageTaken;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UITextField *recommendTextField;
@property (retain, nonatomic) IBOutlet UISwitch *fbuploadswitch;
@property (retain, nonatomic) IBOutlet UISwitch *twuploadswitch;

@end
