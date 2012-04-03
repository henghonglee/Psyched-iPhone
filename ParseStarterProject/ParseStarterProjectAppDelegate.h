// Copyright 2011 Ping Labs, Inc. All rights reserved.

#import <UIKit/UIKit.h>
#import "RouteObject.h"
#import <CoreLocation/CoreLocation.h>
@class ParseStarterProjectViewController;

@interface ParseStarterProjectAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate,PF_FBRequestDelegate> {

}
@property (nonatomic,retain) NSMutableArray* pushedNotifications;
@property (retain, nonatomic) CLLocationManager* locationManager;
@property (retain, nonatomic)  CLLocation* currentLocation;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet ParseStarterProjectViewController *viewController;

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error;

@end
