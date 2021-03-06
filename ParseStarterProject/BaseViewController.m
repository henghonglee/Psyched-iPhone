#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>
#import "BaseViewController.h"
#import "NSMutableDictionary+ImageMetadata.h"
#import "CreateRouteViewController.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import "UIImagePickerController+NoRotate.h"
#import "ParseStarterProjectAppDelegate.h"
#import "FlurryAnalytics.h"
#import "RDActionSheet.h"
#import "LKBadgeView.h"
#import "RouteDetailViewController.h"


@implementation BaseViewController
@synthesize reuseImageData;
@synthesize locationManager;
@synthesize imageMetaData;
@synthesize currentLocation;
@synthesize reusePFObject;
@synthesize tempReuseImageData,tempReusePFObject;
static inline double radians (double degrees) {return degrees * M_PI/180;}
// Create a view controller and setup it's tab bar item with a title and image
-(UIViewController*) viewControllerWithTabTitle:(NSString*) title image:(UIImage*)image
{
  UIViewController* viewController = [[[UIViewController alloc] init] autorelease];
  viewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:title image:image tag:0] autorelease];
  return viewController;
}

// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    
  UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
  button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
  button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
  [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
  [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(CreateRoute:) forControlEvents:UIControlEventTouchUpInside];
//    button.layer.shadowColor = [UIColor blackColor].CGColor;
//    button.layer.shadowOpacity = 0.4;
//    button.layer.shadowOffset = CGSizeMake(0, -4);
   
    
    
  CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
  if (heightDifference < 0)
    button.center = self.tabBar.center;
  else
  {
    CGPoint center = self.tabBar.center;
    center.y = center.y - heightDifference/2.0;
    button.center = center;
  }
    ParseStarterProjectAppDelegate* appDel = (ParseStarterProjectAppDelegate* )[[UIApplication sharedApplication]delegate];
    appDel.badgeView =
    [[[LKBadgeView alloc] initWithFrame:CGRectMake(100, 200, 50, 30)]autorelease];
    appDel.badgeView.widthMode = LKBadgeViewWidthModeSmall;
    appDel.badgeView.center = CGPointMake(self.tabBar.center.x+145, self.tabBar.center.y-20);
    [appDel.badgeView addObserver:appDel.badgeView forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    appDel.badgeView.text = @"0";
    appDel.badgeView.shadowOfText = YES;
    appDel.badgeView.shadow=YES;
    appDel.badgeView.badgeColor = [UIColor redColor];
    appDel.badgeView.outline = YES;
    [self.view addSubview:appDel.badgeView];


  [self.view addSubview:button];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else {
        return NO;
    }
}

-(void)CreateRoute:(id)sender
{
// [self startStandardUpdates];
    [FlurryAnalytics logEvent:@"SHARE_ACTION" timed:YES];
    
    
    if(reuseImageData != nil){
        UIActionSheet* PhotoSourceSelector = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take A Photo",@"Choose From Library",@"Use This Photo", nil];
        [PhotoSourceSelector showInView:self.view];
        [PhotoSourceSelector setBounds:CGRectMake(0,0,320, 280)];
        [PhotoSourceSelector release];
            
        
    }else{
        UIActionSheet* PhotoSourceSelector = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take A Photo",@"Choose From Library", nil];
        [PhotoSourceSelector showInView:self.view];
        [PhotoSourceSelector setBounds:CGRectMake(0,0,320, 210)];
        [PhotoSourceSelector release];
    }

    
    
    
//    RDActionSheet *actionSheet = [[RDActionSheet alloc] initWithCancelButtonTitle:@"Cancel" primaryButtonTitle:@"Save" destroyButtonTitle:@"Destroy" otherButtonTitles:@"Tweet", nil];
//    actionSheet.callbackBlock = ^(RDActionSheetResult result, NSInteger buttonIndex) {
//        
//        switch (result) {
//            case RDActionSheetButtonResultSelected:
//                NSLog(@"Pressed %i", buttonIndex);
//                break;
//            case RDActionSheetResultResultCancelled:
//                NSLog(@"Sheet cancelled");
//        }
//    };
//    [actionSheet showFrom:self.view];
}

-(IBAction) pickPhoto:(id)sender
{
	UIImagePickerController* imagePickerVC = [[UIImagePickerController alloc] init];
	imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerVC.delegate = self;
	[self presentModalViewController:imagePickerVC animated:YES];
	[imagePickerVC release];
}

-(IBAction) takePhoto:(id)sender
{
    
	UIImagePickerController* imagePickerVC = [[UIImagePickerController alloc] init];
    NSLog(@"take photo method");
	imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
	imagePickerVC.delegate = self;
    UIView* overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 320, 320, 150)];
    imagePickerVC.cameraOverlayView = overlayView;
    imagePickerVC.cameraOverlayView.backgroundColor = [UIColor blackColor];
    imagePickerVC.cameraOverlayView.alpha = 0.8;    
	[self presentModalViewController:imagePickerVC animated:YES];
	[imagePickerVC release];
        [overlayView release];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"picker did finish");
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        NSLog(@"picker did finish with camera");
        imageMetaData = [[NSMutableDictionary alloc] init];
        if (!currentLocation){
            CLLocation* mycurrloc = [[CLLocation alloc]init];
            self.currentLocation = mycurrloc;
            [mycurrloc release];
        }
      currentLocation =((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation;
         [imageMetaData setLocation:currentLocation];
        
         [self imageProcessAfterMetaDataWithInfo:info andImagePicker:picker];
       
        
    }else{
         NSLog(@"picker did finish with library");
    imageMetaData = [[NSMutableDictionary alloc] initWithInfoFromImagePicker:info withCompletionBlock:^(BOOL succeeded) {
        if(succeeded){
       NSLog(@"metadata = %@",imageMetaData);
            [self imageProcessAfterMetaDataWithInfo:info andImagePicker:picker];
        }else{
        NSLog(@"metadata retrieval failed");
        }
    }];
    }

}
-(void)imageProcessAfterMetaDataWithInfo:(NSDictionary*)info andImagePicker:(UIImagePickerController*)picker
{
    UIImage *myImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *mycroppedImage =[myImage croppedImage:CGRectMake(0, 0, myImage.size.width, myImage.size.width)];
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) 
    [imageMetaData setObject:@"UIImagePickerControllerSourceTypeCamera" forKey:@"sourceType"];
