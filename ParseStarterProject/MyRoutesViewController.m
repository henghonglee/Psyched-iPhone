//
//  MyTableController.m
//  PsychedApp
//
//  Created by James Yu on 12/29/11.
//  Copyright (c) 2011 Parse Inc. All rights reserved.
//

#import "MyRoutesViewController.h"
#import "SpecialTableCell.h"
#import "RouteCell.h"
#import "JMTabView/Classes/Subviews/JMTabView.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
@implementation MyRoutesViewController
@synthesize routeTableView;
@synthesize selectedSegment;
@synthesize selectedUser;
@synthesize gymFetchArray;
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
    shouldDisplayNext = 0;
    headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor darkGrayColor];
    UIImageView* headerviewimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44 )];
    headerviewimage.image = [UIImage imageNamed:@"headerimgbg@2x.png"];
    [headerView addSubview:headerviewimage];
    [headerviewimage release];
    UILabel* headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 0, 200, 44)];
    headerLabel.font = [UIFont boldSystemFontOfSize:20.0f];
    headerLabel.textAlignment = UITextAlignmentCenter;
    headerLabel.textColor = [UIColor colorWithRed:229.0/255.0 green:182.0/255.0 blue:3.0/255.0 alpha:1.0];
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
    
    
    
    
    
    self.gymFetchArray = [[[NSMutableArray alloc]init]autorelease];
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

