//
//  RouteDetailViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "ProfileViewController.h"
#import "RouteDetailViewController.h"
#import "CommentsCell.h"
#import "ASIHTTPRequest.h"
#import "MKMapView+ZoomLevel.h"
#import <QuartzCore/QuartzCore.h>
@implementation RouteDetailViewController
@synthesize topView;
@synthesize btmView;
@synthesize mapContainer;
@synthesize difficultyLabel;
@synthesize routeMapView;
@synthesize progressBar;
@synthesize routeLocationLabel;
@synthesize pinImageView;
@synthesize unavailableLabel;
@synthesize routeImageView;
@synthesize UserImageView;
@synthesize usernameLabel;
@synthesize descriptionLabel;
@synthesize commentsTable;
@synthesize routeObject;
@synthesize commentTextField;
@synthesize descriptionTextView;
@synthesize likeButton;
@synthesize flashbutton;
@synthesize sentbutton;
@synthesize projbutton;
@synthesize scrollView;
@synthesize flashCountLabel;
@synthesize sendCountLabel;
@synthesize projectCountLabel;
@synthesize likeCountLabel;
@synthesize queryArray;
@synthesize savedArray;
@synthesize commentsArray;
@synthesize viewCountLabel;
@synthesize scroll;
@synthesize commentCountLabel;
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
    commentsArray = [[NSMutableArray alloc]init];
    queryArray = [[NSMutableArray alloc]init];
    savedArray = [[NSMutableArray alloc]init];
    unavailableLabel.frame = CGRectMake(0, 0, 307,111 );
    [unavailableLabel setFont:[UIFont fontWithName:@"Old Stamper" size:20.0]];
    unavailableLabel.textColor = [UIColor redColor];
    [likeButton setUserInteractionEnabled:NO];
    difficultyLabel.text = [routeObject.pfobj objectForKey:@"difficultydescription"];
    NSString *foo = [routeObject.pfobj objectForKey:@"description"];
    CGSize size = [foo sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]
                  constrainedToSize:CGSizeMake(229, 2000)
                      lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"size = %@",NSStringFromCGSize(size));
    descriptionTextView.frame = CGRectMake(-1, 50, 229, MAX(41,size.height+20));
    descriptionTextView.text = foo;
    commentCountLabel.text = [NSString stringWithFormat:@"%@",[[routeObject.pfobj objectForKey:@"commentcount"]stringValue]];
    likeCountLabel.text = [NSString stringWithFormat:@"%@ likes",[[routeObject.pfobj objectForKey:@"likecount"]stringValue]];
    viewCountLabel.text = [NSString stringWithFormat:@"%@ views",[[routeObject.pfobj objectForKey:@"viewcount"]stringValue]];
    NSLog(@"location = %f,%f",((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).latitude,((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).longitude);
    if (!(((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).latitude ==0.0f &&((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).longitude ==0.0f )) {
    CLLocationCoordinate2D routeLoc = CLLocationCoordinate2DMake(((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).latitude, ((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).longitude);
    [routeMapView setCenterCoordinate:routeLoc zoomLevel:14 animated:NO];
        unavailableLabel.hidden=YES;
        pinImageView.hidden=NO;
    }else{
        unavailableLabel.hidden=NO;
        pinImageView.hidden=YES;
    }
    UserImageView.layer.shadowPath = [self renderPaperCurlProfileImage:UserImageView];
    
    UserImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    UserImageView.layer.borderWidth = 2;
    UserImageView.layer.shadowOpacity = 0.5;
    UserImageView.layer.shadowRadius = 1;
    UserImageView.layer.shadowOffset = CGSizeMake(1,2);
    UserImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    viewCountLabel.text = [NSString stringWithFormat:@"%d views",[[routeObject.pfobj objectForKey:@"viewcount"] intValue]+1];
    [routeObject.pfobj setObject:[NSNumber numberWithInt:[viewCountLabel.text intValue]] forKey:@"viewcount"];
    [routeObject.pfobj saveEventually];
    routeImageView.image = routeObject.retrievedImage;
    routeLocationLabel.text = [routeObject.pfobj objectForKey:@"location"]; 
    NSLog(@"getting image if available..");
    [self getImageIfUnavailable];
    NSLog(@"done getting image");
    //scroll.contentSize = CGSizeMake(320, 566);
    self.navigationController.navigationBarHidden = NO;
    NSLog(@"checking like sendstatus");

    [self checksendstatus];
    [self checkCommunitySendStatus];
    NSLog(@"done checking sendstatus and likes");
    usernameLabel.text= [routeObject.pfobj objectForKey:@"username"];
  
    UserImageView.image = routeObject.ownerImage;
    [self arrangeSubViewsaftercomments];
   
      if ([routeObject.pfobj objectForKey:@"photoid"]) {   
          NSLog(@"getting fb route detail");
         [self getFacebookRouteDetails];
      }else{
                 [self checkLikedWithoutFacebook];
          NSLog(@"getting comments");
          PFQuery* query = [PFQuery queryWithClassName:@"Comment"];
                  query.cachePolicy = kPFCachePolicyNetworkElseCache;
          [query whereKey:@"route" equalTo:routeObject.pfobj];
          [query orderByDescending:@"createdAt"];
          [queryArray addObject:query];
          [query findObjectsInBackgroundWithBlock:^(NSArray* fetchedComments,NSError*error){
              NSLog(@"got comments");
              [queryArray removeObject:query];
              [commentsArray addObjectsFromArray:fetchedComments];
              [commentsTable removeFromSuperview];
               [self arrangeSubViewsaftercomments];
             }];
      }
   
  
    
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)didDoubleTap:(UITapGestureRecognizer*)sender {
    
    if(scrollView.zoomScale > 1.0){ 
    
        [scrollView setZoomScale:1 animated:YES]; 
    }else { 
           
        [scrollView setZoomScale:scrollView.maximumZoomScale animated:YES]; 
    }
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
- (CGPathRef)renderPaperCurlProfileImage:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 5.0f;
	CGFloat shadowDepth = 2.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.0f, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
	[path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
			controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
			controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
	return path.CGPath;
}
-(void)arrangeSubViewsaftercomments
{
    NSString *foo = [routeObject.pfobj objectForKey:@"description"];
    CGSize size = [foo sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]
                  constrainedToSize:CGSizeMake(229, 2000)
                      lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"size = %@",NSStringFromCGSize(size));
    topView.frame = CGRectMake(6,330,307,50+MAX(41,size.height+20));
    
    topView.layer.shadowPath = [self renderPaperCurl:topView];
    topView.layer.shadowOpacity = 0.6;
    
    
    //topView.layer.shadowRadius = 2;
    topView.layer.shadowOffset = CGSizeMake(3, 4);
    topView.layer.shadowColor = [UIColor blackColor].CGColor;
    scroll.contentSize = CGSizeMake(320, 2000);
    
    
    mapContainer.frame = CGRectMake(6, 330+20+50+MAX(41,size.height+20), 307, 111);
    mapContainer.layer.borderWidth = 3;
    mapContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    mapContainer.layer.shadowPath = [self renderPaperCurl:mapContainer];
    mapContainer.layer.shadowOpacity = 0.6;
    mapContainer.layer.shadowOffset = CGSizeMake(3, 4);
    mapContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    routeMapView.frame = CGRectMake(0, 0, 307, 111);
    btmView.frame = CGRectMake(6, 330+topView.frame.size.height+20, 307,140);
    
    [commentsTable reloadData];
    [commentsTable layoutIfNeeded];
    NSLog(@"content height =%f",[commentsTable contentSize].height);
    commentsTable.frame = CGRectMake(0, 140, 307, [commentsTable contentSize].height);
    NSLog(@"comments frame = %@",NSStringFromCGRect(commentsTable.frame));
    btmView.frame = CGRectMake(6, 330+topView.frame.size.height+20+111+20, 307, 140+[commentsTable contentSize].height+20);
    [btmView addSubview:commentsTable];
    
    btmView.layer.shadowPath = [self renderPaperCurl:btmView];
    
    btmView.layer.shadowOpacity = 0.8;
    btmView.layer.shadowOffset = CGSizeMake(3, 4);
    btmView.layer.shadowColor = [UIColor blackColor].CGColor;
    scroll.contentSize = CGSizeMake(320, 320+20+topView.frame.size.height+20+btmView.frame.size.height+20+111+20);
    NSLog(@"comments frame = %@",NSStringFromCGRect(commentsTable.frame));  
}
-(void)checkCommunitySendStatus
{
    PFQuery* FlashQuery = [PFQuery queryWithClassName:@"Flash"];
    [FlashQuery whereKey:@"route" equalTo:routeObject.pfobj];
    [queryArray addObject:FlashQuery];
    [FlashQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [queryArray removeObject:FlashQuery];
        flashCountLabel.text = [NSString stringWithFormat:@"%d",number];
    }];
    PFQuery* SendQuery = [PFQuery queryWithClassName:@"Sent"];
    [SendQuery whereKey:@"route" equalTo:routeObject.pfobj];
    [queryArray addObject:SendQuery];
    [SendQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [queryArray removeObject:SendQuery];
        sendCountLabel.text = [NSString stringWithFormat:@"%d",number];
    }];
    PFQuery* ProjQuery = [PFQuery queryWithClassName:@"Project"];
    [ProjQuery whereKey:@"route" equalTo:routeObject.pfobj];
    [queryArray addObject:ProjQuery];
    [ProjQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [queryArray removeObject:ProjQuery];
        projectCountLabel.text = [NSString stringWithFormat:@"%d",number];
    }];
    
}
-(void)checkLikedWithoutFacebook
{
    PFQuery* likequery = [PFQuery queryWithClassName:@"Like"];
   // [likequery whereKey:@"owner" equalTo:[[PFUser currentUser] objectForKey:@"name"]];
    [likequery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
    [likequery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        BOOL liked=NO;
        if ([objects count]) {
            for (PFObject* likeobj in objects) {
                    
                
                if([[likeobj objectForKey:@"owner"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]){
                    liked=YES;
                    [likeButton setImage:[UIImage imageNamed:@"heartcolor.png"] forState:UIControlStateNormal];
                }
                
                
            }
            if (!liked) {
                [likeButton setImage:[UIImage imageNamed:@"popularbutton.png"] forState:UIControlStateNormal];
            }
            likeCountLabel.text = [NSString stringWithFormat:@"%d likes",[objects count]];

        }
                  [likeButton setUserInteractionEnabled:YES];  
    }];
}
-(void)checksendstatus
{
    PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
            query1.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
    [query1 whereKey:@"route" equalTo:routeObject.pfobj];
    [queryArray addObject:query1];
    [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray* fetchedFlash = [NSArray arrayWithArray:objects];
        [queryArray removeObject:query1];
        if ([fetchedFlash count]>0){
            [flashbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
        }else{
            [flashbutton setImage:nil forState:UIControlStateNormal];
        }
    }];
    
    
    
    PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
            query2.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query2 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
    [query2 whereKey:@"route" equalTo:routeObject.pfobj];
    [queryArray addObject:query2];
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray* fetchedSent = [NSArray arrayWithArray:objects];
        [queryArray removeObject:query2];
        if ([fetchedSent count]>0){
            [sentbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
        }else{
            [sentbutton setImage:nil forState:UIControlStateNormal];
        }
    }];
    
    
    
    PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
            query3.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query3 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
    [query3 whereKey:@"route" equalTo:routeObject.pfobj];
    [queryArray addObject:query3];
    [query3 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray* fetchedProject = [NSArray arrayWithArray:objects];
        [queryArray removeObject:query3];
        if ([fetchedProject count]>0){
            [projbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
        }else{
            [projbutton setImage:nil forState:UIControlStateNormal];
        }

    }];
    }


- (IBAction)flashsentproj:(UIButton*)sender {
    [flashbutton setUserInteractionEnabled:NO];
    [sentbutton setUserInteractionEnabled:NO];
    [projbutton setUserInteractionEnabled:NO];
    if (sender.tag==0) {
        
        PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
                query1.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query1 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query1];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedFlash = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query1];
            if ([fetchedFlash count]>0){
                [((PFObject*)[fetchedFlash objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [flashbutton setImage:nil forState:UIControlStateNormal];
                        flashCountLabel.text = [NSString stringWithFormat:@"%d",[flashCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                   
                }];
            }else{
                PFObject* newFlash = [PFObject objectWithClassName:@"Flash"];
                [newFlash setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
                [newFlash setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
                [newFlash setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
                [newFlash setObject:[PFUser currentUser] forKey:@"user"];
                [newFlash setObject:routeObject.pfobj forKey:@"route"];
                
                [newFlash saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                    [flashbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
                    flashCountLabel.text = [NSString stringWithFormat:@"%d",[flashCountLabel.text intValue]+1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }
            
        }];
        
        PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
                query2.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query2 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query2 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query2];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedSent = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query2];
            if ([fetchedSent count]>0){
                [((PFObject*)[fetchedSent objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                    [sentbutton setImage:nil forState:UIControlStateNormal];
                    sendCountLabel.text = [NSString stringWithFormat:@"%d",[sendCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }  
        }];   
        
        PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
                query3.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query3 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query3 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query3];
        [query3 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedProject = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query3];
                if ([fetchedProject count]>0){
                    [((PFObject*)[fetchedProject objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                        [projbutton setImage:nil forState:UIControlStateNormal];
                        projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]-1];
                            [flashbutton setUserInteractionEnabled:YES];
                            [sentbutton setUserInteractionEnabled:YES];
                            [projbutton setUserInteractionEnabled:YES];
                        }
                    }];
            }
         }];
        
    }else if(sender.tag==1){
        
        PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
                query1.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query1 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query1];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedFlash = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query1];
            if ([fetchedFlash count]>0){
                [((PFObject*)[fetchedFlash objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                   [flashbutton setImage:nil forState:UIControlStateNormal];
                    flashCountLabel.text = [NSString stringWithFormat:@"%d",[flashCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }
        }];
        
        PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
                query2.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query2 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query2 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query2];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSArray* fetchedSent = objects;
            [queryArray removeObject:query2];
        if ([fetchedSent count]>0){
            [((PFObject*)[fetchedSent objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
               [sentbutton setImage:nil forState:UIControlStateNormal];
                sendCountLabel.text = [NSString stringWithFormat:@"%d",[sendCountLabel.text intValue]-1];
                    [flashbutton setUserInteractionEnabled:YES];
                    [sentbutton setUserInteractionEnabled:YES];
                    [projbutton setUserInteractionEnabled:YES];
                }
            }];
        }else{
            PFObject* newSent = [PFObject objectWithClassName:@"Sent"];
            [newSent setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
            [newSent setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
            [newSent setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
            [newSent setObject:routeObject.pfobj forKey:@"route"];
            [newSent setObject:[PFUser currentUser] forKey:@"user"];

            [newSent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                [sentbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
                sendCountLabel.text = [NSString stringWithFormat:@"%d",[sendCountLabel.text intValue]+1];
                    [flashbutton setUserInteractionEnabled:YES];
                    [sentbutton setUserInteractionEnabled:YES];
                    [projbutton setUserInteractionEnabled:YES];
                }
            }];

        }
        }];
        
        
        PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
                query3.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query3 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query3 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query3];
        [query3 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [queryArray removeObject:query3];
        NSArray* fetchedProject = objects;
        if ([fetchedProject count]>0){
            [((PFObject*)[fetchedProject objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                [projbutton setImage:nil forState:UIControlStateNormal];
                projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]-1];
                    [flashbutton setUserInteractionEnabled:YES];
                    [sentbutton setUserInteractionEnabled:YES];
                    [projbutton setUserInteractionEnabled:YES];
                }
            }];
        }
        }];
       
    }else if(sender.tag == 2){
        PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
        query1.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query1 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query1];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedFlash = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query1];
            if ([fetchedFlash count]>0){
                [((PFObject*)[fetchedFlash objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                    [flashbutton setImage:nil forState:UIControlStateNormal];
                    flashCountLabel.text = [NSString stringWithFormat:@"%d",[flashCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }
        }];
          
        PFQuery* query2 = [PFQuery queryWithClassName:@"Sent"];
        query2.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query2 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query2 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query2];
        [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedSent = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query2];
            if ([fetchedSent count]>0){
                [((PFObject*)[fetchedSent objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                    [sentbutton setImage:nil forState:UIControlStateNormal];
                    sendCountLabel.text = [NSString stringWithFormat:@"%d",[sendCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }  
        }];   
       
        PFQuery* query3 = [PFQuery queryWithClassName:@"Project"];
        query3.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query3 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query3 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query3];
        [query3 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [queryArray removeObject:query3];
            NSArray* fetchedProject = objects;
            if ([fetchedProject count]>0){
                [((PFObject*)[fetchedProject objectAtIndex:0]) deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                    [projbutton setImage:nil forState:UIControlStateNormal];
                    projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }else{
                PFObject* newProj = [PFObject objectWithClassName:@"Project"];
                [newProj setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
                [newProj setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
                [newProj setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
                [newProj setObject:routeObject.pfobj forKey:@"route"];
                [newProj setObject:[PFUser currentUser] forKey:@"user"];
                [newProj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                    [projbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
                    projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]+1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                        
                    }
                }];
            }
        }];

                
 

    }
       
}

-(void)getFacebookRouteDetails{
    
    NSString* fbphotoid = [routeObject.pfobj objectForKey:@"photoid"];
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",fbphotoid,[PFFacebookUtils facebook].accessToken]]];
    NSLog(@"url = %@",[request url]);
    [request setCompletionBlock:^{
        NSLog(@"request response =%@",[request responseString]);
        SBJSON *parser = [[SBJSON alloc] init];
        [commentsArray removeAllObjects];
        // Prepare URL request to download statuses from Twitter
        
        // Get JSON as a NSString from NSData response
        NSString *json_string = [[NSString alloc] initWithString:[request responseString]];
        NSDictionary *parsedJson = [parser objectWithString:json_string error:nil];
        [parser release];
        [json_string release];
        NSDictionary *commentsDict = [parsedJson objectForKey:@"comments"];
        NSDictionary *likesDict =[parsedJson objectForKey:@"likes"];
        NSArray *likedataDict = [likesDict objectForKey:@"data"];
        NSLog(@"%d likers",[likedataDict count]);
        for (NSDictionary* liker in likedataDict) {
            NSLog(@"liker = %@",[liker objectForKey:@"name"]);
            if ([[liker objectForKey:@"name"]isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
                //color
                [likeButton setImage:[UIImage imageNamed:@"heartcolor.png"] forState:UIControlStateNormal];       
            }
        }
        [likeButton setUserInteractionEnabled:YES];
        [routeObject.pfobj setObject:[NSNumber numberWithInt:[likedataDict count]] forKey:@"likecount"];
        [routeObject.pfobj saveEventually];
        likeCountLabel.text = [NSString stringWithFormat:@"%d likes",[likedataDict count]];
        NSArray *dataDict = [commentsDict objectForKey:@"data"];
        for (NSDictionary* comment in dataDict) {
            NSLog(@"comment =%@",[comment objectForKey:@"message"]);
            NSDictionary *fromDict = [comment objectForKey:@"from"];
            PFObject* fbobject = [PFObject objectWithClassName:@"Comment"];
            [fbobject setObject:[comment objectForKey:@"message"] forKey:@"text"];
            [fbobject setObject:[fromDict objectForKey:@"name"] forKey:@"commentername"];
            [fbobject setObject:routeObject.pfobj forKey:@"route"];
            [fbobject setObject:[comment objectForKey:@"created_time"] forKey:@"createdAt"];
            NSString* urlforprofile = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?access_token=%@",[fromDict objectForKey:@"id"],[PFFacebookUtils facebook].accessToken];
            
            [fbobject setObject:urlforprofile forKey:@"commenterimage"];
            
            [commentsArray addObject:fbobject];
            [commentsTable reloadData];
            [commentsTable layoutIfNeeded];
            if (commentsTable.superview){
                [commentsTable removeFromSuperview];
            }
            [self arrangeSubViewsaftercomments];
            
        }
        [routeObject.pfobj setObject:[NSNumber numberWithInt:[commentsArray count]] forKey:@"commentcount"];
        [routeObject.pfobj saveEventually];
        NSLog(@"comments array after adding fb = %@",commentsArray);
         
        
    }];
    [request setFailedBlock:^{}];
    [request startAsynchronous];
    
}

-(void)getImageIfUnavailable
{
    if (!routeObject.ownerImage){
        NSString* urlstring = [routeObject.pfobj objectForKey:@"userimage"];
        NSLog(@"urlstring =%@,%@",urlstring, [routeObject.pfobj objectForKey:@"userimage"]);
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [request setCompletionBlock:^{
            UIImage* ownerimage = [UIImage imageWithData:[request responseData]];
            routeObject.ownerImage = ownerimage;
            UserImageView.image = ownerimage;
            UserImageView.alpha =0.0;
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 UserImageView.alpha = 1.0;
                             } 
                             completion:^(BOOL finished){
                                 // NSLog(@"Done!");
                             }];

        }];
        
        [request setFailedBlock:^{}];
        [request startAsynchronous];
    }else{
        UserImageView.image= routeObject.ownerImage;
    }

    
    
    //get route image
    
    PFFile *imagefile = [routeObject.pfobj objectForKey:@"imageFile"];
    [queryArray addObject:imagefile];
    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
        NSLog(@"image recieved");
        [progressBar removeFromSuperview];
        self.navigationItem.title = @"Route Details";
        [queryArray removeObject:imagefile];
        UIImage* retrievedImage = [UIImage imageWithData:imageData];
        routeImageView.image = retrievedImage;
        [scrollView setFrame:CGRectMake(0, 0, 320, 320)];
        
        [scrollView setDelegate:self];
        [scrollView addSubview:routeImageView];
        scrollView.contentSize=CGSizeMake(retrievedImage.size.width, retrievedImage.size.width);
        scrollView.maximumZoomScale = 4;
        scrollView.minimumZoomScale = 1;
        [scrollView setZoomScale:1.0f];
   // }];
     
    } progressBlock:^(int percentDone) {
        if (percentDone==0) {
            [progressBar setFrame:CGRectMake(70, 17, 180, 10)];
            [self.navigationController.navigationBar addSubview:progressBar];
        }
        NSLog(@"percentage done = %d",percentDone);
        [progressBar setProgress:((double)percentDone)/100.0 ];
        if (percentDone==100) {
        [progressBar removeFromSuperview];
        }
    } ];
    
    
    
    
    
    
     
     
   
     
}   


