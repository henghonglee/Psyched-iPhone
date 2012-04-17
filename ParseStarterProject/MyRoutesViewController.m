//
//  MyTableController.m
//  ParseStarterProject
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import "MyRoutesViewController.h"
#import "SpecialTableCell.h"
#import "ASIHTTPRequest.h"
@implementation MyRoutesViewController
@synthesize routeTableView;
@synthesize selectedSegment;
@synthesize selectedUser;
@synthesize flashArray,sentArray,projectArray,likedArray,queryArray;
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
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    UIImageView* headerviewimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44 )];
    headerviewimage.image = [UIImage imageNamed:@"headerview2.png"];
    [headerView addSubview:headerviewimage];
    [headerviewimage release];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 44)];
    headerLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.text = @"My Routes";
    headerLabel.backgroundColor = [UIColor clearColor];
    refreshButton = [[DAReloadActivityButton alloc]initWithFrame:CGRectMake(276, 0, 44, 44)];
    [refreshButton addTarget:self action:@selector(animate:) forControlEvents:UIControlEventTouchUpInside];
    refreshButton.contentMode = UIViewContentModeScaleAspectFit;
    refreshButton.showsTouchWhenHighlighted = YES;
    [headerView addSubview:refreshButton];
    [headerView addSubview:headerLabel];  
    [headerLabel release];
    UIButton* backButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 70, 44)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:backButton];
    [backButton release];
    
    self.flashArray = [[[NSMutableArray alloc]init]autorelease];
    self.sentArray = [[[NSMutableArray alloc]init]autorelease];
    self.projectArray = [[[NSMutableArray alloc]init]autorelease];
    self.likedArray = [[[NSMutableArray alloc]init]autorelease];
    self.queryArray =[[[NSMutableArray alloc]init]autorelease];
    [self addStandardTabView];
    [tabView centraliseSubviews];
    tabView.segmentIndex = selectedSegment;
    [tabView setSelectedIndex:selectedSegment];
    [self tabView:tabView didSelectTabAtIndex:selectedSegment];
    
}
-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;
}
-(void)backButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)loadcounter
{
    NSLog(@"%d/%d of loading",loadcount,([flashArray count]+[sentArray count]+[projectArray count]+[likedArray count]));
    if (loadcount == ([flashArray count]+[sentArray count]+[projectArray count]+[likedArray count])) {
        [routeTableView reloadData]; 
        loadcount = 1;
        NSLog(@"finished loading");

    }else{
        loadcount++;
        
    }
    
}