-(void)viewWillDisappear:(BOOL)animated
{
    [self cancelRequests];
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
    [self setSelectedUser:nil];
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
            return [flashArray count]+shouldDisplayNext;
            break;
        case 1:
            return [sentArray count]+shouldDisplayNext;
            break;
        case 2:
            return [projectArray count]+shouldDisplayNext;
            break;
        case 3:
            return [likedArray count]+shouldDisplayNext;
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
    RouteCell* cell = (RouteCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"RouteCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (RouteCell*)currentObject;
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
                if(indexPath.row == [self.flashArray count]){
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
                }
                PFObject* object = ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).pfobj;
         //                       NSLog(@"showing flash array");
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];
                
                __block NSString* imagelink;
                
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {

                    [[object objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        imagelink=[object objectForKey:@"imagelink"];  
                        cell.ownerNameLabel.text = [object objectForKey:@"name"]; 
                    }];
                    
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                }
                
                if (((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                  [cell.ownerImage setImageWithURL:[NSURL URLWithString:imagelink] placeholderImage:[UIImage imageNamed:@"placeholder_user.png"]];
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
                    cell.routeImageView.image = ((RouteObject*)[self.flashArray objectAtIndex:indexPath.row]).retrievedImage;
                    cell.routeImageView.layer.masksToBounds = YES;
                    cell.routeImageView.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
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
                
                
                //  cell.priorityLabel.text = [NSString stringWithFormat:@"%@", [object objectForKey:@"priority"]];
            }
            break;
        case 1:
            if ([self.sentArray count]>0) {
                if(indexPath.row == [self.sentArray count]){
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
                }
                
                
                PFObject* object = ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).pfobj;
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];                
                __block NSString* imagelink;
                
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                    [[object objectForKey:@"Gym"]fetchIfNeeded];
                    [[object objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        imagelink=[object objectForKey:@"imagelink"];  
                         cell.ownerNameLabel.text = [object objectForKey:@"name"]; 
                    }];
                    
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                      cell.ownerNameLabel.text = [object objectForKey:@"username"];
                }

                if (((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).ownerImage;
                }else{
                  [cell.ownerImage setImageWithURL:imagelink placeholderImage:[UIImage imageNamed:@"placeholder_user.png"]];
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
                    cell.routeImageView.image = ((RouteObject*)[self.sentArray objectAtIndex:indexPath.row]).retrievedImage;
                    cell.routeImageView.layer.masksToBounds = YES;
                    cell.routeImageView.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
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
            
                
            }
            break;
        case 2:
            if ([self.projectArray count]>0) {
                if(indexPath.row == [self.projectArray count]){
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
                }
                PFObject* object = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).pfobj;

                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];                
                __block NSString* imagelink;
                
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {

                    [[object objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        imagelink=[object objectForKey:@"imagelink"];  
                        cell.ownerNameLabel.text = [object objectForKey:@"name"]; 
                    }];
                    if (((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage) {
                        cell.ownerImage.image = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage;
                    }else{
                      [cell.ownerImage setImageWithURL:[NSURL URLWithString:imagelink] placeholderImage:[UIImage imageNamed:@"placeholder_user.png"]];
                    }
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                    if (((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage) {
                        cell.ownerImage.image = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).ownerImage;
                    }else{
                      [cell.ownerImage setImageWithURL:[NSURL URLWithString:imagelink] placeholderImage:[UIImage imageNamed:@"placeholder_user.png"]];
                    }
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
                    cell.routeImageView.image = ((RouteObject*)[self.projectArray objectAtIndex:indexPath.row]).retrievedImage;
                    cell.routeImageView.layer.masksToBounds = YES;
                    cell.routeImageView.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
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
             
                
                
            }
            break;
        case 3:
            if ([self.likedArray count]>0) {
                if(indexPath.row == [self.likedArray count]){
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
                }
                PFObject* object = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).pfobj;
                                NSLog(@"showing like array with ob %@",object);
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];  
                
                
                
                __block NSString* imagelink;
                
                if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {

                    [[object objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        imagelink=[object objectForKey:@"imagelink"];  
                        cell.ownerNameLabel.text = [object objectForKey:@"name"]; 
                        if (((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage) {
                            cell.ownerImage.image = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage;
                        }else{
                          [cell.ownerImage setImageWithURL:[NSURL URLWithString:imagelink] placeholderImage:[UIImage imageNamed:@"placeholder_user.png"]];
                        }
                    }];
                    
                }else{
                    imagelink = [object objectForKey:@"userimage"];
                    cell.ownerNameLabel.text = [object objectForKey:@"username"];
                    if (((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage) {
                        cell.ownerImage.image = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).ownerImage;
                    }else{
                      [cell.ownerImage setImageWithURL:[NSURL URLWithString:imagelink] placeholderImage:[UIImage imageNamed:@"placeholder_user.png"]];
                    }
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
                    cell.routeImageView.image = ((RouteObject*)[self.likedArray objectAtIndex:indexPath.row]).retrievedImage;
                    cell.routeImageView.layer.masksToBounds = YES;
                    cell.routeImageView.layer.cornerRadius = 5.0f;
                    cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                    cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                    cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                    cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                    cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                    cell.imageBackgroundView.layer.cornerRadius = 5.0f;
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
               /*
                if ([[object objectForKey:@"approvalstatus"]isEqualToString:@"pending"]) {
                    cell.approvalView.hidden=NO;
                    cell.routePFObject = object;
                    GradientButton* approveButton = [[GradientButton alloc]initWithFrame:CGRectMake(4, 32, 200, 37)];
                    [approveButton setTitle:@"Approve" forState:UIControlStateNormal];
                    [approveButton useGreenConfirmStyle];
                    [approveButton addTarget:cell action:@selector(approveOutdate:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.approvalView addSubview:approveButton];
                    [approveButton release];
                    
                    GradientButton* disapproveButton = [[GradientButton alloc]initWithFrame:CGRectMake(4, 74, 200, 37)];
                    [disapproveButton setTitle:@"Disapprove" forState:UIControlStateNormal];
                    [disapproveButton addTarget:cell action:@selector(disapproveOutdate:) forControlEvents:UIControlEventTouchUpInside];
                    [disapproveButton useRedDeleteStyle];
                    [cell.approvalView addSubview:disapproveButton];
                    [disapproveButton release];
                    
                }else{
                    cell.approvalView.hidden=YES;
                }*/
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
    return 125;
}

-(void)cancelRequests
{
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

#pragma mark - Table view data source

-(void)addStandardTabView
{
    tabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, 320, 44.)] ;
    tabView.backgroundColor = [UIColor colorWithRed:69.0/255.0 green:69.0/255.0 blue:69.0/255.0 alpha:1.0];
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
    
    [tabView setSelectedIndex:0];
    


}
-(void)tabView:(JMTabView *)_tabView didSelectTabAtIndex:(NSUInteger)itemIndex;
{
    [self cancelRequests];
    shouldDisplayNext = 0;
    [routeTableView reloadData];
    tabView.segmentIndex = itemIndex;
    [tabView setSelectedIndex:itemIndex];
    PFQuery* query = [PFQuery queryWithClassName:@"Flash"];
    [query whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:20];
    PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
    [query2 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query2 orderByDescending:@"createdAt"];
    [query2 setLimit:20];
    PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
    [query3 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query3 orderByDescending:@"createdAt"];
    [query3 setLimit:20];
    PFQuery* addedrouteQuery = [PFQuery queryWithClassName:@"Route"];
    [addedrouteQuery whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [addedrouteQuery orderByDescending:@"createdAt"];
    [addedrouteQuery setLimit:20];
    switch (itemIndex) {
            
            
        case 0:
            
            if ([self.flashArray count]==0) {
                [queryArray addObject:query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                [queryArray removeObject:query];
                if ([retrievedObjs count]<20) {
                    shouldDisplayNext = 0;
                }else{
                    shouldDisplayNext = 1;
                }
                __block int flashretrieve=0;
                for (PFObject* flash in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[flash objectForKey:@"route"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        newRouteObject.pfobj = [flash objectForKey:@"route"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                        }
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
                        flashretrieve++;
                        if (flashretrieve==[retrievedObjs count]) {
                            [self fetchGyms];
                        }
                    }];
                    
                }
                     
            }];
            }
            break;
            case 1:
            
            if ([self.sentArray count]==0) {
                [queryArray addObject:query2];
                      [query2 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                          [queryArray removeObject:query2];
                          if ([retrievedObjs count]<20) {
                              shouldDisplayNext = 0;
                          }else{
                              shouldDisplayNext = 1;
                          }
                          __block int sentretrieve=0;
                for (PFObject* sent in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[sent objectForKey:@"route"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        newRouteObject.pfobj = [sent objectForKey:@"route"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                            
                        }
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
                        sentretrieve++;
                        if (sentretrieve== [retrievedObjs count]) {
                            [self fetchGyms];
                        }
                    }];
                    
                }
            }];
    }
            break;
        case 2:
            if ([self.projectArray count]==0) {
                [queryArray addObject:query3];
            [query3 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                [queryArray removeObject:query3];
                if ([retrievedObjs count]<20) {
                    shouldDisplayNext = 0;
                }else{
                    shouldDisplayNext = 1;
                }
                __block int projretrieve=0;
                for (PFObject* proj in retrievedObjs)
                {
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    [[proj objectForKey:@"route"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        newRouteObject.pfobj = [proj objectForKey:@"route"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                        }
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
                        projretrieve++;
                        if (projretrieve==[retrievedObjs count]) {
                            [self fetchGyms];
                        }
                    }];
                    
                }
                 
            }];
        }
            break;
        case 3:
            if ([self.likedArray count]==0) {
                [queryArray addObject:addedrouteQuery];
            [addedrouteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:addedrouteQuery];
                if ([objects count]<20) {
                    shouldDisplayNext = 0;
                }else{
                    shouldDisplayNext = 1;
                }
                [likedArray removeAllObjects];
                for (PFObject* route in objects){
                    
                    RouteObject* newRouteObject = [[RouteObject alloc] init];
                    newRouteObject.pfobj = route;
                    if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                        if ((![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]])) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        }
                    }
                    [self.likedArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                [self fetchGyms];
            }];
            }
            break;
                         
            
            
            
        default:
            break;
    }
    

    
    NSLog(@"Selected Tab Index: %d", tabView.segmentIndex);
    
}

