//
//  ProfileViewController.m
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//
#import "ProfileFeedCell.h"
#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "FeedCell.h"
#import "FeedObject.h"
#import "ASIHTTPRequest.h"
#import "RouteDetailViewController.h"
#import "FollowingViewController.h"
#import "SearchFriendsViewController.h"
#import "UserFeed.h"
@implementation ProfileViewController
@synthesize userimage;
@synthesize levelLabel;
@synthesize queryArray;
@synthesize addedButton;
@synthesize projectsButton;
@synthesize sendsButton;
@synthesize flashButton;
@synthesize followersButton;
@synthesize followingButton;
@synthesize profileView;
@synthesize profileImageView;
@synthesize followingwho;
@synthesize selectedUser;
@synthesize userImageView;
@synthesize username;
@synthesize userNameLabel;
@synthesize userFeedTable;
@synthesize followButton;
@synthesize userfeeds;
@synthesize levelPercentLabel;
@synthesize followingLabel;
@synthesize flashLabel;
@synthesize sendLabel;
@synthesize projectLabel;
@synthesize likeLabel;
@synthesize addfriendsbutton;
@synthesize levelProgressBar;
@synthesize navigationBarItem;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UIImage *selectedImage0 = [UIImage imageNamed:@"HomeDB.png"];
    UIImage *unselectedImage0 = [UIImage imageNamed:@"HomeLB.png"];
    
    UIImage *selectedImage2 = [UIImage imageNamed:@"BuildingsDB.png"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"BuildingsLB.png"];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    
    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];
    
    [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
    [super viewDidLoad];
    
    self.navigationItem.title = @"Profile";
    UIImage *track = [[UIImage imageNamed:@"trackImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    UIImage *progImage = [[UIImage imageNamed:@"progressImage"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)];
    [levelProgressBar setProgressImage:progImage];
    [levelProgressBar setTrackImage:track];
    profileView.layer.cornerRadius = 5;
    _badgeView.layer.cornerRadius = 5;
    _levelView.layer.cornerRadius = 5;
    _chart1View.layer.cornerRadius = 5;
    _chart3view.layer.cornerRadius = 5;
    
    _chartScroll.contentSize = CGSizeMake(840, 202);
    _chartScroll.delegate = self;
    _chartScroll.clipsToBounds  = NO;
    _chartScroll.contentOffset= CGPointMake(280,0 );
    [_chart1View setFrame:CGRectMake(0, 0, 280, 202)];
    [_levelView setFrame:CGRectMake(290, 0, 260, 202)];
    [_chart3view setFrame:CGRectMake(560, 0, 280, 202)];

    levelLabel.layer.cornerRadius=5;
    userImageView.layer.cornerRadius = 5;
    userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    userImageView.layer.borderWidth = 2;
    userImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    userImageView.layer.shadowOffset = CGSizeMake(-1, -1);
    userImageView.layer.shadowRadius = 2;
    userImageView.layer.shadowOpacity = 0.8;
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 4);
    navigationBarItem = [[DAReloadActivityButton alloc] init];
    navigationBarItem.showsTouchWhenHighlighted = NO;
    [navigationBarItem addTarget:self action:@selector(reloadUserDataAction
) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationBarItem];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];
    

    if(!username){
        username = [[PFUser currentUser] objectForKey:@"name"];
        [username retain];
    }
    PFQuery* userQuery = [PFUser query];
    userQuery.cachePolicy= kPFCachePolicyNetworkElseCache;
    [userQuery whereKey:@"name" equalTo:username];
    [queryArray addObject:userQuery];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:userQuery];
        NSLog(@"loading profile");
        selectedUser = [objects objectAtIndex:0];
        [selectedUser retain];
        
        _aboutMeLabel.text = [selectedUser objectForKey:@"about_me"];
        
        [self loadRecentChartData];
        [self loadTotalClimbsChartData];
                
        
        
        
        
        if (userimage) {
            userImageView.image = userimage;
        }else{
            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[selectedUser objectForKey:@"profilepicture"]] ];
            [request setCompletionBlock:^{
                userimage = [UIImage imageWithData:[request responseData]];
                userImageView.image = userimage;
            }];
            [request setFailedBlock:^{}];
            [request startAsynchronous];
        }
        if ([[selectedUser objectForKey:@"score"] isKindOfClass:[NSNull class]]) {
            [selectedUser setObject:[NSNumber numberWithInt:0] forKey:@"score"];
            [selectedUser saveEventually];
            
        }
        
        int totalScore = [((NSNumber*)[selectedUser objectForKey:@"score"]) intValue];
        int level = (int)((1+sqrt(totalScore/5 + 1))/2);
        float percentToNextLevel = (((1+sqrt(totalScore/5 + 1))/2) - level);
        levelProgressBar.progress = percentToNextLevel;
        levelPercentLabel.text = [NSString stringWithFormat:@"%d/%d points to Level %d (%d%%)",totalScore,5*(((level+1)*2-1)*((level+1)*2-1)),level+1,(int)(percentToNextLevel*100)];
        levelLabel.text = [NSString stringWithFormat:@"%d", level];
        
        PFQuery* likequery = [PFQuery queryWithClassName:@"Route"];
        likequery.cachePolicy= kPFCachePolicyNetworkElseCache; 
        [likequery whereKey:@"username" equalTo:username];
        [likequery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            NSLog(@"%d likes",number);
            likeLabel.text = [NSString stringWithFormat:@"%d",number];
            addedButton.userInteractionEnabled = YES;
        }];
        PFQuery* flashquery = [PFQuery queryWithClassName:@"Flash"];
        flashquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [flashquery whereKey:@"username" equalTo:username];
        [flashquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            NSLog(@"%d flashes",number);
            flashLabel.text = [NSString stringWithFormat:@"%d",number];
            flashButton.userInteractionEnabled = YES;
        }];
        PFQuery* sentquery = [PFQuery queryWithClassName:@"Sent"];
        sentquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [sentquery whereKey:@"username" equalTo:username];
        [sentquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            NSLog(@"%d sends",number); 
            sendLabel.text = [NSString stringWithFormat:@"%d",number];
            sendsButton.userInteractionEnabled = YES;
        }];
        PFQuery* projquery = [PFQuery queryWithClassName:@"Project"];
        projquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [projquery whereKey:@"username" equalTo:username];
        [projquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            NSLog(@"%d projs",number);
            projectLabel.text = [NSString stringWithFormat:@"%d",number];
            projectsButton.userInteractionEnabled = YES;
        }];
        PFQuery* followingwhoquery = [PFQuery queryWithClassName:@"Follow"];
        followingwhoquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [followingwhoquery whereKey:@"follower" equalTo:selectedUser];
        [followingwhoquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            followingwho.text = [NSString stringWithFormat:@"%d",number];
            followingButton.userInteractionEnabled = YES;
        }];
        
        PFQuery* followingquery = [PFQuery queryWithClassName:@"Follow"];
        followingquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [followingquery whereKey:@"followed" equalTo:username];
        [followingquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            NSLog(@"%d followers",number);
            followingLabel.text = [NSString stringWithFormat:@"%d",number];
            followersButton.userInteractionEnabled = YES;
        }];
        
        // grab user feeds
        
        userfeeds = [[NSMutableArray alloc]init ];
        queryArray = [[NSMutableArray alloc]init ];
        PFQuery* queryForNotification = [PFQuery queryWithClassName:@"Feed"];
        [queryForNotification  whereKey:@"sender" notEqualTo:username];
        [queryForNotification whereKey:@"message" containsString:username];
        [queryForNotification orderByDescending:@"createdAt"];
        [queryArray addObject:queryForNotification];
        [queryForNotification findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [queryArray removeObject:queryForNotification];
            for (PFObject* pfobject in objects) {
                UserFeed* userfeed = [[UserFeed alloc]init];
                userfeed.pfobj = pfobject;
                [userfeeds addObject:userfeed];
                [userfeed release];
            }
            [userFeedTable reloadData];
        }];
        
        
        //grab user followed
        
        followedArray = [[NSMutableArray alloc]init];
        PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
        
        followedquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
        [queryArray addObject:followedquery];
        [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             [queryArray removeObject:followedquery];
            [followedArray addObjectsFromArray:objects];
            BOOL isFollowing=NO;
            for (PFObject* obj in followedArray) {
                if ([userNameLabel.text isEqualToString:[obj objectForKey:@"followed"]]) {
                    isFollowing =YES;
                }
            }
            if (isFollowing) {
                [followButton setUserInteractionEnabled:YES];
                [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
                followButton.tag = 1;
            }else{
                [followButton setUserInteractionEnabled:YES];
                [followButton setTitle:@"Follow" forState:UIControlStateNormal];
                followButton.tag = 0;
            }
        }];
        
    }];
    
    
}

