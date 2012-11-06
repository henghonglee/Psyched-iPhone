

typedef enum apiCall {
    kAPIGetAppUsersFriendsUsing,
    kAPIGraphUserFriends,
    kAPIGraphUserPhotosPost,
    kAPIGraphPagePhotosPost,
} apiCall;
#import "ASIHTTPRequest.h"
#import "UIImage+Resize.h"
#import "FlurryAnalytics.h"
#import "JSON.h"
#import "JHNotificationManager.h"
#import "MKMapView+ZoomLevel.h"
#import "CreateRouteViewController.h"
#import "ParseStarterProjectAppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "RouteLocationViewController.h"
#import <Twitter/Twitter.h>
@implementation CreateRouteViewController
@synthesize gymSwitch;
@synthesize socialControls;
@synthesize gymControls;
@synthesize gymShareLabel;
@synthesize fblabel;
@synthesize routeLocMapView;
@synthesize recommendTextField;
@synthesize routeImageView;
@synthesize CGPointsArray;
@synthesize imageMetaData;
@synthesize locationManager;
@synthesize myRequest;
@synthesize fbuploadswitch;
@synthesize twuploadswitch;
@synthesize imageView,imageTaken;
@synthesize segControl;
@synthesize arrowTypeArray;
@synthesize arrowColorArray;
@synthesize locationTextField;
@synthesize descriptionTextField;
@synthesize scroll;
@synthesize recommendTextView;
@synthesize gymlist;
@synthesize originalImage;
@synthesize recommendArray;
@synthesize queryArray;
@synthesize difficultyTextField;
@synthesize fileUploadBackgroundTaskId;
@synthesize selectedGymObject;
@synthesize reusePFObject;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        imageMetaData = [[NSMutableDictionary alloc]init];
        // Custom initialization
    }
    return self;
}
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    imageView.image=nil;
    routeImageView.image =nil;
    routeLocMapView =nil;
    // Release any cached data, images, etc that aren't in use.
}
#pragma mark - View lifecycle
- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
#if !(TARGET_IPHONE_SIMULATOR)
    [[PFUser currentUser]refreshInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[[PFUser currentUser]objectForKey:@"isAdmin"]isEqualToNumber:[NSNumber numberWithBool:true]]) {for (UIView* view in gymControls) {
            view.hidden=NO;}}
    }];
#endif
    if ([[[PFUser currentUser]objectForKey:@"isAdmin"]isEqualToNumber:[NSNumber numberWithBool:true]]) {for (UIView* view in gymControls) {
        view.hidden=NO;}}
    

    if (reusePFObject) {
    descriptionTextField.text = [NSString stringWithFormat:@"#%@",[reusePFObject objectForKey:@"hashtag"]];
    locationTextField.text = [NSString stringWithFormat:@"%@",[reusePFObject objectForKey:@"location"]];
    }
   
    
    routeImageView.image = imageTaken;
    routeImageView.layer.borderColor = [UIColor whiteColor].CGColor;    
    routeImageView.layer.borderWidth = 3;

    routeLocMapView.layer.borderColor = [UIColor whiteColor].CGColor;
    routeLocMapView.layer.borderWidth = 3;
    routeLoc = CLLocationCoordinate2DMake([[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Latitude"] doubleValue], [[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Longitude"] doubleValue]);
    
    PFGeoPoint* routeGeoPoint = [PFGeoPoint geoPointWithLatitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Latitude"] doubleValue] longitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Longitude"] doubleValue]];
    //PFGeoPoint* spotGeoPoint = [PFGeoPoint geoPointWithLatitude:40.02194 longitude:-105.25067];
        PFGeoPoint* spotGeoPoint = [PFGeoPoint geoPointWithLatitude:1.297346 longitude:103.786908];
    if ([routeGeoPoint distanceInKilometersTo:spotGeoPoint]<=0.5) {
        gymlist = [[NSArray alloc]initWithObjects:@"1",@"1+", @"2-",@"2",@"2+",@"3-",@"3",@"3+",@"4-",@"4",@"4+",@"5-",@"5",@"5+",@"5++", nil];
    }else{
        gymlist = [[NSArray alloc]initWithObjects:@"------",@"V0-V2", @"V3-V5",@"V6-V8",@"V9-V11",@"V12",@"V13",@"V14",@"V15",@"V16",@"V16+", nil];
    }

    
    
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonSystemItemDone target:self action:@selector(saveAction:)];
    [rightButton setTintColor:[UIColor darkGrayColor]];
    [[UIBarButtonItem appearance] setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    [routeLocMapView setCenterCoordinate:routeLoc zoomLevel:14 animated:NO];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Add Route";
    recommendArray = [[NSMutableArray alloc]init];
    queryArray=[[NSMutableArray alloc]init ];
    imageView.image = imageTaken;
}
-(void)DescriptionDidReturnWithText:(NSString *)text andTaggedUsers:(NSMutableArray *)taggedFriends
{
    descriptionTextField.text = text;
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
        difficultyTextField.text = [gymlist objectAtIndex:[gympickerView selectedRowInComponent:0]];
        difficultyint = [gympickerView selectedRowInComponent:0];
}

