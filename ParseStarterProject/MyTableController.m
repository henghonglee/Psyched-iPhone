//
//  MyTableController.m
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//
#import "SettingsViewController.h"
#import "MyTableController.h"
#import "SpecialTableCell.h"
#import "SearchFriendsViewController.h"
#import "ASIHTTPRequest.h"
#import "LoadMoreCell.h"
#import "UIColor+Hex.h"
#import <QuartzCore/QuartzCore.h>
#import "GradientButton.h"
#import "BarBackgroundLayer.h"
@implementation MyTableController
@synthesize routeTableView;
@synthesize followedPosters;
@synthesize routeArray;
@synthesize queryArray;

@synthesize currentLocation;
@synthesize emptyGradeView;
@synthesize emptyView;


@synthesize settingsButton;
@synthesize newbadge;
@synthesize gymFetchArray;
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
    
    UIImage *selectedImage0 = [UIImage imageNamed:@"HomeDB.png"];
    UIImage *unselectedImage0 = [UIImage imageNamed:@"HomeLB.png"];
    
    UIImage *selectedImage2 = [UIImage imageNamed:@"BuildingsDB.png"];
    UIImage *unselectedImage2 = [UIImage imageNamed:@"BuildingsLB.png"];
    
    UITabBar *tabBar = self.tabBarController.tabBar;
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];

    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];

    
    [item0 setFinishedSelectedImage:selectedImage0 withFinishedUnselectedImage:unselectedImage0];

    [item2 setFinishedSelectedImage:selectedImage2 withFinishedUnselectedImage:unselectedImage2];
    //[item3 setFinishedSelectedImage:selectedImage3 withFinishedUnselectedImage:unselectedImage3];
    //[item4 setFinishedSelectedImage:selectedImage4 withFinishedUnselectedImage:unselectedImage4];

    [super viewDidLoad];
    
    PFQuery* queryForNotification = [PFQuery queryWithClassName:@"Feed"];
    [queryForNotification whereKey:@"viewed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [queryForNotification  whereKey:@"sender" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [queryForNotification whereKey:@"message" containsString:[[PFUser currentUser]objectForKey:@"name"]];
    [queryForNotification countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        ParseStarterProjectAppDelegate* appDel = (ParseStarterProjectAppDelegate* )[[UIApplication sharedApplication]delegate];
        appDel.badgeView.text = [NSString stringWithFormat:@"%d",number];
        
    }];
    PFQuery* recommendQuery = [PFQuery queryWithClassName:@"Route"];
    [recommendQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [recommendQuery whereKey:@"usersrecommended" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery whereKey:@"userssent" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery whereKey:@"usersflashed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery orderByDescending:@"updatedAt"];
    recommendQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    [recommendQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        newbadge.text =[NSString stringWithFormat:@"%d",number];
    }];
    loadcount = 1;
    shouldDisplayNext = 1;
    // [self startStandardUpdates];
    
    

    
    
   
    
    
    routeTableView = [[UITableView alloc]initWithFrame:CGRectMake(0,0 , 320, 411)];
    routeTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    routeTableView.delegate = self;
    routeTableView.dataSource = self;
    routeTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    routeTableView.separatorColor = [UIColor colorWithRed:209.0/255.0 green:209.0/255.0 blue:209.0/255.0 alpha:1.0];
    routeTableView.backgroundColor = [UIColor clearColor];
    routeTableView.showsVerticalScrollIndicator = NO;
    routeTableView.bounces = YES;
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    UIImageView* headerviewimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44 )];
    headerviewimage.image = [UIImage imageNamed:@"headerview.png"];
    [headerView addSubview:headerviewimage];
    [headerviewimage release];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 44)];
    headerLabel.font = [UIFont boldSystemFontOfSize:23.0f];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = @"Psyched!";
    headerLabel.backgroundColor = [UIColor clearColor];
    
    [settingsButton addTarget:self action:@selector(Settings:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:settingsButton];
    [settingsButton setFrame:CGRectMake(7, 3, 38, 38)];
//    UIImageView* buttonBgImage = [[UIImageView alloc]initWithFrame:CGRectMake(276, 3, 38, 38)];
//    [buttonBgImage setImage:[UIImage imageNamed:@"orangeButton.png"]];
     
    refreshButton = [[DAReloadActivityButton alloc]initWithFrame:CGRectMake(276, 3, 38, 38)];
     [refreshButton addTarget:self action:@selector(animate:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.contentMode = UIViewContentModeScaleAspectFit;
    refreshButton.showsTouchWhenHighlighted = YES;
//    [headerView addSubview:buttonBgImage];
//    [buttonBgImage release];
    [headerView addSubview:refreshButton];
    [refreshButton release];
    [headerView addSubview:headerLabel];
    [headerLabel release];
    [self.view addSubview:routeTableView];
    [self addStandardTabView];
 NSLog(@"done added standard tab view");
    self.navigationController.navigationBarHidden = YES;
    self.routeArray = [[[NSMutableArray alloc]init]autorelease];;
    self.queryArray = [[[NSMutableArray alloc]init]autorelease];
    self.gymFetchArray = [[[NSMutableArray alloc]init]autorelease];
    self.followedPosters = [[[NSMutableArray alloc]init]autorelease];
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [queryArray addObject:followedquery];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:followedquery];
        for (PFObject* follow in objects) {
            
            [followedPosters addObject:[follow objectForKey:@"followed"]];
            
        }
        NSLog(@"followposters populated %@",followedPosters);
     [self tabView:tabView didSelectTabAtIndex:tabView.segmentIndex];
    
    }];
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
   
    for (id pfobject in queryArray) {
        if ([pfobject isKindOfClass:[PFFile class]]) {
            [((PFFile*)pfobject) cancel];
        }
        if ([pfobject isKindOfClass:[PFQuery class]]) {
            [((PFQuery*)pfobject) cancel];
        }
    }
    [queryArray removeAllObjects];
    for (id obj in self.routeArray) {
        if ([obj isKindOfClass:[RouteObject class]]) {
         ((RouteObject*)obj).isLoading = NO;     
        }
       
    }
   
    NSLog(@"done canceling queries");
    for (RouteObject* route in routeArray) {
      //  [route release];
    }
}
-(void)LogOut:(id)sender
{
    [PFUser logOut];
    [[PFFacebookUtils facebook] logout];
    [[PFFacebookUtils facebook] setAccessToken:nil];
    
    ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
    applicationDelegate.badgeView.text = @"0";
    if([applicationDelegate.window.rootViewController isKindOfClass:[LoginViewController class]])
    {
        [self dismissModalViewControllerAnimated:YES];
    }else{
        LoginViewController* viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        applicationDelegate.window.rootViewController = viewController;
        [viewController release];
        
    }
}
-(IBAction)Settings:(id)sender
{
    SettingsViewController* viewController = [[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:nil];
    [self presentModalViewController:viewController animated:YES];
    [viewController release];
}

- (void)viewDidUnload
{ 
     NSLog(@"view did unload");
    [self setNewbadge:nil];
    [self setFollowedPosters:nil];
    [self setCurrentLocation:nil];

    [self setRouteTableView:nil];
    [self setRouteArray:nil];
    [self setQueryArray:nil];
    
    [self setEmptyGradeView:nil];
    [self setSettingsButton:nil];
 //   [self viewDidDisappear:NO];
    
    [super viewDidUnload];
   
    
    
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
        if ([[routeArray objectAtIndex:indexPath.row] isKindOfClass:[RouteObject class]]) {
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
                if ([[routeArray objectAtIndex:indexPath.row] isKindOfClass:[RouteObject class]]) {
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
                    __block NSString* imagelink;
                    
                    if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                        if (!cell.isFetchingGym) {
                            cell.isFetchingGym = YES;
                          
                        [[object objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                            cell.isFetchingGym = NO;
                            imagelink=[object objectForKey:@"imagelink"];  
                            cell.ownerNameLabel.text = [object objectForKey:@"name"]; 
                            if (((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage) {
                                cell.ownerImage.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage;
                            }else{
                                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                               
                                [request setCompletionBlock:^{
                                    
                                    UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                    if (ownerImage == nil) {
                                        ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                    }
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

                        }];
                        }
                    }else{
                        imagelink = [object objectForKey:@"userimage"];
                        cell.ownerNameLabel.text = [object objectForKey:@"username"];
                        if (((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage) {
                            
                            cell.ownerImage.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage;
                        }else{
                            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                            [request setCompletionBlock:^{
                             
                                   UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                if (ownerImage == nil) {
                                    ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                }
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

                    }
                                
                ///loading route thumbnail image
                if (!((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage && !((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading) {
                    ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading = YES;
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                     [queryArray addObject:imagefile];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        [queryArray removeObject:imagefile];
                        if ([[self.routeArray objectAtIndex:indexPath.row] isKindOfClass:[RouteObject class]]) {
                        ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading = NO;     
                        }
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
                         cell.routeImageView.layer.masksToBounds = YES;
                         cell.routeImageView.layer.cornerRadius = 5.0f;
                         cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                         cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                         cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                         cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                         cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                         cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                     }];
                    }];
                    
                    
                }else{
                    cell.routeImageView.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage;
                    cell.routeImageView.layer.masksToBounds = YES;
                    cell.routeImageView.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                    
                };
                
                    
                double timesincenow =  [((NSDate*)object.createdAt) timeIntervalSinceNow];
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
                
                
                //loading stamp image
                /*
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
                 */
                if ([object objectForKey:@"difficultydescription"]) {
                    cell.difficultyLabel.text = [object objectForKey:@"difficultydescription"];
                }

                cell.todoTextLabel.text = [object objectForKey:@"description"];
   
                
                
                cell.backgroundColor = [UIColor whiteColor];
            }
            }
    // Configure the cell
    
       return cell;
            
        }else if([[routeArray objectAtIndex:indexPath.row] isKindOfClass:[FeedObject class]]){
            if ([[((FeedObject*)[routeArray objectAtIndex:indexPath.row]).pfobj objectForKey:@"action"] isEqualToString:@"comment"]) {
                static NSString *CommentTableCellIdentifier = @"CommentTableCell";
                CommentTableCell* cell = (CommentTableCell*) [tableView dequeueReusableCellWithIdentifier:CommentTableCellIdentifier]; 
                if (cell == nil) {
                    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentTableCell" owner:nil options:nil];
                    for(id currentObject in topLevelObjects){
                        if([currentObject isKindOfClass:[UITableViewCell class]]){
                            cell = (CommentTableCell*)currentObject;
                            
                        }
                    }
                }    
                
                
                FeedObject* selectedFeedObj = ((FeedObject*)[routeArray objectAtIndex:indexPath.row]);
                PFObject* selectedPFObj = selectedFeedObj.pfobj;
                cell.userNameLabel.text = [selectedPFObj objectForKey:@"sender"];
                cell.commentTextLabel.text = [selectedPFObj objectForKey:@"commenttext"];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                if (!selectedFeedObj.routeImage && !((FeedObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading) {
                    ((FeedObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading = YES;
                    [[selectedFeedObj.pfobj objectForKey:@"linkedroute"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                    [queryArray addObject:imagefile];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        [queryArray removeObject:imagefile];
                            ((FeedObject*)[self.routeArray objectAtIndex:indexPath.row]).isLoading = NO;     
                        UIImage* retrievedImage = [UIImage imageWithData:imageData];
                        ((FeedObject*)[self.routeArray objectAtIndex:indexPath.row]).routeImage = retrievedImage;
                        //till here
                        cell.routeImageView.alpha = 0.0;
                        cell.routeImageView.image = retrievedImage;
                        if (cell.routeImageView.image==nil){
                            cell.routeImageView.image = [UIImage imageNamed:@"placeholder.png"];
                        }
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.routeImageView.alpha = 1.0;
                                         } 
                                         completion:^(BOOL finished){
                                             cell.routeImageView.layer.masksToBounds = YES;
                                             cell.routeImageView.layer.cornerRadius = 5.0f;
                                             cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                                             cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                                             cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                                             cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                                             cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                                             cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                                         }];
                    }];
                        }];
                }else{
                    cell.routeImageView.image = selectedFeedObj.routeImage;
                    cell.routeImageView.layer.masksToBounds = YES;
                    cell.routeImageView.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                }

                if (selectedFeedObj.senderImage){
                    cell.userImageView.image = selectedFeedObj.senderImage;
                }else{
                    NSString* urlstring = [NSString stringWithFormat:@"%@",[selectedPFObj objectForKey:@"senderimagelink"]];
                    
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
                    [request setCompletionBlock:^{
                        
                        selectedFeedObj.senderImage = [UIImage imageWithData:[request responseData]];
                        if (selectedFeedObj.senderImage == nil) {
                            selectedFeedObj.senderImage = [UIImage imageNamed:@"placeholder_user.png"];
                        }
                        cell.userImageView.image = selectedFeedObj.senderImage;
                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];
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
            
            
            FeedObject* selectedFeedObj = ((FeedObject*)[routeArray objectAtIndex:indexPath.row]);
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
               
                
                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
                [request setCompletionBlock:^{
                    
                    selectedFeedObj.senderImage = [UIImage imageWithData:[request responseData]];
                    if (selectedFeedObj.senderImage == nil) {
                        selectedFeedObj.senderImage = [UIImage imageNamed:@"placeholder_user.png"];
                    }
                    cell.senderImage.image = selectedFeedObj.senderImage;
                }];
                [request setFailedBlock:^{}];
                [request startAsynchronous];
            }

            if (![[selectedPFObj objectForKey:@"viewed"] containsObject:[[PFUser currentUser]objectForKey:@"name"]] && ![[selectedPFObj objectForKey:@"sender"] isEqualToString:[[PFUser currentUser] objectForKey:@"name"]] && ([cell.feedLabel.text rangeOfString:@"you"].location != NSNotFound || [cell.feedLabel.text rangeOfString:@"your"].location != NSNotFound)) {
         
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
                                                              
                                                              
                                                          [selectedPFObj addUniqueObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"viewed"];
                                                          [selectedPFObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                              PFQuery* queryForNotification = [PFQuery queryWithClassName:@"Feed"];
                                                              [queryForNotification whereKey:@"viewed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
                                                              [queryForNotification  whereKey:@"sender" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
                                                              [queryForNotification whereKey:@"message" containsString:[[PFUser currentUser]objectForKey:@"name"]];
                                                              [queryForNotification countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
                                                                  ParseStarterProjectAppDelegate* appDel = (ParseStarterProjectAppDelegate* )[[UIApplication sharedApplication]delegate];
                                                                  appDel.badgeView.text = [NSString stringWithFormat:@"%d",number];
                                                              }];

                                                          }];
                                                          }
                                                          
                                                      }];

                                     
                                 }];

            
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
            
        return cell;
            }    
        }else{
            static NSString *gymCellIdentifier = @"GymCell";
            GymCell* cell = (GymCell*) [tableView dequeueReusableCellWithIdentifier:gymCellIdentifier]; 
            if (cell == nil) {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GymCell" owner:nil options:nil];
                for(id currentObject in topLevelObjects){
                    if([currentObject isKindOfClass:[UITableViewCell class]]){
                        cell = (GymCell*)currentObject;
                        cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    }
                }
            }
            if ([routeArray count]) {
                GymObject* selectedGymObject = [routeArray objectAtIndex:indexPath.row];
                cell.addressLabel.text = [selectedGymObject.pfobj objectForKey:@"address"];
                PFGeoPoint* mypoint = [PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude];
                cell.distanceLabel.text = [NSString stringWithFormat:@"%.1f km away",[mypoint distanceInKilometersTo:[selectedGymObject.pfobj objectForKey:@"gymlocation"]]];
                cell.gymNameLabel.text = [selectedGymObject.pfobj objectForKey:@"name"];
                cell.gymAboutLabel.text =[selectedGymObject.pfobj objectForKey:@"about"]; 
                if (!selectedGymObject.thumb) {
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[selectedGymObject.pfobj objectForKey:@"imagelink"]]];
                    [request setCompletionBlock:^{
                        UIImage* gymThumb = [UIImage imageWithData:[request responseData]];
                        cell.imageContainer.alpha = 0.0;
                        cell.gymThumbnailView.image = gymThumb;
                        if (cell.gymThumbnailView.image.size.height>=cell.gymThumbnailView.image.size.width) {
                        [cell.gymThumbnailView setFrame:CGRectMake(0, 0, 105, cell.gymThumbnailView.image.size.height/(cell.gymThumbnailView.image.size.width/105))];
                        }
                        selectedGymObject.thumb= gymThumb;
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.imageContainer.alpha = 1.0;
                                             cell.imageContainer.layer.masksToBounds = YES;
                                             cell.imageContainer.layer.cornerRadius = 5.0f;
                                             cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.imageBackgroundView   .bounds].CGPath;
                                             cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                                             cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                                             cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                                             cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                                             cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                                         } 
                                         completion:^(BOOL finished){
                                             
                                         }];
                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];

                }else{
                    cell.gymThumbnailView.image = selectedGymObject.thumb;
                    cell.gymThumbnailView.layer.masksToBounds = YES;
                    cell.gymThumbnailView.layer.cornerRadius = 5.0f;
                    if (cell.gymThumbnailView.image.size.height>=cell.gymThumbnailView.image.size.width) {
                        [cell.gymThumbnailView setFrame:CGRectMake(0, 0, 105, cell.gymThumbnailView.image.size.height/(cell.gymThumbnailView.image.size.width/105))];
                    }
                    cell.imageContainer.layer.masksToBounds = YES;
                    cell.imageContainer.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.imageBackgroundView   .bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                }
            }

            return  cell;
        }
        }
    }


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([routeArray count] && indexPath.row < [routeArray count]) {
        
        if ([[routeArray objectAtIndex:indexPath.row]isKindOfClass:[RouteObject class]]) {
            return 120;
        }else  if ([[routeArray objectAtIndex:indexPath.row]isKindOfClass:[FeedObject class]]){
               if ([[((FeedObject*)[routeArray objectAtIndex:indexPath.row]).pfobj objectForKey:@"action"] isEqualToString:@"comment"]) {
                   return 64;
               }else{
            return 44;
               }
        }else{
            return 120;
        }
    }
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
    tabView.backgroundColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
    tabView.contentSize = CGSizeMake(430, 44);
    tabView.showsHorizontalScrollIndicator = NO;
    [tabView setDelegate:self];
    newbadge = [[[LKBadgeView alloc]initWithFrame:CGRectMake(90,2, 50, 30)]autorelease];
    newbadge.text = @"0";
    newbadge.widthMode = LKBadgeViewWidthModeSmall;
    newbadge.shadowOfText = YES;
    newbadge.shadow=YES;
    newbadge.badgeColor = [UIColor redColor];
    newbadge.outline = YES;
    
    
    [tabView addTabItemWithTitle:@"Followed" icon:[UIImage imageNamed:@"icon2.png"]];
    [tabView addTabItemWithTitle:@"Places" icon:[UIImage imageNamed:@"followed.png"]];
    [tabView addTabItemWithTitle:@"Recently added" icon:[UIImage imageNamed:@"icon1.png"]];
    [tabView addTabItemWithTitle:@"Recommended           " icon:[UIImage imageNamed:@"nearby.png"] badge:newbadge];
    [newbadge release];
   // [tabView addTabItemWithTitle:@"Projects Near Me" icon:[UIImage imageNamed:@"grade.png"]];
   // [tabView addTabItemWithTitle:@"By Grade Near Me" icon:[UIImage imageNamed:@"project_white.png"]];


    
    [tabView setSelectedIndex:0];
    
}

