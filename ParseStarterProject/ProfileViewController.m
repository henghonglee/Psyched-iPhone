//
//  ProfileViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "FeedCell.h"
#import "FeedObject.h"
#import "ASIHTTPRequest.h"
#import "RouteDetailViewController.h"
#import "FollowingViewController.h"
#import "SearchFriendsViewController.h"
@implementation ProfileViewController
@synthesize userimage;
@synthesize queryArray;
@synthesize addedButton;
@synthesize projectsButton;
@synthesize sendsButton;
@synthesize flashButton;
@synthesize followersButton;
@synthesize followingButton;
@synthesize followingwho;
@synthesize selectedUser;
@synthesize userImageView;
@synthesize username;
@synthesize userNameLabel;
@synthesize userFeedTable;
@synthesize followButton;
@synthesize userfeeds;
@synthesize followingLabel;
@synthesize flashLabel;
@synthesize sendLabel;
@synthesize projectLabel;
@synthesize likeLabel;
@synthesize addfriendsbutton;
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
    userImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    userImageView.layer.borderWidth = 3;
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
    [navigationBarItem addTarget:self action:@selector(reloadUserData) forControlEvents:UIControlEventTouchUpInside];
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
        NSLog(@"selected User = %@ , retain count = %d",selectedUser, [selectedUser retainCount]);
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
            [userfeeds addObjectsFromArray:objects];
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
    
    //TODO: fix crash here
       
    
    // Do any additional setup after loading the view from its nib.
    
    
    
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
-(void)reloadUserData
{
    userFeedTable.scrollEnabled = NO;
    [navigationBarItem startAnimating];
    PFQuery* userQuery = [PFUser query];
    [userQuery whereKey:@"name" equalTo:username];
     [queryArray addObject:userQuery];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         [queryArray removeObject:userQuery];
    selectedUser = [objects objectAtIndex:0];    
        [selectedUser retain];
    NSLog(@"selected user  = %@",selectedUser);
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
            [userfeeds addObjectsFromArray:objects];
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

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)followAction:(UIButton*)sender {
    if (sender.tag == 1) {
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"followed" equalTo:userNameLabel.text];
        [queryArray addObject:query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            [queryArray removeObject:query];
            for (PFObject* obj in objects) {
                [obj deleteInBackground];
            }
            [sender setTitle:@"Follow" forState:UIControlStateNormal];
            sender.tag = 0;
        }];

    }else{
    PFObject* pfObj = [PFObject objectWithClassName:@"Follow"];
    [pfObj setObject:[PFUser currentUser] forKey:@"follower"];
    [pfObj setObject:userNameLabel.text forKey:@"followed"];
    [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [sender setTitle:@"UnFollow" forState:UIControlStateNormal];
        sender.tag = 1;
    }];
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromCellIdentifier = @"FromCell";
    FeedCell* cell = (FeedCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FeedCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (FeedCell*)currentObject;
                
            }
        }
    }
    
    
    
    cell.feedLabel.text = [[[[[[[userfeeds objectAtIndex:indexPath.row] objectForKey:@"message"]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"] stringByReplacingOccurrencesOfString:[[PFUser currentUser]objectForKey:@"name"] withString:@"you"]stringByReplacingOccurrencesOfString:@"his/her" withString:@"your"]stringByReplacingOccurrencesOfString:@"her" withString:@"your"]stringByReplacingOccurrencesOfString:@"his" withString:@"your"]  ;
    
        PFObject* selectedFeedObj = [userfeeds objectAtIndex:indexPath.row];
        NSString* urlstring = [NSString stringWithFormat:@"%@",[selectedFeedObj objectForKey:@"senderimagelink"]];
        NSLog(@"urlstring = %@",urlstring);
        
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [request setCompletionBlock:^{
            
            cell.senderImage.image= [UIImage imageWithData:[request responseData]];
            
        }];
        [request setFailedBlock:^{}];
        [request startAsynchronous];
    

    if ([userfeeds count]>0) {
        PFObject* selectedFeed = [userfeeds objectAtIndex:indexPath.row];
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
    PFObject* selectedFeed = [userfeeds objectAtIndex:indexPath.row];
    NSString* messagestring =[selectedFeed objectForKey:@"message"];
    if([messagestring rangeOfString:@"route"].location!=NSNotFound){
        
           RouteObject* newRouteObject = [[RouteObject alloc]init];
            newRouteObject.pfobj = [[[userfeeds objectAtIndex:indexPath.row] objectForKey:@"linkedroute"]fetchIfNeeded];
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
    [super dealloc];
}
@end