-(void)viewWillDisappear:(BOOL)animated
{
    reusePFObject = nil;
//    NSLog(@"canceling %d queries",[queryArray count]);
//    for (id pfobject in queryArray) {
//        if ([pfobject isKindOfClass:[PFFile class]]) {
//            NSLog(@"cancelling pffile upload/download");
//            [((PFFile*)pfobject) cancel];
//        }
//        if ([pfobject isKindOfClass:[PFQuery class]]) {
//            NSLog(@"cancelling pfquery ");
//            [((PFQuery*)pfobject) cancel];
//        }
//    }
//    [queryArray removeAllObjects];
//    [HUD hide:YES];
//    NSLog(@"done canceling queries");
}
- (void)viewDidUnload
{
    
    [self setSegControl:nil];
    [self setLocationTextField:nil];
    [self setDescriptionTextField:nil];
    [self setImageView:nil];
    [self setScroll:nil];
    [self setRecommendTextField:nil];
    [self setRecommendTextView:nil];
    [self setRouteLocMapView:nil];
    [self setDifficultyTextField:nil];
    [self setTwuploadswitch:nil];
    [self setRouteImageView:nil];
    [self setFbuploadswitch:nil];    
    [self setFblabel:nil];
    [self setSocialControls:nil];
    [self setGymControls:nil];
    [self setGymSwitch:nil];
    [self setGymShareLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)LocationDidReturnWithText:(NSString *)text
{
    locationTextField.text = text;
}
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==descriptionTextField) {
        RouteDescriptionViewController* viewController = [[RouteDescriptionViewController alloc]initWithNibName:@"RouteDescriptionViewController" bundle:nil];
        viewController.descriptionText = descriptionTextField.text;
        viewController.delegate = self;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
        return NO;
    }
    if (textField==locationTextField) {
        RouteLocationViewController* viewController = [[RouteLocationViewController alloc]initWithNibName:@"RouteLocationViewController" bundle:nil];
        PFGeoPoint* gpLoc = [PFGeoPoint geoPointWithLatitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Latitude"] doubleValue] longitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Longitude"] doubleValue]];
        viewController.gpLoc = gpLoc;
        viewController.locationText = locationTextField.text;
        viewController.delegate = self;
        [self.navigationController pushViewController:viewController animated:YES];
        [viewController release];
        return NO;
    }

    if (textField==difficultyTextField){
        gympickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 100, 0,0)];
        gymActionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Difficulty"
                                               delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles:nil];
        
        gympickerView.delegate = self;
        gympickerView.dataSource =self;
        gympickerView.showsSelectionIndicator = YES;
         // note this is default to NO
        [gymActionSheet showInView:self.view];
        
        [gymActionSheet addSubview:gympickerView];
        [gymActionSheet setBounds:CGRectMake(0,0,320, 400)];
        
        
        [gympickerView release];
        [gymActionSheet release];
        return NO;
    }else{
        return YES;
    }
    }
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [gymlist count];
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
   
    return [gymlist objectAtIndex:row];
   
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //turn off facebook switch regardless
    fbuploadswitch.on = false;
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reauthenticate"]){
        NSLog(@"reauthenticating");
        [PFUser logOut];
//        [[PFFacebookUtils facebook] logout];
//        [[PFFacebookUtils facebook] setAccessToken:nil];
        [[PFFacebookUtils session] closeAndClearTokenInformation];
        NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",
                                                                @"user_videos",
                                                                @"user_birthday",
                                                                @"email",
                                                                @"user_photos",
                                                                @"publish_stream",
                                                                @"offline_access",nil];
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            
        }];
        [permissions release];
        }
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]){
        NSLog(@"user cancelled.");
    }    
    
    
}

