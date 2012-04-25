//
//  MyTableController.h
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import <Parse/Parse.h>
#import "RouteDetailViewController.h"
#import "RouteObject.h"
#import "CustomTabItem.h"
#import "CustomSelectionView.h"
#import "CustomBackgroundLayer.h"
#import "CustomNoiseBackgroundView.h"
#import "UIView+Positioning.h"
#import "MyTableController.h"
#import "ASIHTTPRequest.h"
#import <Foundation/Foundation.h>
#import "JMTabView.h"
#import "EGORefreshTableHeaderView.h"
#import "DAReloadActivityButton.h"
#import <CoreLocation/CoreLocation.h>
#import "FollowTableCell.h"
#import "ParseStarterProjectAppDelegate.h"
#import "LoginViewController.h"
#import "FeedCell.h"
#import "FeedObject.h"
#import "GymObject.h"
#import "GymCell.h"
@interface MyTableController : UIViewController<PF_FBRequestDelegate,JMTabViewDelegate,UITableViewDelegate,UITableViewDataSource,EGORefreshTableHeaderDelegate,UIScrollViewDelegate,CLLocationManagerDelegate>
{
    
    CLLocationManager* locationManager;
    EGORefreshTableHeaderView*_refreshHeaderView; 
    	BOOL _reloading;
    NSInteger loadcount;
     NSInteger shouldDisplayNext;
    JMTabView * tabView;
    UIView* headerView;
    UIButton* refreshButton;
     NSMutableArray* followedPosters;
        NSMutableArray* unreadArray;
}
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain,nonatomic)LKBadgeView* newbadge;
@property (retain,nonatomic) NSMutableArray* unreadArray;
@property (retain, nonatomic) NSMutableArray* followedPosters;
@property (retain, nonatomic) IBOutlet UIView *emptyGradeView;
@property (retain, nonatomic) IBOutlet UIView *emptyView;
@property (retain, nonatomic) CLLocationManager* locationManager;
@property (retain, nonatomic)  CLLocation* currentLocation;
@property (retain, nonatomic) UIScrollView *titleTableView;
@property (retain, nonatomic) UITableView *routeTableView;
@property (retain, nonatomic) NSMutableArray* baserouteArray;
@property (retain,nonatomic) NSMutableArray* routeArray;
@property (retain,nonatomic) NSMutableArray* followedArray;
@property (retain,nonatomic) NSMutableArray* queryArray;


-(void)addStandardTabView;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
