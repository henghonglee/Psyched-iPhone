
#import "Parse/Parse.h"
#import "ParseStarterProjectAppDelegate.h"
#import "MyTableController.h"
#import "InstagramViewController.h"
#import "LoginViewController.h"
#import "JHNotificationManager.h"
#import <BugSense-iOS/BugSenseCrashController.h>
#import "FlurryAnalytics.h"

#define VERSION 1.6
@implementation ParseStarterProjectAppDelegate
@synthesize badgeView;
@synthesize window=_window;
@synthesize pushedNotifications;
@synthesize viewController=_viewController;
@synthesize currentLocation,locationManager;
//@synthesize uploadDescription;
//@synthesize uploadLocation;
//@synthesize uploadDifficultydesc;
//@synthesize uploadGeopoint;
//@synthesize isPage;
//@synthesize nearbyGymObject;
//@synthesize isFacebookUpload;
//@synthesize imageData;
//@synthesize thumbImageData;
//@synthesize wasUploading;
//@synthesize difficultyint;
//@synthesize usersrecommended;
//@synthesize fbphotoid;
//@synthesize recommendArray;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    [FlurryAnalytics startSession:@"N66I1CJV446Z75ZV8G8V"];
    NSDictionary *myStuff = [NSDictionary dictionaryWithObjectsAndKeys:@"myObject", @"myKey", nil];
    [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"ade3c7ab" 
                                               userDictionary:myStuff 
                                              sendImmediately:YES];
    [self startStandardUpdates];
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    
    //sandbox
    //[Parse setApplicationId:@"IB67seVg0d1MufvXlA67zW1zHKivUW2cBkXPQ0c0" clientKey:@"Vln8htxgC4uM5ZDIqRDQ2MsJgJjM27hexeGr140i"];
    
    //live
    [Parse setApplicationId:@"rUk14GRi8xY6ieFQGyXcJ39iQUPuGo1ihR2dAKeh" clientKey:@"aOz04F0XOehjH9a58b95V4nKtcCZNUNUxbCoqM48"];
    [PFFacebookUtils initializeWithApplicationId:@"200778040017319"];
    // Override point for customization after application launch.
    
//    if([[NSUserDefaults standardUserDefaults] objectForKey:@"NearbyDistance"] ==nil){
//        [[NSUserDefaults standardUserDefaults] setObject:@"5" forKey:@"NearbyDistance"];
//    }
    
    //test saving array in doc directory
/*    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"array", @"array", @"Stout", @"dark", @"Hefeweizen", @"wheat", @"IPA", 
                                @"hoppy", nil];
    
    // Get path to documents directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, 
                                                         NSUserDomainMask, YES);
    if ([paths count] > 0)
    {
        // Path to save array data
        NSString  *arrayPath = [[paths objectAtIndex:0] 
                                stringByAppendingPathComponent:@"array.out"];
        
            // Write array
       // [array writeToFile:arrayPath atomically:YES];
        
        // Read both back in new collections
        NSMutableArray *arrayFromFile = [NSMutableArray arrayWithContentsOfFile:arrayPath];
     
        
        for (NSString *element in arrayFromFile) 
            NSLog(@"element: %@", element);
    }
    
*/
    