-(void)tabView:(JMTabView *)_tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
        
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
    for (id obj in self.routeArray) {
        if ([obj isKindOfClass:[RouteObject class]]) {
            ((RouteObject*)obj).isLoading = NO;     
        }
        
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
    [gradeQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] withinKilometers:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NearbyDistance"] floatValue]];
    [gradeQuery orderByDescending:@"difficulty"];
    [gradeQuery setLimit:20];
    gradeQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* projectsQuery = [PFQuery queryWithClassName:@"Route"];
    [projectsQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [projectsQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] withinKilometers:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NearbyDistance"] floatValue]];
    PFQuery* projquery = [PFQuery queryWithClassName:@"Project"];
    [projquery whereKey:@"user" equalTo:[PFUser  currentUser]];
    [projquery whereKey:@"route" matchesQuery:projectsQuery];
    [projquery setLimit:20];
    projquery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
    //[gymQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [gymQuery whereKey:@"gymlocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude]];
    [gymQuery setLimit:20];
    gymQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* recommendQuery = [PFQuery queryWithClassName:@"Route"];
    [recommendQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [recommendQuery whereKey:@"usersrecommended" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery whereKey:@"userssent" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery whereKey:@"usersflashed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
     [recommendQuery orderByDescending:@"createdAt"];
    [recommendQuery setLimit:20];
    recommendQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    NSLog(@"starting queries");
    
    
    shouldDisplayNext=1;
    switch (itemIndex) {
        case 0:
            [recentQuery whereKey:@"username" containedIn:followedPosters];
            NSLog(@"followed posters = %@",followedPosters);
            [queryArray addObject:recentQuery];
            
            [recentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"found %d objects",[objects count]);
                [queryArray removeObject:recentQuery];
                [routeArray removeAllObjects];
                [routeTableView reloadData];
                if ([objects count]<20) {
                    shouldDisplayNext =0;
                }
                if ([objects count]>0) {
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                
                }
                PFQuery* feedQuery = [PFQuery queryWithClassName:@"Feed"];
                [feedQuery whereKey:@"sender" containedIn:followedPosters];
                NSArray* arrayActions = [NSArray arrayWithObjects:@"added",@"approval",@"like",@"follow", nil];
                [feedQuery whereKey:@"action" notContainedIn:arrayActions];
                if ([objects count]>0) {
                    [feedQuery whereKey:@"createdAt" greaterThan:((PFObject*)[objects objectAtIndex:([objects count]-1)]).createdAt];
                    
                }else{
                    [feedQuery setLimit:50];
                }
                [queryArray addObject:feedQuery];
                [feedQuery findObjectsInBackgroundWithBlock:^(NSArray *feedobjects, NSError *error) {
                    [queryArray removeObject:feedQuery];
                    for (PFObject* feed in feedobjects) {
                        if ([[feed objectForKey:@"message"] rangeOfString:@"following"].location!=NSNotFound && [[feed objectForKey:@"message"] rangeOfString:[[PFUser currentUser]objectForKey:@"name"]].location==NSNotFound) {
                            
                        }else{
                            
                            
                            FeedObject* feedObject = [[FeedObject alloc]init];
                            feedObject.pfobj = feed;
                            [routeArray addObject:feedObject];
                            [feedObject release];

                        }                        
                    }
                    NSArray *sortedArray;
                    sortedArray = [routeArray sortedArrayUsingComparator:^(id a, id b) {
                        NSDate *first =  ((RouteObject*)a).pfobj.createdAt;
                        NSDate *second = ((RouteObject*)b).pfobj.createdAt;
                        return [second compare:first];
                    }];
                    [routeArray removeAllObjects];
                    [routeArray addObjectsFromArray:sortedArray];
                [self fetchGyms];
                }];
                
                //find feeds that time falls between first and last route
                
                
                    
            }];
            
            
            break;
        case 1:
            
            [queryArray addObject:gymQuery];
            [gymQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:gymQuery];
                [routeArray removeAllObjects] ;
                                [routeTableView reloadData];
                if ([objects count]>0) {
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    for (PFObject* object in objects) {
                        GymObject* newGymObject =  [[GymObject alloc]init];
                        newGymObject.pfobj = object;
                        
                        [routeArray addObject:newGymObject];
                        [newGymObject release];
                    }
                    [routeTableView reloadData];
                }
            }];
            break;
        case 2:
            [queryArray addObject:recentQuery];
            [recentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:recentQuery];
                [routeArray removeAllObjects] ;
                                [routeTableView reloadData];
                if ([objects count]>0) {
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                               [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                }
                [self fetchGyms];
            }];

            break;
        case 3:
            
            [queryArray addObject:recommendQuery];
            [recommendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:recommendQuery];
                [routeArray removeAllObjects] ;
                                [routeTableView reloadData];
                [newbadge setText:[NSString stringWithFormat:@"%d",[objects count]]];
                if ([objects count]>0) {
                    
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                              [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                }
                [self fetchGyms];
            }];    
            break;
        case 4:
            
            [queryArray addObject:projquery];
            [projquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:projquery];
                [routeArray removeAllObjects] ;
                if ([objects count]>0) {
                    
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    [PFObject fetchAllIfNeededInBackground:objects block:^(NSArray *objects, NSError *error) {
    
                    
                    for (PFObject* proj in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = [[proj objectForKey:@"route"]fetchIfNeeded];
                        newRouteObject.stampImage = [UIImage imageNamed:@"projectoverlay210.png"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];

                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                     [self fetchGyms];   
                    }];
                }
                
            }];
            break;
        case 5:
            
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
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                }
                [self fetchGyms];
            }];

                break;
        
    /*        
            
        
//        case 9:
//            [queryArray addObject:popularQuery];
//            [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//                [queryArray removeObject:popularQuery];
//                if ([objects count]<20) {
//                    shouldDisplayNext =0;
//                }
//                [routeArray removeAllObjects];
//                for (PFObject* object in objects) {
//                    RouteObject* newRouteObject =  [[RouteObject alloc]init];
//                    newRouteObject.pfobj = object;
//                    [routeArray addObject:newRouteObject];
//                    [newRouteObject release];
//                }
//                [routeTableView reloadData];
//            }];
//            
//            break;
            //        case 3:
            //            
            //            [queryArray addObject:locationQuery];
            //            [locationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //                [queryArray removeObject:locationQuery];
            //                [routeArray removeAllObjects];
            //                if ([objects count]<20) {
            //                    shouldDisplayNext =0;
            //                }
            //                
            //                for (PFObject* object in objects) {
            //                    RouteObject* newRouteObject =  [[RouteObject alloc]init];
            //                    newRouteObject.pfobj = object;
            //                    [routeArray addObject:newRouteObject];
            //                    [newRouteObject release];
            //                }
            //                [routeTableView reloadData];
            //            }];
            //            break;
     */
        default:
            break;
    }
}


