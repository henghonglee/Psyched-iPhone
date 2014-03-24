//
//  FeedsViewController.m
//  PsychedApp
//
//  Created by HengHong Lee on 15/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "FeedsViewController.h"
#import "FeedObject.h"
#import "UIColor+Hex.h"
#import "SearchFriendsViewController.h"
#import "AFNetworking.h"
#define MAX_LINES 20
@implementation FeedsViewController
@synthesize feedsTable;
@synthesize segheader;
@synthesize emptyView;
@synthesize segmentedControl;
@synthesize feedsArray;
@synthesize queryArray;
@synthesize unreadArray;
@synthesize followsArray;
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
    NSLog(@"maxlines =%d",MAX_LINES);
    self.navigationItem.title = @"Activity";
    shouldDisplayNextForFeeds = 1;
    shouldDisplayNextForFollows = 1;
    
    CAGradientLayer * gradientLayer = [[[CAGradientLayer alloc] init] autorelease];
    //UIColor * startColor = [UIColor colorWithHex:0x4a4b4a];
    UIColor * midColor = [UIColor colorWithHex:0x282928];
    UIColor * endColor = [UIColor colorWithHex:0x4a4b4a];
    gradientLayer.frame = CGRectMake(0, 0, 320, 44);
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[midColor CGColor], (id)[endColor CGColor], nil];
    [segheader.layer insertSublayer:gradientLayer atIndex:0];
    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor darkGrayColor];
    
    [segmentedControl setSelectedSegmentIndex:1];
    
    
    [segmentedControl addTarget:self action:@selector(changeSegment:) 
               forControlEvents:UIControlEventValueChanged];
    
    
    //[self.navigationController.navigationBar addSubview:segmentedControl];
    //[segmentedControl release];
    if (_refreshHeaderView == nil) {
		
		PF_EGORefreshTableHeaderView *view = [[PF_EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.feedsTable.bounds.size.height, self.view.frame.size.width, self.feedsTable.bounds.size.height)];
		view.delegate = self;
		[self.feedsTable addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
   followsArray = [[NSMutableArray alloc]init];
    queryArray = [[NSMutableArray alloc]init];
    feedsArray = [[NSMutableArray alloc]init];
    unreadArray = [[NSMutableArray alloc]init];
    PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
    
    [query whereKey:@"message" containsString:@"route"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:MAX_LINES];
    [queryArray addObject:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray* fetched,NSError* error){
        [queryArray removeObject:query];
        [feedsArray removeAllObjects];
        for (PFObject*obj in fetched){
            FeedObject* feedObject = [[FeedObject alloc]init];
            feedObject.pfobj = obj;
            [feedsArray addObject:feedObject];
            [feedObject release];
        }
        if ([fetched count]<MAX_LINES) {
            shouldDisplayNextForFeeds = 0; 
        }else{
            shouldDisplayNextForFeeds = 1;  
        }
        [feedsTable reloadData];
    }];
    [self refreshFollowsArray];
    emptyView.hidden=YES;
    segmentedControl.hidden = NO;
}
-(void)viewWillAppear:(BOOL)animated
{
    [self refreshFollowsArray];
}

-(void)viewWillDisappear:(BOOL)animated
{

    for (PFObject* unread in unreadArray) {
        NSMutableArray* _unreadArray = [[NSMutableArray alloc]initWithArray:[unread objectForKey:@"viewed"]];
        [_unreadArray addObject:[[PFUser currentUser]objectForKey:@"name"]];
        [unread setObject:_unreadArray forKey:@"viewed"];    
        [unread saveInBackground];
        [_unreadArray release];
    }
    [unreadArray removeAllObjects];
    NSLog(@"canceling %d queries",[queryArray count]);
    for (id pfobject in queryArray) {
        if ([pfobject isKindOfClass:[PFFile class]]) {
            NSLog(@"cancelling pffile upload/download");
            [((PFFile*)pfobject) cancel];
        }
        if ([pfobject isKindOfClass:[PFQuery class]]) {
            NSLog(@"cancelling pfquery ");
            [((PFQuery*)pfobject) cancel];
        }
    }
    [queryArray removeAllObjects];
    NSLog(@"done canceling queries");
    
    
    
}
-(void)changeSegment:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex==0) {
        emptyView.hidden = YES;
    }else{
       
        [self refreshFollowsArray];

    }
    [feedsTable reloadData];
}


