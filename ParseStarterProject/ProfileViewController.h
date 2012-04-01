//
//  ProfileViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FollowFriendsViewController.h"
#import "MyRoutesViewController.h"
#import "DAReloadActivityButton.h"
@interface ProfileViewController : UIViewController <UITableViewDelegate,UITableViewDataSource>
{
    PFUser* selectedUser;
    NSMutableArray* followedArray;
}
@property (retain, nonatomic) IBOutlet UIButton *addedButton;
@property (retain, nonatomic) IBOutlet UIButton *projectsButton;
@property (retain, nonatomic) IBOutlet UIButton *sendsButton;
@property (retain, nonatomic) IBOutlet UIButton *flashButton;
@property (retain, nonatomic) IBOutlet UIButton *followersButton;
@property (retain, nonatomic) IBOutlet UIButton *followingButton;

@property (retain, nonatomic) IBOutlet UILabel *followingwho;
@property (retain,nonatomic) PFUser* selectedUser;
@property (retain, nonatomic) IBOutlet UIImageView *userImageView;
@property (nonatomic, retain) NSString* username;
@property (retain, nonatomic) IBOutlet UILabel *userNameLabel;
@property (retain, nonatomic) IBOutlet UITableView *userFeedTable;
@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain,nonatomic) NSMutableArray* userfeeds;
@property (retain, nonatomic) IBOutlet UILabel *followingLabel;
@property (retain, nonatomic) IBOutlet UILabel *flashLabel;
@property (retain, nonatomic) IBOutlet UILabel *sendLabel;
@property (retain, nonatomic) IBOutlet UILabel *projectLabel;
@property (retain, nonatomic) IBOutlet UILabel *likeLabel;
@property (retain, nonatomic) IBOutlet UIButton *addfriendsbutton;
@property (nonatomic,retain) UIImage* userimage;
@property (nonatomic, strong) DAReloadActivityButton *navigationBarItem;
@end