-(void)fetchGyms
{

    if ([gymFetchArray count]>0) {
        [PFObject fetchAllInBackground:gymFetchArray block:^(NSArray *objects, NSError *error) {
            [gymFetchArray removeAllObjects];
                
            [routeTableView reloadData];
        }];   
    }else{
       
            [routeTableView reloadData];
    }
}

#pragma mark - Table view delegate


-(void)lastCellTapped
{
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
    
    PFQuery* gradeQuery = [PFQuery queryWithClassName:@"Route"];
    [gradeQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [gradeQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] withinKilometers:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NearbyDistance"] floatValue]];
    [gradeQuery orderByDescending:@"difficulty"];
    [gradeQuery setLimit:20];
    gradeQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* projectsQuery = [PFQuery queryWithClassName:@"Route"];
    [projectsQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [projectsQuery whereKey:@"routelocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] withinKilometers:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NearbyDistance"] floatValue]];
    PFQuery* projquery = [PFQuery queryWithClassName:@"Project"];
    [projquery whereKey:@"user" equalTo:[PFUser  currentUser]];
    [projquery whereKey:@"route" matchesQuery:projectsQuery];
    [projquery setLimit:20];
    projquery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    
    PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
    [gymQuery whereKey:@"gymlocation" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude]];
    [gymQuery setLimit:20];
    gymQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    PFQuery* recommendQuery = [PFQuery queryWithClassName:@"Route"];
    [recommendQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [recommendQuery whereKey:@"usersrecommended" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery whereKey:@"userssent" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery whereKey:@"usersflashed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [recommendQuery orderByDescending:@"createdAt"];
    [recommendQuery setLimit:20];
    recommendQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
            int routecount=0;
    
    
    
    switch (tabView.segmentIndex) {
        case 0:

            for (id obj in routeArray) {
                if ([obj isKindOfClass:[RouteObject class]]) {
                    routecount++;
                }
            }
            [recentQuery setSkip:routecount];
            [recentQuery whereKey:@"username" containedIn:followedPosters];
            NSLog(@"followed posters = %@",followedPosters);
            [queryArray addObject:recentQuery];
            
            [recentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                
                [queryArray removeObject:recentQuery];
                int oldroutearraycount = [routeArray count]-1;
                if ([objects count]<20) {
                    shouldDisplayNext =0;
                }
                if ([objects count]>0) {
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                }
                PFQuery* feedQuery = [PFQuery queryWithClassName:@"Feed"];
                [feedQuery whereKey:@"sender" containedIn:followedPosters];
                NSArray* arrayActions = [NSArray arrayWithObjects:@"added",@"approval",@"like",@"follow",nil];
                [feedQuery whereKey:@"action" notContainedIn:arrayActions];
                [feedQuery whereKey:@"createdAt" lessThan:((RouteObject*)[routeArray objectAtIndex:oldroutearraycount]).pfobj.createdAt];
                [feedQuery whereKey:@"createdAt" greaterThan:((RouteObject*)[routeArray objectAtIndex:([routeArray count]-1)]).pfobj.createdAt];
                [queryArray addObject:feedQuery];
                [feedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [queryArray removeObject:feedQuery];
                    for (PFObject* feed in objects) {
                        FeedObject* feedObject = [[FeedObject alloc]init];
                        feedObject.pfobj = feed;
                        [routeArray addObject:feedObject];
                        [feedObject release];
                        
                    }
                    NSArray *sortedArray;
                    sortedArray = [routeArray sortedArrayUsingComparator:^(id a, id b) {
                        NSDate *first =  ((RouteObject*)a).pfobj.createdAt;
                        NSDate *second = ((RouteObject*)b).pfobj.createdAt;
                        return [second compare:first];
                    }];
                    [routeArray removeAllObjects];
                    [routeArray addObjectsFromArray:sortedArray];
            
                         [self fetchGyms];
                }];
            }];
                break;
        case 1:
            
            [queryArray addObject:gymQuery];
            [gymQuery setSkip:[routeArray count]];
            [gymQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:gymQuery];
                [routeArray removeAllObjects] ;
                if ([objects count]>0) {
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    for (PFObject* object in objects) {
                        GymObject* newGymObject =  [[GymObject alloc]init];
                        newGymObject.pfobj = object;
                        [routeArray addObject:newGymObject];
                        [newGymObject release];
                    }
                    [routeTableView reloadData];
                }
            }];
            break;
        case 2:
            
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
                    if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                        [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        
                    }
                    [routeArray addObject:newRouteObject];
                    [newRouteObject release];
                }
            
             [self fetchGyms];
            }];
            break;
        case 3:
            [recommendQuery setSkip:[routeArray count]];
            [queryArray addObject:recommendQuery];
            
            [recommendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:recommendQuery];
                [routeArray removeAllObjects] ;
                 [newbadge setText:[NSString stringWithFormat:@"%d",[objects count]]];
                if ([objects count]>0) {
                    
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    
                    for (PFObject* object in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = object;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                [self fetchGyms];
                }
                
            }];
            break;
        case 4:
            [projquery setSkip:[routeArray count]];
            [queryArray addObject:projquery];
            
            [projquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:projquery];
                [routeArray removeAllObjects] ;
                
                if ([objects count]>0) {
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    
                    for (PFObject* proj in objects) {
                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = proj;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                    [self fetchGyms];
                }
            }];
            break;
        case 5:
            [gradeQuery setSkip:[routeArray count]];
            [queryArray addObject:gradeQuery];
            
            [gradeQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:gradeQuery];

                if ([objects count]>0) {
                    if ([objects count]<20) {
                        shouldDisplayNext =0;
                    }
                    
                    for (PFObject* proj in objects) {

                        RouteObject* newRouteObject =  [[RouteObject alloc]init];
                        newRouteObject.pfobj = proj;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            
                        }
                        [routeArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                    [self fetchGyms];
                }
            }];
            
            break;
     /*   case 6:
            [gymQuery setSkip:[routeArray count]];
            [queryArray addObject:gymQuery];
            
            [gymQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:gymQuery];
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
        case 7:
            [recommendQuery setSkip:[routeArray count]];
            [queryArray addObject:recommendQuery];
            
            [recommendQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:recommendQuery];
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
            
            break;*/
        default:
            break;
    }

}
-(void)cancelRequests
{
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
    for (id obj in self.routeArray) {
        if ([obj isKindOfClass:[RouteObject class]]) {
            ((RouteObject*)obj).isLoading = NO;     
        }
        
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
    [self cancelRequests];

    
    if (indexPath.row==([routeArray count])) {
        [self lastCellTapped];        
        
    }else{
    if ([[routeArray objectAtIndex:indexPath.row] isKindOfClass:[RouteObject class]]) {

        RouteObject* selectedRouteObject = [self.routeArray objectAtIndex:indexPath.row];
        PFObject* gymObject = [selectedRouteObject.pfobj objectForKey:@"Gym"];
        if (gymObject){
        [gymObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
            viewController.routeObject = [self.routeArray objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
               [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [viewController release];
        }];
        }else{
            RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
            viewController.routeObject = [self.routeArray objectAtIndex:indexPath.row];
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [viewController release];
        }
        
        
    }else if([[routeArray objectAtIndex:indexPath.row] isKindOfClass:[FeedObject class]]){
        PFObject* followfeedobj = ((FeedObject*)[routeArray objectAtIndex:indexPath.row]).pfobj;
      
        if([followfeedobj objectForKey:@"linkedroute"]){
            RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
            RouteObject* newRouteObject = [[RouteObject alloc]init];
            [[((FeedObject*)[routeArray objectAtIndex:indexPath.row]).pfobj objectForKey:@"linkedroute"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                if ([object objectForKey:@"Gym"]) {
                [[object objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    newRouteObject.pfobj = object;
                    viewController.routeObject = newRouteObject;
                    [self.navigationController pushViewController:viewController animated:YES];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [viewController release];
                    [newRouteObject release];
                }];
                }else{
                
                newRouteObject.pfobj = object;
                viewController.routeObject = newRouteObject;
                [self.navigationController pushViewController:viewController animated:YES];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
                [viewController release];
                [newRouteObject release];
                }
            }];

        }else{
            ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
            viewController.username= [followfeedobj objectForKey:@"sender"]; 
            [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];                         
            [viewController release];
        }

    }else{
        GymViewController* viewController = [[GymViewController alloc]initWithNibName:@"GymViewController" bundle:nil];
         [((GymObject*)[routeArray objectAtIndex:indexPath.row]).pfobj fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
             viewController.gymObject = object; 
             [self.navigationController pushViewController:viewController animated:YES];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
             [viewController release];
        }];
        
    }
        
        
        
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
    [routeArray removeAllObjects];
    [routeTableView reloadData];
    [button startAnimating];
    [self reloadTableViewDataSource];

}
#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	PFQuery* queryForNotification = [PFQuery queryWithClassName:@"Feed"];
    [queryForNotification whereKey:@"viewed" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [queryForNotification  whereKey:@"sender" notEqualTo:[[PFUser currentUser]objectForKey:@"name"]];
    [queryForNotification whereKey:@"message" containsString:[[PFUser currentUser]objectForKey:@"name"]];
    [queryForNotification countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        ParseStarterProjectAppDelegate* appDel = (ParseStarterProjectAppDelegate* )[[UIApplication sharedApplication]delegate];
        appDel.badgeView.text = [NSString stringWithFormat:@"%d",number];
    }];
    
    //reset stamp image
//    for (id obj in routeArray) {
//        if ([obj isKindOfClass:[RouteObject class]]) {
//        ((RouteObject*)obj).stampImage = nil;     
//        }
//    }
    if (tabView.segmentIndex==0) {
        
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
        [queryArray addObject:followedquery];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:followedquery];
        [followedPosters removeAllObjects];
        for (PFObject* follow in objects) {
            
            [followedPosters addObject:[follow objectForKey:@"followed"]];
            
        }
        
    
     [self tabView:tabView didSelectTabAtIndex:tabView.segmentIndex];
     
     [((DAReloadActivityButton*)refreshButton) stopAnimating];	    
    }];
    }else{
        [self tabView:tabView didSelectTabAtIndex:tabView.segmentIndex];
        
        [((DAReloadActivityButton*)refreshButton) stopAnimating];	
    }
    
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
    [queryArray release];
    [tabView release];
    [routeTableView release];
    [emptyGradeView release];
    [settingsButton release];
    [super dealloc];
}
@end