//rotational code
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else {
        return NO;
    }
}
///////////////////////////////////////////////////////////
//////////////                                /////////////
////////////// creates new gym dynamically deprecated  /////////////
//////////////                                /////////////
///////////////////////////////////////////////////////////
/*
-(void)saveRouteInGym
{
 
    PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
    [gymQuery whereKey:@"facebookid" equalTo:[NSString stringWithFormat:@"%@",[gymSelected objectForKey:@"id"]]];
    [gymQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

        NSLog(@"error = %@",error);
        if ([objects count]>0) {
            [((PFObject*)[objects objectAtIndex:0]) addUniqueObject:[PFUser currentUser].objectId forKey:@"admin"];
            [self performSelector:@selector(saveRouteInGymSelector:) withObject:[objects objectAtIndex:0]];
        }else{
        
            PFObject* newGym = [PFObject objectWithClassName:@"Gym"];
            [newGym setObject:[gymSelected objectForKey:@"id"] forKey:@"facebookid"];
            [newGym setObject:[NSNumber numberWithInt:[[gymSelected objectForKey:@"likes"]intValue]] forKey:@"likes"];
            [newGym setObject:[gymSelected objectForKey:@"name"] forKey:@"name"];
            [newGym setObject:[gymSelected objectForKey:@"picture"] forKey:@"imagelink"];
            [newGym setObject:[gymSelected objectForKey:@"coverimagelink"] forKey:@"coverimagelink"];   
            NSString* aboutString;
            if (![gymSelected objectForKey:@"about"]) {
                aboutString = @"";
            }else{
                aboutString = [gymSelected objectForKey:@"about"];
            }
            [newGym setObject:aboutString forKey:@"about"];
            [newGym setObject:[PFGeoPoint geoPointWithLatitude:routeLoc.latitude longitude:routeLoc.longitude] forKey:@"gymlocation"];       
            NSArray* adminArray = [NSArray arrayWithObjects:[[PFUser currentUser]objectForKey:@"name"], nil];
            [newGym setObject:adminArray forKey:@"admin"];
            [newGym saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
               [self performSelector:@selector(saveRouteInGymSelector:) withObject:newGym]; 
            }];
        }
    }];
}*/
//actually saves the gym route in a gym
-(void)saveRouteInGymSelector:(PFObject*)GymObject
{
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %d for photo upload", self.fileUploadBackgroundTaskId);
        
    PFObject* newRoute = [PFObject objectWithClassName:@"Route"];
    PFGeoPoint* routeGeoPoint = [PFGeoPoint geoPointWithLatitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Latitude"] doubleValue] longitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Longitude"] doubleValue]];
    //PFGeoPoint* spotGeoPoint = [PFGeoPoint geoPointWithLatitude:40.02194 longitude:-105.25067];
    PFGeoPoint* spotGeoPoint = [PFGeoPoint geoPointWithLatitude:1.297346 longitude:103.786908];
    if ([routeGeoPoint distanceInKilometersTo:spotGeoPoint]<=0.5) {
        [newRoute setObject:[NSNumber numberWithBool:YES] forKey:@"spot_route"];
    }else{
        [newRoute setObject:[NSNumber numberWithBool:NO] forKey:@"spot_route"];
    }

    [newRoute setObject:locationTextField.text forKey:@"location"];
  
    NSString* hashtag;
    if ([descriptionTextField.text rangeOfString:@"#"].location != NSNotFound){
        
    NSScanner *scanner = [NSScanner scannerWithString:descriptionTextField.text];
    
    [scanner scanUpToString:@"#" intoString:NULL];
    [scanner setScanLocation:[scanner scanLocation] + 1];
    [scanner scanUpToString:@" " intoString:&hashtag];
    [newRoute setObject:[hashtag lowercaseString] forKey:@"hashtag"];
        [JHNotificationManager notificationWithMessage:[NSString stringWithFormat:@"Found #%@ hashtag =)",[hashtag lowercaseString]]];
    }
    [newRoute setObject:descriptionTextField.text forKey:@"description"];
    [newRoute setObject:[PFGeoPoint geoPointWithLatitude:routeLoc.latitude longitude:routeLoc.longitude] forKey:@"routelocation"];
    [newRoute setObject:difficultyTextField.text forKey:@"difficultydescription"];
    [newRoute setObject:[NSNumber numberWithInt:difficultyint] forKey:@"difficulty"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"commentcount"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"likecount"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"viewcount"];
    [newRoute setObject:[NSNumber numberWithBool:false] forKey:@"outdated"];
    [newRoute setObject:[NSNumber numberWithBool:YES] forKey:@"isPage"];
    [newRoute  setObject:GymObject forKey:@"Gym"];
    UIImage* thumbnailImage = [imageTaken thumbnailImage:200 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbImage.jpeg" data:thumbImageData];
    [queryArray addObject:thumbImageFile];
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [queryArray removeObject:thumbImageFile];
        [newRoute setObject:thumbImageFile forKey:@"thumbImageFile"];
        [newRoute setObject:@"3" forKey:@"routeVersion"];
        [newRoute setObject:CGPointsArray forKey:@"arrowarray"];
        [newRoute setObject:arrowTypeArray forKey:@"arrowtypearray"];
        [newRoute setObject:arrowColorArray forKey:@"arrowcolorarray"];
        NSData *imageData = UIImageJPEGRepresentation(originalImage, 1.0);
        NSData *imageWithArrowsData = UIImageJPEGRepresentation(imageTaken, 1.0);
        
        PFFile *imageFile = [PFFile fileWithName:@"gymNoArrows.jpeg" data:imageData];
        PFFile *imageWithArrows = [PFFile fileWithName:@"gymWithArrows.jpeg" data:imageWithArrowsData];
        NSLog(@"saving...");
        [queryArray addObject:imageWithArrows];
        [imageWithArrows saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [queryArray removeObject:imageWithArrows];
            [queryArray addObject:imageFile];
            //   [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [queryArray removeObject:imageFile];
                [newRoute setObject:imageFile forKey:@"imageFile"];
                [newRoute setObject:imageWithArrows forKey:@"imageFileWithArrows"];
                [newRoute saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    
                    PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                    [feedObject setObject:[GymObject objectForKey:@"name"] forKey:@"sender"];
                    [feedObject setObject:[GymObject objectForKey:@"imagelink"] forKey:@"senderimagelink"];
                    [feedObject setObject:newRoute forKey:@"linkedroute"];
                    [feedObject setObject:[NSString stringWithFormat:@"%@ added a new route",[GymObject objectForKey:@"name"]] forKey:@"message"];
                    [feedObject setObject:@"added" forKey:@"action"];
                    
                    [feedObject saveInBackground];
                    
                    // recommendations or tagging //
                    if ([recommendArray count]>0) {
                        for (PFUser* user in recommendArray) {
                            NSMutableDictionary *data = [NSMutableDictionary dictionary];
                            [data setObject:newRoute.objectId forKey:@"linkedroute"];
                            [data setObject:[NSString stringWithFormat:@"%@ tagged you in a route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
                            [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                            [data setObject:[NSString stringWithFormat:@"%@",[user objectForKey:@"name"]] forKey:@"reciever"];
                            
                            [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[user objectForKey:@"facebookid"]] withData:data];
                        }
                    }
                    // recommendations or tagging end//
                    
                    
                    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",newRoute.objectId]];
                    [HUD hide:YES afterDelay:0];
                    [FlurryAnalytics logEvent:@"COMPLETED_SHARE"];
                    [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
                    [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                    
                    
                }];
                
                
                
                
                
            }
             
             /*progressBlock:^(int percentDone) {
              
              HUD.progress = percentDone/100.0f;
              if (percentDone ==100) {
              HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
              HUD.mode = MBProgressHUDModeCustomView;
              HUD.labelText = @"Completed!";
              
              UIApplication *thisApp = [UIApplication sharedApplication];
              thisApp.idleTimerDisabled = NO;
                           NSLog(@"share action ended");
             
              
              }
              if (percentDone <70 && percentDone>50) {
              HUD.labelText = @"Halfway Done...";
              }
              if (percentDone<100 && percentDone>70) {
              HUD.labelText = @"Almost Done...";
              }
              }*/
             ];
        }];
    }];
    
     [self dismissModalViewControllerAnimated:YES];
}
-(void)saveRoute
{
//no facebook save
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    NSLog(@"Requested background expiration task with id %d for photo upload", self.fileUploadBackgroundTaskId);
    
    
   //
    
    PFObject* newRoute = [PFObject objectWithClassName:@"Route"];
    
    PFGeoPoint* routeGeoPoint = [PFGeoPoint geoPointWithLatitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Latitude"] doubleValue] longitude:[[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Longitude"] doubleValue]];
    //PFGeoPoint* spotGeoPoint = [PFGeoPoint geoPointWithLatitude:40.02194 longitude:-105.25067];
        PFGeoPoint* spotGeoPoint = [PFGeoPoint geoPointWithLatitude:1.297346 longitude:103.786908];
    if ([routeGeoPoint distanceInKilometersTo:spotGeoPoint]<=0.5) {
        [newRoute setObject:[NSNumber numberWithBool:YES] forKey:@"spot_route"];
    }else{
        [newRoute setObject:[NSNumber numberWithBool:NO] forKey:@"spot_route"];
    }

    ///////////////////////////////////////////////////////////
    //////////////                                /////////////
    ////////////// setting fb photoid deprecated  /////////////
    //////////////                                /////////////
    ///////////////////////////////////////////////////////////
    