-(void)fetchGyms
{
     NSLog(@"in gym fetch");
    if ([gymFetchArray count]>0) {
        NSLog(@"fetchinng gyms");
        for (PFObject* gymobj in gymFetchArray) {
            if (gymobj.isDataAvailable) {
                NSLog(@"removing redundancy");
                [gymFetchArray removeObject:gymobj];
            }
        }
        [PFObject fetchAllInBackground:gymFetchArray block:^(NSArray *objects, NSError *error) {
            NSLog(@"done fetchinng gyms");
            [gymFetchArray removeAllObjects];
            
            [routeTableView reloadData];
        }];   
    }else{
        
        [routeTableView reloadData];
    }

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

    [self cancelRequests];
    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
    
    
    switch (tabView.segmentIndex) {
        case 0:
            if (indexPath.row==([self.flashArray count])){
                [self lastCellTapped];        
            }else{
                RouteObject* selectedRouteObject = [self.flashArray objectAtIndex:indexPath.row];
                if ([selectedRouteObject.pfobj objectForKey:@"Gym"]) {
                    PFObject* gymObject = [selectedRouteObject.pfobj objectForKey:@"Gym"];
                    [gymObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        viewController.routeObject = [self.flashArray objectAtIndex:indexPath.row];
                        [self.navigationController pushViewController:viewController animated:YES];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }];
                }else{
                    viewController.routeObject = [self.flashArray objectAtIndex:indexPath.row];
                    [self.navigationController pushViewController:viewController animated:YES];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
            
            break;
        case 1:
            if (indexPath.row==([self.sentArray count])){
                [self lastCellTapped];        
            }else{
                RouteObject* selectedRouteObject = [self.sentArray objectAtIndex:indexPath.row];
                if ([selectedRouteObject.pfobj objectForKey:@"Gym"]) {
                    PFObject* gymObject = [selectedRouteObject.pfobj objectForKey:@"Gym"];
                    [gymObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        viewController.routeObject = [self.sentArray objectAtIndex:indexPath.row];
                        [self.navigationController pushViewController:viewController animated:YES];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }];
                }else{
                    viewController.routeObject = [self.sentArray objectAtIndex:indexPath.row];
                    [self.navigationController pushViewController:viewController animated:YES];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
                
                
              
            }
            break;
        case 2:
            if (indexPath.row==([self.projectArray count])){
                [self lastCellTapped];        
            }else{
                RouteObject* selectedRouteObject = [self.projectArray objectAtIndex:indexPath.row];
                if ([selectedRouteObject.pfobj objectForKey:@"Gym"]) {
                    PFObject* gymObject = [selectedRouteObject.pfobj objectForKey:@"Gym"];
                    [gymObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        viewController.routeObject = [self.projectArray objectAtIndex:indexPath.row];
                        [self.navigationController pushViewController:viewController animated:YES];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }];
                }else{
                    viewController.routeObject = [self.projectArray objectAtIndex:indexPath.row];
                    [self.navigationController pushViewController:viewController animated:YES];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
                
            }
            break;
        case 3:
            if (indexPath.row==([self.likedArray count])){
                [self lastCellTapped];        
            }else{
                RouteObject* selectedRouteObject = [self.likedArray objectAtIndex:indexPath.row];
                if ([selectedRouteObject.pfobj objectForKey:@"Gym"]) {
                    PFObject* gymObject = [selectedRouteObject.pfobj objectForKey:@"Gym"];
                    [gymObject fetchInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        viewController.routeObject = [self.likedArray objectAtIndex:indexPath.row];
                        [self.navigationController pushViewController:viewController animated:YES];
                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    }];
                }else{
                    viewController.routeObject = [self.likedArray objectAtIndex:indexPath.row];
                    [self.navigationController pushViewController:viewController animated:YES];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
                
                
            }
            break;
        default:
            
            break;
            
    }
    [viewController release];
    
}
-(void)lastCellTapped
{
    
    PFQuery* query = [PFQuery queryWithClassName:@"Flash"];
    [query whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:20];
    [query setSkip:[self.flashArray count]];
    PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
    [query2 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query2 orderByDescending:@"createdAt"];
    [query2 setLimit:20];
    [query2 setSkip:[self.sentArray count]];
    PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
    [query3 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query3 orderByDescending:@"createdAt"];
    [query3 setLimit:20];
    [query3 setSkip:[self.projectArray count]];
    PFQuery* addedrouteQuery = [PFQuery queryWithClassName:@"Route"];
    [addedrouteQuery whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [addedrouteQuery orderByDescending:@"createdAt"];
    [addedrouteQuery setLimit:20];
    [addedrouteQuery setSkip:[self.likedArray count]];
    switch (tabView.segmentIndex) {
            
            
        case 0:
                [queryArray addObject:query];
                [query findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                    [queryArray removeObject:query];
                    if ([retrievedObjs count]<20) {
                        shouldDisplayNext = 0;
                    }else{
                        shouldDisplayNext = 1;
                    }
                    for (PFObject* flash in retrievedObjs)
                    {
                        RouteObject* newRouteObject = [[RouteObject alloc] init];
                        [[flash objectForKey:@"route"]fetchIfNeeded];
                        newRouteObject.pfobj = [flash objectForKey:@"route"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                        }
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
                    [self fetchGyms];
                }];
            
            break;
        case 1:
            
            
                [queryArray addObject:query2];
                [query2 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                    [queryArray removeObject:query2];
                    if ([retrievedObjs count]<20) {
                        shouldDisplayNext = 0;
                    }else{
                        shouldDisplayNext = 1;
                    }
                    for (PFObject* sent in retrievedObjs)
                    {
                        RouteObject* newRouteObject = [[RouteObject alloc] init];
                        [[sent objectForKey:@"route"]fetchIfNeeded];
                        newRouteObject.pfobj = [sent objectForKey:@"route"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                            
                        }
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
                    [self fetchGyms];
                }];
            
            break;
        case 2:
            
                [queryArray addObject:query3];
                [query3 findObjectsInBackgroundWithBlock:^(NSArray *retrievedObjs, NSError *error){
                    [queryArray removeObject:query3];
                    if ([retrievedObjs count]<20) {
                        shouldDisplayNext = 0;
                    }else{
                        shouldDisplayNext = 1;
                    }
                    for (PFObject* proj in retrievedObjs)
                    {
                        RouteObject* newRouteObject = [[RouteObject alloc] init];
                        [[proj objectForKey:@"route"]fetchIfNeeded];
                        newRouteObject.pfobj = [proj objectForKey:@"route"];
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                        }
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
                    [self fetchGyms];
                }];
            
            break;
        case 3:
            
                [queryArray addObject:addedrouteQuery];
                [addedrouteQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    [queryArray removeObject:addedrouteQuery];
                    if ([objects count]<20) {
                        shouldDisplayNext = 0;
                    }else{
                        shouldDisplayNext = 1;
                    }

                    for (PFObject* route in objects){
                        
                        RouteObject* newRouteObject = [[RouteObject alloc] init];
                        newRouteObject.pfobj = route;
                        if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                            if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                                [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                            }
                        }
                        [self.likedArray addObject:newRouteObject];
                        [newRouteObject release];
                    }
                    [self fetchGyms];
                }];
            
            break;
            
            
            
            
        default:
            break;
    }

    
    
}


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
    PFQuery* query = [PFQuery queryWithClassName:@"Flash"];
    [query whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query orderByDescending:@"createdAt"];
    [query setLimit:[self.flashArray count]];
    PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
    [query2 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query2 orderByDescending:@"createdAt"];
    [query2 setLimit:[self.sentArray count]];
    PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
    [query3 whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [query3 orderByDescending:@"createdAt"];
    [query3 setLimit:[self.projectArray count]];
    PFQuery* addedrouteQuery = [PFQuery queryWithClassName:@"Route"];
    [addedrouteQuery whereKey:@"username" equalTo:[selectedUser objectForKey:@"name"]];
    [addedrouteQuery orderByDescending:@"createdAt"];
    [addedrouteQuery setLimit:[self.likedArray count]];
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
                    if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                        if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        }
                    }
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
                [self fetchGyms];
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
                    if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                        if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        }
                        
                    }
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
                [self fetchGyms];
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
                    if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                        if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        }
                    }
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
                [self fetchGyms];
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
                    if ([[newRouteObject.pfobj objectForKey:@"isPage"]isEqualToNumber:[NSNumber numberWithBool:true]]) {
                        if (![gymFetchArray containsObject:[newRouteObject.pfobj objectForKey:@"Gym"]]) {
                            [gymFetchArray addObject:[newRouteObject.pfobj objectForKey:@"Gym"]];
                        }
                    }
                    [self.likedArray addObject:newRouteObject];
                    [newRouteObject release];
                }
                [self fetchGyms];
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
