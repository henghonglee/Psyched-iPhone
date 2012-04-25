//
//  CreateRouteViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
@synthesize accounts;
@synthesize arrayOfAccounts;
@synthesize fbAccountPickerView,accountActionSheet;
@synthesize routeLocMapView;
@synthesize recommendTextField;
@synthesize routeImageView;
@synthesize imageMetaData;
@synthesize locationManager;
@synthesize myRequest;
@synthesize fbuploadswitch;
@synthesize twuploadswitch;
@synthesize imageView,imageTaken;
@synthesize segControl;
@synthesize locationTextField;
@synthesize descriptionTextField;
@synthesize scroll;
@synthesize recommendTextView;
@synthesize gymlist;
@synthesize tempArray;
@synthesize friendsArray;
@synthesize FBfriendsArray;
@synthesize recommendArray;
@synthesize difficultyTextField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
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
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    routeImageView.image = imageTaken;
    routeImageView.layer.borderColor = [UIColor whiteColor].CGColor;    
    routeImageView.layer.borderWidth = 3;

    routeLocMapView.layer.borderColor = [UIColor whiteColor].CGColor;
    routeLocMapView.layer.borderWidth = 3;
    routeLoc = CLLocationCoordinate2DMake([[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Latitude"] doubleValue], [[[imageMetaData objectForKey:@"{GPS}"] objectForKey:@"Longitude"] doubleValue]);
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Upload" style:UIBarButtonSystemItemDone target:self action:@selector(saveAction:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];
    [routeLocMapView setCenterCoordinate:routeLoc zoomLevel:14 animated:NO];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Add Route";
    recommendArray = [[NSMutableArray alloc]init];
    friendsArray = [[NSMutableArray alloc]init ];

    tempArray=[[NSMutableArray alloc]init ];
    
    arrayOfAccounts = [[NSMutableArray alloc]init ];  
    accounts = [[NSArray alloc]init];
    //[PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];

    
    //PFQuery* query = [PFQuery queryForUser];
    //[friendsArray addObjectsFromArray:[query findObjects]];


    
    //[tempArray addObjectsFromArray:friendsArray];
  
    imageView.image = imageTaken;
//    scroll.contentSize = CGSizeMake(320,620);
    gymlist = [[NSArray alloc]initWithObjects:@"------",@"V0-V2", @"V3-V5",@"V6-V8",@"V9-V11",@"V12",@"V13",@"V14",@"V15",@"V16",@"V16+", nil];
  
  
    // Do any additional setup after loading the view from its nib.
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
    [self setFbuploadswitch:nil];    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)DescriptionDidReturnWithText:(NSString *)text
{
    descriptionTextField.text = text;
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
    if (textField == recommendTextField) {
        FriendTaggerViewController* viewController = [[FriendTaggerViewController alloc]initWithNibName:@"FriendTaggerViewController" bundle:nil];
//        viewController.friendsArray = friendsArray;
        viewController.recommendArray = recommendArray;
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
    NSLog(@"picker lookingforrows = %@",pickerView);
    if (pickerView==fbAccountPickerView) {
        //return 0;
         return [arrayOfAccounts count];
    }else{
    return [gymlist count];
    }
}
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView==fbAccountPickerView) {
        return [[arrayOfAccounts objectAtIndex:row] objectForKey:@"name"];   
    }else{
    return [gymlist objectAtIndex:row];
    }
}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet == accountActionSheet) {
       
        if ([[[arrayOfAccounts objectAtIndex:[fbAccountPickerView selectedRowInComponent:0]]objectForKey:@"name"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
            isPage = NO;
        }else{
            if ([[[arrayOfAccounts objectAtIndex:[fbAccountPickerView selectedRowInComponent:0]]objectForKey:@"likes"]intValue]<50) {
                isPage = NO;
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Not Enough Likes on your page" message:@"You need at least 50 likes on your page to post as a page" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
                [alert release];
            }else{
            isPage = YES;
            arrIndex = [fbAccountPickerView selectedRowInComponent:0];
            }
        }
        }else{
    difficultyTextField.text = [gymlist objectAtIndex:[gympickerView selectedRowInComponent:0]];
    difficultyint = [gympickerView selectedRowInComponent:0];
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
-(void)saveRouteInGym{
    
    NSDictionary* gymSelected = [arrayOfAccounts objectAtIndex:arrIndex];
  
    //find out if the gym object exists , if not create it with the obj dictionary in arrayOfAccounts
    PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
    [gymQuery whereKey:@"facebookid" equalTo:[NSString stringWithFormat:@"%@",[gymSelected objectForKey:@"id"]]];
    [gymQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
            NSMutableArray* adminarray = [[NSMutableArray alloc]initWithArray:((NSArray*)[object objectForKey:@"admin"])];
            [adminarray addObject:[PFUser currentUser].objectId];
            [object setObject:adminarray forKey:@"admin"];
            [adminarray release];
            [self performSelector:@selector(saveRouteInGymSelector:) withObject:object];
        }else{
            PFObject* newGym = [PFObject objectWithClassName:@"Gym"];
            [newGym setObject:[gymSelected objectForKey:@"id"] forKey:@"facebookid"];
            [newGym setObject:[NSNumber numberWithInt:[[gymSelected objectForKey:@"likes"]intValue]] forKey:@"likes"];
            [newGym setObject:[gymSelected objectForKey:@"name"] forKey:@"name"];
            [newGym setObject:[gymSelected objectForKey:@"picture"] forKey:@"imagelink"];
            [newGym setObject:[gymSelected objectForKey:@"coverimagelink"] forKey:@"coverimagelink"];
            [newGym setObject:[gymSelected objectForKey:@"about"] forKey:@"about"];
            [newGym setObject:[PFGeoPoint geoPointWithLatitude:routeLoc.latitude longitude:routeLoc.longitude] forKey:@"gymlocation"];
            NSArray* adminArray = [NSArray arrayWithObjects:[[PFUser currentUser]objectForKey:@"name"], nil];
            
            [newGym setObject:adminArray forKey:@"admin"];
            [newGym saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
               [self performSelector:@selector(saveRouteInGymSelector:) withObject:newGym]; 
            }];
        }
    }];
}