/*    if (fbuploadswitch.on) {
//        ASIHTTPRequest* accountRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",fbphotoid,[PFFacebookUtils session].accessToken]]];
//        [accountRequest setCompletionBlock:^{
//            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//            NSDictionary *jsonObjects = [jsonParser objectWithString:[accountRequest responseString]];
//            [jsonParser release];
//            jsonParser = nil;
//            [newRoute setObject:[jsonObjects objectForKey:@"source"] forKey:@"fbimagelink"];
//            [newRoute setObject:fbphotoid forKey:@"photoid"];
//            [newRoute saveEventually:^(BOOL succeeded, NSError *error) {
//                NSLog(@"uploaded to facebook and updated newroute pfobj");
//            }];
//            [fbphotoid release];
//                   }];
//        [accountRequest setFailedBlock:^{}];
//        [accountRequest startAsynchronous];
//        
//    }*/

    [newRoute setObject:locationTextField.text forKey:@"location"];
    NSString* hashtag;
    if ([descriptionTextField.text rangeOfString:@"#"].location != NSNotFound){
        NSLog(@"found hashtag!");
        NSScanner *scanner = [NSScanner scannerWithString:descriptionTextField.text];
        
        [scanner scanUpToString:@"#" intoString:NULL];
        [scanner setScanLocation:[scanner scanLocation] + 1];
        [scanner scanUpToString:@" " intoString:&hashtag];
        [newRoute setObject:hashtag forKey:@"hashtag"];
        NSLog(@"sethashtag to %@",hashtag);
    }
    
    [newRoute setObject:descriptionTextField.text forKey:@"description"];
    [newRoute setObject:[PFGeoPoint geoPointWithLatitude:routeLoc.latitude longitude:routeLoc.longitude] forKey:@"routelocation"];
    [newRoute setObject:difficultyTextField.text forKey:@"difficultydescription"];
    [newRoute setObject:[NSNumber numberWithInt:difficultyint] forKey:@"difficulty"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"commentcount"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"likecount"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"viewcount"];
    [newRoute setObject:[NSNumber numberWithBool:false] forKey:@"outdated"];
    [newRoute setObject:[NSNumber numberWithBool:false] forKey:@"isPage"];
    UIImage* thumbnailImage = [imageTaken thumbnailImage:200 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbImage.jpeg" data:thumbImageData];
    NSLog(@"before uploading thumb");
    [queryArray addObject:thumbImageFile];
     [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
         

    [queryArray removeObject:thumbImageFile];
        NSLog(@"after uploading thumb");
    [newRoute setObject:thumbImageFile forKey:@"thumbImageFile"];
    [newRoute setObject:@"3" forKey:@"routeVersion"];
    [newRoute setObject:CGPointsArray forKey:@"arrowarray"];
        [newRoute setObject:arrowTypeArray forKey:@"arrowtypearray"];
         [newRoute setObject:arrowColorArray forKey:@"arrowcolorarray"];
    NSData *imageData = UIImageJPEGRepresentation(originalImage, 1.0);
    NSData *imageWithArrowsData = UIImageJPEGRepresentation(imageTaken, 1.0);
    PFFile *imageFile = [PFFile fileWithName:@"noArrows.jpeg" data:imageData];
    PFFile *imageWithArrows = [PFFile fileWithName:@"gymWithArrows.jpeg" data:imageWithArrowsData];
    NSLog(@"saving...");
    [queryArray addObject:imageWithArrows];
    [imageWithArrows saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [queryArray removeObject:imageWithArrows];
                NSLog(@"done saving imagewith arrows");
        [newRoute setObject:imageWithArrows forKey:@"imageFileWithArrows"];
        NSLog(@"saving imagefile");
    [queryArray addObject:imageFile];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [queryArray removeObject:imageFile];
                NSLog(@"done saving imagefile");
        [newRoute setObject:imageFile forKey:@"imageFile"];
        NSLog(@"saving new route");
        [newRoute saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            NSLog(@"done saving new route");
            PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
            [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
            [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
            [feedObject setObject:newRoute forKey:@"linkedroute"];
            [feedObject setObject:imageFile forKey:@"imagefile"];
            [feedObject setObject:@"added" forKey:@"action"];
            if (![[newRoute objectForKey:@"location"] isEqualToString:@""]) {
                [feedObject setObject:[NSString stringWithFormat:@"%@ added a new route at %@",[[PFUser currentUser] objectForKey:@"name"],[newRoute objectForKey:@"location"]] forKey:@"message"];
            }else{
                [feedObject setObject:[NSString stringWithFormat:@"%@ added a new route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"message"];
            }
            
            [feedObject saveInBackground];
            if ([recommendArray count]>0) {
                for (PFUser* user in recommendArray) {
                    NSMutableDictionary *data = [NSMutableDictionary dictionary];
                    [data setObject:newRoute.objectId forKey:@"linkedroute"];
                    [data setObject:[NSString stringWithFormat:@"%@ tagged you in a route",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
                    [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                    [data setObject:[NSString stringWithFormat:@"%@",[user objectForKey:@"name"]] forKey:@"reciever"];
                    
                    [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[user objectForKey:@"facebookid"]] withData:data];
                }
            }
            
            
            
            [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",newRoute.objectId]];
            NSLog(@"upload completed successfully in background!");
            //FIXME: to do here
            
            ASIHTTPRequest* routeUpdater = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.psychedapp.com/routepost/%@",newRoute.objectId]]];
            [routeUpdater setShouldContinueWhenAppEntersBackground:YES];
            [routeUpdater setTimeOutSeconds:30];
            [routeUpdater setRequestMethod:@"PUT"];
            [routeUpdater setCompletionBlock:^{
                
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"ogshare"]) {
                    NSLog(@"og share enabled!");
                    NSLog(@"route created on heroku ... now posting og");
                [self performSelector:@selector(postOG:) withObject:newRoute afterDelay:3.0];
                }
            }];
            [routeUpdater setFailedBlock:^{
                NSLog(@"failed to create route, trying again");
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
            [routeUpdater startAsynchronous];
            
            
            
                 
            
            
            
        }];
        
        
        
        
        
    }];
 
         }];
    }];
    [self dismissModalViewControllerAnimated:YES];
}
-(void)postOG:(PFObject*)newRoute
{
    if(fbuploadswitch.on){
        NSLog(@"image url = %@",((PFFile*)[newRoute objectForKey:@"imageFileWithArrows"]).url);
        ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/climbing_:add"]];
        [newOGPost setPostValue:@"true" forKey:@"fb:explicitly_shared"];
        [newOGPost setPostValue:[PFFacebookUtils session].accessToken forKey:@"access_token"];
        [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",newRoute.objectId] forKey:@"route"];
        [newOGPost setPostValue:[NSString stringWithFormat:@"%@",descriptionTextField.text] forKey:@"message"];
//        [newOGPost setPostValue:((PFFile*)[newRoute objectForKey:@"imageFileWithArrows"]).url forKey:@"image[0][url]"];
//        [newOGPost setPostValue:@"true" forKey:@"image[0][user_generated]"];
        [newOGPost setRequestMethod:@"POST"];
        [newOGPost setCompletionBlock:^{
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
            [jsonParser release];
            jsonParser = nil;
            if ([jsonObjects objectForKey:@"id"]) {
                NSLog(@"posted og added, %@",[newOGPost responseString]);
                [newRoute setObject:[jsonObjects objectForKey:@"id"] forKey:@"opengraphid"];
                [newRoute saveEventually];
                [JHNotificationManager notificationWithMessage:@"Successfully uploaded your route!"];
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                //   [self postNewLikeWithOG:[jsonObjects objectForKey:@"id"] andLikeCounter:likecounter];
            }else{
                NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                // [self postNewLikeWithOG:nil andLikeCounter:likecounter];
                 [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }
            
        }];
        
        
        [newOGPost setFailedBlock:^{
            NSLog(@"failed");
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        [newOGPost setTimeOutSeconds:30];
        [newOGPost startAsynchronous];
        NSLog(@"finished posting");
        

        
        
        
        
//        postOG = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://psychedsupport.herokuapp.com/support/%@?og=true&access_token=%@&explicit=true&imageurl=%@&image",newRoute.objectId,[PFFacebookUtils session].accessToken,arrowed.url,tagString]]];
//        NSLog(@"postog url = %@",postOG.url);
    }else{
        //silent mode post action
        NSLog(@"image url = %@",((PFFile*)[newRoute objectForKey:@"imageFileWithArrows"]).url);
        ASIFormDataRequest* newOGPost = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"https://graph.facebook.com/me/climbing_:add"]];

        [newOGPost setPostValue:[PFFacebookUtils session].accessToken forKey:@"access_token"];
        [newOGPost setPostValue:[NSString stringWithFormat:@"http://www.psychedapp.com/home/%@",newRoute.objectId] forKey:@"route"];
        [newOGPost setRequestMethod:@"POST"];
        [newOGPost setCompletionBlock:^{
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
            [jsonParser release];
            jsonParser = nil;
            if ([jsonObjects objectForKey:@"id"]) {
                NSLog(@"posted og added, %@",[newOGPost responseString]);
                [newRoute setObject:[jsonObjects objectForKey:@"id"] forKey:@"opengraphid"];
                [newRoute saveEventually];
                [JHNotificationManager notificationWithMessage:@"Successfully uploaded your route!"];
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                //   [self postNewLikeWithOG:[jsonObjects objectForKey:@"id"] andLikeCounter:likecounter];
            }else{
                NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                 [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
                // [self postNewLikeWithOG:nil andLikeCounter:likecounter];
            }
            
        }];
        
        
        [newOGPost setFailedBlock:^{
            NSLog(@"failed");
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }];
        [newOGPost setTimeOutSeconds:30];
        [newOGPost startAsynchronous];
        NSLog(@"finished posting");
    }
//    [postOG setCompletionBlock:^{
//        NSLog(@"added og with response \n %@",postOG.responseString);
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        NSDictionary *jsonObjects = [jsonParser objectWithString:[postOG responseString]];
//        [jsonParser release];
//        jsonParser = nil;
//        [newRoute setObject:[jsonObjects objectForKey:@"id"] forKey:@"opengraphid"];
//        [newRoute saveEventually];
//        [JHNotificationManager notificationWithMessage:@"Successfully uploaded your route!"];
//        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
//    }];
//    [postOG setFailedBlock:^{
//        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
//    }];
//    [postOG setTimeOutSeconds:30];
//    [postOG startAsynchronous];

    
    
        // no action needed, its fire and forget mode
   }
- (IBAction)saveAction:(id)sender
{
    if ([locationTextField.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please fill in route location" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    if ([descriptionTextField.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please fill in route description" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    if ([difficultyTextField.text isEqualToString:@""]) {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Please fill in route difficulty" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
        return;
    }
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"followed" equalTo:[[PFUser currentUser] objectForKey:@"name"]];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [recommendArray removeAllObjects];
        for (PFObject* follow in objects) {
            [recommendArray addObject:[follow objectForKey:@"follower"]];
        }
        NSLog(@"my friends are = %@",recommendArray);
    }];


    
    if (twuploadswitch.on) {
        //twitter on
        if ([TWTweetComposeViewController canSendTweet])
        {
            TWTweetComposeViewController *tweetSheet = 
            [[TWTweetComposeViewController alloc] init];
            if([tweetSheet setInitialText:[NSString stringWithFormat:@"%@",descriptionTextField.text]]){
                [tweetSheet setInitialText:[NSString stringWithFormat:@"%@",descriptionTextField.text]];
            }else{
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Too Long For Tweet" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
                [tweetSheet release];
                return;
            }
            [tweetSheet addImage:imageTaken];
            [tweetSheet setCompletionHandler: 
             ^(TWTweetComposeViewControllerResult result) {
                 if (result==TWTweetComposeViewControllerResultDone) { // after saving with twitter go on to save on parse
                     [self dismissModalViewControllerAnimated:YES];
                     ((UIButton*)sender).enabled =NO;
                     UIApplication *thisApp = [UIApplication sharedApplication];
                     thisApp.idleTimerDisabled = YES;
                  
                     
//                     if (fbuploadswitch.on) {
//                         HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
//                         if (isPage) {
//                                                      NSLog(@"sharing with facebook page");
//                             [self performSelector:@selector(apiGraphPagePhotosPost:) withObject:imageTaken afterDelay:0.0];
//                             HUD.labelText = @"Uploading to Facebook...";
//                         }else {
//                                                      NSLog(@"sharing with facebook self page");
//                            [self performSelector:@selector(apiGraphUserPhotosPost:) withObject:imageTaken afterDelay:0.0];
//                             HUD.labelText = @"Uploading to Facebook...";
//
//                         }
//                         
//                     
//                         
//                     }else{
                         [self performSelector:@selector(saveRoute) withObject:nil afterDelay:4.0];

//                     }
                     
                     
                     
                 }else{
                     NSLog(@"twitter result is something else other than done");
                 }
             }];
            [self presentModalViewController:tweetSheet animated:YES];
            [tweetSheet release];
        }else{
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Couldn't send Tweet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Settings",nil];
            [alert show];
            [alert release];
        }
    }
    else{

        ///////////////////////////////////////////////////////////
        //////////////                                /////////////
        //////////////      If Twitter is off         /////////////
        //////////////                                /////////////
        ///////////////////////////////////////////////////////////
        
        
        ((UIButton*)sender).enabled =NO;
        UIApplication *thisApp = [UIApplication sharedApplication];
        thisApp.idleTimerDisabled = YES;
        
        
        
/*        if (fbuploadswitch.on) {
//            HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES] retain];
//            if (isPage) {
//                [self performSelector:@selector(apiGraphPagePhotosPost:) withObject:imageTaken afterDelay:0.0];
//                HUD.labelText = @"Uploading to Facebook...";
//                return;                
//            }else {
//                [self performSelector:@selector(apiGraphUserPhotosPost:) withObject:imageTaken afterDelay:0.0];
//                HUD.labelText = @"Uploading to Facebook...";
//                return;
//            }
//            }*/
        if(gymSwitch.on){
                
            NSLog(@"saving route in gym selector...");
                    [self performSelector:@selector(saveRouteInGymSelector:) withObject:selectedGymObject afterDelay:0.0];

                return;

            }
            
        [self performSelector:@selector(saveRoute) withObject:nil afterDelay:0.0];

        
   
        
        
    }
     
}
- (IBAction)closeAction:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"share action ended");
    [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
}
- (void)dealloc
{
    if( myRequest ) {
        [[myRequest connection] cancel];
        [myRequest release];
         }
    [selectedGymObject release];
    [gymlist release];
    [oldAccessToken release];
    [locationManager release];
    [segControl release];
    [locationTextField release];
    [descriptionTextField release];
    [imageView release];
    [scroll release];
    [recommendArray release];
    [recommendTextField release];
    [recommendTextView release];
    [fbuploadswitch release];
    [routeLocMapView release];
    [difficultyTextField release];
    [twuploadswitch release];
    [routeImageView release];
    [fblabel release];
    [socialControls release];
    [gymControls release];
    [gymSwitch release];
    [gymShareLabel release];
    [super dealloc];
}



- (IBAction)gymSwitchValueChanged:(UISwitch*)sender
{
    if (sender.on) {
        [fbuploadswitch setOn:NO];
        [twuploadswitch setOn:NO];
        
        for (UIView* view in socialControls) {
            
            view.hidden = YES;
        }
        //fetch gyms and display in action sheet
        PFQuery* queryForGym = [PFQuery queryWithClassName:@"Gym"];
        [queryForGym whereKey:@"admin" equalTo:[PFUser currentUser].objectId];
        [queryForGym findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]==0) {
                for (UIView* view in socialControls) {
                    view.hidden = NO;
                }
                for (UIView* view in gymControls) {
                    view.hidden = YES;
                }
            }else{
                if ([objects count]>1) {
#warning multiple gyms not supported yet!
                    selectedGymObject = [[objects objectAtIndex:0]retain];
                    gymShareLabel.text = [NSString stringWithFormat:@"Share as %@",[selectedGymObject objectForKey:@"name"]];
                }else{
                    selectedGymObject = [[objects objectAtIndex:0] retain];
                    gymShareLabel.text = [NSString stringWithFormat:@"Share as %@",[selectedGymObject objectForKey:@"name"]];
                }
            }
        }];
    }else{
        for (UIView* view in socialControls) {
            view.hidden = NO;
        }
    }
}
- (void)startStandardUpdates
{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    [locationManager startUpdatingLocation];
}
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
    }
    // else skip the event and process the next one.
}
@end
