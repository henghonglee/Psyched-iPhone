//
//  MyTableController.m
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import "MyTableController.h"
#import "SpecialTableCell.h"
#import "SearchFriendsViewController.h"
#import "ASIHTTPRequest.h"
#import "LoadMoreCell.h"
@implementation MyTableController
@synthesize routeTableView;
@synthesize baserouteArray;
@synthesize routeArray;
@synthesize queryArray;
@synthesize titleTableView;
@synthesize currentLocation;
@synthesize emptyGradeView;
@synthesize emptyView;
@synthesize followedArray;
@synthesize locationManager;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self) {
    }
    return self;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    loadcount = 1;
    shouldDisplayNext = 1;
    // [self startStandardUpdates];
    routeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0 , 320, 411)];
    routeTableView.delegate = self;
    routeTableView.dataSource = self;
    routeTableView.backgroundColor = [UIColor darkGrayColor];
    routeTableView.showsVerticalScrollIndicator = NO;
    routeTableView.bounces = YES;
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    UIImageView* headerviewimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44 )];
    headerviewimage.image = [UIImage imageNamed:@"headerview2.png"];
    [headerView addSubview:headerviewimage];
    [headerviewimage release];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 44)];
    headerLabel.font = [UIFont boldSystemFontOfSize:23.0f];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = @"Psyched!";
    headerLabel.backgroundColor = [UIColor clearColor];
    refreshButton = [[DAReloadActivityButton alloc]initWithFrame:CGRectMake(276, 0, 44, 44)];
     [refreshButton addTarget:self action:@selector(animate:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.contentMode = UIViewContentModeScaleAspectFit;
    refreshButton.showsTouchWhenHighlighted = YES;
    [headerView addSubview:refreshButton];
    [refreshButton release];
    [headerView addSubview:headerLabel];
    [headerLabel release];
    [self.view addSubview:routeTableView];
    self.navigationController.navigationBarHidden = YES;
    self.routeArray = [[[NSMutableArray alloc]init]autorelease];
    self.queryArray = [[[NSMutableArray alloc]init]autorelease];
    [self addStandardTabView];
     [self tabView:tabView didSelectTabAtIndex:tabView.segmentIndex];
   
}
-(void)viewWillAppear:(BOOL)animated
{
   // [self startStandardUpdates];
    //
        self.navigationController.navigationBarHidden = YES;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 1){
        if (!tabView.segmentIndex) {
            if (![routeArray count]) {
                emptyView.hidden =NO;
                return emptyView;    
            }
        }else if(tabView.segmentIndex==3){
            if (![routeArray count]) {
                emptyGradeView.hidden =NO;
                return emptyGradeView;    
            }
        }
        emptyGradeView.hidden =YES;
        emptyView.hidden = YES;
        return [[UIView new] autorelease];
    }       
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section ==1) {
        
    if (!tabView.segmentIndex) {
        if (![routeArray count]) {
            return 323;
        }
    }
    return 1;
    }
    return 0;
    
}



-(void)viewWillDisappear:(BOOL)animated
{
       [locationManager stopUpdatingLocation];
    NSLog(@"canceling %d queries",[queryArray count]);
    for (id pfobject in queryArray) {
        if ([pfobject isKindOfClass:[PFFile class]]) {
            [((PFFile*)pfobject) cancel];
        }
        if ([pfobject isKindOfClass:[PFQuery class]]) {
            [((PFQuery*)pfobject) cancel];
        }
    }
    [queryArray removeAllObjects];
    for (PFObject* obj in self.routeArray) {
         ((RouteObject*)obj).isLoading = NO;
    }
   
    NSLog(@"done canceling queries");
}
-(void)loadcounter
{
     NSLog(@"%d/%d of loading",loadcount,[routeArray count]);
    if (loadcount == [routeArray count]) {
       [routeTableView reloadData]; 
        loadcount = 1;
        [((DAReloadActivityButton*)refreshButton) stopAnimating];
        NSLog(@"finished loading");
    }else{
        loadcount++;
       
    }
    
}


