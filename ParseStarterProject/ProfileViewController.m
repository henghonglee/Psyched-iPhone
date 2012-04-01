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
    }
    PFQuery* userQuery = [PFQuery queryForUser];
    userQuery.cachePolicy= kPFCachePolicyNetworkElseCache;
    [userQuery whereKey:@"name" equalTo:username];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {


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
    PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
        query.cachePolicy= kPFCachePolicyNetworkElseCache;
    [query whereKey:@"sender" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [userfeeds addObjectsFromArray:objects];
        NSArray *sortedArray;
        sortedArray = [userfeeds sortedArrayUsingComparator:^(id a, id b) {
            PFObject* first = a;
            PFObject* second = b;
            
            return [((NSDate*)second.createdAt) compare:((NSDate*)first.createdAt)];
            
        }];
        [userfeeds removeAllObjects];
        [userfeeds addObjectsFromArray:sortedArray];
        [userFeedTable reloadData];
    } ];
    
    //grab user followed
    
    followedArray = [[NSMutableArray alloc]init];
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];

        followedquery.cachePolicy= kPFCachePolicyNetworkElseCache;
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
    [navigationBarItem startAnimating];
    PFQuery* userQuery = [PFQuery queryForUser];
    [userQuery whereKey:@"name" equalTo:username];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
    
    userfeeds = [[NSMutableArray alloc]init ];
    PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
        query.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [query whereKey:@"sender" equalTo:username];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [userfeeds addObjectsFromArray:objects];
        NSArray *sortedArray;
        sortedArray = [userfeeds sortedArrayUsingComparator:^(id a, id b) {
            PFObject* first = a;
            PFObject* second = b;
            
            return [((NSDate*)second.createdAt) compare:((NSDate*)first.createdAt)];
            
        }];
        [userfeeds removeAllObjects];
        [userfeeds addObjectsFromArray:sortedArray];
        [userFeedTable reloadData];
    } ];
    
    //grab user followed
    
    followedArray = [[NSMutableArray alloc]init];
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
        followedquery.cachePolicy= kPFCachePolicyNetworkElseCache;         
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction)followAction:(UIButton*)sender {
    if (sender.tag == 1) {
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"followed" equalTo:userNameLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
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
    cell.feedLabel.text = [[[[[userfeeds objectAtIndex:indexPath.row] objectForKey:@"message"]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"] stringByReplacingOccurrencesOfString:[[PFUser currentUser]objectForKey:@"name"] withString:@"You"]stringByReplacingOccurrencesOfString:@"his/her" withString:@"your own"]  ;

    cell.senderImage.image = userimage;
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
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didselectrow");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
    RouteObject* newRouteObject = [[RouteObject alloc]init];
        newRouteObject.pfobj = [[[userfeeds objectAtIndex:indexPath.row] objectForKey:@"linkedroute"]fetchIfNeeded];
    viewController.routeObject = newRouteObject;
    
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    NSLog(@"will release newrouteobj");
 [newRouteObject release]; 
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
    [selectedUser release];
    [userfeeds release];
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