/*
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0, mycroppedImage.size.width);
    transform = CGAffineTransformRotate(transform, -M_PI_2);
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, mycroppedImage.size.width, mycroppedImage.size.width));
    CGImageRef imageRef = mycroppedImage.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap,  newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    CGContextRelease(bitmap);
    newcropped = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
*/
                NSLog(@"get newcrop");
    newcropped=[[mycroppedImage resizedImage:CGSizeMake(960, 960) interpolationQuality:kCGInterpolationHigh]autorelease];    
    
    
    [picker dismissModalViewControllerAnimated:NO];
    EditImageViewController* EditImageVC = [[EditImageViewController alloc] initWithNibName:@"EditImageViewController" bundle:nil];
    UINavigationController* navCont = [[UINavigationController alloc]initWithRootViewController:EditImageVC];
    [EditImageVC release];
    EditImageVC.imageInView = newcropped;
    NSLog(@"imageData transfered = %@",imageMetaData);
    EditImageVC.imageMetaData = imageMetaData;
    EditImageVC.delegate = self;
    [self presentModalViewController:navCont animated:NO];
    [navCont release];
    
}


-(void)EditImagedidFinishWithImage:(UIImage *)image
{
	CreateRouteViewController* viewController= [[CreateRouteViewController alloc]initWithNibName:@"CreateRouteViewController" bundle:nil];
        viewController.imageTaken = image;
        [self presentModalViewController:viewController animated:NO];
        [viewController release];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
	}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            for (id viewController in self.viewControllers) {
                if([viewController isKindOfClass:[UINavigationController class]]){
                    [viewController popToRootViewControllerAnimated:NO];
                }
            }
            [self takePhoto:nil];
            reuseImageData=nil;
            reusePFObject =nil;
            break;
        case 1:
            for (id viewController in self.viewControllers) {
                if([viewController isKindOfClass:[UINavigationController class]]){
                    [viewController popToRootViewControllerAnimated:NO];
                }
            }
            [self pickPhoto:nil];
            reuseImageData=nil;
            reusePFObject =nil;
            break;
        case 2:
            
            if(reuseImageData != nil){
                        tempReuseImageData= reuseImageData;
                        tempReusePFObject = reusePFObject;
                        reuseImageData=nil;
                        reusePFObject =nil;
                        for (id viewController in self.viewControllers) {
                            if([viewController isKindOfClass:[UINavigationController class]]){
                                [viewController popToRootViewControllerAnimated:NO];
                            }
                        }
                
                        UIImage* imagetoUse = [UIImage imageWithData:tempReuseImageData];
                        [tempReuseImageData release];
                        NSLog(@"reused photo saved");
                        EditImageViewController* EditImageVC = [[EditImageViewController alloc] initWithNibName:@"EditImageViewController" bundle:nil];
                        UINavigationController* navCont = [[UINavigationController alloc]initWithRootViewController:EditImageVC];
                [EditImageVC release];
                        EditImageVC.imageInView = imagetoUse;
                        EditImageVC.reusePFObject = tempReusePFObject;
                        
                        imageMetaData = [[NSMutableDictionary alloc]init ];
                        PFGeoPoint* routegp = [tempReusePFObject objectForKey:@"routelocation"];
                        [tempReusePFObject  release];
                        CLLocation* newImageLoc = [[CLLocation alloc]initWithLatitude:routegp.latitude longitude:routegp.longitude];
                        [imageMetaData setLocation:newImageLoc];
                        [newImageLoc release];
                        EditImageVC.imageMetaData = imageMetaData;
                        [imageMetaData release];
                        EditImageVC.delegate = self;
                    
                        [self presentModalViewController:navCont animated:YES];
                        [navCont release];
                    
                
            }else{
                NSLog(@"share action ended");
               [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
            }
            
            break;
        default:
            NSLog(@"share action ended");
            [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
            break;
    }
}

