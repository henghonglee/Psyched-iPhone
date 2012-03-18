//
//  EditImageViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 11/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "EditImageViewController.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import "NSMutableDictionary+ImageMetadata.h"

@implementation EditImageViewController
@synthesize draggableImageView;
@synthesize imageToEdit,imageInView;
@synthesize instructionButton;
@synthesize delegate;
@synthesize confButton;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize imageMetaData;
@synthesize sliderView;
@synthesize imageStack;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
     imageMetaData = [[NSMutableDictionary alloc]init ];
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
   

    originalArrowFrame = CGRectMake(9, 327, 28, 28);
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:scrollView];
    scrollView.delegate = self;
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"editinstructions"]) {
        instructionButton.hidden = YES;
    }else{
        instructionButton.hidden=NO;
    }
      imageToEdit = [[UIImageView alloc]initWithImage:imageInView];
    imageToEdit.userInteractionEnabled = YES;
    CGRect rect = CGRectMake(0, 0, imageInView.size.width, imageInView.size.height);
    [imageToEdit setFrame:rect];
    [scrollView addSubview:imageToEdit];
    scrollView.contentSize=CGSizeMake(imageInView.size.width, imageInView.size.width);
    scrollView.maximumZoomScale = 3;
    scrollView.minimumZoomScale = (320.0f/imageInView.size.width);
    UILongPressGestureRecognizer* longpressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [longpressGesture setDelegate:self];
    [imageToEdit addGestureRecognizer:longpressGesture];
    [longpressGesture release];
    
    
    imageStack = [[NSMutableArray alloc]init ];
    [imageStack addObject:imageInView];
    [self.view sendSubviewToBack:scrollView];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)didFinishInstruction:(UIButton*)sender {
    sender.alpha = 1.0;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         sender.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         [sender removeFromSuperview];
                         [[NSUserDefaults standardUserDefaults]setObject:@"CompletedInstructions" forKey:@"editinstructions"];

                     }];
}
- (IBAction)cancelButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}
-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{
   
    if (sender.state == UIGestureRecognizerStateEnded) {
        
    }else if(sender.state == UIGestureRecognizerStateBegan){
        NSLog(@"pressed for long");
        CGPoint presspoint = [sender locationInView:self.imageToEdit];
         CGPoint presspointInMainView = [sender locationInView:self.view];
        NSLog(@"presspoint = %@",NSStringFromCGPoint(presspoint));
//        draggableImageView.center = CGPointMake(presspoint.x, presspoint.y);
        CGRect slideViewFinalFrame ;
        
           slideViewFinalFrame = CGRectMake(presspointInMainView.x-(imageToEdit.bounds.size.width/20.0f)*scrollView.zoomScale, presspointInMainView.y, (imageToEdit.bounds.size.width/20.0f)*scrollView.zoomScale, (imageToEdit.bounds.size.height/20.0f)*scrollView.zoomScale);
    
        [self.view sendSubviewToBack:scrollView];
        NSLog(@"finalframe = %@",NSStringFromCGRect(slideViewFinalFrame));
        draggableImageView.frame = CGRectMake(0, 0, 320, 320);
        
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         draggableImageView.frame =slideViewFinalFrame;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                         //play smoke anim
                         float imagePercentOfRealImage;
                         if (draggableImageView.image == [UIImage imageNamed:@"start.png"]||draggableImageView.image == [UIImage imageNamed:@"end.png"]) {
                             imagePercentOfRealImage = 10.0f;
                         }else{
                             imagePercentOfRealImage = 20.0f;
                         }
                          draggableImageView.frame = CGRectMake(presspoint.x- (imageToEdit.bounds.size.width/imagePercentOfRealImage), presspoint.y, (imageToEdit.bounds.size.width/imagePercentOfRealImage), (imageToEdit.bounds.size.height/imagePercentOfRealImage));
                         imageToEdit.image = [self imageByDrawingCircleOnImage:imageToEdit.image];
                         [imageToEdit setNeedsDisplay];
                         draggableImageView.frame = originalArrowFrame;
                     }];
       // [draggableImageView setFrame:CGRectMake(presspoint.x- (imageToEdit.bounds.size.width/20.0f), presspoint.y, (imageToEdit.bounds.size.width/20.0f), (imageToEdit.bounds.size.height/20.0f))];

    }
}
- (IBAction)selectArrow:(UIButton*)sender {
    [button1 setBackgroundImage:[UIImage imageNamed:@"graybutton.png"] forState:UIControlStateNormal];
     [button2 setBackgroundImage:[UIImage imageNamed:@"graybutton.png"] forState:UIControlStateNormal];
     [button3 setBackgroundImage:[UIImage imageNamed:@"graybutton.png"] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageNamed:@"graybuttondepressed.png"] forState:UIControlStateNormal];
    switch (sender.tag) {
        case 0:
            draggableImageView.image = [UIImage imageNamed:@"arrow.png"];
            break;
        case 1:
            draggableImageView.image = [UIImage imageNamed:@"start.png"];
            break;
        case 2:
            draggableImageView.image = [UIImage imageNamed:@"end.png"];
            break;
        default:
            break;
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden=YES;
    [scrollView setZoomScale:(320.0f/imageInView.size.width) animated:NO];
}
- (IBAction)reset:(id)sender {
   
    imageToEdit.image = [imageStack objectAtIndex:[imageStack count]-1];
    if( [imageStack objectAtIndex:[imageStack count]-1]==imageInView) {
        
    }else{
    [imageStack removeLastObject];
    }

//   
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)_scrollView {
  	return imageToEdit;
}


