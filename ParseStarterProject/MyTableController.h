//
//  MyTableController.h
//  PsychedApp
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
#import "CommentTableCell.h"
#import "UIView+InnerShadow.h"
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
}
@property (retain, nonatomic) IBOutlet UIButton *settingsButton;
@property (retain,nonatomic)  LKBadgeView* newbadge;
@property (retain, nonatomic) NSMutableArray* followedPosters;
@property (retain, nonatomic) IBOutlet UIView *emptyGradeView;
@property (retain, nonatomic) IBOutlet UIView *emptyView;
@property (retain, nonatomic) CLLocation* currentLocation;
@property (retain, nonatomic) UITableView *routeTableView;
@property (retain,nonatomic)  NSMutableArray* routeArray;
@property (retain,nonatomic)  NSMutableArray* queryArray;
@property (retain,nonatomic)  NSMutableArray* gymFetchArray;


-(void)addStandardTabView;
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;
@end
