
#import "EditImageViewController.h"
#import "AssetsLibrary/ALAssetsLibrary.h"
#import "HRColorPickerViewController.h"
#import "NSMutableDictionary+ImageMetadata.h"
//#import "FlurryAnalytics.h"
#import "ArrowChangeCell.h"
@implementation EditImageViewController
@synthesize draggableImageView;
@synthesize imageToEdit,imageInView;
@synthesize instructionButton;
@synthesize delegate;
@synthesize confButton;
@synthesize CGPointsArray;
@synthesize arrowTypeArray;
@synthesize arrowColorArray;
@synthesize moreArrowsView;
@synthesize arrowImageView;
@synthesize startImageView;
@synthesize endImageView;
@synthesize arrowTable;
@synthesize button1;
@synthesize button2;
@synthesize button3;
@synthesize imageMetaData;
@synthesize sliderView;
@synthesize imageStack;
@synthesize reusePFObject;
@synthesize selectColor;
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
    [self selectArrow:button1];
    selectColor = [UIColor redColor];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(DoneButton:)];
    self.navigationItem.rightBarButtonItem = rightButton;
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    [rightButton release];
    UIBarButtonItem* leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonSystemItemDone target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = leftButton;
    [leftButton release];
    self.navigationItem.title = @"Add Arrows";
    originalArrowFrame = CGRectMake(9, 327, 28, 28);
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    [self.view addSubview:scrollView];
    scrollView.delegate = self;
     [[NSUserDefaults standardUserDefaults]setObject:nil forKey:@"editinstructions"];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"editinstructions"]) {
        instructionButton.hidden = YES;
    }else{
        instructionButton.hidden=NO;
    }
    
    
    
    if ([[imageMetaData objectForKey:@"sourceType"]isEqualToString:@"UIImagePickerControllerSourceTypeCamera"]) {
        
     NSLog(@"crashes around here1");
     CGAffineTransform transform = CGAffineTransformIdentity;
         NSLog(@"crashes around here2");
     transform = CGAffineTransformTranslate(transform, 0, imageInView.size.width);
         NSLog(@"crashes around here3");
     transform = CGAffineTransformRotate(transform, -M_PI_2);
         NSLog(@"crashes around here4");
     CGRect newRect = CGRectIntegral(CGRectMake(0, 0, imageInView.size.width, imageInView.size.width));
 NSLog(@"crashes around here5");
          CGImageRef imageRef = imageInView.CGImage;
         NSLog(@"crashes around here6");
     // Build a context that's the same dimensions as the new size

     CGContextRef bitmap = CGBitmapContextCreate(NULL,
     newRect.size.width,
     newRect.size.height,
     CGImageGetBitsPerComponent(imageRef),
     0,
     CGImageGetColorSpace(imageRef),
     CGImageGetBitmapInfo(imageRef));
        NSLog(@"crashes around here7");
     // Rotate and/or flip the image if required by its orientation
     CGContextConcatCTM(bitmap, transform);
              NSLog(@"crashes around here8");
     // Set the quality level to use when rescaling
     CGContextSetInterpolationQuality(bitmap, kCGInterpolationHigh);
              NSLog(@"crashes around here9");
     // Draw into the context; this scales the image
        
     CGContextDrawImage(bitmap,  newRect, imageRef);
              NSLog(@"crashes around here10");
     // Get the resized image from the context and a UIImage
     CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
                 NSLog(@"crashes around here11");
     CGContextRelease(bitmap);
     imageInView = [UIImage imageWithCGImage:newImageRef];
     CGImageRelease(newImageRef);

    
    }
    
    
    
      imageToEdit = [[UIImageView alloc]initWithImage:imageInView];
    imageToEdit.userInteractionEnabled = YES;
    CGRect rect = CGRectMake(0, 0, imageInView.size.width, imageInView.size.height);
    [imageToEdit setFrame:rect];
    [scrollView addSubview:imageToEdit];
    scrollView.contentSize=CGSizeMake(imageInView.size.width, imageInView.size.width);
    scrollView.maximumZoomScale = 3;
    scrollView.minimumZoomScale = (320.0f/imageInView.size.width);
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture setDelegate:self];
    [imageToEdit addGestureRecognizer:tapGesture];
    [tapGesture release];
    
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [doubleTapGesture setDelegate:self];
    [imageToEdit addGestureRecognizer:doubleTapGesture];
    [doubleTapGesture release];
   
    
    UILongPressGestureRecognizer* longpressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    [longpressGesture setDelegate:self];
    [imageToEdit addGestureRecognizer:longpressGesture];
    [longpressGesture release];
    
    [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
     [tapGesture requireGestureRecognizerToFail:longpressGesture];
            CGPointsArray = [[NSMutableArray alloc]init ];
                arrowTypeArray = [[NSMutableArray alloc]init ];
    arrowColorArray = [[NSMutableArray alloc]init ];
    imageStack = [[NSMutableArray alloc]init ];
    

    [imageStack addObject:imageInView];

    [self.view sendSubviewToBack:scrollView];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)didFinishInstruction:(UIButton*)sender {
    [self.navigationItem.rightBarButtonItem setEnabled:YES];
    sender.alpha = 1.0;
    [UIView animateWithDuration:0.4
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         sender.alpha = 0.0;
                     } 
                     completion:^(BOOL finished){
                         sender.hidden=YES;
                        

                     }];
}
- (IBAction)cancelButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
    NSLog(@"share action ended");