//fetch user notifications
    /*
   // [self apiFQLIMe];
   //http://www.facebook.com/photo.php?fbid=10150725278230883&set=a.10150701479290883.464743.554245882&type=1
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   [NSString stringWithFormat:@"SELECT created_time, sender_id, title_text, body_text, href FROM notification WHERE recipient_id=554245882 AND 'http://www.facebook.com/photo.php?fbid=10150725278230883&set=a.10150701479290883.464743.554245882&type=1'IN href"], @"query",
//                                   nil];
//    [[PFFacebookUtils facebook] requestWithMethodName:@"fql.query"
//                                            andParams:params
//                                        andHttpMethod:@"POST"
//                                          andDelegate:self];
    */
    
    
    
    
    
    
    
   
    InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
     LoginViewController* loginVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0)
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"headerview.png"] forBarMetrics:UIBarMetricsDefault];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"updater1.1"]) {
        
     if ([PFFacebookUtils facebook].accessToken) { //if accesstoken is ok
         NSLog(@"access token is ok");
             NSDictionary *dictionary = 
             [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectForKey:@"email"],@"email",[[PFUser currentUser] objectForKey:@"birthday_date"],@"birthday_date",[[PFUser currentUser] objectForKey:@"name"],@"name",[[PFUser currentUser] objectForKey:@"sex"],@"sex",[[PFUser currentUser] objectForKey:@"uid"],@"uid",[[PFUser currentUser] objectForKey:@"about_me"],@"about_me", nil];
             [FlurryAnalytics setUserID:[[PFUser currentUser] objectForKey:@"name"]];
             [FlurryAnalytics setAge:[[[PFUser currentUser] objectForKey:@"age"]intValue]];
             if ([[[PFUser currentUser] objectForKey:@"sex"] isEqualToString:@"male"]) {
                 [FlurryAnalytics setGender:@"m"];
             }else{
                 [FlurryAnalytics setGender:@"f"];
             }
             [FlurryAnalytics logEvent:@"USER_LOGIN" withParameters:dictionary timed:YES];
                      
                      
                      
                      
                      [[PFUser currentUser] setObject:[NSNumber numberWithDouble:VERSION] forKey:@"version"];
                      [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                          [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]] target:self selector:@selector(subscribeFinished:error:)];
                          NSLog(@"subscribed to channeluser %@",[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]]);
                           
                      }];                 
                      
              self.window.rootViewController = viewController;
         
         }else{
             
             NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",@"user_videos",@"user_birthday",@"email",@"user_photos",@"publish_stream",@"offline_access",@"manage_pages",@"manage_notifications",nil];
             [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
                 [self apiFQLIMe];
                 [[PFUser currentUser] setObject:[NSNumber numberWithDouble:VERSION] forKey:@"version"];
                 
                 [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]] target:self selector:@selector(subscribeFinished:error:)];
                     NSLog(@"subscribed to channeluser %@",[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]]);
                 }];
                 
             }];
             [permissions release];
         }
        }else{
            self.window.rootViewController = loginVC; 
     }
    [viewController release];
    [loginVC release ];
    [self.window makeKeyAndVisible];
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert];
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        PFQuery* routequery = [PFQuery queryWithClassName:@"Route"];
        [routequery whereKey:@"objectId" equalTo:[userInfo objectForKey:@"linkedroute"]];
        [routequery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"done running query");
            RouteObject* newRouteObject = [[RouteObject alloc]init];
            newRouteObject.pfobj = object;
            RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
            
            viewController.routeObject = newRouteObject;
            NSLog(@"rootview = %@",self.window.rootViewController);
            
            UINavigationController* target = [((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0];
            [((InstagramViewController*)self.window.rootViewController) setSelectedViewController:target];
            [target popToRootViewControllerAnimated:NO];
            [target pushViewController:viewController animated:YES];
            [viewController release];
            [newRouteObject release];
        }];
    }
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
                                                    UIRemoteNotificationTypeAlert|
                                                    UIRemoteNotificationTypeSound];
    return YES;
}

#pragma mark fb methods

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[PFFacebookUtils facebook] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PFFacebookUtils facebook] handleOpenURL:url]; 
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Update Now"]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/psyched!/id511887569?mt=8"]];
    }else if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Reauthenticate"]) {
        [PFUser logOut];
        [[PFFacebookUtils facebook] logout];
        [[PFFacebookUtils facebook] setAccessToken:nil];
        NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",@"user_videos",@"user_birthday",@"email",@"user_photos",@"publish_stream",@"offline_access",@"manage_pages",@"manage_notifications",nil];
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            
        }];
        [permissions release]; 
    }
                
    }
