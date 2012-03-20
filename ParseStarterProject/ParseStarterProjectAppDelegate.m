
#import "Parse/Parse.h"
#import "ParseStarterProjectAppDelegate.h"
#import "MyTableController.h"
#import "InstagramViewController.h"
#import "LoginViewController.h"
#import "JHNotificationManager.h"
#import <BugSense-iOS/BugSenseCrashController.h>
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
    //NSDictionary *myStuff = [NSDictionary dictionaryWithObjectsAndKeys:@"myObject", @"myKey", nil];
    //[BugSenseCrashController sharedInstanceWithBugSenseAPIKey:@"ade3c7ab" 
    //                                           userDictionary:myStuff 
    //                                          sendImmediately:NO];
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
   // viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  //  [self presentModalViewController:viewController animated:YES];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0){
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"headerview.png"] forBarMetrics:UIBarMetricsDefault];}
     if ([PFFacebookUtils facebook].accessToken) {
            NSLog(@"expiration timer = %@",[[PFUser currentUser] facebookExpirationDate]);
   
         self.window.rootViewController = viewController;

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
    [PFPush subscribeToChannelInBackground:@"" withTarget:self selector:@selector(subscribeFinished:error:)];
        [PFPush subscribeToChannelInBackground:@"channelrecommend" withTarget:self selector:@selector(subscribeFinished:error:)];
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

@end