-(void)saveRouteInGymSelector:(PFObject*)GymObject
{
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Uploading...";
    
    PFObject* newRoute = [PFObject objectWithClassName:@"Route"];
    if (fbuploadswitch.on) {
        [newRoute setObject:fbphotoid forKey:@"photoid"];  
        [fbphotoid release];
    }
    [newRoute setObject:locationTextField.text forKey:@"location"];
    if ([recommendArray count]>0) {
        descriptionTextField.text = [descriptionTextField.text stringByAppendingFormat:@"(%@)  ",[gymlist objectAtIndex:difficultyint]];
        
        for (FBfriend*user in recommendArray) {
            descriptionTextField.text = [descriptionTextField.text stringByAppendingFormat:@"@%@ ",user.name];
        }
        
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
    NSMutableArray* usersrecommended = [[NSMutableArray alloc]init];
    for (FBfriend* friend in recommendArray) {
        [usersrecommended addObject:friend.name];
    }
    [newRoute setObject:usersrecommended forKey:@"usersrecommended"];
    [usersrecommended release];
    UIImage* thumbnailImage = [imageTaken thumbnailImage:200 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbImage.jpeg" data:thumbImageData];
    [thumbImageFile save];
    [newRoute setObject:thumbImageFile forKey:@"thumbImageFile"];
    
    
    NSData *imageData = UIImageJPEGRepresentation(imageTaken, 1.0);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
    NSLog(@"saving...");
    
    //   [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [newRoute setObject:imageFile forKey:@"imageFile"];
        
        [newRoute saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
            [feedObject setObject:[GymObject objectForKey:@"name"] forKey:@"sender"];
            [feedObject setObject:[GymObject objectForKey:@"imagelink"] forKey:@"senderimagelink"];
            [feedObject setObject:newRoute forKey:@"linkedroute"];
            [feedObject setObject:[NSString stringWithFormat:@"%@ added a new route",[GymObject objectForKey:@"name"]] forKey:@"message"];
            [feedObject setObject:@"added" forKey:@"action"];
            
            [feedObject saveInBackground];
            
            //recommendations or tagging
            
            if ([recommendArray count]>0) {
                NSLog(@"recommend array count = %d", [recommendArray count]);
                for (FBfriend* user in recommendArray) {
                    NSMutableDictionary *data = [NSMutableDictionary dictionary];
                    [data setObject:newRoute.objectId forKey:@"linkedroute"];
                    [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
                    [data setObject:[NSString stringWithFormat:@"%@ tagged you in a route",[[PFUser currentUser] objectForKey:@"name"],[newRoute objectForKey:@"username"]] forKey:@"alert"];
                    [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                    [data setObject:[NSString stringWithFormat:@"%@",user.name] forKey:@"reciever"];
                    
                    [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",user.uid] withData:data];
                    
                                        
                    
                    
                    
                }

                if ([recommendArray count]==1) {
                FBfriend*user = [recommendArray objectAtIndex:0];                
                PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
                [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
                [feedObject setObject:newRoute forKey:@"linkedroute"];
                [feedObject setObject:imageFile forKey:@"imagefile"];
                [feedObject setObject:@"tag" forKey:@"action"];
                [feedObject setObject:[NSString stringWithFormat:@"%@ tagged %@ in a route",[[PFUser currentUser] objectForKey:@"name"],user.name] forKey:@"message"];
                
                [feedObject saveInBackground];

                }else if ([recommendArray count]==2){
                    FBfriend*user = [recommendArray objectAtIndex:0];
                    PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
                    [feedObject setObject:newRoute forKey:@"linkedroute"];
                    [feedObject setObject:imageFile forKey:@"imagefile"];
                    [feedObject setObject:@"tag" forKey:@"action"];
                    [feedObject setObject:[NSString stringWithFormat:@"%@ tagged %@ and %d other in a route",[[PFUser currentUser] objectForKey:@"name"],user.name,1] forKey:@"message"];
                    
                    [feedObject saveInBackground];   
                }else{
                    FBfriend*user = [recommendArray objectAtIndex:0];
                    PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
                    [feedObject setObject:newRoute forKey:@"linkedroute"];
                    [feedObject setObject:imageFile forKey:@"imagefile"];
                    [feedObject setObject:@"tag" forKey:@"action"];
                    [feedObject setObject:[NSString stringWithFormat:@"%@ tagged %@ and %d others in a route",[[PFUser currentUser] objectForKey:@"name"],user.name,[recommendArray count]-1] forKey:@"message"];
                    
                    [feedObject saveInBackground];
                }
                
                
                
            }
            [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",newRoute.objectId]];
            [HUD hide:YES afterDelay:0];
            [self dismissModalViewControllerAnimated:YES];
            
            
            
        }];
        
        
        
        
        
    } progressBlock:^(int percentDone) {
        
        HUD.progress = percentDone/100.0f;
        if (percentDone ==100) {
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"Completed!";
            
            UIApplication *thisApp = [UIApplication sharedApplication];
            thisApp.idleTimerDisabled = NO;
            [FlurryAnalytics logEvent:@"COMPLETED_SHARE"];
            NSLog(@"share action ended");
            [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
            
        }
        if (percentDone <70 && percentDone>50) {
            HUD.labelText = @"Halfway Done...";
        }
        if (percentDone<100 && percentDone>70) {
            HUD.labelText = @"Almost Done...";
        }
    }];
    
}

-(void)saveRoute
{

    
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText = @"Uploading...";
    
    PFObject* newRoute = [PFObject objectWithClassName:@"Route"];
    if (fbuploadswitch.on) {
    [newRoute setObject:fbphotoid forKey:@"photoid"];  
        [fbphotoid release];
    }
    [newRoute setObject:locationTextField.text forKey:@"location"];
    if ([recommendArray count]>0) {
        descriptionTextField.text = [descriptionTextField.text stringByAppendingFormat:@"(%@)  ",[gymlist objectAtIndex:difficultyint]];
        
        for (FBfriend*user in recommendArray) {
            descriptionTextField.text = [descriptionTextField.text stringByAppendingFormat:@"@%@ ",user.name];
        }
        
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
    NSMutableArray* usersrecommended = [[NSMutableArray alloc]init];
    for (FBfriend* friend in recommendArray) {
        [usersrecommended addObject:friend.name];
    }
    [newRoute setObject:usersrecommended forKey:@"usersrecommended"];
    [usersrecommended release];
    UIImage* thumbnailImage = [imageTaken thumbnailImage:200 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    NSData *thumbImageData = UIImageJPEGRepresentation(thumbnailImage, 1.0);
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbImage.jpeg" data:thumbImageData];
     [thumbImageFile save];
    [newRoute setObject:thumbImageFile forKey:@"thumbImageFile"];
    
    
    NSData *imageData = UIImageJPEGRepresentation(imageTaken, 1.0);
    PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
    NSLog(@"saving...");

    //   [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
        [newRoute setObject:imageFile forKey:@"imageFile"];
        
        [newRoute saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        
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
                NSLog(@"recommend array count = %d", [recommendArray count]);
                for (FBfriend* user in recommendArray) {
                    NSMutableDictionary *data = [NSMutableDictionary dictionary];
                    [data setObject:newRoute.objectId forKey:@"linkedroute"];
                    [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
                    [data setObject:[NSString stringWithFormat:@"%@ tagged you in a route",[[PFUser currentUser] objectForKey:@"name"],[newRoute objectForKey:@"username"]] forKey:@"alert"];
                    [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                    [data setObject:[NSString stringWithFormat:@"%@",user.name] forKey:@"reciever"];
                    
                    [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",user.uid] withData:data];
                    
                    PFObject* feedObject = [PFObject objectWithClassName:@"Feed"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
                    [feedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
                    [feedObject setObject:newRoute forKey:@"linkedroute"];
                    [feedObject setObject:imageFile forKey:@"imagefile"];
                    [feedObject setObject:@"tag" forKey:@"action"];
                    [feedObject setObject:[NSString stringWithFormat:@"%@ tagged %@ in a route",[[PFUser currentUser] objectForKey:@"name"],user.name] forKey:@"message"];
                    
                    [feedObject saveInBackground];
                    
                    
                    
                    
                }
                
                
                
                
                
            }
            
            
            
            [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",newRoute.objectId]];
                [HUD hide:YES afterDelay:0];
                 [self dismissModalViewControllerAnimated:YES];
            
            
            
        }];
        
        
        
        
        
    } progressBlock:^(int percentDone) {

        HUD.progress = percentDone/100.0f;
        if (percentDone ==100) {
            HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.labelText = @"Completed!";

            UIApplication *thisApp = [UIApplication sharedApplication];
            thisApp.idleTimerDisabled = NO;
            [FlurryAnalytics logEvent:@"COMPLETED_SHARE"];
            NSLog(@"share action ended");
            [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
            
        }
        if (percentDone <70 && percentDone>50) {
            HUD.labelText = @"Halfway Done...";
        }
        if (percentDone<100 && percentDone>70) {
            HUD.labelText = @"Almost Done...";
        }
    }];
    
}
- (IBAction)saveAction:(id)sender {
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
    if (twuploadswitch.on) {
        
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
                return;
            }
            [tweetSheet addImage:imageTaken];
            [tweetSheet addURL:[NSURL URLWithString:@"http://bit.ly/HSTcNw"]];
            [tweetSheet setCompletionHandler: 
             ^(TWTweetComposeViewControllerResult result) {
                 if (result==TWTweetComposeViewControllerResultDone) {
                     [self dismissModalViewControllerAnimated:YES];
                     ((UIButton*)sender).enabled =NO;
                     UIApplication *thisApp = [UIApplication sharedApplication];
                     thisApp.idleTimerDisabled = YES;
                     HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES]retain];
                     
                     if (fbuploadswitch.on) {
                         if (isPage) {
                             [self performSelector:@selector(apiGraphPagePhotosPost:) withObject:imageTaken afterDelay:0.0];
                             HUD.labelText = @"Uploading...";
                         }else {
                             [self performSelector:@selector(apiGraphUserPhotosPost:) withObject:imageTaken afterDelay:0.0];
                             HUD.labelText = @"Uploading...";
                         }
                         
                     } else{
                         [self performSelector:@selector(saveRoute) withObject:nil afterDelay:0.0];
                         HUD.labelText = @"Preparing...";
                     }
                     
                     
                     
                 }else{
                     
                 }
             }];
            [self presentModalViewController:tweetSheet animated:YES];
             
        }else{
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Couldn't send Tweet" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Settings",nil];
            [alert show];
            [alert release];
        }
    }else{
        ((UIButton*)sender).enabled =NO;
        UIApplication *thisApp = [UIApplication sharedApplication];
        thisApp.idleTimerDisabled = YES;
        HUD = [[MBProgressHUD showHUDAddedTo:self.view animated:YES]retain];
        
        if (fbuploadswitch.on) {
            if (isPage) {
                [self performSelector:@selector(apiGraphPagePhotosPost:) withObject:imageTaken afterDelay:0.0];
                HUD.labelText = @"Uploading...";
            }else {
                [self performSelector:@selector(apiGraphUserPhotosPost:) withObject:imageTaken afterDelay:0.0];
                HUD.labelText = @"Uploading...";
            }

        } else{
            [self performSelector:@selector(saveRoute) withObject:nil afterDelay:0.0];
            HUD.labelText = @"Preparing...";
        }
        //[PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        
    }
     
}
- (IBAction)closeAction:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"share action ended");
    [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
}


- (void)dealloc {
    if( myRequest ) {
        [[myRequest connection] cancel];
        [myRequest release];
         }
    [oldAccessToken release];
    [locationManager release];
    [segControl release];
    [locationTextField release];
    [descriptionTextField release];
    [imageView release];
    [scroll release];
    [friendsArray release];
    [tempArray release];
    [recommendArray release];
    [recommendTextField release];
    [recommendTextView release];
    [fbuploadswitch release];
    [routeLocMapView release];
    [difficultyTextField release];
    [twuploadswitch release];
    [routeImageView release];
    [super dealloc];
}



-(void)TaggerDidReturnWithRecommendedArray:(NSMutableArray *)recommendedArray
{

    recommendTextField.text = @"";
    for (FBfriend* user in recommendedArray) {
        if ([recommendTextField.text isEqualToString:@""]) {
            recommendTextField.text = [NSString stringWithFormat:@"%@",user.name];
        }else{
        recommendTextField.text = [recommendTextField.text stringByAppendingFormat:@",%@",user.name];   
        }
    }
}



- (void)apiGraphUserPhotosPost:(UIImage*)img {
    currentAPIcall = kAPIGraphUserPhotosPost;
    UIImage* resizedimg = [img resizedImage:CGSizeMake(960, 960) interpolationQuality:kCGInterpolationHigh];
    
    UIGraphicsEndImageContext();
    NSMutableArray* tags = [[NSMutableArray alloc]init];
   for (FBfriend* user in recommendArray) {
        NSMutableDictionary* tag = [NSMutableDictionary dictionaryWithObjectsAndKeys:user.uid ,@"tag_uid",@"50",@"x",@"50",@"y",nil];
        [tags addObject:tag];
    }
    SBJSON *jsonWriter = [[SBJSON new] autorelease];
    
    // The action links to be shown with the post in the feed
   // NSArray* actionLinks = [NSArray arrayWithObjects:tags, nil];
    NSString *actionLinksStr = [jsonWriter stringWithObject:tags];
    [tags release];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   resizedimg, @"picture",descriptionTextField.text,@"name",@"960",@"height",@"960",@"width",actionLinksStr,@"tags",
                                   nil];

    [[PFFacebookUtils facebook] requestWithGraphPath:@"me/photos"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
}

-(IBAction)facebookswitchon:(UISwitch*)sender{
    if (sender.on) {
    ASIHTTPRequest* accountRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/accounts&access_token=%@",[PFFacebookUtils facebook].accessToken]]];
    [accountRequest setCompletionBlock:^{
        NSDictionary *contentOfDictionary = [[accountRequest responseString]JSONValue];
        NSLog(@"%@",[accountRequest responseString]);
        accounts = [contentOfDictionary objectForKey:@"data"];
       
        if ([accounts count]){
        pagesHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            pagesHUD.labelText = @"Fetching your managed pages";
            [self performSelectorInBackground:@selector(presentAccountsSheet:) withObject:accounts];
            
        }
    }];
        
        
        [accountRequest setFailedBlock:^{}];
        [accountRequest startAsynchronous];

    
    }
     
}
-(void)presentAccountsSheet:(NSArray*)fetchedAccounts{
    [arrayOfAccounts removeAllObjects];
    for (NSDictionary* obj in fetchedAccounts) {
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@&access_token=%@",[NSString stringWithFormat:@"%@",[obj objectForKey:@"id"],[obj objectForKey:@"access_token"]]]]];
        [request startSynchronous];   
        NSDictionary *contentDictionary = [[request responseString]JSONValue];
        NSLog(@"canpost = %@",[contentDictionary objectForKey:@"can_post"]);    
        [obj setValue:[contentDictionary objectForKey:@"likes"] forKey:@"likes"];
        [obj setValue:[contentDictionary objectForKey:@"picture"] forKey:@"picture"];
        [obj setValue:[contentDictionary objectForKey:@"id"] forKey:@"id"];
        [obj setValue:[[contentDictionary objectForKey:@"cover"]objectForKey:@"source"] forKey:@"coverimagelink"];
        [obj setValue:[contentDictionary objectForKey:@"about"] forKey:@"about"];
        if ([contentDictionary objectForKey:@"can_post"]) {
            
            [arrayOfAccounts addObject:obj];
            
        }
        
        
        
    }
    [pagesHUD hide:YES];
    if ([arrayOfAccounts count]) {
        NSDictionary* userDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectForKey:@"name"],@"name",[PFFacebookUtils facebook].accessToken,@"access_token", nil];
        [arrayOfAccounts addObject:userDictionary];
        NSLog(@"arr = %@",arrayOfAccounts);
        fbAccountPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 100, 0,0)];
        accountActionSheet = [[UIActionSheet alloc] initWithTitle:@"Share as :"
                                                         delegate:self cancelButtonTitle:@"Done" destructiveButtonTitle:nil otherButtonTitles:nil];
        
        fbAccountPickerView.delegate = self;
        fbAccountPickerView.dataSource =self;
        fbAccountPickerView.showsSelectionIndicator = YES;
        // note this is default to NO
        [accountActionSheet showInView:self.view];
        
        [accountActionSheet addSubview:fbAccountPickerView];
        [accountActionSheet setBounds:CGRectMake(0,0,320, 400)];
        
        
        [fbAccountPickerView release];
        [accountActionSheet release];
        
    }

}
- (void)apiGraphPagePhotosPost:(UIImage*)img {
    currentAPIcall = kAPIGraphPagePhotosPost;
    oldAccessToken = [PFFacebookUtils facebook].accessToken;
    [oldAccessToken retain];
    UIImage* resizedimg = [img resizedImage:CGSizeMake(960, 960) interpolationQuality:kCGInterpolationHigh];
    
    UIGraphicsEndImageContext();

    
       
    
                        [[PFFacebookUtils facebook]setAccessToken:[NSString stringWithFormat:@"%@",[[arrayOfAccounts objectAtIndex:arrIndex] objectForKey:@"access_token"]]];
                        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                       resizedimg, @"source",descriptionTextField.text,@"message",
                                                       nil];
                        
                        [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/photos",[[arrayOfAccounts objectAtIndex:arrIndex] objectForKey:@"id"]]
                                                               andParams:params
                                                           andHttpMethod:@"POST"
                                                             andDelegate:self];
                                      
   


        
}
-(void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@",response);
        
    switch (currentAPIcall) {
        case kAPIGraphUserFriends:
    
            break;
        case kAPIGraphUserPhotosPost:
            break;
        case kAPIGraphPagePhotosPost:
            break;
        default:
            break;
            
    }
   
}
- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    //NSString* photoid;

    switch (currentAPIcall) {
        case kAPIGraphUserFriends:
            NSLog(@"result");
            NSArray* fbfriends = [result objectForKey:@"data"];
            [FBfriendsArray removeAllObjects];
            for (NSDictionary* obj in fbfriends) {
                FBfriend* newFBfriend = [[FBfriend alloc]init];
                newFBfriend.uid = [obj objectForKey:@"id"];
                newFBfriend.name = [obj objectForKey:@"name"];
                [FBfriendsArray addObject:newFBfriend];
                   [newFBfriend release];
            }
         
            [friendsArray addObjectsFromArray:FBfriendsArray];
            [PF_MBProgressHUD hideHUDForView:self.view animated:YES];
            
                       break;

         case kAPIGraphUserPhotosPost:
            fbphotoid  =   [result objectForKey:@"id"]; 
            [fbphotoid retain];
            NSLog(@"facebook photoid = %@",fbphotoid);
            [self performSelector:@selector(saveRoute) withObject:nil afterDelay:0.0];
              [JHNotificationManager notificationWithMessage:@"Photo uploaded successfully to Facebook!"];  
            break;
        case kAPIGraphPagePhotosPost:
            
            fbphotoid  =   [result objectForKey:@"id"]; 
            [fbphotoid retain];
            NSLog(@"facebook photoid = %@",fbphotoid);
            [self performSelector:@selector(saveRouteInGym) withObject:nil afterDelay:0.0];
            [JHNotificationManager notificationWithMessage:@"Photo uploaded successfully to Facebook Page!"];  
            [[PFFacebookUtils facebook]setAccessToken:[NSString stringWithFormat:@"%@",oldAccessToken]];
            break;
        default:
            break;
    }
//    NSString* photoid = [result objectForKey:@"id"];
  //  for (PFUser* user in recommendArray) {
  //      [self tagPhoto:photoid withUser:[user objectForKey:@"facebookid"]];
  //  }
  //  [JHNotificationManager notificationWithMessage:@"Photo uploaded successfully to Facebook!"];    
}

-(void)tagPhoto:(NSString*)photoid withUser:(NSString*)facebookid
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [NSString stringWithFormat:@"%@",facebookid ], @"to",@"50",@"x",@"50",@"y",nil];
    [[PFFacebookUtils facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/tags",photoid]
                                  andParams:params
                              andHttpMethod:@"POST"
                                andDelegate:self];   
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