/*
 //gym alert
 if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Show Me!"]) {
 NSLog(@"showing nearbyGym");
 GymViewController* viewController = [[GymViewController alloc]initWithNibName:@"GymViewController" bundle:nil];
 viewController.gymObject = nearbyGymObject;
 NSLog(@"selfwindowroot = %@",self.window.rootViewController);
 if ([self.window.rootViewController isKindOfClass:[InstagramViewController class]]) {
 UINavigationController* target = [((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0];
 [((InstagramViewController*)self.window.rootViewController) setSelectedViewController:target];
 [target popToRootViewControllerAnimated:NO];
 [target pushViewController:viewController animated:YES];
 
 }else{
 [self.window.rootViewController dismissModalViewControllerAnimated:NO];
 InstagramViewController* ISviewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
 self.window.rootViewController= ISviewController;
 UINavigationController* target = [((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0];
 [((InstagramViewController*)self.window.rootViewController) setSelectedViewController:target];
 [target popToRootViewControllerAnimated:NO];
 [target pushViewController:viewController animated:YES];
 [ISviewController release];
 
 
 }
 [viewController release];
 }else{

 */

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken{
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
    
    [PFPush unsubscribeFromChannelInBackground:@"channelrecommend"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) // 3010 is for the iPhone Simulator
    {
        // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"userInfo = %@",userInfo);
    
   if (![[userInfo objectForKey:@"sender"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
    if ([[userInfo objectForKey:@"reciever"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
      
     
        [JHNotificationManager notificationWithMessage:
         [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
        
    }else{
    
        [JHNotificationManager notificationWithMessage:
         [[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"]];
        
    }
   
    }

    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        NSLog(@"inactive app state.. recieving push");
    PFQuery* routequery = [PFQuery queryWithClassName:@"Route"];
    [routequery whereKey:@"objectId" equalTo:[userInfo objectForKey:@"linkedroute"]];
    [routequery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            NSLog(@"done running query");
        RouteObject* newRouteObject = [[RouteObject alloc]init];
        newRouteObject.pfobj = object;
        RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
        
        viewController.routeObject = newRouteObject;
        NSLog(@"rootview = %@",self.window.rootViewController);
        UINavigationController* target = [((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0];
        [((InstagramViewController*)self.window.rootViewController) setSelectedViewController:target];
        [target popToRootViewControllerAnimated:NO];
        NSLog(@"target = %@",[((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0]);
        [target pushViewController:viewController animated:YES];
        [viewController release];
        [newRouteObject release];
    }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
    //bguploading
    /*
//    UIApplication  *app = [UIApplication sharedApplication];
//    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{ 
//        [app endBackgroundTask:bgTask]; 
//        bgTask = UIBackgroundTaskInvalid;
//    }];
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if(wasUploading){
//            wasUploading = NO;
//                NSLog(@"begining background ....");
//            [self saveRoute];
//        }
//    });
//    
//    [app endBackgroundTask:bgTask]; bgTask = UIBackgroundTaskInvalid;
    */
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    
    NSLog(@"application will enter foreground");
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    //GYM NEARBY CHECK
    /*
    NSLog(@"current user = %@",[PFUser currentUser]);
    if ([PFUser currentUser]) {
        PFGeoPoint* mypoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
        PFQuery* nearestGymQuery = [PFQuery queryWithClassName:@"Gym"];
        [nearestGymQuery whereKey:@"gymlocation" nearGeoPoint:mypoint withinKilometers:2.0f];
        [nearestGymQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if (object){
                
                nearbyGymObject = object;
                [nearbyGymObject retain];
                
                UIAlertView* gymAlert = [[UIAlertView alloc]initWithTitle:@"Hey there!" message:[NSString stringWithFormat:@"We realised you are near %@! \n would you like to go to their page?",[object objectForKey:@"name"]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Show Me!",nil];
                [gymAlert show];
                [gymAlert release];
            }
        }];
        */
    
    [self performSelector:@selector(fbOAuthCheck) withObject:nil afterDelay:7];
        
    }

    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
-(void)fbOAuthCheck{
    NSLog(@"facebook oauth check when entering foreground %@",[PFFacebookUtils facebook].accessToken);
    ASIHTTPRequest* accountRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?access_token=%@",[PFFacebookUtils facebook].accessToken]]];
    accountRequest.shouldRedirect = YES;
    [accountRequest setCompletionBlock:^{
        
        NSLog(@"response = %@",accountRequest.url);
        if ([[accountRequest responseString] rangeOfString:@"Invalid OAuth access token."].location != NSNotFound) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Sorry!" message:@"You need to reauthenticate with Facebook" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Reauthenticate",nil];
            
            [alert show];
            [alert release];
        }else{
            [[PFUser currentUser] setObject:[NSString stringWithFormat:@"%@",accountRequest.url] forKey:@"profilepicture"]; 
            [[PFUser currentUser]saveEventually];
        }
    }];
    [accountRequest setFailedBlock:^{
        
    }];
    [accountRequest startAsynchronous];
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"app did become active");
    
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    PFQuery* versionquery = [PFQuery queryWithClassName:@"Version"];
    [versionquery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if ([[object objectForKey:@"version"] doubleValue] > VERSION) {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[object objectForKey:@"updatetitle"] message:[object objectForKey:@"updatetext"] delegate:self cancelButtonTitle:@"Update later" otherButtonTitles:@"Update Now!",nil];
            [alert show];
            [alert release];
        }  
    }];
    
    //check for Invalid OAuth access token
       /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     
     */
}

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
}
- (void)startStandardUpdates{
    // Create the location manager if this object does not
    // already have one.
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Set a movement threshold for new events.
    locationManager.distanceFilter = 500;
    
    [locationManager startUpdatingLocation];
    CLLocation *location = locationManager.location;
    [FlurryAnalytics setLatitude:location.coordinate.latitude
                       longitude:location.coordinate.longitude
              horizontalAccuracy:location.horizontalAccuracy
                verticalAccuracy:location.verticalAccuracy];
}
// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        if (!currentLocation){
            CLLocation* mycurrloc = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            self.currentLocation = mycurrloc;
             NSLog(@"currentLocation new= %@",self.currentLocation);
            [mycurrloc release];
        }else{
            self.currentLocation = newLocation;
             NSLog(@"currentLocation = %@",self.currentLocation);
        }
    }
    // else skip the event and process the next one.
}

- (void)dealloc{
    [_window release];
    [_viewController release];
    [badgeView removeObserver:self forKeyPath:@"text"];
    [badgeView release];
    [super dealloc];
}




- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSLog(@"in apiFQLMe function");
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                   @"SELECT about_me,locale,birthday,birthday_date,sex,uid, name, pic , email FROM user WHERE uid=me()", @"query",
//                                   nil];
//    [[PFFacebookUtils facebook] requestWithMethodName:@"fql.query"
//                                            andParams:params
//                                        andHttpMethod:@"POST"
//                                          andDelegate:self];
    
    NSURL* reqURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/fql?q=SELECT+about_me,locale,birthday,birthday_date,sex,uid,name,pic,email+FROM+user+WHERE+uid=me()&access_token=%@",[PFFacebookUtils facebook].accessToken]];
    ASIHTTPRequest* fqlRequest = [ASIHTTPRequest requestWithURL:reqURL];
    [fqlRequest setCompletionBlock:^{
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSArray *jsonObjects = [[jsonParser objectWithString:[fqlRequest responseString]] objectForKey:@"data"];
        [jsonParser release];
        jsonParser = nil;
        
        NSLog(@"result = %@ class = %@",jsonObjects,[jsonObjects class]);
        if ([jsonObjects isKindOfClass:[NSArray class]]) {
            if([((NSArray*)jsonObjects) count]==0) {
                NSLog(@"couldnt get user values .. exiting");
                return;
            }else{
                
                NSDictionary* result = [((NSArray*)jsonObjects) objectAtIndex:0];
                // This callback can be a result of getting the user's basic
                // information or getting the user's permissions.
                if ([result objectForKey:@"name"]) {
                    
                    [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"pic"] forKey:@"profilepicture"]; 
                    [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"name"]; 
                    [[PFUser currentUser] setObject:[result objectForKey:@"uid"] forKey:@"facebookid"]; 
                    [[PFUser currentUser] setObject:[result objectForKey:@"birthday_date"] forKey:@"birthday_date"];
                    
                    NSString *trimmedString=[((NSString*)[result objectForKey:@"birthday_date"]) substringFromIndex:[((NSString*)[result objectForKey:@"birthday_date"]) length]-4];
                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                    [formatter setDateFormat:@"YYYY"];
                    NSString *yearString = [formatter stringFromDate:[NSDate date]];
                    [formatter release];
                    int age = [yearString intValue]-[trimmedString intValue];
                    
                    [[PFUser currentUser] setObject:[NSNumber numberWithInt:age] forKey:@"age"];         
                    [[PFUser currentUser] setObject:[result objectForKey:@"sex"] forKey:@"sex"]; 
                    [[PFUser currentUser] setObject:[result objectForKey:@"locale"] forKey:@"locale"];
                    [[PFUser currentUser] setObject:[result objectForKey:@"about_me"] forKey:@"about_me"];
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]] target:self selector:@selector(subscribeFinished:error:)];
                        NSLog(@"subscribed to channeluser %@",[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]]);
                        [FlurryAnalytics setUserID:[[PFUser currentUser] objectForKey:@"name"]];
                        if ([[[PFUser currentUser] objectForKey:@"sex"] isEqualToString:@"male"]) {
                            [FlurryAnalytics setGender:@"m"];
                        }else{
                            [FlurryAnalytics setGender:@"f"];
                        }
                        [FlurryAnalytics setAge:age];
                        NSDictionary *dictionary = 
                        [NSDictionary dictionaryWithObjectsAndKeys:[result objectForKey:@"email"],@"email",[result objectForKey:@"birthday"],@"birthday",[result objectForKey:@"name"],@"name",[result objectForKey:@"sex"],@"sex",[result objectForKey:@"uid"],@"uid",[result objectForKey:@"about_me"],@"about_me", nil];
                        
                        [FlurryAnalytics logEvent:@"USER_LOGIN" withParameters:dictionary timed:YES];
                        InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
                        [[NSUserDefaults standardUserDefaults]setObject:@"updated" forKey:@"updater1.1"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        self.window.rootViewController = viewController;
                        [viewController release];
                    }];
                    
                    
                    
                }
            }
        }
    }];
    [fqlRequest setFailedBlock:^{
        NSLog(@"fql req failed");
    }];
    [fqlRequest startAsynchronous];
    
    
}