- (IBAction)showfollowers:(id)sender {
    FollowFriendsViewController* viewController = [[FollowFriendsViewController alloc]initWithNibName:@"FollowFriendsViewController" bundle:nil];
    viewController.selectedUser = selectedUser;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}
-(void)viewDidAppear:(BOOL)animated
{
    
}
- (IBAction)addFollowers:(id)sender {
    SearchFriendsViewController* viewController = [[SearchFriendsViewController alloc]initWithNibName:@"SearchFriendsViewController" bundle:nil];
    viewController.selectedUser = selectedUser;
    
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (IBAction)showFollowing:(id)sender {
    FollowingViewController* viewController = [[FollowingViewController alloc]initWithNibName:@"FollowingViewController" bundle:nil];
    viewController.selectedUser = selectedUser;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}
- (IBAction)showsubmitted:(id)sender {
}
-(void)reloadUserDataAction
{
//    if ([selectedUser.objectId isEqualToString:[PFUser currentUser].objectId]) {
//        NSLog(@"calculating score..");
//    [PFCloud callFunctionInBackground:@"calculateScore" withParameters:[NSDictionary new] target:self selector:@selector(reloadUserData)];
//    }else{
        [self performSelector:@selector(reloadUserData)];
//    }

}
-(void)loadTotalClimbsChartData{
    //TODO: should offload these into cloudcode
    __block NSString* urlstring = [NSString stringWithFormat:@""];
    _noTotalClimbsLabel.hidden = YES;
    [_totalClimbsChartActivityIndicator startAnimating];
    PFQuery *v0v2flash = [PFQuery queryWithClassName:@"Flash"];
    [v0v2flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:0]];
    [v0v2flash whereKey:@"username" equalTo:username];
    [v0v2flash countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        PFQuery *v0v2send = [PFQuery queryWithClassName:@"Sent"];
        [v0v2send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:0]];
        [v0v2send whereKey:@"username" equalTo:username];
        [v0v2send countObjectsInBackgroundWithBlock:^(int number2, NSError *error) {
            urlstring = [urlstring stringByAppendingFormat:@"%d,",number+number2];
            [urlstring retain];
            PFQuery *v3v5flash = [PFQuery queryWithClassName:@"Flash"];
            [v3v5flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:1]];
            [v3v5flash whereKey:@"username" equalTo:username];
            [v3v5flash countObjectsInBackgroundWithBlock:^(int number3, NSError *error) {
                PFQuery *v3v5send = [PFQuery queryWithClassName:@"Sent"];
                [v3v5send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:1]];
                [v3v5send whereKey:@"username" equalTo:username];
                [v3v5send countObjectsInBackgroundWithBlock:^(int number4, NSError *error) {
                    urlstring = [urlstring stringByAppendingFormat:@"%d,",number3+number4];
                    [urlstring retain];
                    PFQuery *v6v8flash = [PFQuery queryWithClassName:@"Flash"];
                    [v6v8flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:2]];
                    [v6v8flash whereKey:@"username" equalTo:username];
                    [v6v8flash countObjectsInBackgroundWithBlock:^(int number5, NSError *error) {
                        PFQuery *v6v8send = [PFQuery queryWithClassName:@"Sent"];
                        [v6v8send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:2]];
                        [v6v8send whereKey:@"username" equalTo:username];
                        [v6v8send countObjectsInBackgroundWithBlock:^(int number6, NSError *error) {
                            urlstring = [urlstring stringByAppendingFormat:@"%d,",number5+number6];
                            [urlstring retain];
                            PFQuery *v9v11flash = [PFQuery queryWithClassName:@"Flash"];
                            [v9v11flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:3]];
                            [v9v11flash whereKey:@"username" equalTo:username];
                            [v9v11flash countObjectsInBackgroundWithBlock:^(int number7, NSError *error) {
                                PFQuery *v9v11send = [PFQuery queryWithClassName:@"Sent"];
                                [v9v11send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:3]];
                                [v9v11send whereKey:@"username" equalTo:username];
                                [v9v11send countObjectsInBackgroundWithBlock:^(int number8, NSError *error) {
                                    urlstring = [urlstring stringByAppendingFormat:@"%d,",number7+number8];
                                    [urlstring retain];
                                    PFQuery *v12flash = [PFQuery queryWithClassName:@"Flash"];
                                    [v12flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:4]];
                                    [v12flash whereKey:@"username" equalTo:username];
                                    [v12flash countObjectsInBackgroundWithBlock:^(int number9, NSError *error) {
                                        PFQuery *v12send = [PFQuery queryWithClassName:@"Sent"];
                                        [v12send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:4]];
                                        [v12send whereKey:@"username" equalTo:username];
                                        [v12send countObjectsInBackgroundWithBlock:^(int number10, NSError *error) {
                                            urlstring = [urlstring stringByAppendingFormat:@"%d,",number9+number10];
                                            [urlstring retain];
                                            PFQuery *v13flash = [PFQuery queryWithClassName:@"Flash"];
                                            [v13flash whereKey:@"difficulty" greaterThan:[NSNumber numberWithInt:5]];
                                            [v13flash whereKey:@"username" equalTo:username];
                                            [v13flash countObjectsInBackgroundWithBlock:^(int number11, NSError *error) {
                                                PFQuery *v13send = [PFQuery queryWithClassName:@"Sent"];
                                                [v13send whereKey:@"difficulty" greaterThan:[NSNumber numberWithInt:5]];
                                                [v13send whereKey:@"username" equalTo:username];
                                                [v13send countObjectsInBackgroundWithBlock:^(int number12, NSError *error) {
                                                    urlstring = [urlstring stringByAppendingFormat:@"%d",number11+number12];
                                                    [urlstring retain];
                                                    
                                                    if ([urlstring isEqualToString:@"0,0,0,0,0,0"])
                                                    {
                                                        _noTotalClimbsLabel.hidden = NO;
                                                        [_totalClimbsChartActivityIndicator stopAnimating];
                                                    }else{
                                                            NSURL* urlFinal = [NSURL URLWithString:[[NSString stringWithFormat:@"https://chart.googleapis.com/chart?chs=520x324&cht=bvs&chco=19F587|F5EC11|FF9B13|F53312|3019F5|CC16F5|000000&chd=t:%@&chds=a&chxt=x&chxl=0:|----|V0-V2|V3-V5|V6-V8|V9-V11|>V11&chbh=a,0&chm=N,000000,0,-1,15&chf=bg,s,65432100",urlstring]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                                            NSLog(@"urlstringfinal = %@",urlFinal);
                                                            ASIHTTPRequest* chartImageRequest = [ASIHTTPRequest requestWithURL:urlFinal];
                                                            NSLog(@"chartreq=%@",chartImageRequest.url);
                                                            
                                                            [chartImageRequest setCompletionBlock:^{
                                                                [_totalClimbsChartView setImage:[UIImage imageWithData:[chartImageRequest responseData]]];
                                                                [_totalClimbsChartActivityIndicator stopAnimating];
                                                                
                                                                [urlstring release];
                                                            }];
                                                            [chartImageRequest setFailedBlock:^{
                                                                NSLog(@"failedddd");
                                                                [_totalClimbsChartActivityIndicator stopAnimating];
                                                                [urlstring release];
                                                            }];
                                                            [chartImageRequest setTimeOutSeconds:10];
                                                            [chartImageRequest startAsynchronous];
                                                    }
                                                        }];
                                                
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
}
-(void)loadRecentChartData{
    
    //TODO: should offload these into cloudcode
    __block NSString* urlstring = [NSString stringWithFormat:@""];
    _noRecentClimbsLabel.hidden = YES;
    [_chartActivityIndicator startAnimating];
    PFQuery *v0v2flash = [PFQuery queryWithClassName:@"Flash"];
    [v0v2flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:0]];
    [v0v2flash whereKey:@"username" equalTo:username];
    [v0v2flash whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
    [v0v2flash countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        PFQuery *v0v2send = [PFQuery queryWithClassName:@"Sent"];
        [v0v2send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:0]];
        [v0v2send whereKey:@"username" equalTo:username];
       [v0v2send whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
        [v0v2send countObjectsInBackgroundWithBlock:^(int number2, NSError *error) {
            urlstring = [urlstring stringByAppendingFormat:@"%d,",number+number2];
            [urlstring retain];
            PFQuery *v3v5flash = [PFQuery queryWithClassName:@"Flash"];
            [v3v5flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:1]];
            [v3v5flash whereKey:@"username" equalTo:username];
            [v3v5flash whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
            [v3v5flash countObjectsInBackgroundWithBlock:^(int number3, NSError *error) {
                PFQuery *v3v5send = [PFQuery queryWithClassName:@"Sent"];
                [v3v5send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:1]];
                [v3v5send whereKey:@"username" equalTo:username];
                [v3v5send whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                [v3v5send countObjectsInBackgroundWithBlock:^(int number4, NSError *error) {
                    urlstring = [urlstring stringByAppendingFormat:@"%d,",number3+number4];
                    [urlstring retain];
                    PFQuery *v6v8flash = [PFQuery queryWithClassName:@"Flash"];
                    [v6v8flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:2]];
                    [v6v8flash whereKey:@"username" equalTo:username];
                    [v6v8flash whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                    [v6v8flash countObjectsInBackgroundWithBlock:^(int number5, NSError *error) {
                        PFQuery *v6v8send = [PFQuery queryWithClassName:@"Sent"];
                        [v6v8send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:2]];
                        [v6v8send whereKey:@"username" equalTo:username];
                       [v6v8send  whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                        [v6v8send countObjectsInBackgroundWithBlock:^(int number6, NSError *error) {
                            urlstring = [urlstring stringByAppendingFormat:@"%d,",number5+number6];
                            [urlstring retain];
                            PFQuery *v9v11flash = [PFQuery queryWithClassName:@"Flash"];
                            [v9v11flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:3]];
                            [v9v11flash whereKey:@"username" equalTo:username];
                            [v9v11flash whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                            [v9v11flash countObjectsInBackgroundWithBlock:^(int number7, NSError *error) {
                                PFQuery *v9v11send = [PFQuery queryWithClassName:@"Sent"];
                                [v9v11send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:3]];
                                [v9v11send whereKey:@"username" equalTo:username];
                                [v9v11send whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                                [v9v11send countObjectsInBackgroundWithBlock:^(int number8, NSError *error) {
                                    urlstring = [urlstring stringByAppendingFormat:@"%d,",number7+number8];
                                    [urlstring retain];
                                    PFQuery *v12flash = [PFQuery queryWithClassName:@"Flash"];
                                    [v12flash whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:4]];
                                    [v12flash whereKey:@"username" equalTo:username];
                                    [v12flash whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                                    [v12flash countObjectsInBackgroundWithBlock:^(int number9, NSError *error) {
                                        PFQuery *v12send = [PFQuery queryWithClassName:@"Sent"];
                                        [v12send whereKey:@"difficulty" equalTo:[NSNumber numberWithInt:4]];
                                        [v12send whereKey:@"username" equalTo:username];
                                        [v12send whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                                        [v12send countObjectsInBackgroundWithBlock:^(int number10, NSError *error) {
                                            urlstring = [urlstring stringByAppendingFormat:@"%d,",number9+number10];
                                            [urlstring retain];
                                            PFQuery *v13flash = [PFQuery queryWithClassName:@"Flash"];
                                            [v13flash whereKey:@"difficulty" greaterThan:[NSNumber numberWithInt:5]];
                                            [v13flash whereKey:@"username" equalTo:username];
                                            [v13flash whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                                            [v13flash countObjectsInBackgroundWithBlock:^(int number11, NSError *error) {
                                                PFQuery *v13send = [PFQuery queryWithClassName:@"Sent"];
                                                [v13send whereKey:@"difficulty" greaterThan:[NSNumber numberWithInt:5]];
                                                [v13send whereKey:@"username" equalTo:username];
                                                [v13send whereKey:@"createdAt" greaterThan:[NSDate dateWithTimeIntervalSinceNow:-604800]];
                                                [v13send countObjectsInBackgroundWithBlock:^(int number12, NSError *error) {
                                                    urlstring = [urlstring stringByAppendingFormat:@"%d",number11+number12];
                                                    [urlstring retain];
                                                    
                                                    if ([urlstring isEqualToString:@"0,0,0,0,0,0"])
                                                    {
                                                        _noRecentClimbsLabel.hidden = NO;
                                                        [_chartActivityIndicator stopAnimating];
                                                    }else{
                                                    NSURL* urlFinal = [NSURL URLWithString:[[NSString stringWithFormat:@"https://chart.googleapis.com/chart?chs=520x324&cht=bvs&chco=19F587|F5EC11|FF9B13|F53312|3019F5|CC16F5|000000&chd=t:%@&chds=a&chxt=x&chxl=0:|<V0|V0-V2|V3-V5|V6-V8|V9-V11|>V11&chbh=a,0&chm=N,000000,0,-1,15&chf=bg,s,65432100",urlstring]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                                                    NSLog(@"urlstringfinal = %@",urlFinal);
                                                    ASIHTTPRequest* chartImageRequest = [ASIHTTPRequest requestWithURL:urlFinal];
                                                    NSLog(@"chartreq=%@",chartImageRequest.url);
                                                    
                                                    [chartImageRequest setCompletionBlock:^{
                                                        [_chartImageView setImage:[UIImage imageWithData:[chartImageRequest responseData]]];
                                                        [_chartActivityIndicator stopAnimating];
                                                        [urlstring release];
                                                    }];
                                                    [chartImageRequest setFailedBlock:^{
                                                        NSLog(@"failedddd");
                                                        [_chartActivityIndicator stopAnimating];
                                                        [urlstring release];
                                                    }];
                                                    [chartImageRequest setTimeOutSeconds:10];
                                                    [chartImageRequest startAsynchronous];
                                                    }
                                                }];
                                                
                                            }];
                                        }];
                                    }];
                                }];
                            }];
                        }];
                    }];
                }];
            }];
        }];
    }];
    
}
-(void)reloadUserData
{
    userFeedTable.scrollEnabled = NO;
    [navigationBarItem startAnimating];
    
    
    [self loadTotalClimbsChartData];
    [self loadRecentChartData];
    
    
    
    PFQuery* userQuery = [PFUser query];
    [userQuery whereKey:@"name" equalTo:username];
     [queryArray addObject:userQuery];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         [queryArray removeObject:userQuery];
    selectedUser = [objects objectAtIndex:0];
        [selectedUser retain];
//        int totalScore = [((NSNumber*)[selectedUser objectForKey:@"score"]) intValue];
//        int level = (int)((1+sqrt(totalScore/5 + 1))/2);
//        float percentToNextLevel = (((1+sqrt(totalScore/5 + 1))/2) - level);
//        levelProgressBar.progress = percentToNextLevel;
//        levelPercentLabel.text = [NSString stringWithFormat:@"%d/%d points to Level %d (%d%%)",totalScore,5*(((level+1)*2-1)*((level+1)*2-1)),level+1,(int)(percentToNextLevel*100)];
//        levelLabel.text = [NSString stringWithFormat:@"%d", level];
    if (userimage) {
        userImageView.image = userimage;
    }else{
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[selectedUser objectForKey:@"profilepicture"]] ];
        [request setCompletionBlock:^{
            userimage = [UIImage imageWithData:[request responseData]];
            userImageView.image = userimage;
        }];
        [request setFailedBlock:^{}];
        [request startAsynchronous];
    }
    PFQuery* likequery = [PFQuery queryWithClassName:@"Route"];
        likequery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [likequery whereKey:@"username" equalTo:username];
    [likequery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"%d likes",number);
        likeLabel.text = [NSString stringWithFormat:@"%d",number];
        addedButton.userInteractionEnabled = YES;
    }];
    PFQuery* flashquery = [PFQuery queryWithClassName:@"Flash"];
        flashquery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [flashquery whereKey:@"username" equalTo:username];
    [flashquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"%d flashes",number);
        flashLabel.text = [NSString stringWithFormat:@"%d",number];
        flashButton.userInteractionEnabled = YES;
    }];
    PFQuery* sentquery = [PFQuery queryWithClassName:@"Sent"];
        sentquery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [sentquery whereKey:@"username" equalTo:username];
    [sentquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"%d sends",number); 
        sendLabel.text = [NSString stringWithFormat:@"%d",number];
       sendsButton.userInteractionEnabled = YES;
    }];
        PFQuery* followingwhoquery = [PFQuery queryWithClassName:@"Follow"];
        followingwhoquery.cachePolicy= kPFCachePolicyNetworkElseCache;
        [followingwhoquery whereKey:@"follower" equalTo:selectedUser];
        [followingwhoquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
            followingwho.text = [NSString stringWithFormat:@"%d",number];
            followingButton.userInteractionEnabled = YES;
        }];
        
    PFQuery* projquery = [PFQuery queryWithClassName:@"Project"];
        projquery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [projquery whereKey:@"username" equalTo:username];
    [projquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"%d projs",number);
        projectLabel.text = [NSString stringWithFormat:@"%d",number];
        [projectsButton setUserInteractionEnabled:YES];
    }];
    
    PFQuery* followingquery = [PFQuery queryWithClassName:@"Follow"];
        followingquery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [followingquery whereKey:@"followed" equalTo:username];
    [followingquery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        NSLog(@"%d followers",number);
        followingLabel.text = [NSString stringWithFormat:@"%d",number];
        followersButton.userInteractionEnabled = YES;
    }];
    
    // grab user feeds
        // grab user feeds
        

        PFQuery* queryForNotification = [PFQuery queryWithClassName:@"Feed"];
        [queryForNotification  whereKey:@"sender" notEqualTo:username];
        [queryForNotification whereKey:@"message" containsString:username];
        [queryForNotification orderByDescending:@"createdAt"];
         [queryArray addObject:queryForNotification];
        [queryForNotification findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
             [queryArray addObject:queryForNotification];
            [userfeeds removeAllObjects];
            for (PFObject* pfobject in objects) {
                UserFeed* userfeed = [[UserFeed alloc]init];
                userfeed.pfobj = pfobject;
                [userfeeds addObject:userfeed];
                [userfeed release];
            }
            [userFeedTable reloadData];
            [userFeedTable setScrollEnabled:YES];
        }];    
    //grab user followed
    
    followedArray = [[NSMutableArray alloc]init];
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
        followedquery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
        [queryArray addObject:followedquery];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:followedquery];
        [followedArray addObjectsFromArray:objects];
        BOOL isFollowing=NO;
        for (PFObject* obj in followedArray) {
            if ([userNameLabel.text isEqualToString:[obj objectForKey:@"followed"]]) {
                isFollowing =YES;
            }
        }
        if (isFollowing) {
            [followButton setTitle:@"Unfollow" forState:UIControlStateNormal];
            followButton.tag = 1;
        }else{
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
            followButton.tag = 0;
        }
    }];
    }];
    [navigationBarItem stopAnimating];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
            [followButton setUserInteractionEnabled:NO];
    if ([username isEqualToString:[[PFUser currentUser] objectForKey:@"name"]]) {
        addfriendsbutton.hidden=NO;
        followButton.hidden = YES;
    }else{
        addfriendsbutton.hidden=YES;
        followButton.hidden = NO;
    }
    self.navigationController.navigationBarHidden = NO;
    userNameLabel.text = username;

    
}

