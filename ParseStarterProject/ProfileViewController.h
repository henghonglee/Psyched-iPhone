//
//  ProfileViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "FollowFriendsViewController.h"
#import "MyRoutesViewController.h"
#import "DAReloadActivityButton.h"
@interface ProfileViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,UIScrollViewDelegate>
{
    PFUser* selectedUser;
    NSMutableArray* followedArray;
    float startDragX;
}
@property (retain, nonatomic) IBOutlet UIScrollView *chartScroll;
@property (retain, nonatomic) IBOutlet UIView *chart3view;
@property (retain, nonatomic) IBOutlet UIView *chart1View;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *chartActivityIndicator;
@property (retain, nonatomic) IBOutlet UIImageView *chartImageView;
@property (retain, nonatomic) IBOutlet UIView *badgeView;
@property (retain, nonatomic) IBOutlet UILabel *aboutMeLabel;
@property (retain, nonatomic) IBOutlet UIView *levelView;
@property (retain, nonatomic) IBOutlet UIImageView *profileImageView;
@property (retain, nonatomic) IBOutlet UIView *profileView;
@property (retain, nonatomic) IBOutlet UILabel *levelPercentLabel;
@property (retain, nonatomic) IBOutlet UILabel *levelLabel;
@property (retain, nonatomic) IBOutlet UIProgressView *levelProgressBar;
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
@property (retain,nonatomic) NSMutableArray* queryArray;
@property (retain, nonatomic) IBOutlet UILabel *followingLabel;
@property (retain, nonatomic) IBOutlet UILabel *flashLabel;
@property (retain, nonatomic) IBOutlet UILabel *sendLabel;
@property (retain, nonatomic) IBOutlet UILabel *projectLabel;
@property (retain, nonatomic) IBOutlet UILabel *likeLabel;
@property (retain, nonatomic) IBOutlet UIButton *addfriendsbutton;
@property (nonatomic,retain) UIImage* userimage;
@property (nonatomic, strong) DAReloadActivityButton *navigationBarItem;
@end
