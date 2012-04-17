
#import "Parse/Parse.h"
#import "ParseStarterProjectAppDelegate.h"
#import "MyTableController.h"
#import "InstagramViewController.h"
#import "LoginViewController.h"
#import "JHNotificationManager.h"
#import <BugSense-iOS/BugSenseCrashController.h>
#import "FlurryAnalytics.h"

#define VERSION 1.2
@implementation ParseStarterProjectAppDelegate

@synthesize window=_window;
@synthesize pushedNotifications;
@synthesize viewController=_viewController;
@synthesize currentLocation,locationManager;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"notification payload = %@",launchOptions );
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:YES];
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    [FlurryAnalytics startSession:@"N66I1CJV446Z75ZV8G8V"];
   // NSDictionary *myStuff = [NSDictionary dictionaryWithObjectsAndKeys:@"myObject", @"myKey", nil];
   // [BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"ade3c7ab" 
   //                                            userDictionary:myStuff 
   //                                           sendImmediately:YES];
    [self startStandardUpdates];
    // ****************************************************************************
    // Uncomment and fill in with your Parse credentials:
    
    //sandbox
    //[Parse setApplicationId:@"IB67seVg0d1MufvXlA67zW1zHKivUW2cBkXPQ0c0" clientKey:@"Vln8htxgC4uM5ZDIqRDQ2MsJgJjM27hexeGr140i"];
    
    //live
    [Parse setApplicationId:@"rUk14GRi8xY6ieFQGyXcJ39iQUPuGo1ihR2dAKeh" clientKey:@"aOz04F0XOehjH9a58b95V4nKtcCZNUNUxbCoqM48"];
    [PFFacebookUtils initializeWithApplicationId:@"200778040017319"];
    // Override point for customization after application launch.
   

    
    InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
     LoginViewController* loginVC = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0){
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"headerview.png"] forBarMetrics:UIBarMetricsDefault];}
    
     if ([PFFacebookUtils facebook].accessToken) {

         NSLog(@"updater = %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"updater1.1"]);
         
                  if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"updater1.1"] isEqualToString:@"updated"]) {
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
                      [[PFUser currentUser] saveInBackground];
                      PFQuery* versionquery = [PFQuery queryWithClassName:@"Version"];
                      [versionquery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                          if ([[object objectForKey:@"version"] doubleValue] > VERSION) {
                              UIAlertView* alert = [[UIAlertView alloc]initWithTitle:[object objectForKey:@"updatetitle"] message:[object objectForKey:@"updatetext"] delegate:self cancelButtonTitle:@"Update later" otherButtonTitles:@"Update Now!",nil];
                              [alert show];
                              [alert release];
                          }  
                      }];                      
                      
                      
                      
                      
                      
                      
                      
                      
                      
             self.window.rootViewController = viewController;
         
         
         }else{
             NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",@"user_videos",@"user_birthday",@"email",@"user_photos",@"publish_stream",@"offline_access","manage_pages",nil];
             [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
                 [self apiFQLIMe];
                 

                 
                 
             }];
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
            NSLog(@"target = %@",[((InstagramViewController*)self.window.rootViewController).viewControllers objectAtIndex:0]);
            [target pushViewController:viewController animated:YES];
            [viewController release];
            [newRouteObject release];
        }];
    }
    
   // [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
    //                                                UIRemoteNotificationTypeAlert|
     //                                               UIRemoteNotificationTypeSound];
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
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/psyched!/id511887569?mt=8"]];
    }else{
        
    }
}

/*
 
///////////////////////////////////////////////////////////
// Uncomment these two methods if you are using Facebook
///////////////////////////////////////////////////////////
 
// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [[PFUser facebook] handleOpenURL:url]; 
}
 
// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
    sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[PFUser facebook] handleOpenURL:url]; 
} 
 
*/

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken];
    [PFPush subscribeToChannelInBackground:@"" target:self selector:@selector(subscribeFinished:error:)];
    [PFPush unsubscribeFromChannelInBackground:@"channelrecommend"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
	NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	if ([error code] != 3010) // 3010 is for the iPhone Simulator
    {
        // show some alert or otherwise handle the failure to register.
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSLog(@"userInfo = %@",userInfo);
   
    
    if ([[userInfo objectForKey:@"reciever"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
      
        
        [JHNotificationManager notificationWithMessage:
         [NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"savedArray"]) {
            pushedNotifications = [[NSMutableArray alloc]init ];
        }else{
            pushedNotifications = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedArray"];
            [pushedNotifications addObject:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
            [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:pushedNotifications] forKey:@"savedArray"];
            NSLog(@"saved array = %@",pushedNotifications);
        }
        
    }else{
    if ([[userInfo objectForKey:@"sender"] isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]) {
        
    }else{
        
       
        [JHNotificationManager notificationWithMessage:
         [[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@'s",[[PFUser currentUser]objectForKey:@"name"]] withString:@"your"]];
        if (![[NSUserDefaults standardUserDefaults] objectForKey:@"savedArray"]) {
             pushedNotifications = [[NSMutableArray alloc]init ];
        }else{
            pushedNotifications = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedArray"];
            [pushedNotifications addObject:[NSString stringWithFormat:@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]]];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:pushedNotifications] forKey:@"savedArray"];
            NSLog(@"saved array = %@",pushedNotifications);
        }
    }
   
    }
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {

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

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[UIApplication sharedApplication]setApplicationIconBadgeNumber:0];
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
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
- (void)startStandardUpdates
{
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
        if (!currentLocation){
            CLLocation* mycurrloc = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            self.currentLocation = mycurrloc;
            [mycurrloc release];
        }else{
            self.currentLocation = newLocation;
        }
    }
    // else skip the event and process the next one.
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}




- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT about_me,locale,birthday,birthday_date,sex,uid, name, pic , email FROM user WHERE uid=me()", @"query",
                                   nil];
    [[PFFacebookUtils facebook] requestWithMethodName:@"fql.query"
                                            andParams:params
                                        andHttpMethod:@"POST"
                                          andDelegate:self];
}

#pragma mark - FBRequestDelegate Methods

- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {

}

- (void)request:(PF_FBRequest *)request didLoad:(id)result {
        NSLog(@"result = %@",result);
    if ([result isKindOfClass:[NSArray class]]) {
        result = [((NSArray*)result) objectAtIndex:0];
    }
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
        
        [[PFUser currentUser] saveInBackground];
        
        
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
    }
}



@end