- (IBAction)confirm:(id)sender {
    // Image to save
    
    // Request to save the image to camera roll
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];

   
  
    
   // [imageMetaData setObject:[self updateExif:myCurrentLocation] forKey:(NSString*)kCGImagePropertyGPSDictionary];          
   

    [library writeImageToSavedPhotosAlbum:[imageToEdit.image CGImage] metadata:imageMetaData completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"error is %@",error);
        }
        
         [JHNotificationManager notificationWithMessage:@"Photo saved with location to camera roll"];
    }];
    
   // UIImageWriteToSavedPhotosAlbum(imageToEdit.image, self, 
    //                               @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [library release];
}
 
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error 
  contextInfo:(void *)contextInfo
{
    // Was there an error?
    if (error != NULL)
    {
        // Show error message...
        
    }
    else  // No errors
    {
    [JHNotificationManager notificationWithMessage:@"Photo saved to camera roll"];
    }
}
/*
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    sliderView.hidden = NO;
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.view];
            NSLog(@"touchedview = %@",touch.view);
   
        for (UIView* view in self.view.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                if (view.tag == 1) {
                    NSLog(@"view tag = %d",view.tag);
                    if (CGRectContainsPoint(view.frame, location)) {
                                    NSLog(@"draggableview = %@",view);
                            draggableImageView = (UIImageView*)view;
                        if (!CGRectContainsPoint(CGRectMake(0, 0, 320, 320), location)) {
                            originalArrowFrame = view.frame;
                        }
                    }
                }
            }
        

    }
    //N/SLog(@"touch.view = %@",touch.view);
	
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	//[self touchesBegan:touches withEvent:event];
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    draggableImageView.center = CGPointMake(location.x, location.y);

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
        UITouch *touch = [[event allTouches] anyObject];
    
        locationinscroll = [touch locationInView:scrollView];
    //draggableImageView.center = CGPointMake(location.x, location.y);
 //   CGPoint presspoint = [touch locationInView:self.imageToEdit];
    //CGPoint presspointInMainView = [touch locationInView:self.view];
   // 
  //  draggableImageView.frame = originalArrowFrame;
    
    
    
    
}
*/
- (IBAction)DoneButton:(id)sender {
    CreateRouteViewController* viewController= [[CreateRouteViewController alloc]initWithNibName:@"CreateRouteViewController" bundle:nil];
	viewController.imageTaken = imageToEdit.image;
    viewController.imageMetaData = self.imageMetaData;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}

- (UIImage *)imageByDrawingCircleOnImage:(UIImage *)image
{

        
	// begin a graphics context of sufficient size
    [imageStack addObject:image];
    
	UIGraphicsBeginImageContext(image.size);
    
	// draw original image into the context
	[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
	
    CGRect newrect = CGRectMake((draggableImageView.frame.origin.x/imageToEdit.bounds.size.width)*image.size.width, (draggableImageView.frame.origin.y/imageToEdit.bounds.size.height)*image.size.height, (draggableImageView.frame.size.width/imageToEdit.bounds.size.width)*image.size.width, (draggableImageView.frame.size.height/imageToEdit.bounds.size.height)*image.size.height);
    
    NSLog(@"newrect = %@",NSStringFromCGRect(newrect));
    [draggableImageView.image drawInRect:newrect];

	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
   
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage; 
}



- (void)viewDidUnload
{
    [self setDraggableImageView:nil];
    [self setSliderView:nil];
    [self setConfButton:nil];
    [self setInstructionButton:nil];
    [self setButton1:nil];
    [self setButton2:nil];
    [self setButton3:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
-(void)dealloc
{
    [imageMetaData release];
    [draggableImageView release];
    [sliderView release];
    [confButton release];
    [instructionButton release];
    [button1 release];
    [button2 release];
    [button3 release];
    [super dealloc];
    [imageToEdit release];
}
@end