- (void)viewDidUnload
{
    [self setFeedsTable:nil];
    [self setSegmentedControl:nil];
    [self setSegheader:nil];
    [self setEmptyView:nil];
    [self setUnreadArray:nil];
    [self setFeedsArray:nil];
    [self setFollowsArray:nil];
    [self viewDidDisappear:YES];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (IBAction)addFollowers:(id)sender {
    NSLog(@"adding followers");
    SearchFriendsViewController* viewController = [[SearchFriendsViewController alloc]initWithNibName:@"SearchFriendsViewController" bundle:nil];
    viewController.selectedUser = [PFUser currentUser];
    
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else {
        return NO;
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        if (segmentedControl.selectedSegmentIndex) {
            if (![followsArray count]) {
            return emptyView;    
            }
        }
        emptyView.hidden = YES;
                return [[UIView new] autorelease];
    }       
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (segmentedControl.selectedSegmentIndex) {
        if (![followsArray count]) {
            return 323;
        }
    }
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (segmentedControl.selectedSegmentIndex==0) {
        if (indexPath.row == [feedsArray count]) {
            [self refreshFeedsWithSkip:[feedsArray count]];
        }else{
            PFObject* feedobj = ((FeedObject*)[feedsArray objectAtIndex:indexPath.row]).pfobj;
            NSString* messagestring =[feedobj objectForKey:@"message"];
            if([messagestring rangeOfString:@"route"].location!=NSNotFound){
                RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
                RouteObject* newRouteObject = [[RouteObject alloc]init];
                newRouteObject.pfobj = [[((FeedObject*)[feedsArray objectAtIndex:indexPath.row]).pfobj objectForKey:@"linkedroute"] fetchIfNeeded];
                viewController.routeObject = newRouteObject;
                [self.navigationController pushViewController:viewController animated:YES];
                [viewController release];
                [newRouteObject release];
            }
            
        }
    }else{
        
         if (indexPath.row == [followsArray count]) {
             [self refreshFollowsWithSkip:[followsArray count]];
         }else{
             PFObject* followfeedobj = ((FeedObject*)[followsArray objectAtIndex:indexPath.row]).pfobj;
             NSString* followmessagestring =[followfeedobj objectForKey:@"message"];
              if([followmessagestring rangeOfString:@"route"].location!=NSNotFound){
             RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
             RouteObject* newRouteObject = [[RouteObject alloc]init];
             newRouteObject.pfobj = [[((FeedObject*)[followsArray objectAtIndex:indexPath.row]).pfobj objectForKey:@"linkedroute"]fetchIfNeeded];
             viewController.routeObject = newRouteObject;
             [self.navigationController pushViewController:viewController animated:YES];
             [viewController release];
             [newRouteObject release];
              }else{
                  ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
                  viewController.username= [followfeedobj objectForKey:@"sender"]; 
                  [self.navigationController pushViewController:viewController animated:YES];
                  [viewController release];
              }
         }
    }
            

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (segmentedControl.selectedSegmentIndex==0) {
        if ([feedsArray count]==0) {
            return 0;
        }
        return [feedsArray count]+shouldDisplayNextForFeeds;
    }else{
        if ([followsArray count]==0) {
            return 0;
        }
        return [followsArray count]+shouldDisplayNextForFollows;
    }
    

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (segmentedControl.selectedSegmentIndex==0) {
        if (indexPath.row == [feedsArray count]) {
            static NSString *identifier = @"lastCell";
            LoadMoreFeedCell* cell = (LoadMoreFeedCell*) [tableView dequeueReusableCellWithIdentifier:identifier]; 
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoadMoreFeedCell" owner:nil options:nil];
                for(id currentObject in topLevelObjects){
                    if([currentObject isKindOfClass:[UITableViewCell class]]){
                        cell = (LoadMoreFeedCell*)currentObject;
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    }
                }
            }
            return cell;

        }else{
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
            if ([feedsArray count]) {
                FeedObject* selectedFeedObj = ((FeedObject*)[feedsArray objectAtIndex:indexPath.row]);
                PFObject* selectedPFObj = selectedFeedObj.pfobj;
                
        cell.feedLabel.text = [[[selectedPFObj objectForKey:@"message"]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"] stringByReplacingOccurrencesOfString:[[PFUser currentUser]objectForKey:@"name"] withString:@"you"]  ;
                NSString* currentUser = [[PFUser currentUser]objectForKey:@"name"];
                NSString* sender= [selectedPFObj objectForKey:@"sender"]; 
                
                if ([currentUser isEqualToString:sender]) {
                    cell.feedLabel.text = [[[cell.feedLabel.text stringByReplacingOccurrencesOfString:@" his " withString:@" your "] stringByReplacingOccurrencesOfString:@" her " withString:@" your "]stringByReplacingOccurrencesOfString:@"his/her" withString:@"your"];
                }
                
        if (selectedFeedObj.senderImage){
            cell.senderImage.image = selectedFeedObj.senderImage;
        }else{
            NSString* urlstring = [NSString stringWithFormat:@"%@",[selectedPFObj objectForKey:@"senderimagelink"]];
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            [manager GET:urlstring parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSLog(@"JSON: %@", responseObject);
              selectedFeedObj.senderImage = [UIImage imageWithData:[responseObject responseData]];
              cell.senderImage.image = selectedFeedObj.senderImage;
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              NSLog(@"Error: %@", error);
            }];
        }
                if (![[selectedPFObj objectForKey:@"viewed"] containsObject:[[PFUser currentUser]objectForKey:@"name"]] && ![[selectedPFObj objectForKey:@"sender"] isEqualToString:[[PFUser currentUser] objectForKey:@"name"]] && ([cell.feedLabel.text rangeOfString:@"you"].location != NSNotFound || [cell.feedLabel.text rangeOfString:@"your"].location != NSNotFound)) {
                    cell.readSphereView.image = [UIImage imageNamed:@"bluesphere.png"];
                    if (![unreadArray containsObject:selectedPFObj]) {
                        [unreadArray addObject:selectedPFObj]; }
                        
                }else{
                    cell.readSphereView.image = nil;
                }
            
            double timesincenow =  [((NSDate*)selectedPFObj.createdAt) timeIntervalSinceNow];
           
            int timeint = ((int)timesincenow);
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
    }else{
        if (indexPath.row == [followsArray count]) {
            static NSString *identifier = @"lastCell";
            LoadMoreFeedCell* cell = (LoadMoreFeedCell*) [tableView dequeueReusableCellWithIdentifier:identifier]; 
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoadMoreFeedCell" owner:nil options:nil];
                for(id currentObject in topLevelObjects){
                    if([currentObject isKindOfClass:[UITableViewCell class]]){
                        cell = (LoadMoreFeedCell*)currentObject;
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    }
                }
            }
            return cell;
            
        }else{
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
            
    if ([followsArray count]) {
            FeedObject* selectedFeedObj = ((FeedObject*)[followsArray objectAtIndex:indexPath.row]);
            PFObject* selectedPFObj = selectedFeedObj.pfobj;
            cell.feedLabel.text = [[[selectedPFObj objectForKey:@"message"]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"] stringByReplacingOccurrencesOfString:[[PFUser currentUser]objectForKey:@"name"] withString:@"you"];
            if ([[[PFUser currentUser]objectForKey:@"name"] isEqualToString:[selectedPFObj objectForKey:@"sender"]]) {

                    cell.feedLabel.text = [[[cell.feedLabel.text stringByReplacingOccurrencesOfString:@" his " withString:@" your "] stringByReplacingOccurrencesOfString:@" her " withString:@" your "]stringByReplacingOccurrencesOfString:@"his/her" withString:@"your"];
                }
            if (selectedFeedObj.senderImage){
        cell.senderImage.image = selectedFeedObj.senderImage;
    }else{
      NSString* urlstring = [NSString stringWithFormat:@"%@",[((FeedObject*)[followsArray objectAtIndex:indexPath.row]).pfobj objectForKey:@"senderimagelink"]];
      NSLog(@"urlstring = %@",urlstring);
      AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
      [manager GET:@"http://example.com/resources.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        ((FeedObject*)[followsArray objectAtIndex:indexPath.row]).senderImage = [UIImage imageWithData:[responseObject responseData]];
        cell.senderImage.image = ((FeedObject*)[followsArray objectAtIndex:indexPath.row]).senderImage;
      } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
      }];
    }
       
        if (![[selectedPFObj objectForKey:@"viewed"] containsObject:[[PFUser currentUser]objectForKey:@"name"]] && ![[selectedPFObj objectForKey:@"sender"] isEqualToString:[[PFUser currentUser] objectForKey:@"name"]] && ([cell.feedLabel.text rangeOfString:@"you"].location != NSNotFound || [cell.feedLabel.text rangeOfString:@"your"].location != NSNotFound)) {
  cell.readSphereView.image = [UIImage imageNamed:@"bluesphere.png"];
            if (![unreadArray containsObject:selectedPFObj]) {
                [unreadArray addObject:selectedPFObj]; }
        }else{
  cell.readSphereView.image = nil;
        }
       
        
//        cell.accessoryView.backgroundColor =([selectedPFObj objectForKey:@"viewed"] != [NSNumber numberWithBool:YES])?[UIColor orangeColor]:[UIColor whiteColor];
        
        
            double timesincenow =  [((NSDate*)selectedPFObj.createdAt) timeIntervalSinceNow];
            int timeint = ((int)timesincenow);
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
    }
   
  
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

-(void)refreshFeedsWithSkip:(int)skip
{
    PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
    [query whereKey:@"message" containsString:@"route"];
    [query orderByDescending:@"createdAt"];
    [query setSkip:skip];
    [query setLimit:MAX_LINES];
    [queryArray addObject:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray* fetched,NSError* error){
        [queryArray removeObject:query];     
        for (PFObject*obj in fetched){
            FeedObject* feedObject = [[FeedObject alloc]init];
            feedObject.pfobj = obj;
            [feedsArray addObject:feedObject];
            [feedObject release];
        }
        if ([fetched count]<MAX_LINES) {
            shouldDisplayNextForFeeds = 0; 
        }
        [feedsTable reloadData];
    }];
}
-(void)refreshFollowsWithSkip:(int)skip
{
    PFQuery* followquery = [PFQuery queryWithClassName:@"Follow"];
    [followquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    followquery.cachePolicy = kPFCachePolicyNetworkElseCache;
    [queryArray addObject:followquery];
    [followquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:followquery];
        
        
        PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
        NSMutableArray* names = [[NSMutableArray alloc]init];
        for (PFObject* obj in objects) {
            [names addObject:[obj objectForKey:@"followed"]];
        }
        
        
        [query whereKey:@"sender" containedIn:names];
        [query orderByDescending:@"createdAt"];
        [query setSkip:skip];
        [query setLimit:MAX_LINES];
       
        [names release];
        [queryArray addObject:query];
        [query findObjectsInBackgroundWithBlock:^(NSArray* fetched,NSError* error){
            [queryArray removeObject:query];
            for (PFObject*newobj in fetched){
                FeedObject* feedObject = [[FeedObject alloc]init];
                feedObject.pfobj = newobj;
                if ([[newobj objectForKey:@"message"] rangeOfString:@"following"].location!=NSNotFound && [[newobj objectForKey:@"message"] rangeOfString:[[PFUser currentUser]objectForKey:@"name"]].location==NSNotFound) {
                    
                }else{
                [followsArray addObject:feedObject];
                }
                [feedObject release];
            }
            if ([fetched count]<MAX_LINES) {
                shouldDisplayNextForFollows =0;
            }
            [feedsTable reloadData];
            if (![feedsTable numberOfRowsInSection:0]) {
                emptyView.hidden=NO;
            }else{
                emptyView.hidden=YES;
            }
        }];
        
    }];
    
}
-(void)refreshFollowsArray
{
    PFQuery* followquery = [PFQuery queryWithClassName:@"Follow"];
    [followquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    // [followquery setLimit:[NSNumber numberWithInt:[followsArray count]]];
    followquery.cachePolicy = kPFCachePolicyNetworkElseCache;
    [queryArray addObject:followquery];
    [followquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:followquery];
       
        
        PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
        NSMutableArray* names = [[NSMutableArray alloc]init];
        for (PFObject* obj in objects) {
            [names addObject:[obj objectForKey:@"followed"]];
        }
        
        
        [query whereKey:@"sender" containedIn:names];
        [query orderByDescending:@"createdAt"];
        [query setLimit:MAX_LINES];
        [names release];
        [queryArray addObject:query];
        [query findObjectsInBackgroundWithBlock:^(NSArray* fetched,NSError* error){
            [queryArray removeObject:query];
             [followsArray removeAllObjects];  
            for (PFObject*newobj in fetched){
                FeedObject* feedObject = [[FeedObject alloc]init];
                feedObject.pfobj = newobj;
                if ([[newobj objectForKey:@"message"] rangeOfString:@"following"].location!=NSNotFound && [[newobj objectForKey:@"message"] rangeOfString:[[PFUser currentUser]objectForKey:@"name"]].location==NSNotFound) {
                    
                }else{
                [followsArray addObject:feedObject];
                }
                [feedObject release];
            }
            if ([fetched count]<MAX_LINES) {
                shouldDisplayNextForFollows =0;
            }else{
                shouldDisplayNextForFollows =1;
            }
            [feedsTable reloadData];
            if (![feedsTable numberOfRowsInSection:0]) {
                emptyView.hidden=NO;
            }else{
                emptyView.hidden=YES;
            }
        }];
        
    }];
    
    
}


- (void)reloadTableViewDataSource{
    if (segmentedControl.selectedSegmentIndex) {
         [self refreshFollowsArray];
    }else{
	PFQuery* query = [PFQuery queryWithClassName:@"Feed"];
        [query whereKey:@"message" containsString:@"route"];
    [query orderByDescending:@"createdAt"];
    [query setLimit:MAX_LINES];
    [queryArray addObject:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray* fetched,NSError* error){
        [queryArray removeObject:query];
    [feedsArray removeAllObjects];        
        for (PFObject*obj in fetched){
            FeedObject* feedObject = [[FeedObject alloc]init];
            feedObject.pfobj = obj;
            [feedsArray addObject:feedObject];
            [feedObject release];
        }
        if ([fetched count]<MAX_LINES) {
            shouldDisplayNextForFeeds = 0; 
        }else{
            shouldDisplayNextForFeeds = 1; 
        }
        [feedsTable reloadData];
    }];
    }

	_reloading = YES;
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.feedsTable];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}


#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(PF_EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(PF_EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(PF_EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}


- (void)dealloc {
    [queryArray release];
    [feedsArray release ];
    [feedsTable release];
    [segmentedControl release];
    [segheader release];
    [emptyView release];
    [super dealloc];
}
@end
