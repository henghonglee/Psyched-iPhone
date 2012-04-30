//
//  GymViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "JMTabView.h"
#import "GymDetailCell.h"
@interface GymViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,JMTabViewDelegate>
{
        JMTabView * tabView;
}
@property (nonatomic,retain) NSString* gymName;
@property (nonatomic,retain) NSMutableArray* gymGradeDown;
@property (nonatomic,retain) NSMutableArray* gymGradeUp;
@property (nonatomic,retain) NSMutableArray* gymReccomended;
@property (nonatomic,retain) NSMutableArray* gymLiked;
@property (nonatomic,retain) NSMutableArray* gymCommented;
@property (nonatomic,retain) NSMutableArray* gymTags;
@property (nonatomic,retain) NSMutableArray* routeArray;
@property (nonatomic,retain) NSMutableDictionary* gymSections;
@property (nonatomic,retain) NSURL* gymURL;
@property (retain,nonatomic) PFObject* gymObject;
@property (retain, nonatomic) IBOutlet UIImageView *gymProfileImageView;
@property (retain, nonatomic) IBOutlet UIButton *routeCountButton;
@property (retain, nonatomic) IBOutlet UIButton *followingCountButton;
@property (retain, nonatomic) IBOutlet UILabel *gymNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *gymCoverImageView;
@property (retain, nonatomic) IBOutlet UITableView *gymTable;
@property (retain, nonatomic) IBOutlet UIView *headerView;
@property (retain, nonatomic) IBOutlet UIView *gymMapViewController;
@property (retain, nonatomic) IBOutlet MKMapView *gymMapView;

@end