-(void)viewWillDisappear:(BOOL)animated
{
 
    [commentTextField resignFirstResponder];
    if (progressBar.superview) {
    [progressBar removeFromSuperview];
    }
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
         
 
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView {
  	return routeImageView;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    

}

- (void)viewDidUnload
{
    
    [self setRouteImageView:nil];
    [self setUserImageView:nil];
    [self setUsernameLabel:nil];
    [self setDescriptionLabel:nil];
    [self setCommentsTable:nil];
    [self setLikeCountLabel:nil];
    [self setViewCountLabel:nil];
    [self setCommentCountLabel:nil];
    [self setScroll:nil];
    [self setDescriptionTextView:nil];
    [self setCommentTextField:nil];
    [self setLikeButton:nil];
    [self setRouteLocationLabel:nil];
    [self setFlashbutton:nil];
    [self setSentbutton:nil];
    [self setProjbutton:nil];
    [self setProgressBar:nil];
    [self setScrollView:nil];
    [self setBtmView:nil];
    [self setFlashCountLabel:nil];
    [self setSendCountLabel:nil];
    [self setProjectCountLabel:nil];
    [self setTopView:nil];
    [self setRouteMapView:nil];
    [self setMapContainer:nil];
    [self setUnavailableLabel:nil];
    [self setPinImageView:nil];
    [self setDifficultyLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    scroll.scrollEnabled = NO;
    scroll.contentOffset = CGPointMake(0, btmView.frame.origin.y-20);
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    scroll.scrollEnabled = YES;
}
- (IBAction)viewUser:(id)sender {
    ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    viewController.username= usernameLabel.text;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (IBAction)PostComment:(id)sender {
    NSError*error=nil;
    [commentTextField becomeFirstResponder];
    [commentTextField resignFirstResponder];
    if ([[commentTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        //do nothing
    }else{
    if ([routeObject.pfobj objectForKey:@"photoid"])
    {//if uploaded to facebook also upload comment to facebook.. keep everything there
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       commentTextField.text, @"message",nil];
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/comments",[routeObject.pfobj objectForKey:@"photoid"]]
                                      andParams:params
                                  andHttpMethod:@"POST"
                                    andDelegate:self];
        
    
    }else{
        [PFPush subscribeToChannel:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] withError:&error];
        if (!error) {
            NSLog(@"subscribed to channel %@",routeObject.pfobj.objectId);
        }else{
            NSLog(@"error = %@",error);
        }    
       
        [self CommentNotification];
        
    PFObject* object = [PFObject objectWithClassName:@"Comment"];
    [object setObject:commentTextField.text forKey:@"text"];
    [object setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"commentername"];
    [object setObject:[[PFUser currentUser]objectForKey:@"profilepicture"] forKey:@"commenterimage"];
    
    [object setObject:routeObject.pfobj forKey:@"route"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded,NSError*error){
        NSLog(@"saved comment");
        
        PFQuery* query = [PFQuery queryWithClassName:@"Comment"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query whereKey:@"route" equalTo:routeObject.pfobj];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray* fetchedComments,NSError*error){
            NSLog(@"found some comments = %@",fetchedComments);
            [commentsArray removeAllObjects];
            [commentsArray addObjectsFromArray:fetchedComments];
            [routeObject.pfobj setObject:[NSNumber numberWithInt:[commentsArray count]] forKey:@"commentcount"];
            [routeObject.pfobj saveEventually];
            [commentsTable removeFromSuperview];
            [commentsTable reloadData];
            [commentsTable layoutIfNeeded];
            commentsTable.frame = CGRectMake(0, 68, 320, [commentsTable contentSize].height);
         [self arrangeSubViewsaftercomments];
            
        }];
        
    }];
    }
    }