#pragma mark - FBRequestDelegate Methods

- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    
}












#pragma mark saveroute methods for bg saving
/*
-(void)saveRoute
{
    PFObject* newRoute = [PFObject objectWithClassName:@"Route"];
    if (isFacebookUpload) {
        [newRoute setObject:fbphotoid forKey:@"photoid"];  
        
    }
    [newRoute setObject:uploadLocation forKey:@"location"];
    if ([usersrecommended count]>0) {
        uploadDescription = [uploadDescription stringByAppendingFormat:@"(%@)  ",difficultyint];
        
        for (NSString*user in usersrecommended) {
            uploadDescription = [uploadDescription stringByAppendingFormat:@"@%@ ",user];
        }
        
    }
    [newRoute setObject:uploadDescription forKey:@"description"];
    [newRoute setObject:uploadGeopoint forKey:@"routelocation"];
    [newRoute setObject:uploadDifficultydesc forKey:@"difficultydescription"];
    [newRoute setObject:[NSNumber numberWithInt:difficultyint] forKey:@"difficulty"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"username"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"userimage"];
    [newRoute setObject:[[PFUser currentUser] objectForKey:@"email"] forKey:@"useremail"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"commentcount"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"likecount"];
    [newRoute setObject:[NSNumber numberWithInt:0] forKey:@"viewcount"];
    [newRoute setObject:[NSNumber numberWithBool:false] forKey:@"outdated"];
    [newRoute setObject:[NSNumber numberWithBool:false] forKey:@"isPage"];
    
    [newRoute setObject:usersrecommended forKey:@"usersrecommended"];
    
    [usersrecommended release];
    NSLog(@"saving thumb in background...");            
    PFFile *thumbImageFile = [PFFile fileWithName:@"thumbImage.jpeg" data:thumbImageData];
    [thumbImageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [newRoute setObject:thumbImageFile forKey:@"thumbImageFile"];  
        
        
        
        PFFile *imageFile = [PFFile fileWithName:@"image.jpeg" data:imageData];
        NSLog(@"saving in background...");
        
        //   [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            NSLog(@"done saving image");
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
                
                [feedObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    NSLog(@"done saving add feed");
                }];
                if ([recommendArray count]>0) {
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
                
                
                
                [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",newRoute.objectId] block:^(BOOL succeeded, NSError *error) {
                    NSMutableDictionary *data = [NSMutableDictionary dictionary];
                    [data setObject:newRoute.objectId forKey:@"linkedroute"];
                    [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
                    [data setObject:[NSString stringWithFormat:@"Upload Complete!"] forKey:@"alert"];
                    [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                    [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"reciever"];
                    
                    [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]] withData:data]; 
                }];
                
                
                
            }];
            
            
            
            
            
        }];
        
        
    }];
}
*/
@end
