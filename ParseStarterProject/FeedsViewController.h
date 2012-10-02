//
//  FeedsViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 15/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedCell.h"
#import <Parse/Parse.h>
#import "RouteDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "LoadMoreFeedCell.h"
@interface FeedsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,PF_EGORefreshTableHeaderDelegate>
{
    NSInteger shouldDisplayNextForFeeds;
    NSInteger shouldDisplayNextForFollows;
    PF_EGORefreshTableHeaderView*_refreshHeaderView; 
    BOOL _reloading;
    NSMutableArray* unreadArray;
}
@property (retain,nonatomic) NSMutableArray* unreadArray;
@property (retain, nonatomic) IBOutlet UIView *emptyView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (retain,nonatomic) NSMutableArray* feedsArray;
@property (retain,nonatomic) NSMutableArray* followsArray;
@property (retain,nonatomic) NSMutableArray* queryArray;
@property (retain, nonatomic) IBOutlet UITableView *feedsTable;
@property (retain, nonatomic) IBOutlet UIView *segheader;
-(void)refreshFollowsArray;
@end
