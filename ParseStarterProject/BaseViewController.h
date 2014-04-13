#import "ParseStarterProjectAppDelegate.h"
#import "EditImageViewController.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import <CoreLocation/CoreLocation.h>
@interface BaseViewController : UITabBarController<UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,EditImageDelegate,UIAlertViewDelegate,CLLocationManagerDelegate>
{
    NSMutableDictionary* imageMetaData;
     CLLocation* myCurrentLocation;
    NSDictionary* cameraImageDictionary;
    UIImagePickerController* imagepicker;
    UIImage* newcropped;
}
@property (retain , nonatomic) NSData* reuseImageData;
@property (retain , nonatomic) NSData* tempReuseImageData;
@property (retain , nonatomic) PFObject* tempReusePFObject;
@property (retain , nonatomic) PFObject* reusePFObject;

@property (retain, nonatomic) NSMutableDictionary* imageMetaData;
@property (retain, nonatomic) CLLocationManager* locationManager;
@property (retain, nonatomic)  CLLocation* currentLocation;
// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*)title image:(UIImage*)image;
-(void)imageProcessAfterMetaDataWithInfo:(NSDictionary*)info andImagePicker:(UIImagePickerController*)picker;
// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage;

@end