-(UIImage*)image:(UIImage*)image ByScalingToSize:(CGSize)targetSize
{
    UIImage* sourceImage = image; 
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    
    CGImageRef imageRef = [sourceImage CGImage];
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    CGColorSpaceRef colorSpaceInfo = CGImageGetColorSpace(imageRef);
    
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGImageAlphaNoneSkipLast;
    }
    
    CGContextRef bitmap;
    
    if (sourceImage.imageOrientation == UIImageOrientationUp || sourceImage.imageOrientation == UIImageOrientationDown) {
        bitmap = CGBitmapContextCreate(NULL, targetWidth, targetHeight, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    } else {
        bitmap = CGBitmapContextCreate(NULL, targetHeight, targetWidth, CGImageGetBitsPerComponent(imageRef), CGImageGetBytesPerRow(imageRef), colorSpaceInfo, bitmapInfo);
        
    }       
    
    if (sourceImage.imageOrientation == UIImageOrientationLeft) {
        CGContextRotateCTM (bitmap, radians(90));
        CGContextTranslateCTM (bitmap, 0, -targetHeight);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationRight) {
        CGContextRotateCTM (bitmap, radians(-90));
        CGContextTranslateCTM (bitmap, -targetWidth, 0);
        
    } else if (sourceImage.imageOrientation == UIImageOrientationUp) {
        // NOTHING
    } else if (sourceImage.imageOrientation == UIImageOrientationDown) {
        CGContextTranslateCTM (bitmap, targetWidth, targetHeight);
        CGContextRotateCTM (bitmap, radians(-180.));
    }
    
    CGContextDrawImage(bitmap, CGRectMake(0, 0, targetWidth, targetHeight), imageRef);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    
    CGContextRelease(bitmap);
    CGImageRelease(ref);
    
    return newImage; 
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	//[picker.view removeFromSuperview];
	[picker dismissModalViewControllerAnimated:YES];
    NSLog(@"share action ended");
    [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
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
        [locationManager stopUpdatingLocation];
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);
        if (!currentLocation){
           CLLocation* mycurrloc = [[CLLocation alloc]initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
            self.currentLocation = mycurrloc;
           
            [mycurrloc release];
        }else{
            self.currentLocation = newLocation;
            NSLog(@"currentLocation = %@",self.currentLocation);
        }

      
        
        
    }
    // else skip the event and process the next one.
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        // Request to save the image to camera roll
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        [FlurryAnalytics logEvent:@"USED_SAVE_BUTTON"];
        
        [library writeImageToSavedPhotosAlbum:[newcropped CGImage] metadata:imageMetaData completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"error is %@",error);
            }
            
            [JHNotificationManager notificationWithMessage:@"Photo saved with location to camera roll"];
        }];
        
        [library release];
        [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
        [imagepicker dismissModalViewControllerAnimated:YES];
    }else{
        [imagepicker dismissModalViewControllerAnimated:NO];
        EditImageViewController* EditImageVC = [[EditImageViewController alloc] initWithNibName:@"EditImageViewController" bundle:nil];
        UINavigationController* navCont = [[UINavigationController alloc]initWithRootViewController:EditImageVC];
        [EditImageVC release];
        EditImageVC.imageInView = newcropped;
        NSLog(@"imageData transfered = %@",imageMetaData);
        EditImageVC.imageMetaData = imageMetaData;
        EditImageVC.delegate = self;
        [self presentModalViewController:navCont animated:NO];
        [navCont release];
    }
}


-(void)dealloc
{
    [super dealloc];
    [imageMetaData release];
    [myCurrentLocation release];
    [locationManager release];
}

@end