//    [FlurryAnalytics endTimedEvent:@"SHARE_ACTION" withParameters:nil];
}
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [scrollView frame].size.height / scale;
    zoomRect.size.width  = [scrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}
-(void)handleDoubleTap:(UITapGestureRecognizer*)sender{
    if (scrollView.zoomScale  > 1.0){
        float newScale = (320.0f/imageInView.size.width);
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[sender locationInView:sender.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
        
           
    }else{
        float newScale = 2;
        CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[sender locationInView:sender.view]];
        [scrollView zoomToRect:zoomRect animated:YES];
 
    }


}
-(void)handleTap:(UITapGestureRecognizer*)sender{

CGPoint presspoint = [sender locationInView:self.imageToEdit];
CGPoint presspointInMainView = [sender locationInView:self.view];

CGRect slideViewFinalFrame ;

slideViewFinalFrame = CGRectMake(presspointInMainView.x-(imageToEdit.bounds.size.width/20.0f)*scrollView.zoomScale, presspointInMainView.y, (imageToEdit.bounds.size.width/20.0f)*scrollView.zoomScale, (imageToEdit.bounds.size.height/20.0f)*scrollView.zoomScale);

[self.view sendSubviewToBack:scrollView];
//NSLog(@"finalframe = %@",NSStringFromCGRect(slideViewFinalFrame));
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
                     if (draggableImageView.image == startImageView.image||draggableImageView.image == endImageView.image) {
                         imagePercentOfRealImage = 10.0f;
                     }else{
                         imagePercentOfRealImage = 20.0f;
                     }
                     draggableImageView.frame = CGRectMake(presspoint.x- (imageToEdit.bounds.size.width/imagePercentOfRealImage), presspoint.y, (imageToEdit.bounds.size.width/imagePercentOfRealImage), (imageToEdit.bounds.size.height/imagePercentOfRealImage));
                     imageToEdit.image = [self imageByDrawingCircleOnImage:imageToEdit.image];
                     //[self clipImageViewWithMask:imageToEdit];
                     
                     [imageToEdit setNeedsDisplay];
                     [CGPointsArray addObject: NSStringFromCGRect(draggableImageView.frame)];
                     [arrowTypeArray addObject:selectedArrowType];
                     CGColorRef colorRef = selectColor.CGColor;
                     NSString *colorString = [CIColor colorWithCGColor:colorRef].stringRepresentation;
                     [arrowColorArray addObject:colorString];
                     draggableImageView.frame = originalArrowFrame;
                    
                 }];

}

