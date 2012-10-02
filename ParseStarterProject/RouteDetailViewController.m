#import "InstagramViewController.h"
#import "MBProgressHUD.h"
#import "JHNotificationManager.h"
#import "ProfileViewController.h"
#import "RouteDetailViewController.h"
#import "CommentsCell.h"
#import "ASIHTTPRequest.h"
#import "MKMapView+ZoomLevel.h"
#import "ASIFormDataRequest.h"
#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"
@implementation RouteDetailViewController
@synthesize recommendView;
@synthesize topView;
@synthesize btmView;
@synthesize mapContainer;
@synthesize approvalView;
@synthesize outdateButton;
@synthesize difficultyLabel;
@synthesize unoutdateButton;
@synthesize postButton;
@synthesize routeMapView;
@synthesize routeimage;
@synthesize recommendedFBFriends;
//@synthesize rawImageData;
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
@synthesize approveButton;
@synthesize disapproveButton;
@synthesize likeCountLabel;
@synthesize queryArray;
@synthesize savedArray;
@synthesize commentsArray;
@synthesize viewCountLabel;
@synthesize scroll;
@synthesize commentCountLabel;
@synthesize routeGymObject;
typedef enum apiCall {
kAPICheckLikedComment,
kAPICheckLikedPage,
kAPIGraphLikePhoto,
kAPIGraphCommentPhoto,
} apiCall;

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
/*
- (IBAction)didFlagAsOutdated:(id)sender {
    if ([self.routeObject.pfobj objectForKey:@"outdated"]==[NSNumber numberWithBool:true]) {
        // if user is the owner of the route , show the not outdated button
        
    }else{
        flagalert = [[UIAlertView alloc]initWithTitle:@"Flag as outdated" message:@"Are you sure?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No",nil];
    [flagalert show];
    [flagalert release];
    }
    
}

- (IBAction)unoutdate:(id)sender {
    [self.routeObject.pfobj setObject:[NSNumber numberWithBool:false]forKey:@"outdated"];
    [self.routeObject.pfobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    outdateButton.hidden = NO;
        unoutdateButton.hidden =YES;
    }];
    

}
- (IBAction)approveOutdate:(id)sender {
    [approveButton setUserInteractionEnabled:NO];
    [self.routeObject.pfobj setObject:@"approved" forKey:@"approvalstatus"];
    [self.routeObject.pfobj setObject:[NSNumber numberWithBool:YES] forKey:@"outdated"];
    [self.routeObject.pfobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            approvalView.hidden = YES;
         [approveButton setUserInteractionEnabled:YES];
        if ([self.routeObject.pfobj objectForKey:@"approvalreqFBid"]) {
         
        if (![[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"facebookid"]]isEqualToString:[self.routeObject.pfobj objectForKey:@"approvalreqFBid"]]) {
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            [data setObject:self.routeObject.pfobj.objectId forKey:@"linkedroute"];
            [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
            [data setObject:[NSString stringWithFormat:@"%@ approved your outdate request",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
            [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
            [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[self.routeObject.pfobj objectForKey:@"approvalreqFBid"]] withData:data];
        }
        }
    }];

}
- (IBAction)disapproveOutdate:(id)sender {
    [disapproveButton setUserInteractionEnabled:NO];
    [self.routeObject.pfobj setObject:@"disapproved" forKey:@"approvalstatus"];
    [self.routeObject.pfobj setObject:[NSNumber numberWithBool:NO] forKey:@"outdated"];
    [self.routeObject.pfobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    approvalView.hidden = YES;    
        [disapproveButton setUserInteractionEnabled:YES];
    }];

}
 */
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (flagalert) {
    if (buttonIndex==0) {
        //set approval status to "pending"
        //[self.routeObject.pfobj setObject:[NSNumber numberWithBool:true]forKey:@"outdated"];
        [self.routeObject.pfobj setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"facebookid"] ] forKey:@"approvalreqFBid"];
        [self.routeObject.pfobj setObject:@"pending" forKey:@"approvalstatus"];
        [self.routeObject.pfobj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        outdateButton.hidden = YES;    
            PFQuery* userQuery = [PFUser query];
            [userQuery whereKey:@"name" equalTo:[self.routeObject.pfobj objectForKey:@"username"]];
            [userQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                [data setObject:self.routeObject.pfobj.objectId forKey:@"linkedroute"];
                [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
                [data setObject:[NSString stringWithFormat:@"%@ marked your route as outdated",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
                [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                [data setObject:[NSString stringWithFormat:@"%@",[object objectForKey:@"name"]] forKey:@"reciever"];
                [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[object objectForKey:@"facebookid"]] withData:data];
                NSLog(@"push notification sent for approval");
                
            }];
        }];
        
        }
    }else if(dislikealert){
        if ([[dislikealert buttonTitleAtIndex:buttonIndex]isEqualToString:@"Show Me"]) {
            [[routeObject.pfobj objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://page/%@",[object objectForKey:@"facebookid"]]]];                
            }];

        }
    }
}

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
 /*   approveButton = [[[GradientButton alloc]initWithFrame:CGRectMake(195, 6, 100, 40)]autorelease];
    [approveButton setTitle:@"Approve" forState:UIControlStateNormal];
    [approveButton useGreenConfirmStyle];
    [approveButton addTarget:self action:@selector(approveOutdate:) forControlEvents:UIControlEventTouchUpInside];
    [approvalView addSubview:approveButton];

    
    disapproveButton = [[[GradientButton alloc]initWithFrame:CGRectMake(195, 51, 100, 40)] autorelease];
    [disapproveButton setTitle:@"Disapprove" forState:UIControlStateNormal];
    [disapproveButton addTarget:self action:@selector(disapproveOutdate:) forControlEvents:UIControlEventTouchUpInside];
    [disapproveButton useRedDeleteStyle];
    [approvalView addSubview:disapproveButton];
*/
    
    difficultyLabel.text = [routeObject.pfobj objectForKey:@"difficultydescription"];
    NSString *foo = [routeObject.pfobj objectForKey:@"description"];
    CGSize size = [foo sizeWithFont:[UIFont fontWithName:@"Helvetica" size:11.0f]
                  constrainedToSize:CGSizeMake(229, 2000)
                      lineBreakMode:UILineBreakModeWordWrap];

    descriptionTextView.frame = CGRectMake(-1, 50, 229, MAX(41,size.height+30));
    descriptionTextView.text = foo;
    
    commentCountLabel.text = [NSString stringWithFormat:@"%@",[[routeObject.pfobj objectForKey:@"commentcount"]stringValue]];
    likeCountLabel.text = [NSString stringWithFormat:@"%@ likes",[[routeObject.pfobj objectForKey:@"likecount"]stringValue]];
    viewCountLabel.text = [NSString stringWithFormat:@"%@ views",[[routeObject.pfobj objectForKey:@"viewcount"]stringValue]];
    
    
    
 
    if (!(((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).latitude ==0.0f &&((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).longitude ==0.0f )) {
    CLLocationCoordinate2D routeLoc = CLLocationCoordinate2DMake(((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).latitude, ((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).longitude);
    [routeMapView setCenterCoordinate:routeLoc zoomLevel:14 animated:NO];
        unavailableLabel.hidden=YES;
        pinImageView.hidden=NO;
    }else{
        unavailableLabel.hidden=NO;
        pinImageView.hidden=YES;
    }
    
    
    //if user is owner and is route is outdated, show unoutdate button
    //elseif route is outdated ,hide outdatebutton

   /* if ([routeObject.pfobj objectForKey:@"outdated"]==[NSNumber numberWithBool:true]) {
        outdateButton.hidden = YES;
    }else{
        outdateButton.hidden = NO;
    }
    */
    //if route object is near admin geopoint , add ability to delete
    
    

    if ([[routeObject.pfobj objectForKey:@"username"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
        //add delete button if user is owner
        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(deleteActionSheetShow)];
        self.navigationItem.rightBarButtonItem = anotherButton;
        [anotherButton release];
        
   //     if ([routeObject.pfobj objectForKey:@"outdated"]==[NSNumber numberWithBool:true]) {
    //        unoutdateButton.hidden = NO;
    //    }
    }else{
        __block BOOL isNear=NO;
        PFGeoPoint* routeGP = [routeObject.pfobj objectForKey:@"routelocation"];
        [[PFUser currentUser]refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if ([[[PFUser currentUser]objectForKey:@"isAdmin"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
                //fetch gyms hes admin for
                PFQuery* gymManaged = [PFQuery queryWithClassName:@"Gym"];
                [gymManaged whereKey:@"admin" containsString:[PFUser currentUser].objectId];
                [gymManaged findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if ([objects count]>0) {
                        for (PFObject* gym in objects) {
                            if ([routeGP distanceInKilometersTo:[gym objectForKey:@"gymlocation"]]<0.5) {
                                isNear=YES;
                            }

                        }
                        if (isNear) {
                            
                        
                        UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(deleteActionSheetShow)];
                        self.navigationItem.rightBarButtonItem = anotherButton;
                        [anotherButton release];
                        
            //            if ([routeObject.pfobj objectForKey:@"outdated"]==[NSNumber numberWithBool:true]) {
              //              unoutdateButton.hidden = NO;
                //            }
                        }

                    }
                }];
            }
        }];
    }
  /*  if ([[self.routeObject.pfobj objectForKey:@"approvalstatus"]isEqualToString:@"pending"] && [[self.routeObject.pfobj objectForKey:@"username"]isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
        approvalView.hidden=NO;
        
        
    }else{
        approvalView.hidden=YES;
    }
    */
    
    
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
    
    [self getImageIfUnavailable];
    //scroll.contentSize = CGSizeMake(320, 566);
    self.navigationController.navigationBarHidden = NO;

    [self checksendstatus];
    [self checkCommunitySendStatus];

    if ([routeObject.pfobj objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
        if (routeGymObject) {
            [routeObject.pfobj setObject:routeGymObject forKey:@"Gym"];
            NSLog(@"preparing to fetch... may cause lag..");
            [[routeObject.pfobj objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                usernameLabel.text = [object objectForKey:@"name"];
                NSLog(@"fetch complete");

            }];
        }
        else{
            NSLog(@"preparing to fetch... may cause lag..");
            [[routeObject.pfobj objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                usernameLabel.text = [object objectForKey:@"name"];
                NSLog(@"fetch complete");
                
            }];
        }
    }else{
    usernameLabel.text= [routeObject.pfobj objectForKey:@"username"];
    }
    
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

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}
- (IBAction)didDoubleTap:(UITapGestureRecognizer*)sender {
    if (scrollView.zoomScale == 4.0){
        float newScale = scrollView.minimumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[sender locationInView:sender.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        
        
    }else{
        float newScale = scrollView.maximumZoomScale;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[sender locationInView:sender.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        
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

    topView.frame = CGRectMake(6,330,307,50+MAX(41,size.height+30));
    
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

-(void)deleteActionSheetShow
{
    deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
    [deleteActionSheet showFromTabBar:self.tabBarController.tabBar];
    [deleteActionSheet setBounds:CGRectMake(0,0,320, 150)];
    [deleteActionSheet release];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex && actionSheet==deleteActionSheet) {
        [self deleteAction:nil];   
    }else{

    }
}

-(void)deleteAction:(id)sender
{
    MBProgressHUD* hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Deleting route from Psyched... =(";
    
   
        [routeObject.pfobj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFQuery* deleteQueryFeed = [PFQuery queryWithClassName:@"Feed"];
        [deleteQueryFeed whereKey:@"linkedroute" equalTo:routeObject.pfobj];
        [deleteQueryFeed findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject* obj in objects) {
                [self deleteOGwithId:[obj objectForKey:@"facebookid"]];
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"deleted 1 feed");
                }];
            }
        }];
        PFQuery* deleteQueryLike = [PFQuery queryWithClassName:@"Like"];
        [deleteQueryLike whereKey:@"linkedroute" equalTo:routeObject.pfobj];
        [deleteQueryLike findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject* obj in objects) {
                [self deleteOGwithId:[obj objectForKey:@"facebookid"]];
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"deleted 1 like");
                }];
            }
        }];
        PFQuery* deleteQueryFlash = [PFQuery queryWithClassName:@"Flash"];
        [deleteQueryFlash whereKey:@"route" equalTo:routeObject.pfobj];
        [deleteQueryFlash findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject* obj in objects) {
                [self deleteOGwithId:[obj objectForKey:@"facebookid"]];
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"deleted 1 flash");
                }];
            }
        }];
        PFQuery* deleteQuerySent = [PFQuery queryWithClassName:@"Sent"];
        [deleteQuerySent whereKey:@"route" equalTo:routeObject.pfobj];
        [deleteQuerySent findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject* obj in objects) {
                [self deleteOGwithId:[obj objectForKey:@"facebookid"]];
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                }];
            }
        }];
        PFQuery* deleteQueryProj = [PFQuery queryWithClassName:@"Project"];
        [deleteQueryProj whereKey:@"route" equalTo:routeObject.pfobj];
        [deleteQueryProj findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            for (PFObject* obj in objects) {
                [self deleteOGwithId:[obj objectForKey:@"facebookid"]];
                [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"deleted 1 proj");
                }];
            }
        }];
            
            PFQuery* deleteQueryComments = [PFQuery queryWithClassName:@"Comment"];
            [deleteQueryComments whereKey:@"route" equalTo:routeObject.pfobj];
            [deleteQueryComments findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                for (PFObject* obj in objects) {
                    [self deleteOGwithId:[obj objectForKey:@"facebookid"]];
                    [obj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        NSLog(@"deleted 1 comment");
                    }];
                }
            }];
            [self deleteOGwithId:[routeObject.pfobj objectForKey:@"opengraphid"]];
            ASIHTTPRequest* routeDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.psychedapp.com/routepost/%@",routeObject.pfobj.objectId]]];
            [routeDelete setRequestMethod:@"DELETE"];

            [routeDelete setCompletionBlock:^{
                NSLog(@"routeDelete posted, %@",[routeDelete responseString]);
            }];
            [routeDelete setFailedBlock:^{
                NSLog(@"routeDelete failed");
            }];
            [routeDelete startAsynchronous];
    [hud hide:YES];
    [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (IBAction)flashsentproj:(UIButton*)sender {
    [flashbutton setUserInteractionEnabled:NO];
    [sentbutton setUserInteractionEnabled:NO];
    [projbutton setUserInteractionEnabled:NO];
    if (sender.tag==0)
    {
        //clear all flashes
        NSArray* tempFlashArray = [routeObject.pfobj objectForKey:@"usersflashed"];
        NSMutableArray* routeFlashArray = [[NSMutableArray alloc]init ];
        [routeFlashArray addObjectsFromArray:tempFlashArray];
        if ([routeFlashArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeFlashArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeFlashArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeFlashArray forKey:@"usersflashed"];
            [routeObject.pfobj saveEventually];
        }else{
           [routeFlashArray addObject:[[PFUser currentUser] objectForKey:@"name"]]; 
            [routeObject.pfobj setObject:routeFlashArray forKey:@"usersflashed"];
            [routeObject.pfobj saveEventually];
        }
         [routeFlashArray release]; 
      
        //clear sends
        NSArray* tempSentArray = [routeObject.pfobj objectForKey:@"userssent"];
        NSMutableArray* routeSentArray = [[NSMutableArray alloc]init ];
        [routeSentArray addObjectsFromArray:tempSentArray];
        if ([routeSentArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeSentArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeSentArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeSentArray forKey:@"userssent"];
            [routeObject.pfobj saveEventually];
            
        }
        [routeSentArray release];
        
        //clear projects
        NSArray* tempProjArray = [routeObject.pfobj objectForKey:@"usersproj"];
        NSMutableArray* routeProjArray = [[NSMutableArray alloc]init ];
        [routeProjArray addObjectsFromArray:tempProjArray];
        if ([routeProjArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeProjArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeProjArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeProjArray forKey:@"usersproj"];
            [routeObject.pfobj saveEventually];
            
        }
        [routeProjArray release];
        
        
        
        //clear flashes deprecated
        PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
        [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query1 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query1];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [queryArray removeObject:query1];
            
            NSArray* fetchedFlash = [NSArray arrayWithArray:objects];

            if ([fetchedFlash count]>0){
                PFObject* fspObject = [fetchedFlash objectAtIndex:0];
                if ([fspObject objectForKey:@"facebookid"])
                {
                    NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                    [newOGDelete setRequestMethod:@"DELETE"];
                    [newOGDelete setCompletionBlock:^{
                            NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                    }];
                    [newOGDelete setFailedBlock:^{
                        NSLog(@"newOGDelete failed");
                    }];
                    [newOGDelete startAsynchronous];

 
                }
                [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        //should clear flash feed also
                        PFQuery* flashFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                        [flashFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                        [flashFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [flashFeedQuery whereKey:@"action" equalTo:@"flash"];
                        [flashFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            for (PFObject* feed in objects) {
                                [feed deleteInBackground];
                            }
                        }];
                        [flashbutton setImage:nil forState:UIControlStateNormal];
                        flashCountLabel.text = [NSString stringWithFormat:@"%d",[flashCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                   
                }];
            }else{
               
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
                    ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/climbing_:flash"]];
                    [newOGPost setPostValue:[PFFacebookUtils facebook].accessToken forKey:@"access_token"];
                    [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",routeObject.pfobj.objectId] forKey:@"route"];
                    [newOGPost setRequestMethod:@"POST"];
                    [newOGPost setCompletionBlock:^{
                        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                        NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
                        [jsonParser release];
                        jsonParser = nil;
                        if ([jsonObjects objectForKey:@"id"]) {
                            NSLog(@"posted, %@",[newOGPost responseString]);
                            [self postNewFlashWithOG:[jsonObjects objectForKey:@"id"]];
                        }else{
                            NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                            [self postNewFlashWithOG:nil];
                        }
                        
                    }];
                    
                    
                    [newOGPost setFailedBlock:^{
                        NSLog(@"failed");
                    }];
                    [newOGPost startAsynchronous];
                    NSLog(@"finished posting");

                }else{
                    [self postNewFlashWithOG:nil];

                }
                // post here to facebook OG
                
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
                PFObject* fspObject = [fetchedSent objectAtIndex:0];
                if ([fspObject objectForKey:@"facebookid"])
                {
                    NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                    [newOGDelete setRequestMethod:@"DELETE"];
                    [newOGDelete setCompletionBlock:^{
                        NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                    }];
                    [newOGDelete setFailedBlock:^{
                        NSLog(@"newOGDelete failed");
                    }];
                    [newOGDelete startAsynchronous];
                    
                    
                }
                [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                    if (succeeded) {
                        PFQuery* sendFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                        [sendFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                        [sendFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [sendFeedQuery whereKey:@"action" equalTo:@"sent"];
                        [sendFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            for (PFObject* feed in objects) {
                                [feed deleteInBackground];
                            }
                        }];
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
                    PFObject* fspObject = [fetchedProject objectAtIndex:0];
                    if ([fspObject objectForKey:@"facebookid"])
                    {
                        NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                        ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                        [newOGDelete setRequestMethod:@"DELETE"];
                        [newOGDelete setCompletionBlock:^{
                            NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                        }];
                        [newOGDelete setFailedBlock:^{
                            NSLog(@"newOGDelete failed");
                        }];
                        [newOGDelete startAsynchronous];
                        
                        
                    }
                    [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {

                        if (succeeded) {
                            PFQuery* projFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                            [projFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                            [projFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                            [projFeedQuery whereKey:@"action" equalTo:@"project"];
                            [projFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                for (PFObject* feed in objects) {
                                    [feed deleteInBackground];
                                }
                            }];
                        [projbutton setImage:nil forState:UIControlStateNormal];
                        projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]-1];
                            [flashbutton setUserInteractionEnabled:YES];
                            [sentbutton setUserInteractionEnabled:YES];
                            [projbutton setUserInteractionEnabled:YES];
                        }
                    }];
            }
         }];
        
    }else if(sender.tag==1)
    {
        //clear all flashes
        NSArray* tempFlashArray = [routeObject.pfobj objectForKey:@"usersflashed"];
        NSMutableArray* routeFlashArray = [[NSMutableArray alloc]init ];
        [routeFlashArray addObjectsFromArray:tempFlashArray];
        if ([routeFlashArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeFlashArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeFlashArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeFlashArray forKey:@"usersflashed"];
            [routeObject.pfobj saveEventually];
        }
        [routeFlashArray release]; 
        
        //clear sends
        NSArray* tempSentArray = [routeObject.pfobj objectForKey:@"userssent"];
        NSMutableArray* routeSentArray = [[NSMutableArray alloc]init ];
        [routeSentArray addObjectsFromArray:tempSentArray];
        if ([routeSentArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeSentArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeSentArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeSentArray forKey:@"userssent"];
            [routeObject.pfobj saveEventually];
            
        }else{
            [routeSentArray addObject:[[PFUser currentUser] objectForKey:@"name"]]; 
            [routeObject.pfobj setObject:routeSentArray forKey:@"userssent"];
            [routeObject.pfobj saveEventually];
        }
        [routeSentArray release];
        
        //clear projects
        NSArray* tempProjArray = [routeObject.pfobj objectForKey:@"usersproj"];
        NSMutableArray* routeProjArray = [[NSMutableArray alloc]init ];
        [routeProjArray addObjectsFromArray:tempProjArray];
        if ([routeProjArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeProjArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeProjArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeProjArray forKey:@"usersproj"];
            [routeObject.pfobj saveEventually];
            
        }
        [routeProjArray release];
        

        
        
        
        
        
        
        
        PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
        query1.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query1 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query1];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedFlash = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query1];
            if ([fetchedFlash count]>0){
                PFObject* fspObject = [fetchedFlash  objectAtIndex:0];
                if ([fspObject objectForKey:@"facebookid"])
                {
                    NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                    [newOGDelete setRequestMethod:@"DELETE"];
                    [newOGDelete setCompletionBlock:^{
                        NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                    }];
                    [newOGDelete setFailedBlock:^{
                        NSLog(@"newOGDelete failed");
                    }];
                    [newOGDelete startAsynchronous];
                    
                    
                }
                [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFQuery* flashFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                        [flashFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                        [flashFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [flashFeedQuery whereKey:@"action" equalTo:@"flash"];
                        [flashFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            for (PFObject* feed in objects) {
                                [feed deleteInBackground];
                            }
                        }];
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
            PFObject* fspObject = [fetchedSent  objectAtIndex:0];
            if ([fspObject objectForKey:@"facebookid"])
            {
                NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                [newOGDelete setRequestMethod:@"DELETE"];
                [newOGDelete setCompletionBlock:^{
                    NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                }];
                [newOGDelete setFailedBlock:^{
                    NSLog(@"newOGDelete failed");
                }];
                [newOGDelete startAsynchronous];
                
                
            }
            [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    PFQuery* sendFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                    [sendFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                    [sendFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                    [sendFeedQuery whereKey:@"action" equalTo:@"sent"];
                    [sendFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for (PFObject* feed in objects) {
                            [feed deleteInBackground];
                        }
                    }];
               [sentbutton setImage:nil forState:UIControlStateNormal];
                sendCountLabel.text = [NSString stringWithFormat:@"%d",[sendCountLabel.text intValue]-1];
                    [flashbutton setUserInteractionEnabled:YES];
                    [sentbutton setUserInteractionEnabled:YES];
                    [projbutton setUserInteractionEnabled:YES];
                }
            }];
        }else{
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
                ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/climbing_:climb"]];
                [newOGPost setPostValue:[PFFacebookUtils facebook].accessToken forKey:@"access_token"];
                [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",routeObject.pfobj.objectId] forKey:@"route"];
                [newOGPost setRequestMethod:@"POST"];
                [newOGPost setCompletionBlock:^{
                    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                    NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
                    [jsonParser release];
                    jsonParser = nil;
                    if ([jsonObjects objectForKey:@"id"]) {
                        NSLog(@"posted, %@",[newOGPost responseString]);
                        [self postNewSendWithOG:[jsonObjects objectForKey:@"id"]];
                    }else{
                        NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                        [self postNewSendWithOG:nil];
                    }
                    
                }];
                
                
                [newOGPost setFailedBlock:^{
                    NSLog(@"failed");
                }];
                [newOGPost startAsynchronous];
                NSLog(@"finished posting");
                
            }else{
                [self postNewSendWithOG:nil];
                
            }

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
            PFObject* fspObject = [fetchedProject  objectAtIndex:0];
            if ([fspObject objectForKey:@"facebookid"])
            {
                NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                [newOGDelete setRequestMethod:@"DELETE"];
                [newOGDelete setCompletionBlock:^{
                    NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                }];
                [newOGDelete setFailedBlock:^{
                    NSLog(@"newOGDelete failed");
                }];
                [newOGDelete startAsynchronous];
                
                
            }
            [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    PFQuery* projFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                    
                    [projFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                    [projFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                    [projFeedQuery whereKey:@"action" equalTo:@"project"];
                    [projFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        for (PFObject* feed in objects) {
                            [feed deleteInBackground];
                        }
                    }];
                [projbutton setImage:nil forState:UIControlStateNormal];
                projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]-1];
                    [flashbutton setUserInteractionEnabled:YES];
                    [sentbutton setUserInteractionEnabled:YES];
                    [projbutton setUserInteractionEnabled:YES];
                }
            }];
        }
        }];
       
    }else if(sender.tag == 2)
    {
        
        //clear all flashes
        NSArray* tempFlashArray = [routeObject.pfobj objectForKey:@"usersflashed"];
        NSMutableArray* routeFlashArray = [[NSMutableArray alloc]init ];
        [routeFlashArray addObjectsFromArray:tempFlashArray];
        if ([routeFlashArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeFlashArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeFlashArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeFlashArray forKey:@"usersflashed"];
            [routeObject.pfobj saveEventually];
        }
        [routeFlashArray release]; 
        
        //clear sends
        NSArray* tempSentArray = [routeObject.pfobj objectForKey:@"userssent"];
        NSMutableArray* routeSentArray = [[NSMutableArray alloc]init ];
        [routeSentArray addObjectsFromArray:tempSentArray];
        if ([routeSentArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeSentArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeSentArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeSentArray forKey:@"userssent"];
            [routeObject.pfobj saveEventually];
            
        }
        [routeSentArray release];
        
        //clear projects
        NSArray* tempProjArray = [routeObject.pfobj objectForKey:@"usersproj"];
        NSMutableArray* routeProjArray = [[NSMutableArray alloc]init ];
        [routeProjArray addObjectsFromArray:tempProjArray];
        if ([routeProjArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
            while ([routeProjArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
                [routeProjArray removeObject:[[PFUser currentUser] objectForKey:@"name"]];      
            }
            [routeObject.pfobj setObject:routeProjArray forKey:@"usersproj"];
            [routeObject.pfobj saveEventually];
            
        }else{
            [routeProjArray addObject:[[PFUser currentUser] objectForKey:@"name"]]; 
            [routeObject.pfobj setObject:routeProjArray forKey:@"usersproj"];
            [routeObject.pfobj saveEventually];
        }
        [routeProjArray release];
        
        
        
        PFQuery* query1 = [PFQuery queryWithClassName:@"Flash"];
        query1.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query1 whereKey:@"username" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
        [query1 whereKey:@"route" equalTo:routeObject.pfobj];
        [queryArray addObject:query1];
        [query1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            NSArray* fetchedFlash = [NSArray arrayWithArray:objects];
            [queryArray removeObject:query1];
            if ([fetchedFlash count]>0){
                PFObject* fspObject = [fetchedFlash  objectAtIndex:0];
                if ([fspObject objectForKey:@"facebookid"])
                {
                    NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                    [newOGDelete setRequestMethod:@"DELETE"];
                    [newOGDelete setCompletionBlock:^{
                        NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                    }];
                    [newOGDelete setFailedBlock:^{
                        NSLog(@"newOGDelete failed");
                    }];
                    [newOGDelete startAsynchronous];
                    
                    
                }
                [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFQuery* flashFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                        [flashFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                        [flashFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [flashFeedQuery whereKey:@"action" equalTo:@"flash"];
                        [flashFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            for (PFObject* feed in objects) {
                                [feed deleteInBackground];
                            }
                        }];
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
                PFObject* fspObject = [fetchedSent  objectAtIndex:0];
                if ([fspObject objectForKey:@"facebookid"])
                {
                    NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                    [newOGDelete setRequestMethod:@"DELETE"];
                    [newOGDelete setCompletionBlock:^{
                        NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                    }];
                    [newOGDelete setFailedBlock:^{
                        NSLog(@"newOGDelete failed");
                    }];
                    [newOGDelete startAsynchronous];
                    
                    
                }
                [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFQuery* sendFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                        [sendFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                        [sendFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [sendFeedQuery whereKey:@"action" equalTo:@"sent"];
                        [sendFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            for (PFObject* feed in objects) {
                                [feed deleteInBackground];
                            }
                        }];
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
                PFObject* fspObject = [fetchedProject  objectAtIndex:0];
                if ([fspObject objectForKey:@"facebookid"])
                {
                    NSLog(@"deleting %@...",[fspObject objectForKey:@"facebookid"]);
                    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",[fspObject objectForKey:@"facebookid"],[PFFacebookUtils facebook].accessToken]]];
                    [newOGDelete setRequestMethod:@"DELETE"];
                    [newOGDelete setCompletionBlock:^{
                        NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
                    }];
                    [newOGDelete setFailedBlock:^{
                        NSLog(@"newOGDelete failed");
                    }];
                    [newOGDelete startAsynchronous];
                    
                    
                }
                [fspObject deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        PFQuery* projFeedQuery = [PFQuery queryWithClassName:@"Feed"];
                        [projFeedQuery whereKey:@"sender" equalTo:[[PFUser currentUser]objectForKey:@"name"]];
                        [projFeedQuery whereKey:@"linkedroute" equalTo:routeObject.pfobj];
                        [projFeedQuery whereKey:@"action" equalTo:@"project"];
                        [projFeedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            for (PFObject* feed in objects) {
                                [feed deleteInBackground];
                            }
                        }];
                    [projbutton setImage:nil forState:UIControlStateNormal];
                    projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]-1];
                        [flashbutton setUserInteractionEnabled:YES];
                        [sentbutton setUserInteractionEnabled:YES];
                        [projbutton setUserInteractionEnabled:YES];
                    }
                }];
            }else{
                if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
                    ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/climbing_:project"]];
                    [newOGPost setPostValue:[PFFacebookUtils facebook].accessToken forKey:@"access_token"];
                    [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",routeObject.pfobj.objectId] forKey:@"route"];
                    [newOGPost setRequestMethod:@"POST"];
                    [newOGPost setCompletionBlock:^{
                        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                        NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
                        [jsonParser release];
                        jsonParser = nil;
                        if ([jsonObjects objectForKey:@"id"]) {
                            NSLog(@"posted, %@",[newOGPost responseString]);
                            [self postNewProjWithOG:[jsonObjects objectForKey:@"id"]];
                        }else{
                            NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                            [self postNewProjWithOG:nil];
                        }
                        
                    }];
                    
                    
                    [newOGPost setFailedBlock:^{
                        NSLog(@"failed");
                    }];
                    [newOGPost startAsynchronous];
                    NSLog(@"finished posting");
                    
                }else{
                    [self postNewProjWithOG:nil];
                    
                }
                // post here to facebook OG
            }
        }];

                
 

    }
       
}