commentTextField.text = @"";
}
-(void)CommentNotification{
    if(![[[PFUser currentUser] objectForKey:@"name"] isEqualToString:[routeObject.pfobj objectForKey:@"username"]]){
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:routeObject.pfobj.objectId forKey:@"linkedroute"];
        [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
        [data setObject:[NSString stringWithFormat:@"%@ commented on %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"alert"];
        [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
        
        [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] withData:data];
        
        PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
        [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
        [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];
        [feedObject setObject:[NSString stringWithFormat:@"%@ commented on %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"message"];
        [feedObject saveEventually];
        
        
    }else{
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:routeObject.pfobj.objectId forKey:@"linkedroute"];
        [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
        [data setObject:[NSString stringWithFormat:@"%@ commented on his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
        [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
        
        [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] withData:data];
        
        PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
        [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
        [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];                    [feedObject setObject:[NSString stringWithFormat:@"%@ commented on his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
        [feedObject saveEventually];
        
        
    }
    
}
-(void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@",response);
    
    
}
- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    NSLog(@"request didload with result %@",result); 
    if([[result objectForKey:@"result"]isEqualToString:@"true"])
    {
        if (facebookliked) {
            //set button color to heartcolor
            [likeButton setImage:[UIImage imageNamed:@"heartcolor.png"] forState:UIControlStateNormal];       
        }else{
            [likeButton setImage:[UIImage imageNamed:@"popularbutton.png"] forState:UIControlStateNormal];       
        }
    
          [self getFacebookRouteDetails]; 
    
    }
         
}
- (IBAction)showUsers:(UIButton*)sender {
    SendUserViewController*viewController = [[SendUserViewController alloc]initWithNibName:@"SendUserViewController" bundle:nil];
    switch (sender.tag) {
        case 0:
            viewController.sendStatus = @"Flash";
            break;
        case 1:
            viewController.sendStatus = @"Sent";
            break;
        case 2:
            viewController.sendStatus = @"Project";
            break;
        
            
        default:
            break;
    }
    
    viewController.route = routeObject.pfobj;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

- (IBAction)likeButton:(id)sender {
    [likeButton setUserInteractionEnabled:NO];
    if ([routeObject.pfobj objectForKey:@"photoid"])
    {//if uploaded to facebook also upload comment to facebook.. keep everything there
        
        if([likeButton imageForState:UIControlStateNormal]==[UIImage imageNamed:@"heartcolor.png"]){
            facebookliked = NO; //unlike!
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser]objectForKey:@"name"],[[[PFUser currentUser]objectForKey:@"facebookid"] stringValue],nil];
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/likes",[routeObject.pfobj objectForKey:@"photoid"]]
                                               andParams:params
                                           andHttpMethod:@"DELETE"
                                             andDelegate:self];
            
        }else{
            facebookliked = YES; //liked
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser]objectForKey:@"name"],[[[PFUser currentUser]objectForKey:@"facebookid"] stringValue],nil];
            [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/likes",[routeObject.pfobj objectForKey:@"photoid"]]
                                                   andParams:params
                                               andHttpMethod:@"POST"
                                                 andDelegate:self]; 
        }
        
    }else{
    
    PFQuery* likequery = [PFQuery queryWithClassName:@"Like"];

    [likequery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
    [queryArray  addObject:likequery];
    
    [likequery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:likequery];
            [likeButton setUserInteractionEnabled:YES];
            BOOL didLike=NO;
        if ([objects count]) {

            for (PFObject* likeobj in objects) {
                if ([[likeobj objectForKey:@"owner"]isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
                    didLike = YES;
                    [likeobj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                        [routeObject.pfobj setObject:[NSNumber numberWithInt:([objects count]-1)] forKey:@"likecount"];
                        [routeObject.pfobj saveInBackground];
                        likeCountLabel.text = [NSString stringWithFormat:@"%d likes",([objects count]-1)];
                        [likeButton setImage:[UIImage imageNamed:@"popularbutton.png"] forState:UIControlStateNormal];       
                        PFQuery* feedquery = [PFQuery queryWithClassName:@"Feed"];
                        [feedquery whereKey:@"sender" equalTo:[[PFUser currentUser] objectForKey:@"name"]];
                        [feedquery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [queryArray addObject:feedquery];
                        [feedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            [queryArray removeObject:feedquery];
                            if ([objects count]) {
                                [((PFObject*)[objects objectAtIndex:0]) delete];
                                
                            }
                        }];
                    }];
                }
            }
        }
            if (!didLike) {
                NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
                                                                                     selector:@selector(LikeOperation:) object:[objects count]] autorelease];
                [theOp start];

            }
                        

        
    }];
       
    
    }
    }