- (IBAction)myroutes:(UIButton*)sender {
    MyRoutesViewController* viewController = [[MyRoutesViewController alloc]initWithNibName:@"MyRoutesViewController" bundle:nil];
    viewController.selectedUser = selectedUser;
    viewController.selectedSegment = sender.tag;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
}
- (IBAction)tagfriends:(id)sender {
}
- (IBAction)followfriends:(id)sender {
    FollowFriendsViewController* followFriendsViewController = [[FollowFriendsViewController alloc]initWithNibName:@"FollowFriendsViewController" bundle:nil];
    [self.navigationController pushViewController:followFriendsViewController animated:YES];
    [followFriendsViewController release];
}

- (void)viewDidUnload
{
    [self setUserFeedTable:nil];
    [self setUserNameLabel:nil];
    [self setUserImageView:nil];
    [self setFollowButton:nil];
    [self setFollowingLabel:nil];
    [self setFlashLabel:nil];
    [self setSendLabel:nil];
    [self setProjectLabel:nil];
    [self setLikeLabel:nil];
    [self setFollowingwho:nil];
    [self setAddfriendsbutton:nil];
    [self setAddedButton:nil];
    [self setProjectsButton:nil];
    [self setSendsButton:nil];
    [self setFlashButton:nil];
    [self setFollowersButton:nil];
    [self setFollowingButton:nil];
    [self setSelectedUser:nil];
    
    [self setNavigationBarItem:nil];
    [self setUserfeeds:nil];

    [self setLevelProgressBar:nil];
    [self setLevelLabel:nil];
    [self setLevelPercentLabel:nil];
    [self setProfileView:nil];
    [self setProfileImageView:nil];
    [self setLevelView:nil];
    [self setAboutMeLabel:nil];
    [self setBadgeView:nil];
    [self setChartImageView:nil];
    [self setChartActivityIndicator:nil];
    [self setChart1View:nil];
    [self setChart3view:nil];
    [self setChartScroll:nil];
    [self setTotalClimbsChartView:nil];
    [self setTotalClimbsChartActivityIndicator:nil];
    [self setNoRecentClimbsLabel:nil];
    [self setNoTotalClimbsLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)followAction:(UIButton*)sender {
    if (sender.tag == 1) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Stop Following %@?",userNameLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
        alert.delegate = self;
    [alert show];
    [alert release];

    }else{
    PFObject* pfObj = [PFObject objectWithClassName:@"Follow"];
    [pfObj setObject:[PFUser currentUser] forKey:@"follower"];
    [pfObj setObject:userNameLabel.text forKey:@"followed"];
    [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFQuery* userQ = [PFUser query];
        [userQ whereKey:@"name" equalTo:userNameLabel.text];
        [userQ getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object) {
                [PFPush sendPushMessageToChannelInBackground:[NSString stringWithFormat:@"channel%@",[object objectForKey:@"facebookid"]] withMessage:[NSString stringWithFormat:@"%@ is now following you on Psyched!",[[PFUser currentUser] objectForKey:@"name"]]];
            }else{
                NSLog(@"error = %@",error);
            }
        }];
        [sender setTitle:@"UnFollow" forState:UIControlStateNormal];
        sender.tag = 1;
    }];
    }
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"followed" equalTo:userNameLabel.text];
        [queryArray addObject:query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [queryArray removeObject:query];
            for (PFObject* obj in objects) {
                [obj deleteInBackground];
            }
            [followButton setTitle:@"Follow" forState:UIControlStateNormal];
            followButton.tag = 0;
        }];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromCellIdentifier = @"FromCell";
    ProfileFeedCell* cell = (ProfileFeedCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProfileFeedCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (ProfileFeedCell*)currentObject;
                
            }
        }
    }
    
    
    
    cell.senderImage.layer.cornerRadius = 5;
    cell.feedLabel.text = [[[[[[((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).pfobj objectForKey:@"message"]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"] stringByReplacingOccurrencesOfString:[[PFUser currentUser]objectForKey:@"name"] withString:@"you"]stringByReplacingOccurrencesOfString:@"his/her" withString:@"your"]stringByReplacingOccurrencesOfString:@"her" withString:@"your"]stringByReplacingOccurrencesOfString:@"his" withString:@"your"]  ;
    
        PFObject* selectedFeedObj = ((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).pfobj;
        NSString* urlstring = [NSString stringWithFormat:@"%@",[selectedFeedObj objectForKey:@"senderimagelink"]];
        NSLog(@"urlstring = %@",urlstring);
    
        if (((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).senderImage) {
            cell.senderImage.image = ((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).senderImage;
        }else{
            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
            [request setCompletionBlock:^{
                cell.senderImage.image= [UIImage imageWithData:[request responseData]];
                ((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).senderImage = cell.senderImage.image;
            }];
            [request setFailedBlock:^{
                cell.senderImage.image= [UIImage imageNamed:@"placeholder_user.png"];
            }];
            [request startAsynchronous];
        }

    if ([userfeeds count]>0) {
        PFObject* selectedFeed = ((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).pfobj;
        double timesincenow =  [((NSDate*)selectedFeed.createdAt) timeIntervalSinceNow];
       // NSLog(@"timesincenow = %i",((int)timesincenow));
        int timeint = ((int)timesincenow);
        //if more than 1 day show number of days
        //if more than 60min show number of hrs
        //if more than 24hrs show days
        
        if (timeint < -86400) {
            cell.timeLabel.text = [NSString stringWithFormat:@"%id ago",timeint/-86400];
        }else if(timeint < -3600){
            cell.timeLabel.text = [NSString stringWithFormat:@"%ih ago",timeint/-3600];
        }else{
            cell.timeLabel.text = [NSString stringWithFormat:@"%im ago",timeint/-60];
        }
        if (![[selectedFeed objectForKey:@"viewed"] containsObject:[[PFUser currentUser]objectForKey:@"name"]] && ![[selectedFeed objectForKey:@"sender"] isEqualToString:[[PFUser currentUser] objectForKey:@"name"]] && ([cell.feedLabel.text rangeOfString:@"you"].location != NSNotFound || [cell.feedLabel.text rangeOfString:@"your"].location != NSNotFound)) {
            
            cell.readSphereView.image = [UIImage imageNamed:@"bluesphere.png"];
            [UIView animateWithDuration:0.4
                                  delay:1.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 cell.readSphereView.alpha = 0.0;
                             } 
                             completion:^(BOOL finished){
                                 cell.readSphereView.image = [UIImage imageNamed:@"tick.png"];
                                 [UIView animateWithDuration:0.4
                                                       delay:0.0
                                                     options: UIViewAnimationCurveEaseOut
                                                  animations:^{
                                                      cell.readSphereView.alpha = 1.0;
                                                  } 
                                                  completion:^(BOOL finished){
                                                      if (finished) {
                                                          
                                                          
                                                          NSMutableArray* _unreadArray = [[NSMutableArray alloc]initWithArray:[selectedFeed objectForKey:@"viewed"]];
                                                          [_unreadArray addObject:[[PFUser currentUser]objectForKey:@"name"]];
                                                          [selectedFeed setObject:_unreadArray forKey:@"viewed"];    
                                                          [selectedFeed saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                              PFQuery* queryForNotification = [PFQuery queryWithClassName:@"Feed"];
                                                              [queryForNotification whereKey:@"viewed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
                                                              [queryForNotification  whereKey:@"sender" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
                                                              [queryForNotification whereKey:@"message" containsString:[[PFUser currentUser]objectForKey:@"name"]];
                                                              [queryForNotification countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                                                  ParseStarterProjectAppDelegate* appDel = (ParseStarterProjectAppDelegate* )[[UIApplication sharedApplication]delegate];
                                                                  appDel.badgeView.text = [NSString stringWithFormat:@"%d",number];
                                                                  NSLog(@"number = %d",number);
                                                              }];
                                                              
                                                          }];
                                                          [_unreadArray release];
                                                      }
                                                      
                                                  }];
                                 
                                 
                             }];
            
            
        }else{
            cell.readSphereView.image = nil;
            
            
        }
        
    }
    
    
    
    
    
    return cell;
}

-(void)cancelQueries
{
    NSLog(@"canceling %d queries",[queryArray count]);
    for (id pfobject in queryArray) {
        if ([pfobject isKindOfClass:[PFQuery class]]) {
            NSLog(@"cancelling pfquery ");
            [((PFQuery*)pfobject) cancel];
        }
    }
    [queryArray removeAllObjects];
    NSLog(@"done canceling queries");
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didselectrow");
    [self cancelQueries];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PFObject* selectedFeed = ((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).pfobj;
    NSString* messagestring =[selectedFeed objectForKey:@"message"];
    if([messagestring rangeOfString:@"route"].location!=NSNotFound){
        
           RouteObject* newRouteObject = [[RouteObject alloc]init];
            newRouteObject.pfobj = [[((UserFeed*)[userfeeds objectAtIndex:indexPath.row]).pfobj objectForKey:@"linkedroute"]fetchIfNeeded];
             RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
            viewController.routeObject = newRouteObject;
            
            [self.navigationController pushViewController:viewController animated:YES];
            [viewController release];
            NSLog(@"will release newrouteobj");
            [newRouteObject release]; 
    
    
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
return [userfeeds count];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else {
        return NO;
    }
}


- (void)dealloc {
    [queryArray release];
    [selectedUser release];
    [userfeeds release];
    [username release];
    [userFeedTable release];
    [userNameLabel release];
    [userImageView release];
    [followButton release];
    [followingLabel release];
    [flashLabel release];
    [sendLabel release];
    [projectLabel release];
    [likeLabel release];
    [followingwho release];
    [addfriendsbutton release];
    [addedButton release];
    [projectsButton release];
    [sendsButton release];
    [flashButton release];
    [followersButton release];
    [followingButton release];
    [levelProgressBar release];
    [levelLabel release];
    [levelPercentLabel release];
    [profileView release];
    [profileImageView release];
    [_levelView release];
    [_aboutMeLabel release];
    [_badgeView release];
    [_chartImageView release];
    [_chartActivityIndicator release];
    [_chart1View release];
    [_chart3view release];
    [_chartScroll release];
    [_totalClimbsChartView release];
    [_totalClimbsChartActivityIndicator release];
    [_noRecentClimbsLabel release];
    [_noTotalClimbsLabel release];
    [super dealloc];
}
@end