- (void)viewDidUnload
{
    
    [super viewDidUnload];
    NSLog(@"view did unload");
    self.flashArray = nil;
 //   [self.flashArray release];
    self.sentArray = nil;
 //   [self.sentArray release];
    self.projectArray=nil;
//    [self.projectArray release];
    self.likedArray=nil;
    self.queryArray=nil;
//    [self.likedArray release];
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
    if (section==1) {
    switch (tabView.segmentIndex) {
        case 0:
            return [flashArray count];
            break;
        case 1:
            return [sentArray count];
            break;
        case 2:
            return [projectArray count];
            break;
        case 3:
            return [likedArray count];
            break;
            
        default:
            return 0;
            break;
            
    }
    }else{
    return 0;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [[UIView new] autorelease];
    }       
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    SpecialTableCell* cell = (SpecialTableCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SpecialTableCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (SpecialTableCell*)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                // cell.routeImageView.layer.cornerRadius = 5;
                //     cell.routeImageView.layer.borderColor = [UIColor blackColor].CGColor;
                //    cell.routeImageView.layer.borderWidth =3;
            }
        }
    } 
    switch (tabView.segmentIndex) {
            
        case 0:
            if ([self.flashArray count]>0) {
                PFObject* object = ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).pfobj;
                                NSLog(@"showing flash array");
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];
                
                NSString* imagelink;
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    imagelink=[[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"imagelink"];
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                }
                
                if (((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                    [request setCompletionBlock:^{
                        UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                           
                        cell.ownerImage.image = ownerImage;
                        ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
                     cell.ownerImage.alpha =0.0;
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.ownerImage.alpha = 1.0;
                                         } 
                                         completion:^(BOOL finished){
                                             // NSLog(@"Done!");
                                         }];
                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];
                }
                if (!((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).retrievedImage) {
                    
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        UIImage* retrievedImage = [UIImage imageWithData:imageData];
                       
                        ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
                        cell.routeImageView.image = retrievedImage;
                         cell.routeImageView.alpha =0.0;
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
                    cell.routeImageView.image = ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).retrievedImage;
                }
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
                
                cell.todoTextLabel.text = [object objectForKey:@"description"];
                cell.difficultyLabel.text = [object objectForKey:@"difficultydescription"];
                // cell.routeImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagelink]]];
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    cell.ownerNameLabel.text = [[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"name"];
                }else{
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                }
                
                //  cell.priorityLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"priority"]];
            }
            break;
        case 1:
            if ([self.sentArray count]>0) {
                PFObject* object = ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).pfobj;
                NSLog(@"showing sent array");
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];                
                NSString* imagelink;
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    imagelink=[[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"imagelink"];
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                }

                if (((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                    [request setCompletionBlock:^{
                        UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                        cell.ownerImage.image = ownerImage;
                        ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
                        cell.ownerImage.alpha =0.0;
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.ownerImage.alpha = 1.0;
                                         } 
                                         completion:^(BOOL finished){
                                             // NSLog(@"Done!");
                                         }];

                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];
                }
                if (!((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).retrievedImage) {
                    
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        UIImage* retrievedImage = [UIImage imageWithData:imageData];
                        ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
                        cell.routeImageView.image = retrievedImage;
                        cell.routeImageView.alpha =0.0;
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
                    cell.routeImageView.image = ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).retrievedImage;
                }
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
                cell.difficultyLabel.text = [object objectForKey:@"difficultydescription"];
                cell.todoTextLabel.text = [object objectForKey:@"description"];
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    cell.ownerNameLabel.text = [[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"name"];
                }else{
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                }
                
            }
            break;
        case 2:
            if ([self.projectArray count]>0) {
                PFObject* object = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).pfobj;
NSLog(@"showing proj array with ob %@",object);
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];                
                NSString* imagelink;
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    imagelink=[[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"imagelink"];
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                }

                if (((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                    [request setCompletionBlock:^{
                        UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                        cell.ownerImage.image = ownerImage;
                        ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
                        cell.ownerImage.alpha =0.0;
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.ownerImage.alpha = 1.0;
                                         } 
                                         completion:^(BOOL finished){
                                             // NSLog(@"Done!");
                                         }];

                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];
                }
                if (!((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).retrievedImage) {
                    
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        UIImage* retrievedImage = [UIImage imageWithData:imageData];
                        ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
                        cell.routeImageView.image = retrievedImage;
                        cell.routeImageView.alpha =0.0;
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
                    cell.routeImageView.image = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).retrievedImage;
                }
                
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
                
                cell.todoTextLabel.text = [object objectForKey:@"description"];
                cell.difficultyLabel.text = [object objectForKey:@"difficultydescription"];
                // cell.routeImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagelink]]];
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    cell.ownerNameLabel.text = [[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"name"];
                }else{
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                }
                
                
            }
            break;
        case 3:
            if ([self.likedArray count]>0) {
                PFObject* object = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).pfobj;
                                NSLog(@"showing like array with ob %@",object);
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];  
                
                
                
                NSString* imagelink;
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    imagelink=[[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"imagelink"];
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                }

                if (((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                    [request setCompletionBlock:^{
                        UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                        cell.ownerImage.image = ownerImage;
                        ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
                        cell.ownerImage.alpha =0.0;
                        [UIView animateWithDuration:0.3
                                              delay:0.0
                                            options: UIViewAnimationCurveEaseOut
                                         animations:^{
                                             cell.ownerImage.alpha = 1.0;
                                         } 
                                         completion:^(BOOL finished){
                                             // NSLog(@"Done!");
                                         }];

                    }];
                    [request setFailedBlock:^{}];
                    [request startAsynchronous];
                }
                if (!((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).retrievedImage) {
                    
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        UIImage* retrievedImage = [UIImage imageWithData:imageData];
                        ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
                        cell.routeImageView.image = retrievedImage;
                        cell.routeImageView.alpha =0.0;
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
                    cell.routeImageView.image = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).retrievedImage;
                }
                
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
                cell.difficultyLabel.text = [object objectForKey:@"difficultydescription"];
                cell.todoTextLabel.text = [object objectForKey:@"description"];
                
                // cell.routeImageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imagelink]]];
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    cell.ownerNameLabel.text = [[[object objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"name"];
                }else{
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                }
                
                //  cell.priorityLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"priority"]];
            }
            break;

        default:
            break;
    }
    
    // Configure the cell
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}