-(void)LikeOperation:(NSInteger)likecounter
{
    
    PFObject* newLike = [PFObject objectWithClassName:@"Like"];
    [newLike setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"owner"];
    [newLike setObject:routeObject.pfobj forKey:@"linkedroute"];
    [newLike setObject:routeObject.pfobj.objectId forKey:@"linkedrouteID"];
    [newLike saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded){
            likecount = likecounter + 1;
            [routeObject.pfobj setObject:[NSNumber numberWithInt:likecount] forKey:@"likecount"];
            [routeObject.pfobj saveInBackground];
            likeCountLabel.text = [NSString stringWithFormat:@"%d likes",likecount];
            [likeButton setImage:[UIImage imageNamed:@"heartcolor.png"] forState:UIControlStateNormal];
                    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] block:^(BOOL succeeded, NSError *error) {
            NSLog(@"subscribed to channel %@",routeObject.pfobj.objectId);
           
                
            likeCountLabel.text = [NSString stringWithFormat:@"%d likes",likecount];
            
            
            // send notification ///
                        NSMutableDictionary *data = [NSMutableDictionary dictionary];
                        [data setObject:routeObject.pfobj.objectId forKey:@"linkedroute"];
                        [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
                        if ([[[PFUser currentUser] objectForKey:@"name"] isEqualToString:[routeObject.pfobj objectForKey:@"username"]]) {
                            NSLog(@"sent his/her notification");
                      
                            [data setObject:[NSString stringWithFormat:@"%@ liked his/her route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"alert"];
                        }else{
                           
                            [data setObject:[NSString stringWithFormat:@"%@ liked %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"alert"];
                        }
                        [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                        
                        [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] withData:data];
            //done sending notifications ///////
                        
                        
                
            PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
            [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
            [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
            [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
            [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];
            [feedObject  setObject:[NSString stringWithFormat:@"%@ liked %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"message"];
            
            [feedObject saveEventually];
                        
                    }];
        }else{
            NSLog(@"failed with error = %@",error);
            [newLike saveEventually];
        }
    }];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSString *foo = [[commentsArray objectAtIndex:indexPath.row] objectForKey:@"text"];
    NSLog(@"foo = %@",foo);
    CGSize size = [foo sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10.0f]
                  constrainedToSize:CGSizeMake(236, 2000)
                      lineBreakMode:UILineBreakModeWordWrap];
    NSLog(@"CGSize =%@",NSStringFromCGSize(size));
    return MAX(65,size.height+28);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"commentsArray = %d",[commentsArray count]);
    return [commentsArray count];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//commented out going to commenter profile since commenter may not be a user
    
    
//    ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
//    viewController.username = [[commentsArray objectAtIndex:indexPath.row] objectForKey:@"commentername"];
//    [self.navigationController pushViewController:viewController animated:YES];
//    [viewController release];
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromCellIdentifier = @"FromCell";
CommentsCell* cell = (CommentsCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
if (cell == nil) {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CommentsCell" owner:nil options:nil];
    for(id currentObject in topLevelObjects){
        if([currentObject isKindOfClass:[UITableViewCell class]]){
            cell = (CommentsCell*)currentObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}
    NSString *foo = [[commentsArray objectAtIndex:indexPath.row] objectForKey:@"text"];
    CGSize size = [foo sizeWithFont:[UIFont fontWithName:@"Helvetica" size:10.0f]
                  constrainedToSize:CGSizeMake(236, 2000)
                      lineBreakMode:UILineBreakModeWordWrap];
    [cell.commentLabel setFrame:CGRectMake(46, 27, 236,size.height)];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+0000'"];
    NSString* datestring = ((NSString*)[[commentsArray objectAtIndex:indexPath.row] objectForKey:@"createdAt"]);

    NSDate * date = [dateFormatter dateFromString:datestring];
    [dateFormatter release];
    if (!datestring) {
        date = (((NSDate*)((PFObject*)[commentsArray objectAtIndex:indexPath.row]).createdAt));
    }
    double timesincenow =  [date timeIntervalSinceNow];
    //NSLog(@"timesincenow = %i",((int)timesincenow));

    int timeint = ((int)timesincenow);
    //if more than 1 day show number of days
    //if more than 60min show number of hrs
    //if more than 24hrs show days
    
    if (timeint < -86400) {
        cell.commentTime.text = [NSString stringWithFormat:@"%id ago",timeint/-86400];
    }else if(timeint < -3600){
        cell.commentTime.text = [NSString stringWithFormat:@"%ih ago",timeint/-3600];
    }else{
        cell.commentTime.text = [NSString stringWithFormat:@"%im ago",timeint/-60];
    }

    cell.commentLabel.text = [[commentsArray objectAtIndex:indexPath.row] objectForKey:@"text"];
    cell.commenterNameLabel.text = [[commentsArray objectAtIndex:indexPath.row] objectForKey:@"commentername"];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[[commentsArray objectAtIndex:indexPath.row] objectForKey:@"commenterimage"]] ];
    [request setCompletionBlock:^{
        cell.commenterImageView.image = [UIImage imageWithData:[request responseData]];
    }];
    [request setFailedBlock:^{NSLog(@"image retrival failed");}];
    [request startAsynchronous];

    return cell;  
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


- (void)dealloc {
    [savedArray release];
    [routeImageView release];
    [UserImageView release];
    [usernameLabel release];
    [descriptionLabel release];
    [commentsTable release];
    [viewCountLabel release];
    [commentCountLabel release];
    [scroll release];
    [descriptionTextView release];
    [commentTextField release];
    [likeButton release];
    [routeLocationLabel release];
    [flashbutton release];
    [sentbutton release];
    [projbutton release];
    [progressBar release];
    [scrollView release];
    [btmView release];
    [likeCountLabel release];
    [flashCountLabel release];
    [sendCountLabel release];
    [projectCountLabel release];
    [topView release];
    [routeMapView release];
    [mapContainer release];
    [unavailableLabel release];
    [pinImageView release];
    [difficultyLabel release];
    [super dealloc];
}
@end
