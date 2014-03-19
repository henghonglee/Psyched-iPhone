

#import <UIKit/UIKit.h>
#import "RouteObject.h"
#import <CoreLocation/CoreLocation.h>
#import "LKBadgeView.h"
#import <Parse/Parse.h>
#import "FBfriend.h"

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)



@class ParseStarterProjectViewController;

@interface ParseStarterProjectAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate,PF_FBRequestDelegate,UIAlertViewDelegate> {
UIBackgroundTaskIdentifier bgTask;
}
//@property (nonatomic,retain) PFObject* nearbyGymObject;
@property (nonatomic,retain) NSMutableArray* pushedNotifications;
@property (retain, nonatomic) CLLocationManager* locationManager;
@property (retain, nonatomic)  CLLocation* currentLocation;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic,retain) LKBadgeView* badgeView;

//@property (nonatomic, retain) NSString* fbphotoid;
//@property (nonatomic, retain) NSString* uploadDescription;
//@property (nonatomic, retain) NSString* uploadLocation;
//@property (nonatomic, retain) NSString* uploadDifficultydesc;
//@property (nonatomic,retain)PFGeoPoint* uploadGeopoint;
//@property (nonatomic) BOOL wasUploading;
//@property (nonatomic) BOOL isPage;
//@property (nonatomic) BOOL isFacebookUpload;
//@property (nonatomic, retain) NSData* imageData;
//@property (nonatomic, retain) NSData* thumbImageData;
//@property (nonatomic, retain) NSMutableArray* usersrecommended;
//@property (nonatomic) int difficultyint;
//@property (nonatomic, retain) NSArray* recommendArray;
//currentusers - 
//email
//name
//profilepicture

//@property (nonatomic, retain) NSString* uploadDescription;

- (void)subscribeFinished:(NSNumber *)result error:(NSError *)error;

@end
