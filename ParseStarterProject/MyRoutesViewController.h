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
#import "ASIHTTPRequest.h"
#import <Foundation/Foundation.h>
#import "JMTabView.h"
#import "DAReloadActivityButton.h"
#import "LoadMoreCell.h"
#import "EGORefreshTableHeaderView.h"
@interface MyRoutesViewController : UIViewController<PF_FBRequestDelegate,JMTabViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSInteger loadcount;
    JMTabView * tabView;
    UIView* headerView;
    UIButton* refreshButton;
    NSInteger shouldDisplayNext;
    
}
@property(nonatomic)NSInteger selectedSegment;
@property(retain, nonatomic) PFUser* selectedUser;
@property (retain, nonatomic) IBOutlet UITableView *routeTableView;
@property (retain, nonatomic) NSMutableArray* flashArray;
@property (retain, nonatomic) NSMutableArray* sentArray;
@property (retain, nonatomic) NSMutableArray* projectArray;
@property (retain, nonatomic) NSMutableArray* likedArray;
@property (retain, nonatomic) NSMutableArray* queryArray;
@property (retain,nonatomic) NSMutableArray* gymFetchArray;
-(void)addStandardTabView;
- (void)reloadTableViewDataSource;
@end
