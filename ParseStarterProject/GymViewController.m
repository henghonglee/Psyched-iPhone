//
//  GymViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "JMTabView.h"
#import "GymViewController.h"
#import "ASIHTTPRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "SpecialTableCell.h"
#import <Parse/Parse.h>
#import "RouteObject.h"
#import "RouteDetailViewController.h"
@interface GymViewController ()

@end

@implementation GymViewController
@synthesize imageViewContainer;
@synthesize profileshadow;
@synthesize gymName,gymURL,gymObject;
@synthesize gymProfileImageView;
@synthesize routeCountButton;
@synthesize followingCountButton;
@synthesize gymNameLabel;
@synthesize gymCoverImageView;
@synthesize gymTable;
@synthesize headerView;
@synthesize gymMapViewController;
@synthesize gymMapView;
@synthesize routeArray;
@synthesize gymGradeDown;
@synthesize gymGradeUp;
@synthesize gymReccomended;
@synthesize gymLiked;
@synthesize gymCommented;
@synthesize gymTags;
@synthesize gymSections;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)FollowUs:(id)sender {
}
- (IBAction)LikeOurPage:(id)sender {

    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://page/%@",[gymObject objectForKey:@"facebookid"]]]];    

    
}
- (IBAction)routeNumber:(id)sender {
}
- (IBAction)peopleFollowing:(id)sender {
}
-(void)viewWillAppear:(BOOL)animated
{
        self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    gymSections = [[NSMutableDictionary alloc]init ];
    if (gymObject) {
        [self furthurinit];               
    }else{
    PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
    [gymQuery whereKey:@"name" equalTo:gymName];
    [gymQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        gymObject = object;
        
        [self furthurinit];
    
    
    
    
    
    }];
    }
    
    
    
    // Do any additional setup after loading the view from its nib.
}
- (CGPathRef)renderPaperCurl:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 10.0f;
	CGFloat shadowDepth = 5.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.0f, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
	[path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
			controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
			controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
	return path.CGPath;
}
-(void)furthurinit
{
    
    imageViewContainer.layer.borderColor = [UIColor whiteColor].CGColor;    
    imageViewContainer.layer.borderWidth = 3;
   
    profileshadow.layer.shadowRadius=2;
    profileshadow.layer.shadowOpacity = 0.3;
    profileshadow.layer.shadowColor = [UIColor blackColor].CGColor;
    profileshadow.layer.shadowOffset = CGSizeMake(0, 2);
    
    profileshadow.layer.shadowPath = [self renderPaperCurl:profileshadow];
   
    
    gymNameLabel.text = [NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]];
    gymMapView.layer.borderColor = [UIColor whiteColor].CGColor;
    gymMapView.layer.borderWidth = 3;
    PFGeoPoint* gymgeopoint = ((PFGeoPoint*)[gymObject objectForKey:@"gymlocation"]);
    
    CLLocationCoordinate2D gymLoc = CLLocationCoordinate2DMake(gymgeopoint.latitude,gymgeopoint.longitude);
    [gymMapView setCenterCoordinate:gymLoc zoomLevel:14 animated:NO];
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]];
    
    
    ASIHTTPRequest* coverrequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[gymObject objectForKey:@"coverimagelink"]] ];
    [coverrequest setCompletionBlock:^{
        gymCoverImageView.image = [UIImage imageWithData:[coverrequest responseData]];
        
        [gymTable reloadData];
    }];
    [coverrequest setFailedBlock:^{}];
    [coverrequest startAsynchronous];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[gymObject objectForKey:@"imagelink"]] ];
    [request setCompletionBlock:^{
        
        gymProfileImageView.image = [UIImage imageWithData:[request responseData]];
        NSLog(@"size ht = %f",gymProfileImageView.image.size.height);
        NSLog(@"size wd = %f",gymProfileImageView.image.size.width);
        if (gymProfileImageView.image.size.height>=gymProfileImageView.image.size.width) {
        [gymProfileImageView setFrame:CGRectMake(0, 0, 75, gymProfileImageView.image.size.height/(gymProfileImageView.image.size.width/75))];
        }
        [gymTable reloadData];
    }];
    [request setFailedBlock:^{}];
    [request startAsynchronous];
    [gymTable reloadData];
    PFQuery* queryRoute = [PFQuery queryWithClassName:@"Route"];
    [queryRoute whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [queryRoute whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:1.];
    [queryRoute orderByAscending:@"difficulty"];
    // [queryRoute setLimit:20];
    [queryRoute findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"objects = %@",objects);
        //prepare arrays
        for (NSString* key in [self.gymSections allKeys]) {
            [[self.gymSections objectForKey:key] removeAllObjects];
        }
        for (PFObject* object in objects) {
            NSString* sectionToInsert =  [object objectForKey:@"hashtag"];
            BOOL found = NO;
            for (NSString *str in [self.gymSections allKeys])
            {
                if ([str isEqualToString:sectionToInsert])
                {
                    found = YES;
                }
            }
            if (!found && sectionToInsert!=NULL)
            {
                
                [self.gymSections setValue:[[[NSMutableArray alloc] init]autorelease] forKey:sectionToInsert];
            }
        }
        
        for (PFObject* object in objects) {
            if ([object objectForKey:@"hashtag"]) {
                
                RouteObject* route = [[RouteObject alloc]init];
                route.pfobj = object;
                
                [[self.gymSections objectForKey:[object objectForKey:@"hashtag"]] addObject:route];
                [route release];
            }
        }
        
        [self.gymTags addObjectsFromArray:[self.gymSections allKeys]];
        [self.gymTags sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        //    NSLog(@"self.gymsections all keys = %@",self.gymTags);
        [gymTable reloadData];
    }];
    [self addStandardTabView];
    tabView.contentSize = CGSizeMake(320, 44);
    tabView.showsHorizontalScrollIndicator = NO;

    gymGradeDown = [[NSMutableArray alloc]init];
    gymGradeUp = [[NSMutableArray alloc]init];
    gymReccomended = [[NSMutableArray alloc]init];
    gymTags = [[NSMutableArray alloc]init];
    gymLiked = [[NSMutableArray alloc]init];
    routeArray = [[NSMutableArray alloc]init];
    
    gymCommented = [[NSMutableArray alloc]init];
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tabView.segmentIndex==3) {
    
         return [self.gymTags count]+2;
    }
    return 2;

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   // NSLog(@"size = %f",(gymCoverImageView.image.size.height/(gymCoverImageView.image.size.width/320.0)));
   // return (gymCoverImageView.image.size.height/(gymCoverImageView.image.size.width/320.0));
        
    if(section==0)
        return 184;
    if(section==1)
    return 44;
    
    return 34;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section>1) {
    NSString* selectedsection = [[self.gymTags objectAtIndex:section-2] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        return selectedsection;
    }else{
        return nil;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0){
        return 84;
    }
    if(indexPath.section==1){
       return 120;
    }
        return 120;        
    

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    if (section==1) {
switch (tabView.segmentIndex) {
    case 0:
            return [routeArray count];
            break;
        case 1:
              return [gymGradeUp count];
            break;
        case 2:
            return [gymGradeDown count];
            break;    
        case 3:
            return 0;
            break;    
        case 4:
            return [gymLiked count];
            break;   
        case 5:
            return [gymCommented count];
            break;   
        default:
            return 0;
            break;
        }
    }else{
               NSString* selectedsection = [self.gymTags objectAtIndex:section-2];
        NSLog(@"number of rows in section %d = %d",section,[[self.gymSections valueForKey:selectedsection] count]);

        return [[self.gymSections valueForKey:selectedsection] count];
    }
  
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
   
        return [[UIView new] autorelease];
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
if (tabView.segmentIndex==3) {
    if (section==1){

            if ([self.gymTags count]==0) {
            return 323;
            }else{
                return 0;
            }
        }
        
    }
    
    if(section==1){
    switch (tabView.segmentIndex) {
        case 0:
             if([routeArray count]==0)
                return 323;
            break;
        case 1:
            if([gymGradeUp count]==0)
                return 323;
            break;
        case 2:
            if([gymGradeDown count]==0)
                return 323;
            break;    
        case 3:
            if([gymReccomended count]==0)
                return 323;
            break;    
        case 4:
            if([gymLiked count]==0)
                return 323;
            break;   
        case 5:
            if([gymCommented count]==0)
                return 323;
            break;   
        default:
            return 0;
            break;
    }
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{


    if (section==0) {
    return headerView;        
    }
    
    if (section==1) {
        return tabView;
    }
    
    UIView* sectionHeaderView= [[[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 34)]autorelease];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    sectionHeaderView.alpha = 0.9;
    UILabel* userLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 34)];
    NSString* selectedsection = [[self.gymTags objectAtIndex:section-2] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
    userLabel.textAlignment = UITextAlignmentCenter;
    userLabel.text = selectedsection;
    userLabel.textColor = [UIColor colorWithRed:70.0/255.0 green:130.0/255.0 blue:180.0/255.0 alpha:1.0];
    userLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0f];
    userLabel.backgroundColor = [UIColor clearColor];
    
    [sectionHeaderView addSubview:userLabel];
    //[headerView addSubview:profileImageView];
   // [sectionHeaderView release];
    [userLabel release];
    return sectionHeaderView;
    

}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        static NSString *FromCellIdentifier = @"DetailCell";
        GymDetailCell* cell = (GymDetailCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
        if (cell == nil) {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"GymDetailCell" owner:nil options:nil];
            for(id currentObject in topLevelObjects){
                if([currentObject isKindOfClass:[UITableViewCell class]]){
                    cell = (GymDetailCell*)currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
            }
        }
        cell.owner = self;
        cell.pfObject = gymObject;
        
        PFGeoPoint* geopoint = [gymObject objectForKey:@"gymlocation"];
        CLLocationCoordinate2D gymloc = CLLocationCoordinate2DMake(geopoint.latitude, geopoint.longitude);
        [cell.gymMapView setCenterCoordinate:gymloc zoomLevel:14 animated:NO];
        cell.gymMapView.layer.borderColor = [UIColor lightGrayColor].CGColor;    
        cell.gymMapView.layer.borderWidth = 3;
        
        
        return  cell;    
    }else{
        
    static NSString *FromCellIdentifier = @"FromCell";
    SpecialTableCell* cell = (SpecialTableCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SpecialTableCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (SpecialTableCell*)currentObject;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
        }
    }
    
        switch (tabView.segmentIndex) {
            case 0:
                if ([self.routeArray count]>0) {
                    PFObject* pfobject = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).pfobj;
             //       NSLog(@"showing flash array");
                    cell.commentcount.text = [NSString stringWithFormat:@"%@",[[pfobject objectForKey:@"commentcount"]stringValue]];
                    cell.likecount.text = [NSString stringWithFormat:@"%@",[[pfobject objectForKey:@"likecount"]stringValue ]];
                    cell.viewcount.text = [NSString stringWithFormat:@"%@",[[pfobject objectForKey:@"viewcount"]stringValue ]];
                    cell.routeLocationLabel.text = [pfobject objectForKey:@"location"];
                    
                    __block NSString* imagelink;
                    
                    if ([pfobject objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                        
                        
                            imagelink=[gymObject objectForKey:@"imagelink"];  
                            cell.ownerNameLabel.text = [gymObject objectForKey:@"name"]; 
                            if (((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage) {
                                cell.ownerImage.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage;
                            }else{
                                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                                [request setCompletionBlock:^{
                                    UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                    if (ownerImage == nil) {
                                        ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                    }
                                    cell.ownerImage.image = ownerImage;
                                    ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                        
                        
                    }else{
                        imagelink = [pfobject objectForKey:@"userimage"];
                        cell.ownerNameLabel.text = [pfobject objectForKey:@"username"];
                    
                    if (((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage) {
                        cell.ownerImage.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage;
                    }else{
                        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                        [request setCompletionBlock:^{
                            UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                            if (ownerImage == nil) {
                                ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                            }
                            cell.ownerImage.image = ownerImage;
                            ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                    }
                    if (!((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage) {
                        
                        PFFile *imagefile = [pfobject objectForKey:@"thumbImageFile"];
                        [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                            UIImage* retrievedImage = [UIImage imageWithData:imageData];
                            
                            ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
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
                        cell.routeImageView.image = ((RouteObject*)[self.routeArray objectAtIndex:indexPath.row]).retrievedImage;
                        cell.routeImageView.layer.masksToBounds = YES;
                        cell.routeImageView.layer.cornerRadius = 5.0f;
                        cell.imageBackgroundView.layer.shadowPath =[UIBezierPath bezierPathWithRect:cell.routeImageView.bounds].CGPath;
                        cell.imageBackgroundView.layer.shadowColor = [UIColor blackColor].CGColor;
                        cell.imageBackgroundView.layer.shadowOpacity = 0.7f;
                        cell.imageBackgroundView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
                        cell.imageBackgroundView.layer.shadowRadius = 3.0f;
                        cell.imageBackgroundView.layer.cornerRadius = 5.0f;
                    }
                    double timesincenow =  [((NSDate*)pfobject.createdAt) timeIntervalSinceNow];
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
                    
                    cell.todoTextLabel.text = [pfobject objectForKey:@"description"];
                    cell.difficultyLabel.text = [pfobject objectForKey:@"difficultydescription"];
                    
                }
                break;
            case 1:
                if ([self.gymGradeUp count]>0) {
                    PFObject* object = ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).pfobj;
                cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                cell.routeLocationLabel.text = [object objectForKey:@"location"];
                
                    __block NSString* imagelink;
                    
                    if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                        
                        
                            imagelink=[gymObject objectForKey:@"imagelink"];  
                            cell.ownerNameLabel.text = [gymObject objectForKey:@"name"];
                            if (((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).ownerImage) {
                                cell.ownerImage.image = ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).ownerImage;
                            }else{
                                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                                [request setCompletionBlock:^{
                                    UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                    if (ownerImage == nil) {
                                        ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                    }
                                    cell.ownerImage.image = ownerImage;
                                    ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                        
                        
                    }else{
                        imagelink = [object objectForKey:@"userimage"];
                        cell.ownerNameLabel.text = [object objectForKey:@"username"];
                    
                
                if (((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).ownerImage) {
                    cell.ownerImage.image = ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).ownerImage;
                }else{
                    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                    [request setCompletionBlock:^{
                        UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                        if (ownerImage == nil) {
                            ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                        }
                        cell.ownerImage.image = ownerImage;
                        ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                    }
                if (!((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).retrievedImage) {
                    
                    PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                        UIImage* retrievedImage = [UIImage imageWithData:imageData];
                        
                        ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
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
                    cell.routeImageView.image = ((RouteObject*)[self.gymGradeUp objectAtIndex:indexPath.row]).retrievedImage;
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
                
        }
                break;
            case 2:
                if ([self.gymGradeDown count]>0) {
                    PFObject* object = ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).pfobj;
                    cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                    cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                    cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                    cell.routeLocationLabel.text = [object objectForKey:@"location"];
                    
                    __block NSString* imagelink;
                    
                    if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                        
                       
                            imagelink=[gymObject objectForKey:@"imagelink"];  
                            cell.ownerNameLabel.text = [gymObject objectForKey:@"name"]; 
                            if (((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).ownerImage) {
                                cell.ownerImage.image = ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).ownerImage;
                            }else{
                                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                                [request setCompletionBlock:^{
                                    UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                    if (ownerImage == nil) {
                                        ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                    }
                                    cell.ownerImage.image = ownerImage;
                                    ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                            
                        
                    }else{
                        imagelink = [object objectForKey:@"userimage"];
                        cell.ownerNameLabel.text = [object objectForKey:@"username"];
                    
                    
                    if (((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).ownerImage) {
                        cell.ownerImage.image = ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).ownerImage;
                    }else{
                        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                        [request setCompletionBlock:^{
                            UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                            if (ownerImage == nil) {
                                ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                            } 
                            cell.ownerImage.image = ownerImage;
                            ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                    }
                    if (!((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).retrievedImage) {
                        
                        PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                        [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                            UIImage* retrievedImage = [UIImage imageWithData:imageData];
                            
                            ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
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
                        cell.routeImageView.image = ((RouteObject*)[self.gymGradeDown objectAtIndex:indexPath.row]).retrievedImage;
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
                   
                }
                break;
            case 3:
            //      NSLog(@"cellforrow");
              //  self.gymTags = [self.gymSections valueForKey:[[self.gymSections allKeys]objectAtIndex:indexPath.section-2]];
              
                if ([[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] count]>0) {
                    PFObject* object = ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).pfobj;
                //    NSLog(@"showing flash array");
                    cell.commentcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"commentcount"]stringValue]];
                    cell.likecount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"likecount"]stringValue ]];
                    cell.viewcount.text = [NSString stringWithFormat:@"%@",[[object objectForKey:@"viewcount"]stringValue ]];
                    cell.routeLocationLabel.text = [object objectForKey:@"location"];
                    
                    __block NSString* imagelink;
                    
                    if ([object objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
                       
                            imagelink=[gymObject objectForKey:@"imagelink"];  
                            cell.ownerNameLabel.text = [gymObject objectForKey:@"name"];
                            if (((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).ownerImage) {
                                cell.ownerImage.image = ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).ownerImage;
                            }else{
                                ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                                [request setCompletionBlock:^{
                                    UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                    if (ownerImage == nil) {
                                        ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                    }
                                    cell.ownerImage.image = ownerImage;
                                    ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                    
                        
                    }else{
                        imagelink = [object objectForKey:@"userimage"];
                        cell.ownerNameLabel.text = [object objectForKey:@"username"];
                        
                        
                        if (((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).ownerImage) {
                            cell.ownerImage.image = ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).ownerImage;
                        }else{
                            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
                            [request setCompletionBlock:^{
                                UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                                if (ownerImage == nil) {
                                    ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                                } 
                                cell.ownerImage.image = ownerImage;
                                ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).ownerImage= ownerImage;
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
                    }
                    if (!((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).retrievedImage) {
                        
                        PFFile *imagefile = [object objectForKey:@"thumbImageFile"];
                        [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
                            UIImage* retrievedImage = [UIImage imageWithData:imageData];
                            
                            ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).retrievedImage = retrievedImage;
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
                        cell.routeImageView.image = ((RouteObject*)[[self.gymSections valueForKey:[self.gymTags objectAtIndex:indexPath.section-2]] objectAtIndex:indexPath.row]).retrievedImage;
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
                    
                }
                break;
            
            default:
                break;
        }
    
    return  cell;   
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"indexrow =%d",indexPath.row);
    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
              
    switch (tabView.segmentIndex) {
        case 0:
            viewController.routeObject = [self.routeArray objectAtIndex:indexPath.row];
            
            break;
        case 1:
            viewController.routeObject = [self.gymGradeUp objectAtIndex:indexPath.row];
            break;
        case 2:
            viewController.routeObject = [self.gymGradeDown objectAtIndex:indexPath.row];
            break;
        case 3:
            NSLog(@"test");
            NSString* selectedSection = [self.gymTags  objectAtIndex:indexPath.section-2];
            NSMutableArray* selectedArray = [self.gymSections valueForKey:selectedSection]; 
            viewController.routeObject = [selectedArray objectAtIndex:indexPath.row];
            break;
        case 4:
            viewController.routeObject = [self.gymLiked objectAtIndex:indexPath.row];
            break;
        case 5:
            viewController.routeObject = [self.gymCommented objectAtIndex:indexPath.row];
            break;
        default:
            
            break;
            
    }
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

-(void)addStandardTabView
{
    tabView = [[JMTabView alloc] initWithFrame:CGRectMake(0, 0, 320, 44.)] ;
    
    [tabView setDelegate:self];
    
    [tabView addTabItemWithTitle:@"Newest!" icon:[UIImage imageNamed:@"icon1.png"]];
    [tabView addTabItemWithTitle:@"Hardest" icon:[UIImage imageNamed:@"project_white.png"]];
    [tabView addTabItemWithTitle:@"Easiest" icon:[UIImage imageNamed:@"flash_white.png"]];
    [tabView addTabItemWithTitle:@"Hashtags" icon:[UIImage imageNamed:@"project_white.png"]];
    [tabView setSelectedIndex:0];
    [self tabView:tabView didSelectTabAtIndex:0];
    
    
}
-(void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)itemIndex
{
    [gymTable reloadData];
    PFQuery* queryRoute = [PFQuery queryWithClassName:@"Route"];
    switch (itemIndex) {
        case 0:
            [queryRoute whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
            [queryRoute whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:1.];
            [queryRoute orderByDescending:@"createdAt"];
            [queryRoute findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"objects = %@",objects);
                for (PFObject* object in objects) {
                    RouteObject* route = [[RouteObject alloc]init];
                    route.pfobj = object;
                    BOOL isadded =NO;
                    for (RouteObject* obj in routeArray){
                        if ([obj.pfobj.objectId isEqualToString:route.pfobj.objectId]) {
                            isadded = YES;
                        }
                    }
                    if (!isadded) {
                        [self.routeArray addObject:route];
                    }
                    [route release];
                }
                
                [gymTable reloadData];
            }];

            break;
            
        case 3:
            [queryRoute whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
            [queryRoute whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:1.];
            [queryRoute whereKeyExists:@"hashtag"];
            [queryRoute findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSMutableArray *hashtags = [NSMutableArray array];
                
                for (PFObject* object in objects) {
                    if (![hashtags containsObject:[object objectForKey:@"hashtag"]]) {
                        [hashtags addObject:[object objectForKey:@"hashtag"]];
                    }
                }
            }];
            
            break;
        case 2:
            [queryRoute whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
            [queryRoute whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:1.];
            [queryRoute orderByAscending:@"difficulty"];
            [queryRoute findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"objects = %@",objects);
                for (PFObject* object in objects) {
                    RouteObject* route = [[RouteObject alloc]init];
                    route.pfobj = object;
                    BOOL isadded =NO;
                    for (RouteObject* obj in gymGradeDown){
                        if ([obj.pfobj.objectId isEqualToString:route.pfobj.objectId]) {
                            isadded = YES;
                        }
                    }
                    if (!isadded) {
                        [self.gymGradeDown addObject:route];
                    }
                    [route release];
                }
                
                [gymTable reloadData];
            }];

            break;
        case 1:
            [queryRoute whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
            [queryRoute whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:1.];
            [queryRoute orderByDescending:@"difficulty"];
           // [queryRoute setLimit:20];
            [queryRoute findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                NSLog(@"objects = %@",objects);
                for (PFObject* object in objects) {
                    RouteObject* route = [[RouteObject alloc]init];
                    route.pfobj = object;
                    BOOL isadded =NO;
                    for (RouteObject* obj in gymGradeUp){
                        if ([obj.pfobj.objectId isEqualToString:route.pfobj.objectId]) {
                            isadded = YES;
                        }
                    }
                    if (!isadded) {
                        [self.gymGradeUp addObject:route];
                    }
                    [route release];
                }
                
                [gymTable reloadData];
            }];
            break;
        default:
            break;
    }
    }

- (void)viewDidUnload
{
    [self setGymProfileImageView:nil];
    [self setRouteCountButton:nil];
    [self setFollowingCountButton:nil];
    [self setGymNameLabel:nil];
    [self setGymCoverImageView:nil];
    [self setGymTable:nil];
    [self setHeaderView:nil];
    [self setGymMapViewController:nil];
    [self setGymMapView:nil];
    [self setProfileshadow:nil];
    [self setImageViewContainer:nil];
    [self setGymGradeUp:nil];
    [self setGymGradeDown:nil];
    [self setGymReccomended:nil];
    [self setGymLiked:nil];
    [self setGymCommented:nil];
    [self setGymTags:nil];
    [self setRouteArray:nil];
    [self setGymSections:nil];
    [self setGymURL:nil];
    [self setGymObject:nil];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [gymProfileImageView release];
    [routeCountButton release];
    [followingCountButton release];
    [gymNameLabel release];
    [gymCoverImageView release];
    [gymTable release];
    [headerView release];
    [gymMapViewController release];
    [gymMapView release];
    [profileshadow release];
    [imageViewContainer release];
    [super dealloc];
}
@end