#pragma mark - Table view data source

-(void)addStandardTabView
{
    tabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, 320, 44.)] ;
 //  tabView = [[JMTabView alloc] init];
    tabView.layer.shadowColor = [UIColor blackColor].CGColor;
    tabView.layer.shadowOpacity = 0.4;
    tabView.layer.shadowOffset = CGSizeMake(0, 2);
    self.tabBarController.tabBar.layer.shadowColor= [UIColor blackColor].CGColor;
    self.tabBarController.tabBar.layer.shadowOpacity = 0.4;
    self.tabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, -4);
    [tabView setDelegate:self];
    
    [tabView addTabItemWithTitle:@"Flash" icon:[UIImage imageNamed:@"flash_white.png"]];
    [tabView addTabItemWithTitle:@"Sent" icon:[UIImage imageNamed:@"sent_white.png"]];
    [tabView addTabItemWithTitle:@"Project" icon:[UIImage imageNamed:@"project_white.png"]];
    [tabView addTabItemWithTitle:@"Added" icon:[UIImage imageNamed:@"followed.png"]];
    
    
    
    //    You can run blocks by specifiying an executeBlock: paremeter
    //    #if NS_BLOCKS_AVAILABLE
    //    [tabView addTabItemWithTitle:@"One" icon:nil executeBlock:^{NSLog(@"abc");}];
    //    #endif
    
    [tabView setSelectedIndex:0];
    
