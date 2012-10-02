
#import "Parse/Parse.h"
#import "ParseStarterProjectAppDelegate.h"
#import "MyTableController.h"
#import "InstagramViewController.h"
#import "LoginViewController.h"
#import "JHNotificationManager.h"
#import "FlurryAnalytics.h"
#import <BugSense-iOS/BugSenseCrashController.h>
#define VERSION 2.0
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
//    application.applicationIconBadgeNumber = 0;
//    [[PFInstallation currentInstallation]setBadge:0];
 //   [[PFInstallation currentInstallation] saveEventually];
    [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"ade3c7ab"];
    [FlurryAnalytics startSession:@"N66I1CJV446Z75ZV8G8V"];
    [self startStandardUpdates];
    [Parse setApplicationId:@"rUk14GRi8xY6ieFQGyXcJ39iQUPuGo1ihR2dAKeh" clientKey:@"aOz04F0XOehjH9a58b95V4nKtcCZNUNUxbCoqM48"];
    //sandbox
   // [Parse setApplicationId:@"ayrordrSISjoYKVt9hh7WjrA2lJVY3qJTLMCgPnn" clientKey:@"LA3t7cVnclnYqAe5X18sX9AJQi9WuQ3apa9FExJ7"];
    [PFFacebookUtils initializeWithApplicationId:@"200778040017319"];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"ogshare"];
    

     LoginViewController* loginVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0){
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"headerimgbg@2x.png"] forBarMetrics:UIBarMetricsDefault];
        NSDictionary *textTitleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor colorWithRed:229.0/255.0 green:182.0/255.0 blue:3.0/255.0 alpha:1.0], UITextAttributeTextColor,nil, UITextAttributeTextShadowColor,[UIFont fontWithName:@"Helvetica-Light" size:10.0],UITextAttributeFont,nil];
        [[UINavigationBar appearance] setTitleTextAttributes:textTitleOptions];
        
    }
    
     if ([PFFacebookUtils facebook].accessToken) { //if accesstoken is ok
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
       
         


         InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
         self.window.rootViewController = viewController;
         [viewController release];

                      [[PFUser currentUser] setObject:[NSNumber numberWithDouble:VERSION] forKey:@"version"];
                      [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                          
                      }];
         }else{
             self.window.rootViewController = loginVC; 
         }
       
    [loginVC release ];
    [self.window makeKeyAndVisible];    
//    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
//        NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        
//        PFQuery* routequery = [PFQuery queryWithClassName:@"Route"];
//        [routequery whereKey:@"objectId" equalTo:[userInfo objectForKey:@"linkedroute"]];
//        [routequery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//            NSLog(@"done running query");
//            RouteObject* newRouteObject = [[RouteObject alloc]init];
//            newRouteObject.pfobj = object;
//            RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
//            
//            viewController.routeObject = newRouteObject;
//            NSLog(@"rootview = %@",self.window.rootViewController);
//            
//            UINavigationController* target = [((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0];
//            [((InstagramViewController*)self.window.rootViewController) setSelectedViewController:target];
//            [target popToRootViewControllerAnimated:NO];
//            [target pushViewController:viewController animated:YES];
//            [viewController release];
//            [newRouteObject release];
//        }];
//    }
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
         UIRemoteNotificationTypeAlert|
         UIRemoteNotificationTypeSound];

        return YES;
}