-(void)handleLongPress:(UILongPressGestureRecognizer*)sender{

//    if (sender.state == UIGestureRecognizerStateEnded) {
//        
//    }else if(sender.state == UIGestureRecognizerStateBegan){
//
//        CGPoint presspoint = [sender locationInView:self.imageToEdit];
//         CGPoint presspointInMainView = [sender locationInView:self.view];
//
////        draggableImageView.center = CGPointMake(presspoint.x, presspoint.y);
//        CGRect slideViewFinalFrame ;
//        
//           slideViewFinalFrame = CGRectMake(presspointInMainView.x-(imageToEdit.bounds.size.width/20.0f)*scrollView.zoomScale, presspointInMainView.y, (imageToEdit.bounds.size.width/20.0f)*scrollView.zoomScale, (imageToEdit.bounds.size.height/20.0f)*scrollView.zoomScale);
//    
//        [self.view sendSubviewToBack:scrollView];
//        NSLog(@"finalframe = %@",NSStringFromCGRect(slideViewFinalFrame));
//        draggableImageView.frame = CGRectMake(0, 0, 320, 320);
//        
//    [UIView animateWithDuration:0.1
//                          delay:0.0
//                        options: UIViewAnimationCurveEaseIn
//                     animations:^{
//                         draggableImageView.frame =slideViewFinalFrame;
//                     } 
//                     completion:^(BOOL finished){
//                         NSLog(@"Done!");
//                         //play smoke anim
//                         float imagePercentOfRealImage;
//                         if (draggableImageView.image == startImageView.image||draggableImageView.image == endImageView.image) {
//                             imagePercentOfRealImage = 10.0f;
//                         }else{
//                             imagePercentOfRealImage = 20.0f;
//                         }
//                          draggableImageView.frame = CGRectMake(presspoint.x- (imageToEdit.bounds.size.width/imagePercentOfRealImage), presspoint.y, (imageToEdit.bounds.size.width/imagePercentOfRealImage), (imageToEdit.bounds.size.height/imagePercentOfRealImage));
//                         imageToEdit.image = [self imageByDrawingCircleOnImage:imageToEdit.image];
//                         [imageToEdit setNeedsDisplay];
//                         [CGPointsArray addObject: NSStringFromCGRect(draggableImageView.frame)];
//                         [arrowTypeArray addObject:selectedArrowType];
//                         NSLog(@"cgpointsarray = %@",CGPointsArray);
//                                               NSLog(@"arrowtype array = %@",arrowTypeArray);
//                         draggableImageView.frame = originalArrowFrame;
//                     }];
//       // [draggableImageView setFrame:CGRectMake(presspoint.x- (imageToEdit.bounds.size.width/20.0f), presspoint.y, (imageToEdit.bounds.size.width/20.0f), (imageToEdit.bounds.size.height/20.0f))];
//
//    }
}
- (IBAction)selectArrow:(UIButton*)sender {
    [button1 setBackgroundImage:[UIImage imageNamed:@"graybutton.png"] forState:UIControlStateNormal];
     [button2 setBackgroundImage:[UIImage imageNamed:@"graybutton.png"] forState:UIControlStateNormal];
     [button3 setBackgroundImage:[UIImage imageNamed:@"graybutton.png"] forState:UIControlStateNormal];
    [sender setBackgroundImage:[UIImage imageNamed:@"graybuttondepressed.png"] forState:UIControlStateNormal];
    switch (sender.tag) {
        case 0:
            draggableImageView.image = arrowImageView.image;
                selectedArrowType = [NSNumber numberWithInt:0];
            
            break;
        case 1:
            draggableImageView.image = startImageView.image;
                selectedArrowType = [NSNumber numberWithInt:1];
            
            break;
        case 2:
            draggableImageView.image = endImageView.image;
                selectedArrowType = [NSNumber numberWithInt:2];
            break;
        default:
            break;
    }
        
    
}
-(void)viewWillAppear:(BOOL)animated
{

    [scrollView setZoomScale:(320.0f/imageInView.size.width) animated:NO];

}
- (IBAction)reset:(id)sender {
   
    imageToEdit.image = [imageStack objectAtIndex:[imageStack count]-1];
    if([CGPointsArray count]){
    [CGPointsArray removeLastObject];
    [arrowTypeArray removeLastObject];
        [arrowColorArray removeLastObject];
    }
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
- (void)setSelectedColor:(UIColor*)color
{
    [self setSelectColor:color];
    
        UIGraphicsBeginImageContext(arrowImageView.image.size);
        [arrowImageView.image drawAtPoint:CGPointZero];
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect rect = CGRectMake(0, 0, arrowImageView.image.size.width, arrowImageView.image.size.height);
	     CGContextClipToMask(context, rect , [UIImage imageNamed:@"arrow3flip"].CGImage);

   
        
        [arrowImageView.image drawInRect:arrowImageView.frame blendMode:kCGBlendModeNormal alpha:1.0];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [selectColor setFill];
        CGContextFillRect(context, rect);
        // make image out of bitmap context
        UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
        
        // free the context
        UIGraphicsEndImageContext();
    arrowImageView.image = retImage;
    
}
- (IBAction)moreArrows:(id)sender {
    HRColorPickerViewController* controller = [HRColorPickerViewController fullColorPickerViewControllerWithColor:selectColor];
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
//    if (CGRectEqualToRect(moreArrowsView.frame, CGRectMake(17, 106, 211, 237))) {
//        CGRect slideFinalFrame = CGRectMake(17, 320, 211, 237);
//        [UIView animateWithDuration:0.3
//                              delay:0.0
//                            options: UIViewAnimationCurveEaseIn
//                         animations:^{
//                             moreArrowsView.frame = slideFinalFrame;
//                         } 
//                         completion:^(BOOL finished){
//                         }];  
//    }else{
//    CGRect slideFinalFrame = CGRectMake(17, 106, 211, 237);
//    [UIView animateWithDuration:0.3
//                          delay:0.0
//                        options: UIViewAnimationCurveEaseIn
//                     animations:^{
//                         moreArrowsView.frame = slideFinalFrame;
//                     } 
//                     completion:^(BOOL finished){
//                     }];
//    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromCellIdentifier = @"FromCell";
    ArrowChangeCell* cell = (ArrowChangeCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ArrowChangeCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (ArrowChangeCell*)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
        }
    }
    cell.arrowImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"arrow%d",indexPath.row+1]];
    cell.startImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"start%d",indexPath.row+1]];
    cell.endImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"end%d",indexPath.row+1]];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    arrowImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"arrow%d",indexPath.row+1]];
    startImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"start%d",indexPath.row+1]];
    endImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"end%d",indexPath.row+1]]; 
    [self selectArrow:button1];
    CGRect slideFinalFrame = CGRectMake(17, 320, 211, 237);
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         moreArrowsView.frame = slideFinalFrame;
                     } 
                     completion:^(BOOL finished){
                     }];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (IBAction)confirm:(id)sender {
    // Image to save
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Save To Camera Roll" message:@"We'll save your photo and geotag it so you can continue later!  " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
    [alert show];
    [alert release];
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex) {
    // Request to save the image to camera roll
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
 //   [FlurryAnalytics logEvent:@"USED_SAVE_BUTTON"];
    
    
    
    // [imageMetaData setObject:[self updateExif:myCurrentLocation] forKey:(NSString*)kCGImagePropertyGPSDictionary];          
    
    
    [library writeImageToSavedPhotosAlbum:[[imageStack objectAtIndex:0] CGImage] metadata:imageMetaData completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"error is %@",error);
        }
        
        [JHNotificationManager notificationWithMessage:@"Photo saved with location to camera roll"];
    }];
    
    // UIImageWriteToSavedPhotosAlbum(imageToEdit.image, self, 
    //                               @selector(image:didFinishSavingWithError:contextInfo:), nil);
    [library release];
}
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
    NSLog(@"color array = %@",arrowColorArray);
    viewController.reusePFObject = reusePFObject;
	viewController.imageTaken = imageToEdit.image;
    viewController.originalImage = [imageStack objectAtIndex:0];
    viewController.CGPointsArray = CGPointsArray;
    viewController.arrowTypeArray = arrowTypeArray;
    viewController.arrowColorArray = arrowColorArray;
    viewController.imageMetaData = self.imageMetaData;
    [imageStack removeAllObjects];
    [imageStack addObject:viewController.originalImage];

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
	
    CGContextRef context = UIGraphicsGetCurrentContext();
    
     CGRect newrect = CGRectMake((draggableImageView.frame.origin.x/imageToEdit.bounds.size.width)*image.size.width, (draggableImageView.frame.origin.y/imageToEdit.bounds.size.height)*image.size.height, (draggableImageView.frame.size.width/imageToEdit.bounds.size.width)*image.size.width, (draggableImageView.frame.size.height/imageToEdit.bounds.size.height)*image.size.height);
     
    //set the clipping area to the image
    if (selectedArrowType==[NSNumber numberWithInt:0]) {
    CGContextClipToMask(context, newrect, [UIImage imageNamed:@"arrow3flip"].CGImage);
        
        [draggableImageView.image drawInRect:newrect blendMode:kCGBlendModeNormal alpha:1.0];
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        [selectColor setFill];
        CGContextFillRect(context, newrect);
    }else if(selectedArrowType==[NSNumber numberWithInt:1]) {
        CGContextSetFillColorWithColor(context, selectColor.CGColor);
        NSString* text = @"START";
        [text drawInRect:newrect withFont:[UIFont boldSystemFontOfSize:25]];
//        CGContextClipToMask(context, newrect, [UIImage imageNamed:@"start1flip"].CGImage);
    }else if(selectedArrowType==[NSNumber numberWithInt:2]) {
        CGContextSetFillColorWithColor(context, selectColor.CGColor);
        NSString* text = @"END";
        [text drawInRect:newrect withFont:[UIFont boldSystemFontOfSize:25]];
    }
    
        
    
    
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
    [self setArrowImageView:nil];
    [self setStartImageView:nil];
    [self setEndImageView:nil];
    [self setArrowTable:nil];

    [self setMoreArrowsView:nil];
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
- (IBAction)helpButton:(id)sender {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    if (instructionButton.hidden) {
        instructionButton.hidden=NO;
        instructionButton.alpha = 0;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             instructionButton.alpha = 1.0;
                         } 
                         completion:^(BOOL finished){                        
                             
                         }];
    }else{
        instructionButton.alpha = 1.0;
        [UIView animateWithDuration:0.4
                              delay:0.0
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             instructionButton.alpha = 0.0;
                         } 
                         completion:^(BOOL finished){
                             instructionButton.hidden = YES;
                             
                             
                         }];
    }
}
- (IBAction)turnClockwise:(id)sender {
    //pop all images and turn image
    imageToEdit.image = [imageStack objectAtIndex:0];
    if([CGPointsArray count]){
        [CGPointsArray removeAllObjects];
        [arrowTypeArray removeAllObjects];
        [arrowColorArray removeAllObjects];
    }
    [imageStack removeAllObjects];
    int imgorientation = 0 ;
    switch (imageInView.imageOrientation) {
        case UIImageOrientationLeft:
            imgorientation = UIImageOrientationUp;
            break;
        case UIImageOrientationUp:
            imgorientation = UIImageOrientationRight;
            break;   
        case UIImageOrientationDown:
            imgorientation = UIImageOrientationLeft;
            break;
        case UIImageOrientationRight:
            imgorientation = UIImageOrientationDown;
            break;    
        default:
            break;
    }
    UIImage * PortraitImage = [[UIImage alloc] initWithCGImage: imageInView.CGImage
                                                         scale: 1.0
                                                   orientation: imgorientation];
    imageInView = PortraitImage;
    imageToEdit.image = PortraitImage;
  
    [imageStack addObject:PortraitImage];
      [PortraitImage release];
}
-(void)dealloc
{
    NSLog(@"dealloc on editimageview.. clearing image stack");
    [imageStack release];
    [imageMetaData release];
    [draggableImageView release];
    [sliderView release];
    [confButton release];
    [instructionButton release];
    [button1 release];
    [button2 release];
    [button3 release];
    [arrowImageView release];
    [startImageView release];
    [endImageView release];
    [arrowTable release];
    [arrowTypeArray release];
    [arrowColorArray release];
    [CGPointsArray release];
    [super dealloc];
    [imageToEdit release];
}
@end