-(void)postNewLikeWithOG:(NSString*)idstring  andLikeCounter:(NSInteger)likecounter
{
    PFObject* newLike = [PFObject objectWithClassName:@"Like"];
    [newLike setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"owner"];
    [newLike setObject:routeObject.pfobj forKey:@"linkedroute"];
    [newLike setObject:routeObject.pfobj.objectId forKey:@"linkedrouteID"];
    if(idstring)
        [newLike setObject:idstring forKey:@"facebookid"];
    
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
                
                
                PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
                [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
                [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
                [feedObject setObject:@"like" forKey:@"action"];
                if (![[[PFUser currentUser] objectForKey:@"name"] isEqualToString:[routeObject.pfobj objectForKey:@"username"]]) {
                    [feedObject  setObject:[NSString stringWithFormat:@"%@ liked %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"message"];
                }else{
                    if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
                        [feedObject setObject:[NSString stringWithFormat:@"%@ liked her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                        
                    }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
                        [feedObject setObject:[NSString stringWithFormat:@"%@ liked his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                    }else{
                        [feedObject setObject:[NSString stringWithFormat:@"%@ liked his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                    }
                    
                }
                
                [feedObject saveInBackground];
                
            }];
        }else{
            NSLog(@"failed with error = %@",error);
            [newLike saveInBackground];
        }
    }];
}




-(void)postNewFlashWithOG:(NSString*)idstring
{
    PFObject* newFlash = [PFObject objectWithClassName:@"Flash"];
    [newFlash setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
    [newFlash setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
    [newFlash setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
    [newFlash setObject:[PFUser currentUser] forKey:@"user"];
    [newFlash setObject:routeObject.pfobj forKey:@"route"];
    if(idstring)
        [newFlash setObject:idstring forKey:@"facebookid"];
    [newFlash saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            //add flash feed here
            PFObject* flashFeed = [PFObject objectWithClassName:@"Feed"];
            [flashFeed setObject:routeObject.pfobj forKey:@"linkedroute"];
            [flashFeed setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"sender"];
            [flashFeed setObject:[[PFUser currentUser]objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
            
            
            [flashFeed setObject:@"flash" forKey:@"action"];
            
            if (![[[PFUser currentUser]objectForKey:@"name"] isEqualToString:usernameLabel.text]){
                [flashFeed setObject:[NSString stringWithFormat:@"%@ flashed %@'s route",[[PFUser currentUser]objectForKey:@"name"],usernameLabel.text] forKey:@"message"];
                
            }else{
                if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
                    [flashFeed setObject:[NSString stringWithFormat:@"%@ flashed her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                    
                }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
                    [flashFeed setObject:[NSString stringWithFormat:@"%@ flashed his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                }else{
                    [flashFeed setObject:[NSString stringWithFormat:@"%@ flashed his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                }
                
            }
            [flashFeed saveInBackground];
            [flashbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
            flashCountLabel.text = [NSString stringWithFormat:@"%d",[flashCountLabel.text intValue]+1];
            [flashbutton setUserInteractionEnabled:YES];
            [sentbutton setUserInteractionEnabled:YES];
            [projbutton setUserInteractionEnabled:YES];
        }
    }];
}
-(void)postNewSendWithOG:(NSString*)idstring
{
    
    PFObject* newSent = [PFObject objectWithClassName:@"Sent"];
    [newSent setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
    [newSent setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
    [newSent setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
    [newSent setObject:routeObject.pfobj forKey:@"route"];
    if(idstring)
        [newSent setObject:idstring forKey:@"facebookid"];
    [newSent setObject:[PFUser currentUser] forKey:@"user"];
    
    [newSent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFObject* sendFeed = [PFObject objectWithClassName:@"Feed"];
            [sendFeed setObject:routeObject.pfobj forKey:@"linkedroute"];
            if (![[[PFUser currentUser]objectForKey:@"name"] isEqualToString:usernameLabel.text]){
                [sendFeed setObject:[NSString stringWithFormat:@"%@ sent %@'s route",[[PFUser currentUser]objectForKey:@"name"],usernameLabel.text] forKey:@"message"];
                
            }else{
                if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
                    [sendFeed setObject:[NSString stringWithFormat:@"%@ sent her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                    
                }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
                    [sendFeed setObject:[NSString stringWithFormat:@"%@ sent his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                }else{
                    [sendFeed setObject:[NSString stringWithFormat:@"%@ sent his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                }
                
            }
            [sendFeed setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"sender"];
            [sendFeed setObject:[[PFUser currentUser]objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
            [sendFeed setObject:@"sent" forKey:@"action"];
            [sendFeed saveInBackground];
            [sentbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
            sendCountLabel.text = [NSString stringWithFormat:@"%d",[sendCountLabel.text intValue]+1];
            [flashbutton setUserInteractionEnabled:YES];
            [sentbutton setUserInteractionEnabled:YES];
            [projbutton setUserInteractionEnabled:YES];
        }
    }];

    
    
    }
-(void)postNewProjWithOG:(NSString*)idstring
{
    PFObject* newProj = [PFObject objectWithClassName:@"Project"];
    [newProj setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
    [newProj setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
    [newProj setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
    [newProj setObject:routeObject.pfobj forKey:@"route"];
    if(idstring)
        [newProj setObject:idstring forKey:@"facebookid"];
    [newProj setObject:[PFUser currentUser] forKey:@"user"];
    [newProj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFObject* projFeed = [PFObject objectWithClassName:@"Feed"];
        [projFeed setObject:routeObject.pfobj forKey:@"linkedroute"];
        if (![[[PFUser currentUser]objectForKey:@"name"] isEqualToString:usernameLabel.text]){
            [projFeed setObject:[NSString stringWithFormat:@"%@ started projecting %@'s route",[[PFUser currentUser]objectForKey:@"name"],usernameLabel.text] forKey:@"message"];
            
        }else{
            if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
                [projFeed setObject:[NSString stringWithFormat:@"%@ started projecting her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                
            }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
                [projFeed setObject:[NSString stringWithFormat:@"%@ started projecting his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
            }else{
                [projFeed setObject:[NSString stringWithFormat:@"%@ started projecting his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
            }
            
        }
        [projFeed setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"sender"];
        [projFeed setObject:[[PFUser currentUser]objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
        [projFeed setObject:@"project" forKey:@"action"];
        [projFeed saveInBackground];
        if (succeeded) {
            [projbutton setImage:[UIImage imageNamed:@"tick.png"] forState:UIControlStateNormal];
            projectCountLabel.text = [NSString stringWithFormat:@"%d",[projectCountLabel.text intValue]+1];
            [flashbutton setUserInteractionEnabled:YES];
            [sentbutton setUserInteractionEnabled:YES];
            [projbutton setUserInteractionEnabled:YES];
            
        }
    }];
}

-(void)deleteOGwithId:(NSString*)idstring
{
    if (idstring) {
    ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",idstring,[PFFacebookUtils facebook].accessToken]]];
    [newOGDelete setRequestMethod:@"DELETE"];
        NSLog(@"deleting %@",newOGDelete.url);
    [newOGDelete setCompletionBlock:^{
        NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
    }];
    [newOGDelete setFailedBlock:^{
        NSLog(@"newOGDelete failed");
    }];
    [newOGDelete startAsynchronous];
        
    }
}

-(void)getFacebookRouteDetails{
    
    NSString* fbphotoid = [routeObject.pfobj objectForKey:@"photoid"];
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",fbphotoid,[PFFacebookUtils facebook].accessToken]]];
    NSLog(@"url = %@",[request url]);
    [request setCompletionBlock:^{
            NSLog(@"request response = %@",[request responseString]);
        if(![[request responseString] isEqualToString:@"false"]){
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
        if ([likedataDict count]>0) {
        [routeObject.pfobj setObject:[NSNumber numberWithInt:[likedataDict count]] forKey:@"likecount"];
        [routeObject.pfobj saveEventually];
        }
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
            
            
        }
        [self arrangeSubViewsaftercomments];
        if ([commentsArray count]>0) {
        [routeObject.pfobj setObject:[NSNumber numberWithInt:[commentsArray count]] forKey:@"commentcount"];
        [routeObject.pfobj saveEventually];
        }
        }else if([[request responseString]isEqualToString:@"false"]){
            
            [JHNotificationManager notificationWithMessage:[NSString stringWithFormat:@"Sorry! Only friends of %@ can like and post/view comments",usernameLabel.text]];
        }
     [postButton setUserInteractionEnabled:YES];
    }];
    [request setFailedBlock:^{NSLog(@"failed with error =%@",[request error]);}];
    [request startAsynchronous];
    
}

-(void)getImageIfUnavailable
{
    if (!routeObject.ownerImage){
        NSString* urlstring;
        if ([routeObject.pfobj objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
            NSLog(@"preparing to fetch... may cause lag..");
            urlstring=[[[routeObject.pfobj objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"imagelink"];
            NSLog(@"fetch completed");
        }else{
        urlstring = [routeObject.pfobj objectForKey:@"userimage"];
        
        }
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
    if(routeimage){
        [self setRouteImageWithImage:routeimage andData:UIImagePNGRepresentation(routeimage)];
        [routeimage release];
    }else{
    PFFile *imagefile = [routeObject.pfobj objectForKey:@"imageFile"];
    if(!imagefile.isDataAvailable){
    [queryArray addObject:imagefile];
    [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
        NSLog(@"image recieved");
        [progressBar removeFromSuperview];
        self.navigationItem.title = @"Route Details";
        [queryArray removeObject:imagefile];
        //rawImageData = imageData;
        //[rawImageData retain];
        UIImage* retrievedImage = [UIImage imageWithData:imageData];
        [self setRouteImageWithImage:retrievedImage andData:imageData];
   // }];
     
    } progressBlock:^(int percentDone) {
        if (percentDone==0) {
            [progressBar setFrame:CGRectMake(70, 17, 180, 10)];
            [self.navigationController.navigationBar addSubview:progressBar];
        }
        //NSLog(@"percentage done = %d",percentDone);
        [progressBar setProgress:((double)percentDone)/100.0 ];
        if (percentDone==100) {
        [progressBar removeFromSuperview];
        }
    } ];
    
    }else{
        [progressBar removeFromSuperview];
        self.navigationItem.title = @"Route Details";
        [queryArray removeObject:imagefile];
        //rawImageData = imageData;
        //[rawImageData retain];
        UIImage* retrievedImage = [UIImage imageWithData:imagefile.getData];
        [self setRouteImageWithImage:retrievedImage andData:imagefile.getData];
    }
    }
     
}
-(void)setRouteImageWithImage:(UIImage*)retrievedImage andData:(NSData*)imageData
{
    routeImageView.image = retrievedImage;
    [scrollView setFrame:CGRectMake(0, 0, 320, 320)];
    
    [scrollView setDelegate:self];
    [scrollView addSubview:routeImageView];
    [routeImageView release];
    scrollView.contentSize=CGSizeMake(retrievedImage.size.width, retrievedImage.size.width);
    scrollView.maximumZoomScale = 4;
    scrollView.minimumZoomScale = 1;
    [scrollView setZoomScale:1.0f];
    if([[routeObject.pfobj objectForKey:@"routeVersion"] isEqualToString:@"3"]){
        NSLog(@"route is version 3, attach overlay here");
        ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
        ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = imageData;
        ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = routeObject.pfobj;
        NSArray* routearrowarray = [routeObject.pfobj objectForKey:@"arrowarray"];
        NSArray* arrowtypearray = [routeObject.pfobj objectForKey:@"arrowtypearray"];
        NSArray* arrowcolorarray = [routeObject.pfobj objectForKey:@"arrowcolorarray"];
        UIImage* pastedimage = nil;
        for (int i=0; i<[routearrowarray count]; i++) {
            
            
            CGRect routearrowrect = CGRectFromString([routearrowarray objectAtIndex:i]);
                        
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:0]]){
              routeImageView.image =  [self imageByDrawingClippedImage:[UIImage imageNamed:@"arrow3.png"] OnImage:routeImageView.image inRect:routearrowrect withColorString:[arrowcolorarray objectAtIndex:i]];
                continue;
            }
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:1]]){
                routeImageView.image =  [self imageByDrawingClippedText:@"START" OnImage:routeImageView.image inRect:routearrowrect withColorString:[arrowcolorarray objectAtIndex:i]];
                continue;}
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:2]]){
               routeImageView.image =[self imageByDrawingClippedText:@"END" OnImage:routeImageView.image inRect:routearrowrect withColorString:[arrowcolorarray objectAtIndex:i]];}
            continue;
        }
        
        
        
    }

    if([[routeObject.pfobj objectForKey:@"routeVersion"] isEqualToString:@"2"]){
        NSLog(@"route is version 2, attach overlay here");
        ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
        ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = imageData;
        ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = routeObject.pfobj;
        NSArray* routearrowarray = [routeObject.pfobj objectForKey:@"arrowarray"];
        NSArray* arrowtypearray = [routeObject.pfobj objectForKey:@"arrowtypearray"];
        UIImage* pastedimage = nil;
        NSLog(@"routearrowarray = %@",routearrowarray);
        for (int i=0; i<[routearrowarray count]; i++) {
            
            
            CGRect routearrowrect = CGRectFromString([routearrowarray objectAtIndex:i]);
            
            
            
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:0]])
                pastedimage = [UIImage imageNamed:@"arrow1.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:1]])
                pastedimage = [UIImage imageNamed:@"start1.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:2]])
                pastedimage = [UIImage imageNamed:@"end1.png"];
            
            
            
            
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:3]])
                pastedimage = [UIImage imageNamed:@"arrow2.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:4]])
                pastedimage = [UIImage imageNamed:@"start2.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:5]])
                pastedimage = [UIImage imageNamed:@"end2.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:6]])
                pastedimage = [UIImage imageNamed:@"arrow3.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:7]])
                pastedimage = [UIImage imageNamed:@"start3.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:8]])
                pastedimage = [UIImage imageNamed:@"end3.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:9]])
                pastedimage = [UIImage imageNamed:@"arrow4.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:10]])
                pastedimage = [UIImage imageNamed:@"start4.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:11]])
                pastedimage = [UIImage imageNamed:@"end4.png"];
            
                routeImageView.image = [self imageByDrawingImage:pastedimage OnImage:routeImageView.image inRect:routearrowrect];
               
            // [pastedimage release];
        }
        
        
        
    }

}

- (UIImage *)imageByDrawingClippedImage:(UIImage*)pastedImage OnImage:(UIImage *)image inRect:(CGRect)rect withColorString:(NSString*)colorstring
{
    
    
    
	UIGraphicsBeginImageContext(image.size);
    
	// draw original image into the context
	[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
    CGContextRef context = UIGraphicsGetCurrentContext();
    
	CGContextClipToMask(context, rect, [UIImage imageNamed:@"arrowbgflip"].CGImage);
    
    [pastedImage drawInRect:rect blendMode:kCGBlendModeColor alpha:1.0];
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, rect);
    
    
    
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIGraphicsBeginImageContext(retImage.size);
    
	// draw original image into the context
	[retImage drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
    CGContextRef newcontext = UIGraphicsGetCurrentContext();
    
	CGContextClipToMask(newcontext, rect, [UIImage imageNamed:@"arrow3flip"].CGImage);
    
    [pastedImage drawInRect:rect blendMode:kCGBlendModeColor alpha:1.0];
    CGContextSetBlendMode(newcontext, kCGBlendModeNormal);
    NSArray *components = [colorstring componentsSeparatedByString:@","];
    CGFloat r = [[components objectAtIndex:0] floatValue];
    CGFloat g = [[components objectAtIndex:1] floatValue];
    CGFloat b = [[components objectAtIndex:2] floatValue];
    CGFloat a = [[components objectAtIndex:3] floatValue];
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    [color setFill];
    CGContextFillRect(newcontext, rect);

    
    UIImage *newretImage = UIGraphicsGetImageFromCurrentImageContext();
	// free the context
	UIGraphicsEndImageContext();
    
	return newretImage;
}
- (UIImage *)imageByDrawingClippedText:(NSString*)pastedText OnImage:(UIImage *)image inRect:(CGRect)rect withColorString:(NSString*)colorstring
{
    
    
    
	UIGraphicsBeginImageContext(image.size);
    
	// draw original image into the context
	[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
    CGContextRef context = UIGraphicsGetCurrentContext();

    NSArray *components = [colorstring componentsSeparatedByString:@","];
    CGFloat r = [[components objectAtIndex:0] floatValue];
    CGFloat g = [[components objectAtIndex:1] floatValue];
    CGFloat b = [[components objectAtIndex:2] floatValue];
    CGFloat a = [[components objectAtIndex:3] floatValue];
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:a];
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
    CGContextSetTextDrawingMode(context, kCGTextFillStroke);
    [pastedText drawInRect:rect withFont:[UIFont boldSystemFontOfSize:25] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentRight];
    
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
}

- (UIImage *)imageByDrawingImage:(UIImage*)pastedImage OnImage:(UIImage *)image inRect:(CGRect)rect
{
    
    
    
	UIGraphicsBeginImageContext(image.size);
    
	// draw original image into the context
	[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
	
    [pastedImage drawInRect:rect];

    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
}


-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"route detail viewdiddisappear");
    ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
    ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = nil;
    ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = nil;
   
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
    NSLog(@"done canceling queries 1");

    
   
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
    
   // [self setRawImageData:nil];
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
    [self setOutdateButton:nil];
    [self setUnoutdateButton:nil];
    [self setApprovalView:nil];
    //[self setApproveButton:nil];
    //[self setDisapproveButton:nil];
    [self setPostButton:nil];
    [self setCommentsArray:nil];
    [self setQueryArray:nil];
    [self setSavedArray:nil];
    [self setRouteObject:nil];
    [self setRecommendView:nil];
    [self setRecommendTextView:nil];
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
            if ([routeObject.pfobj objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
//                NSLog(@"opening gym page");
//                GymViewController* viewController = [[GymViewController alloc]initWithNibName:@"GymViewController" bundle:nil];
//                [((GymObject*)[routeObject.pfobj objectForKey:@"Gym"]) fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                    viewController.gymObject = object;
//                     NSLog(@"pushing in gym object , %@",object);
//                    [self.navigationController pushViewController:viewController animated:YES];
//                    [viewController release];
//                }];
                
            }else{
    ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];

    viewController.username= [routeObject.pfobj objectForKey:@"username"];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
            }
}
- (IBAction)didSelectMap:(id)sender {
    MapViewController* mapVC = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    mapVC.geopoint = (PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"];
    mapVC.gymName = [routeObject.pfobj objectForKey:@"location"];
    [self.navigationController pushViewController:mapVC animated:YES];

    [mapVC release];
//    UIApplication *app = [UIApplication sharedApplication];  
//    [app openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?ll=%f,%f",((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).latitude,((PFGeoPoint*)[routeObject.pfobj objectForKey:@"routelocation"]).longitude]]];  

}
- (IBAction)tryPostComment:(id)sender {

    [commentTextField becomeFirstResponder];
    [commentTextField resignFirstResponder];
    if ([[commentTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        //do nothing
    }else{
        [postButton setUserInteractionEnabled:NO];
    if ([routeObject.pfobj objectForKey:@"isPage"]==[NSNumber numberWithBool:YES] &&[routeObject.pfobj objectForKey:@"photoid"]) {

        [[self.routeObject.pfobj objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        currentAPICall = kAPICheckLikedComment;
            NSLog(@"preparing to fetch... may cause lag..");
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           [NSString stringWithFormat:@"select uid from page_fan where uid=me() and page_id=%@",[[[self.routeObject.pfobj objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"facebookid"]], @"query",
                                           nil];
            NSLog(@"fetch completed");
            [[PFFacebookUtils facebook] requestWithMethodName:@"fql.query"
                                                    andParams:params
                                                andHttpMethod:@"POST"
                                                  andDelegate:self];
        }];
        
   
    }else{
        [self PostComment:nil];   
    }
    }
}
- (IBAction)PostComment:(id)sender {
        NSError*error=nil;
    if ([routeObject.pfobj objectForKey:@"photoid"])
    {//if uploaded to facebook also upload comment to facebook.. keep everything there
        
        
        //save photoid in array in docs directory
//        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
//                                                            NSUserDomainMask, YES);
//        if ([paths count] > 0)
//        {
//            // Path to save array data
//            NSString  *arrayPath = [[paths objectAtIndex:0] 
//                                    stringByAppendingPathComponent:@"array.out"];
//            NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
//            if (![arrayFromFile containsObject:[routeObject.pfobj objectForKey:@"photoid"]]) {
//                [arrayFromFile addObject:[routeObject.pfobj objectForKey:@"photoid"]];
//
//            }
//            [arrayFromFile writeToFile:arrayPath atomically:YES];
//
//            
//        }
        
            
            
        currentAPICall = kAPIGraphCommentPhoto;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       commentTextField.text, @"message",nil];
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/comments",[routeObject.pfobj objectForKey:@"photoid"]]
                                      andParams:params
                                  andHttpMethod:@"POST"
                                    andDelegate:self];
       
    
    }else{
        NSLog(@"comment on psyched .. post normally");
        
    PFObject* object = [PFObject objectWithClassName:@"Comment"];
    [object setObject:commentTextField.text forKey:@"text"];
    [object setObject:[[PFUser currentUser]objectForKey:@"name"] forKey:@"commentername"];
    [object setObject:[[PFUser currentUser]objectForKey:@"profilepicture"] forKey:@"commenterimage"];
    
    [object setObject:routeObject.pfobj forKey:@"route"];
    [object saveInBackgroundWithBlock:^(BOOL succeeded,NSError*error){
        
        PFQuery* query = [PFQuery queryWithClassName:@"Comment"];
        query.cachePolicy = kPFCachePolicyNetworkElseCache;
        [query whereKey:@"route" equalTo:routeObject.pfobj];
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray* fetchedComments,NSError*error){
            NSLog(@"found some comments = %@",fetchedComments);
            [commentsArray removeAllObjects];
            [commentsArray addObjectsFromArray:fetchedComments];
            if ([commentsArray count]>0) {
            [routeObject.pfobj setObject:[NSNumber numberWithInt:[commentsArray count]] forKey:@"commentcount"];
            [routeObject.pfobj saveEventually];
            }
            [commentsTable removeFromSuperview];
            [commentsTable reloadData];
            [commentsTable layoutIfNeeded];
            commentsTable.frame = CGRectMake(0, 68, 320, [commentsTable contentSize].height);
         [self arrangeSubViewsaftercomments];
                    [postButton setUserInteractionEnabled:YES];
        }];
        
    }];
        
        
    }    
        [PFPush subscribeToChannel:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] error:&error];
        if (!error) {
            NSLog(@"subscribed to channel %@",routeObject.pfobj.objectId);
        }else{
            NSLog(@"error = %@",error);
        }    
          [self CommentNotification];
    
commentTextField.text = @"";
}
-(void)CommentNotification{
    if(![[[PFUser currentUser] objectForKey:@"name"] isEqualToString:usernameLabel.text]){
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:routeObject.pfobj.objectId forKey:@"linkedroute"];
        [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
        [data setObject:[NSString stringWithFormat:@"%@ commented on %@'s route",[[PFUser currentUser] objectForKey:@"name"],usernameLabel.text] forKey:@"alert"];
        [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
        
        [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] withData:data];
        
        PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
        [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
        [feedObject setObject:commentTextField.text forKey:@"commenttext"];
        [feedObject setObject:@"comment" forKey:@"action"];
        [feedObject setObject:[NSString stringWithFormat:@"%@ commented on %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"message"];
        [feedObject saveInBackground];
        
        
    }else{
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:routeObject.pfobj.objectId forKey:@"linkedroute"];
        [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
        if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
            [data setObject:[NSString stringWithFormat:@"%@ commented on her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
            
        }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
            [data setObject:[NSString stringWithFormat:@"%@ commented on his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
        }else{
            [data setObject:[NSString stringWithFormat:@"%@ commented on his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
        }
        [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
        
        [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",routeObject.pfobj.objectId] withData:data];
        
        PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
        [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
        [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
        [feedObject setObject:commentTextField.text forKey:@"commenttext"];
        [feedObject setObject:@"comment" forKey:@"action"];
        if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
            [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];                    [feedObject setObject:[NSString stringWithFormat:@"%@ commented on her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
            
        }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
            [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];                    [feedObject setObject:[NSString stringWithFormat:@"%@ commented on his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
        }else{
           [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];                    [feedObject setObject:[NSString stringWithFormat:@"%@ commented on his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
        }
        
        [feedObject saveInBackground];
        
        
    }
    
}
-(void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@",response);
    
    
}
- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    NSLog(@"request didload with result %@",result); 
    switch (currentAPICall) {
        case kAPIGraphCommentPhoto:    
            [self getFacebookRouteDetails];
            break;
        case kAPICheckLikedComment:
            
            if ([(NSArray*)result count]) {
                if([[[[(NSArray*)result objectAtIndex:0] objectForKey:@"uid"]stringValue] isEqualToString:[[[PFUser currentUser]objectForKey:@"facebookid"]stringValue]])
                {
                    [self PostComment:nil];
                }
            }else{
#warning i want to remove this
                [likeButton setUserInteractionEnabled:YES];
                dislikealert = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:@"Like our page to comment/like our routes!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show Me",nil];
                [dislikealert show];
                [dislikealert release];
            }
            break;

        case kAPICheckLikedPage:

            if ([(NSArray*)result count]) {
            if([[[[(NSArray*)result objectAtIndex:0] objectForKey:@"uid"]stringValue] isEqualToString:[[[PFUser currentUser]objectForKey:@"facebookid"]stringValue]])
            {
                NSLog(@"already liked");
                [self LikeButton];
            }
            }else{
                    [likeButton setUserInteractionEnabled:YES];
                dislikealert = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:@"Like our page to comment/like our routes!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show Me",nil];
                [dislikealert show];
                [dislikealert release];
            }
            break;
        case kAPIGraphLikePhoto:
            if([[result objectForKey:@"result"]isEqualToString:@"true"])
            {
                if (facebookliked) {
                    //set button color to heartcolor
                    [likeButton setImage:[UIImage imageNamed:@"heartcolor.png"] forState:UIControlStateNormal];
                    PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
                    [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
                    [feedObject setObject:[routeObject.pfobj objectForKey:@"imageFile"] forKey:@"imagefile"];
                    [feedObject setObject:@"like" forKey:@"action"];
                    if (![[[PFUser currentUser] objectForKey:@"name"] isEqualToString:[routeObject.pfobj objectForKey:@"username"]]) {
                        [feedObject  setObject:[NSString stringWithFormat:@"%@ liked %@'s route",[[PFUser currentUser] objectForKey:@"name"],[routeObject.pfobj objectForKey:@"username"]] forKey:@"message"];
                    }else{
                        if ([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"female"]) {
                            [feedObject setObject:[NSString stringWithFormat:@"%@ liked her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                            
                        }else if([[[PFUser currentUser]objectForKey:@"sex"] isEqualToString:@"male"]) {
                            [feedObject setObject:[NSString stringWithFormat:@"%@ liked his route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                        }else{
                            [feedObject setObject:[NSString stringWithFormat:@"%@ liked his/her route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
                        }
                        
                    }
                    [feedObject saveInBackground];
                }else{
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
                }
                
                
                
            }
              [self getFacebookRouteDetails];   
            break;
        default:
            break;
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

-(IBAction)LikeButtonPressed:(id)sender{
    [likeButton setUserInteractionEnabled:NO];
if ([routeObject.pfobj objectForKey:@"isPage"]==[NSNumber numberWithBool:YES] &&[routeObject.pfobj objectForKey:@"photoid"]) {
    currentAPICall = kAPICheckLikedPage;
    [[self.routeObject.pfobj objectForKey:@"Gym"]fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        NSLog(@"preparing to fetch... may cause lag..");
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"select uid from page_fan where uid=me() and page_id=%@",[[[self.routeObject.pfobj objectForKey:@"Gym"]fetchIfNeeded] objectForKey:@"facebookid"]], @"query",
                                   nil];
        NSLog(@"fetch complete");
    [[PFFacebookUtils facebook] requestWithMethodName:@"fql.query"
                                            andParams:params
                                        andHttpMethod:@"POST"
                                          andDelegate:self];
    }];

    
}else{
    [self LikeButton];   
}
}
- (void)LikeButton {
    [likeButton setUserInteractionEnabled:NO];
    NSLog(@"likebutton function");
    if ([routeObject.pfobj objectForKey:@"photoid"])
    {//if uploaded to facebook also upload comment to facebook.. keep everything there
        
        if([likeButton imageForState:UIControlStateNormal]==[UIImage imageNamed:@"heartcolor.png"]){
            facebookliked = NO; //unlike!
            NSLog(@"unlike");
            currentAPICall= kAPIGraphLikePhoto;
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser]objectForKey:@"name"],[[[PFUser currentUser]objectForKey:@"facebookid"] stringValue],nil];
        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/likes",[routeObject.pfobj objectForKey:@"photoid"]]
                                               andParams:params
                                           andHttpMethod:@"DELETE"
                                             andDelegate:self];
           
        }else{
            facebookliked = YES; //liked
            currentAPICall= kAPIGraphLikePhoto;     
            NSLog(@"likeed");
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser]objectForKey:@"name"],[[[PFUser currentUser]objectForKey:@"facebookid"] stringValue],nil];
            [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"/%@/likes",[routeObject.pfobj objectForKey:@"photoid"]]
                                                   andParams:params
                                               andHttpMethod:@"POST"
                                                 andDelegate:self]; 
        }
        
    }else{
        NSLog(@"no photoid");
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
                    [self deleteOGwithId:[likeobj objectForKey:@"facebookid"]];
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
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
        ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/og.likes"]];
        [newOGPost setPostValue:[PFFacebookUtils facebook].accessToken forKey:@"access_token"];
        [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",routeObject.pfobj.objectId] forKey:@"object"];
        [newOGPost setRequestMethod:@"POST"];
        [newOGPost setCompletionBlock:^{
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
            [jsonParser release];
            jsonParser = nil;
            if ([jsonObjects objectForKey:@"id"]) {
                NSLog(@"posted, %@",[newOGPost responseString]);
                [self postNewLikeWithOG:[jsonObjects objectForKey:@"id"] andLikeCounter:likecounter];
            }else{
                NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                [self postNewLikeWithOG:nil andLikeCounter:likecounter];
            }
            
        }];
        
        
        [newOGPost setFailedBlock:^{
            NSLog(@"failed");
        }];
        [newOGPost startAsynchronous];
        NSLog(@"finished posting");
        
    }else{
        [self postNewLikeWithOG:nil andLikeCounter:likecounter];
        
    }
    
    
    
    
    
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
- (IBAction)recommendButton:(id)sender {

    self.scroll.scrollEnabled = NO;
    [self.scroll scrollRectToVisible:CGRectMake(0, 0, 320, 200) animated:YES];
    [_recommendTextView becomeFirstResponder];
    recommendView.alpha = 0;
    [self.scroll addSubview:recommendView];
    [UIView animateWithDuration:0.3
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         recommendView.alpha = 1;
                     }
                     completion:^(BOOL finished){
                     }];
    
}
- (IBAction)dismissRecommend:(id)sender {
    [UIView animateWithDuration:0.3
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         recommendView.alpha = 0;
                     } 
                     completion:^(BOOL finished){
                        [recommendView removeFromSuperview];
                          [self.scroll setScrollEnabled:YES];
                         if(recommendedFBFriends){
                             [recommendedFBFriends release];
                         }
                         _recommendTextView.text =@"";
                         recommendView.alpha = 1;
                     }];
    
}
- (IBAction)addFriend:(id)sender {
        FriendTaggerViewController* viewController = [[FriendTaggerViewController alloc]initWithNibName:@"FriendTaggerViewController" bundle:nil];
            viewController.delegate = self;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
}
- (IBAction)PostRecommend:(id)sender {
    if (recommendedFBFriends) {
        NSMutableArray *discardedItems = [NSMutableArray array];
        for (FBfriend* friend in recommendedFBFriends) {
        if ([_recommendTextView.text rangeOfString:friend.name].location == NSNotFound) {
            [discardedItems addObject:friend];
        }else{
            _recommendTextView.text = [_recommendTextView.text stringByReplacingOccurrencesOfString:friend.name withString:[NSString stringWithFormat:@"@[%@]",friend.uid]];
        }
        }
        
        [recommendedFBFriends removeObjectsInArray:discardedItems];
        
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
            ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/climbing_:recommend"]];
            [newOGPost setPostValue:[PFFacebookUtils facebook].accessToken forKey:@"access_token"];
            [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",routeObject.pfobj.objectId] forKey:@"route"];
            [newOGPost setPostValue:[NSString stringWithFormat:@"%@",_recommendTextView.text] forKey:@"message"];
            [newOGPost setRequestMethod:@"POST"];
            [newOGPost setCompletionBlock:^{
                SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
                [jsonParser release];
                jsonParser = nil;
                if ([jsonObjects objectForKey:@"id"]) {
                    NSLog(@"posted og recommendation, %@",[newOGPost responseString]);
                 //   [self postNewLikeWithOG:[jsonObjects objectForKey:@"id"] andLikeCounter:likecounter];
                }else{
                    NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                   // [self postNewLikeWithOG:nil andLikeCounter:likecounter];
                }
                
            }];
            
            
            [newOGPost setFailedBlock:^{
                NSLog(@"failed");
            }];
            [newOGPost startAsynchronous];
            NSLog(@"finished posting");
            
        }
        
    for (FBfriend* friend in recommendedFBFriends) {
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        [data setObject:routeObject.pfobj.objectId forKey:@"linkedroute"];
        [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
        [data setObject:[NSString stringWithFormat:@"%@ recommended you a route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
        [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
        [data setObject:[NSString stringWithFormat:@"%@",friend.name] forKey:@"reciever"];
        
        [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",friend.uid] withData:data];
        
        
        NSMutableArray* recommendedUsersArray = [[NSMutableArray alloc]initWithArray:[routeObject.pfobj objectForKey:@"usersrecommended"]];
        if (![recommendedUsersArray containsObject:friend.name]) {
            [recommendedUsersArray addObject:friend.name];
            [routeObject.pfobj setObject:recommendedUsersArray forKey:@"usersrecommended"];
        }
        [recommendedUsersArray release];
        
    }
    
    
    PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
    [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
    [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
    [feedObject setObject:routeObject.pfobj forKey:@"linkedroute"];
    [feedObject setObject:@"recommend" forKey:@"action"];
    
    
    if ([recommendedFBFriends count]==0) {
        
    }else if([recommendedFBFriends count]==1){
        [feedObject setObject:[NSString stringWithFormat:@"%@ recommended %@'s route to %@",[[PFUser currentUser]objectForKey:@"name"],usernameLabel.text,((FBfriend*)[recommendedFBFriends objectAtIndex:0]).name] forKey:@"message"];
    }else if([recommendedFBFriends count]==2){
        [feedObject setObject:[NSString stringWithFormat:@"%@ recommended %@'s route to %@ and 1 other",[[PFUser currentUser]objectForKey:@"name"],usernameLabel.text,((FBfriend*)[recommendedFBFriends objectAtIndex:0]).name] forKey:@"message"];
    }else{
        [feedObject setObject:[NSString stringWithFormat:@"%@ recommended %@'s route to %@ and %d others",[[PFUser currentUser]objectForKey:@"name"],usernameLabel.text,((FBfriend*)[recommendedFBFriends objectAtIndex:0]).name,[recommendedFBFriends count]-1] forKey:@"message"];
    }
    
    
    
    
    [feedObject saveInBackground];
    [routeObject.pfobj saveEventually];
    [recommendedFBFriends release];
    }
    [recommendView removeFromSuperview];
    _recommendTextView.text = @"";
    [self.scroll setScrollEnabled:YES];
}
-(void)TaggerDidReturnWithRecommendedArray:(NSMutableArray *)recommendedArray
{
    recommendedFBFriends = [[NSMutableArray alloc]init];
        recommendedFBFriends = recommendedArray;
     for (FBfriend* friend in recommendedArray) {
         _recommendTextView.text = [NSString stringWithFormat:@"%@ %@",_recommendTextView.text,friend.name];
     }
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
    
  //  [rawImageData release];
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
    [outdateButton release];
    [unoutdateButton release];
    [approvalView release];
    [routeObject release];
    [postButton release];
    [recommendView release];
    [_recommendTextView release];
    [super dealloc];

}
@end