//    [self.view addSubview:tabView];

}
-(void)tabView:(JMTabView *)_tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
    tabView.segmentIndex = itemIndex;
    [tabView setSelectedIndex:itemIndex];
    PFQuery* query = [PFQuery queryWithClassName:@"Flash"];
    [query whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query orderByDescending:@"createdAt"];
    PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
    [query2 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query2 orderByDescending:@"createdAt"];
    PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
    [query3 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query3 orderByDescending:@"createdAt"];    
    PFQuery* addedrouteQuery = [PFQuery queryWithClassName:@"Route"];
    [addedrouteQuery whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [addedrouteQuery orderByDescending:@"createdAt"];
    switch (itemIndex) {
            
            
        case 0:
            if ([self.flashArray count]==0) {
                [queryArray addObject:query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                [queryArray removeObject:query];
                for (PFObject* flash in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[flash objectForKey:@"route"]fetchIfNeeded];
                    newRouteObject.pfobj = [flash objectForKey:@"route"];
                    
                    BOOL isadded =NO;
                    for (RouteObject* obj in flashArray){
                        if ([obj.pfobj.objectId isEqualToString:newRouteObject.pfobj.objectId]) {
                            isadded = YES;
                        }
                    }
                    if (!isadded) {
                        [self.flashArray addObject:newRouteObject];
                    }
                [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
            }
            break;
            case 1:
            
            if ([self.sentArray count]==0) {
                [queryArray addObject:query2];
                      [query2 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                          [queryArray removeObject:query2];
                for (PFObject* sent in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[sent objectForKey:@"route"]fetchIfNeeded];
                    newRouteObject.pfobj = [sent objectForKey:@"route"];
                    
                    BOOL isadded =NO;
                    for (RouteObject* obj in sentArray){
                        if ([obj.pfobj.objectId isEqualToString:newRouteObject.pfobj.objectId]) {
                            isadded = YES;
                        }
                    }
                    if (!isadded) {
                        [self.sentArray addObject:newRouteObject];
                    }
                    [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
    }
            break;
        case 2:
            if ([self.projectArray count]==0) {
                [queryArray addObject:query3];
            [query3 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                [queryArray removeObject:query3];    
                for (PFObject* proj in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[proj objectForKey:@"route"]fetchIfNeeded];
                    newRouteObject.pfobj = [proj objectForKey:@"route"];
                    
                    BOOL isadded =NO;
                    for (RouteObject* obj in projectArray){
                        if ([obj.pfobj.objectId isEqualToString:newRouteObject.pfobj.objectId]) {
                            isadded = YES;
                        }
                    }
                    if (!isadded) {
                        [self.projectArray addObject:newRouteObject];
                    }
                    [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
        }
            break;
        case 3:
            if ([self.likedArray count]==0) {
                [queryArray addObject:addedrouteQuery];
            [addedrouteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:addedrouteQuery];
                [likedArray removeAllObjects];
                for (PFObject* route in objects){
                    
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    newRouteObject.pfobj = route;
                    [self.likedArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
            }
            break;
                         
            
            
            
        default:
            break;
    }
    
    [routeTableView reloadData];
    
    NSLog(@"Selected Tab Index: %d", tabView.segmentIndex);
    
}

#pragma mark - Table view delegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 44;
    }else{
        return 44;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"didselecte");
    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
    
    
    switch (tabView.segmentIndex) {
        case 0:
            viewController.routeObject = [self.flashArray objectAtIndex:indexPath.row];
            
            break;
        case 1:
            viewController.routeObject = [self.sentArray objectAtIndex:indexPath.row];
            break;
        case 2:
            viewController.routeObject = [self.projectArray objectAtIndex:indexPath.row];
            break;
        case 3:
            viewController.routeObject = [self.likedArray objectAtIndex:indexPath.row];
            break;
        default:
            
            break;
            
    }
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
    
}



#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
    PFQuery* query = [PFQuery queryWithClassName:@"Flash"];
    [query whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query orderByDescending:@"createdAt"];
    PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
    [query2 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query2 orderByDescending:@"createdAt"];
    PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
    [query3 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query3 orderByDescending:@"createdAt"];
    PFQuery* addedrouteQuery = [PFQuery queryWithClassName:@"Route"];
    [addedrouteQuery whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [addedrouteQuery orderByDescending:@"createdAt"];
    switch (tabView.segmentIndex) {                        
        case 0:
            [queryArray addObject:query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                [queryArray removeObject:query];
                [self.flashArray removeAllObjects];
                for (PFObject* flash in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[flash objectForKey:@"route"]fetchIfNeeded];
                    newRouteObject.pfobj = [flash objectForKey:@"route"];
                    [self.flashArray addObject:newRouteObject];
                    [newRouteObject release];
                    
                }
                [routeTableView reloadData];
            }];
            
            break;
        case 1:
            [queryArray addObject:query2];
            [query2 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                [queryArray removeObject:query2];    
                [self.sentArray removeAllObjects];
                for (PFObject* sent in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[sent objectForKey:@"route"]fetchIfNeeded];
                    newRouteObject.pfobj = [sent objectForKey:@"route"];
                    [self.sentArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
            
            break;
        case 2:
            [queryArray addObject:query3];
            [query3 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){                                    
                [queryArray removeObject:query3];
                [self.projectArray removeAllObjects];
                for (PFObject* proj in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[proj objectForKey:@"route"]fetchIfNeeded];
                    newRouteObject.pfobj = [proj objectForKey:@"route"];
                    [self.projectArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                [routeTableView reloadData];
            }];
            
            break;
        case 3:
            [queryArray addObject:addedrouteQuery];
            [addedrouteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [queryArray removeObject:addedrouteQuery];                
                [self.likedArray removeAllObjects];
                for (PFObject* route in objects){
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    newRouteObject.pfobj = route;
                    [self.likedArray addObject:newRouteObject];
                     [newRouteObject release];
                     }
                [routeTableView reloadData];
            }];
            
            break;
            
            
            
            
        default:
            break;
    }
    
    [routeTableView reloadData];
    
    [((DAReloadActivityButton*)refreshButton) stopAnimating];
	
}





- (void)dealloc {
    
    [routeTableView release];
    [super dealloc];
}
@end