- (void)viewDidUnload
{
    
    [self setEmptyGradeView:nil];
    [super viewDidUnload];
    NSLog(@"view did unload");
    self.routeArray = nil;
    [self setRouteTableView:nil];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section==0) {
            return 0;
    }else{
        if ([routeArray count]==0) {
            return 0;
        }
        return [routeArray count]+shouldDisplayNext;
    }


}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == [routeArray count]){
        static NSString *identifier = @"lastCell";
        LoadMoreCell* cell = (LoadMoreCell*) [tableView dequeueReusableCellWithIdentifier:identifier]; 
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LoadMoreCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (LoadMoreCell*)currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
            }
        }
        return cell;
    }else{
        
        static NSString *CellIdentifier = @"Cell";
    SpecialTableCell* cell = (SpecialTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SpecialTableCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (SpecialTableCell*)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
        }
    } 
       
            if ([self.routeArray count]>0) {
                PFObject* object = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).pfobj;
               
                
                //set route location
                cell.routeLocationLabel.text = [NSString stringWithFormat:@"%@",[object objectForKey:@"location"]];
                if ([cell.routeLocationLabel.text isEqualToString:@""]) {
                    cell.pinImageView.hidden = YES;   
                }else{
                 cell.pinImageView.hidden = NO;      
                }
                
                //set counts
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                
                
                NSString* imagelink = [object objectForKey:@"userimage"];
                if (((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                    [request setCompletionBlock:^{
                        UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                        cell.ownerImage.alpha = 0.0;
                        cell.ownerImage.image = ownerImage;
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.ownerImage.alpha = 1.0;
                                         } 
                                         completion:^(BOOL finished){
                                           
                                         }];
                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];
                }
                if (!((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage && !((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading) {
                    ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading = YES;
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                     [queryArray addObject:imagefile];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        [queryArray removeObject:imagefile];
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading = NO;
                       UIImage* retrievedImage = [UIImage imageWithData:imageData];
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
                        cell.routeImageView.alpha = 0.0;
                        cell.routeImageView.image = retrievedImage;
                       
                        [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         cell.routeImageView.alpha = 1.0;
                     } 
                     completion:^(BOOL finished){
                        // NSLog(@"Done!");
                     }];
                    }];
                    
                    
                }else{
                    cell.routeImageView.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage;
                    
                };
                
                
                double timesincenow =  [((NSDate*)object.createdAt) timeIntervalSinceNow];
                //NSLog(@"timesincenow = %i",((int)timesincenow));
                int timeint = ((int)timesincenow);
                //if more than 1 day show number of days
                //if more than 60min show number of hrs
                //if more than 24hrs show days
                
                if (timeint < -86400) {
                    cell.timeLabel.text = [NSString stringWithFormat:@"%id",timeint/-86400];
                }else if(timeint < -3600){
                    cell.timeLabel.text = [NSString stringWithFormat:@"%ih",timeint/-3600];
                }else{
                    cell.timeLabel.text = [NSString stringWithFormat:@"%im",timeint/-60];
                }
                //    [request2 release];
                if (((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).stampImage) {
                    [cell.stampImageView setImage:((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).stampImage];
                }else{
                PFQuery* flashquery = [PFQuery queryWithClassName:@"Flash"];
                [flashquery whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                [flashquery whereKey:@"route" equalTo:((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).pfobj];
                [queryArray addObject:flashquery];
                [flashquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [queryArray removeObject:flashquery];
                    if ([objects count]) {
                        [cell.stampImageView setImage:[UIImage imageNamed:@"flashoverlay210.png"]];
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).stampImage = [UIImage imageNamed:@"flashoverlay210.png"];
                    }
                }];
                PFQuery* sentquery = [PFQuery queryWithClassName:@"Sent"];
                [sentquery whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                [sentquery whereKey:@"route" equalTo:((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).pfobj];
                [queryArray addObject:sentquery];
                [sentquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [queryArray removeObject:sentquery];
                    if ([objects count]) {
                        [cell.stampImageView setImage:[UIImage imageNamed:@"sentoverlay210.png"]];
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).stampImage = [UIImage imageNamed:@"sentoverlay210.png"];
                    }
                }];
                PFQuery* projquery = [PFQuery queryWithClassName:@"Project"];
                [projquery whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                [projquery whereKey:@"route" equalTo:((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).pfobj];
                [queryArray addObject:projquery];
                [projquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [queryArray removeObject:projquery];
                    if ([objects count]) {
                        [cell.stampImageView setImage:[UIImage imageNamed:@"projectoverlay210.png"]];
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).stampImage = [UIImage imageNamed:@"projectoverlay210.png"];
                    }
                }];
                }
                if ([object objectForKey:@"difficultydescription"]) {
                    cell.difficultyLabel.text = [object objectForKey:@"difficultydescription"];
                }

                cell.todoTextLabel.text = [object objectForKey:@"description"];
                cell.ownerNameLabel.text = [object objectForKey:@"username"];
                cell.backgroundColor = [UIColor whiteColor];
            }
    // Configure the cell
    
       return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
        return 120;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 44;
    }else{
        return 44;
    }
}

#pragma mark - Table view data source

-(void)addStandardTabView
{
    tabView = [[JMTabView alloc] init];
    [tabView setDelegate:self];
    
    [tabView addTabItemWithTitle:@"Followed" icon:[UIImage imageNamed:@"followed.png"]];
    [tabView addTabItemWithTitle:@"Popular" icon:[UIImage imageNamed:@"icon2.png"]];
    [tabView addTabItemWithTitle:@"Nearby" icon:[UIImage imageNamed:@"nearby.png"]];
    [tabView addTabItemWithTitle:@"Grade" icon:[UIImage imageNamed:@"grade.png"]];
    
    
    //    You can run blocks by specifiying an executeBlock: paremeter
    //    #if NS_BLOCKS_AVAILABLE
    //    [tabView addTabItemWithTitle:@"One" icon:nil executeBlock:^{NSLog(@"abc");}];
    //    #endif
    
    [tabView setSelectedIndex:0];
    
   // [self.view addSubview:tabView];
}
-(void)invertGradeArray
{
//    NSLog(@"segmentedindex=%d",tabView.segmentIndex);
//    if (tabView.segmentIndex==3) {
//        NSArray* reversed = [[routeArray reverseObjectEnumerator] allObjects];
//        [routeArray removeAllObjects];
//        [routeArray addObjectsFromArray:reversed];
//        [routeTableView reloadData];
//    }
}
-(void)tabView:(JMTabView *)_tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
    NSLog(@"canceling %d queries",[queryArray count]);
    for (id pfobject in queryArray) {
        if (pfobject) {
        if ([pfobject isKindOfClass:[PFFile class]]) {
            [((PFFile*)pfobject) cancel];
        }
        if ([pfobject isKindOfClass:[PFQuery class]]) {
            [((PFQuery*)pfobject) cancel];
        }
    }
    }
    [queryArray removeAllObjects];
    for (PFObject* obj in self.routeArray) {
        ((RouteObject*)obj).isLoading = NO;
    }
    
    
    PFQuery* locationQuery = [PFQuery queryWithClassName:@"Route"];
    [locationQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude]];
    [locationQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [locationQuery setLimit:20];
    locationQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
    [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [popularQuery orderByDescending:@"likecount"];
    [popularQuery addDescendingOrder:@"createdAt"];
    [popularQuery setLimit:20];
    popularQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* recentQuery = [PFQuery queryWithClassName:@"Route"];
    [recentQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [recentQuery orderByDescending:@"createdAt"];
    [recentQuery setLimit:20];
    recentQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* gradeQuery = [PFQuery queryWithClassName:@"Route"];
    [gradeQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [gradeQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] withinKilometers:1];
    [gradeQuery orderByDescending:@"difficulty"];
    
    [gradeQuery setLimit:20];
    gradeQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    shouldDisplayNext=1;
    
    switch (itemIndex) {
        case 0:
            NSLog(@"cancelingqueries");
               
             NSMutableArray* followedPosters = [[[NSMutableArray alloc]init ]autorelease];
           
            PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
            [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
            [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject* follow in objects) {
                NSLog(@"showing routes of %@",[follow objectForKey:@"followed"]);
               
                [followedPosters addObject:[follow objectForKey:@"followed"]];

            }
            [recentQuery whereKey:@"username" containedIn:followedPosters];
            [queryArray addObject:recentQuery];
            
            [recentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                [queryArray removeObject:recentQuery];
                [routeArray removeAllObjects];
                if ([objects count]<20) {
                    shouldDisplayNext =0;
                }
                if ([objects count]>0) {
                for (PFObject* object in objects) {
                    RouteObject* newRouteObject =  [[RouteObject alloc]init];
                    newRouteObject.pfobj = object;
                    [routeArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                    
                }
                [routeTableView reloadData];
                
            }];
            }];
            break;
        case 1:
            [queryArray addObject:popularQuery];
            [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:popularQuery];
                if ([objects count]<20) {
                    shouldDisplayNext =0;
                }
                [routeArray removeAllObjects];
                for (PFObject* object in objects) {
                    RouteObject* newRouteObject =  [[RouteObject alloc]init];
                    newRouteObject.pfobj = object;
                    [routeArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
          
            break;
        case 2:
           
            [queryArray addObject:locationQuery];
           [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
               [queryArray removeObject:locationQuery];
               [routeArray removeAllObjects];
               if ([objects count]<20) {
                   shouldDisplayNext =0;
               }
               
               for (PFObject* object in objects) {
                  RouteObject* newRouteObject =  [[RouteObject alloc]init];
                   newRouteObject.pfobj = object;
                   [routeArray addObject:newRouteObject];
                   [newRouteObject release];
               }
               [routeTableView reloadData];
           }];
            break;
        case 3:
           
            [queryArray addObject:gradeQuery];
            [gradeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:gradeQuery];
                [routeArray removeAllObjects] ;
                if ([objects count]>0) {
                if ([objects count]<20) {
                    shouldDisplayNext =0;
                }

                for (PFObject* object in objects) {
                    RouteObject* newRouteObject =  [[RouteObject alloc]init];
                    newRouteObject.pfobj = object;
                    [routeArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                }
                [routeTableView reloadData];
            }];
            break;
        default:
            break;
    }
        NSLog(@"Selected Tab Index: %d", tabView.segmentIndex);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"routearray count = %d, index = %d",[routeArray count],indexPath.row)
    ;
    
    
    PFQuery* locationQuery = [PFQuery queryWithClassName:@"Route"];
    [locationQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [locationQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude]];
    [locationQuery setLimit:20];
    locationQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
    [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [popularQuery orderByDescending:@"likecount"];
    [popularQuery setLimit:20];
    popularQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* recentQuery = [PFQuery queryWithClassName:@"Route"];
    [recentQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [recentQuery orderByDescending:@"createdAt"];
    [recentQuery setLimit:20];
    recentQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    if (indexPath.row==([routeArray count])) {
        NSLog(@"will load next 20 for %d",tabView.segmentIndex); 
        switch (tabView.segmentIndex) {
            case 0:
                [recentQuery setSkip:[routeArray count]];
                [queryArray addObject:recentQuery];
                [recentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([objects count]<20) {
                        shouldDisplayNext = 0;
                    }
                    [queryArray removeObject:recentQuery];
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                    [routeTableView reloadData];
                }];
                break;
            case 1:
                [popularQuery setSkip:[routeArray count]];
                [queryArray addObject:recentQuery];
                [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([objects count]<20) {
                        shouldDisplayNext = 0;
                    }
                    [queryArray removeObject:popularQuery];
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                    [routeTableView reloadData];
                }];
                break;
            case 2:
                [locationQuery setSkip:[routeArray count]];
                [queryArray addObject:recentQuery];
                [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([objects count]<20) {
                        shouldDisplayNext = 0;
                    }
                    [queryArray removeObject:locationQuery];
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                    [routeTableView reloadData];
                }];
                break;
                
            default:
                break;
        }
        
        
    }else{

    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
   
    viewController.routeObject = [routeArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    }

}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return headerView;
    }else{
        return tabView;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 2;
    
}
- (void)animate:(DAReloadActivityButton *)button
{
    [button startAnimating];
    [self reloadTableViewDataSource];

}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
    //reset stamp image
    for (RouteObject* routeobj in routeArray) {
        routeobj.stampImage = nil;
    }
    [self tabView:tabView didSelectTabAtIndex:tabView.segmentIndex];
    
    [((DAReloadActivityButton*)refreshButton) stopAnimating];	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.routeTableView];
	
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods



#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
	
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

- (IBAction)addFollows:(id)sender {
    NSLog(@"adding followers");
    SearchFriendsViewController* viewController = [[SearchFriendsViewController alloc]initWithNibName:@"SearchFriendsViewController" bundle:nil];
    viewController.selectedUser = [PFUser currentUser];
    
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}


- (void)dealloc {
    [emptyView release];
    [currentLocation release];
    [locationManager release];
    [followedArray release];


    [routeTableView release];
    [emptyGradeView release];
    [super dealloc];
}
@end