#pragma mark fb methods

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[PFFacebookUtils session] handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PFFacebookUtils session] handleOpenURL:url];
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Update Now"]) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/psyched!/id511887569?mt=8"]];
    }else if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"Reauthenticate"]) {
        [PFUser logOut];
     //   [[PFFacebookUtils facebook] closeAndClearTokenInformation];
        [[PFFacebookUtils facebook] logout];
        [[PFFacebookUtils facebook] setAccessToken:nil];
        NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",@"user_videos",@"user_birthday",@"email",@"user_photos",@"publish_stream",@"offline_access",nil];
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
    NSLog(@"registering for broadcast channel");

    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];

    
}
- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error {
    if ([result boolValue]) {
        NSLog(@"ParseStarterProject successfully subscribed to push notifications on the broadcast channel.");
       
        [[PFInstallation currentInstallation]saveEventually:^(BOOL succeeded, NSError *error) {
            NSLog(@"installation saved");
        }];
    } else {
        NSLog(@"ParseStarterProject failed to subscribe to push notifications on the broadcast channel.");
    }
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
    if([userInfo objectForKey:@"pushid"]){ //if analytics is on acknowledge it
        ASIHTTPRequest* pushAck = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.psychedapp.com/push/%@?user[objectId]=%@",[userInfo objectForKey:@"pushid"],[PFUser currentUser].objectId]]];
        [pushAck setRequestMethod:@"PUT"];
        [pushAck setCompletionBlock:^{
            // no action needed, its fire and forget mode
        }];
        [pushAck setFailedBlock:^{
            // no action needed, its fire and forget mode
        }];
        [pushAck startAsynchronous];
        //send webservice to rails server at psychedapp.herokuapp.com to set viewed flag for push
        //track time opened also
    }
   if (![[userInfo objectForKey:@"sender"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
    if ([[userInfo objectForKey:@"reciever"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
      
     // app is active
        [JHNotificationManager notificationWithMessage:
         [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
        
    }else{
    
        [JHNotificationManager notificationWithMessage:
         [[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"]];
        
    }
   
    }

    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        NSLog(@"inactive app state.. recieving push");
        if([userInfo objectForKey:@"pushid"]){ //if analytics is on acknowledge it
            ASIHTTPRequest* pushAck = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.psychedapp.com/push/%@?user[objectId]=%@",[userInfo objectForKey:@"pushid"],[PFUser currentUser].objectId]]];
            [pushAck setRequestMethod:@"PUT"];
            [pushAck setCompletionBlock:^{
                // no action needed, its fire and forget mode
            }];
            [pushAck setFailedBlock:^{
                // no action needed, its fire and forget mode
            }];
            [pushAck startAsynchronous];
            //send webservice to rails server at psychedapp.herokuapp.com to set viewed flag for push
            //track time opened also
        }
    if([userInfo objectForKey:@"linkedgym"]){
            PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
            [gymQuery whereKey:@"objectId" equalTo:[userInfo objectForKey:@"linkedgym"]];
            [gymQuery getFirstObjectInBackgroundWithBlock:^(PFObject *gymobject, NSError *error) {
                UINavigationController* target = [((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0];
                [((InstagramViewController*)self.window.rootViewController) setSelectedViewController:target];
                [target popToRootViewControllerAnimated:NO];
                
                GymViewController* viewController = [[GymViewController alloc]initWithNibName:@"GymViewController" bundle:nil];
                viewController.gymObject = gymobject;
                [target pushViewController:viewController animated:YES];
                [viewController release];
                
                
            }];
        }

        if([userInfo objectForKey:@"linkedroute"]){
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
}

- (void)applicationWillResignActive:(UIApplication *)application{
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application{
 
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
//        application.applicationIconBadgeNumber = 0;
//        [[PFInstallation currentInstallation]setBadge:0];
//    [[PFInstallation currentInstallation] saveEventually];
    CLLocation *location = locationManager.location;
    PFGeoPoint* userGeopoint = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    [[PFInstallation currentInstallation]setObject:userGeopoint forKey:@"userRecentLocation"];
    [[PFInstallation currentInstallation]setObject:[NSNumber numberWithDouble:VERSION] forKey:@"Version"];
    [[PFInstallation currentInstallation]saveEventually];
    NSLog(@"application will enter foreground");
  
       [self performSelector:@selector(fbOAuthCheck) withObject:nil afterDelay:7];
    }

    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
-(void)fbOAuthCheck{
    NSLog(@"facebook oauth check when entering foreground %@",[PFFacebookUtils facebook].accessToken);
    if (![self.window.rootViewController isKindOfClass:[LoginViewController class]]) {
    ASIHTTPRequest* accountRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/picture?access_token=%@",[PFFacebookUtils facebook].accessToken]]];
    accountRequest.shouldRedirect = YES;
    [accountRequest setCompletionBlock:^{
        
        NSLog(@"response = %@",accountRequest.url);
        if (([[accountRequest responseString] rangeOfString:@"Invalid OAuth access token."].location != NSNotFound)&&[PFFacebookUtils facebook].accessToken) {
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
}

- (void)applicationDidBecomeActive:(UIApplication *)application{
    NSLog(@"app did become active");
//    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
//    if (currentInstallation.badge != 0) {
//        currentInstallation.badge = 0;
//    }
//    [currentInstallation setObject:[NSNumber numberWithDouble:VERSION ] forKey:@"Version"];
//    [currentInstallation saveEventually];
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
   
   [FlurryAnalytics setLatitude:locationManager.location.coordinate.latitude
                       longitude:locationManager.location.coordinate.longitude
              horizontalAccuracy:locationManager.location.horizontalAccuracy
                verticalAccuracy:locationManager.location.verticalAccuracy];
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
                                                            NSLog(@"subscription commpleted");  
                    }];
                    
                    
                    InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
                    
                    self.window.rootViewController = viewController;
                    [viewController release];
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









@end
