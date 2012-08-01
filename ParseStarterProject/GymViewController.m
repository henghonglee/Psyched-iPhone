//
//  GymViewViewController.m
//  PsychedApp
//
//  Created by HengHong on 31/7/12.
//
//

#import "GymViewController.h"

#import <QuartzCore/QuartzCore.h>
@implementation GymViewController
@synthesize pageControl;
@synthesize gymWallScroll;
@synthesize gymRouteScroll;
@synthesize maskbgView;
@synthesize wallImageViews;
@synthesize gymProfileImageView;
@synthesize ourRoutesButton;
@synthesize gymNameLabel;
@synthesize profileshadow;
@synthesize gymCoverImageView;
@synthesize gymMapView;
@synthesize imageViewContainer;
@synthesize gymObject,gymName;
@synthesize wallViewArrays;
@synthesize gymTags,gymSections;
@synthesize wallRoutesArrowArray;
@synthesize imageDataArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)didChangePage:(id)sender {
    // Update the scroll view to the appropriate page
    NSLog(@"changing page");
	CGRect frame;
	frame.origin.x = self.gymWallScroll.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.gymWallScroll.frame.size;
	[self.gymWallScroll scrollRectToVisible:frame animated:YES];
	
	pageControlBeingUsed = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    wallViewArrays = [[NSMutableArray alloc]init];
    gymTags = [[NSMutableArray alloc]init];
    gymSections = [[NSMutableDictionary alloc]init ];
    wallRoutesArrowArray = [[NSMutableArray alloc]init];
    imageDataArray =[[NSMutableArray alloc]init];
    __block int downloadedRouteCount=0;
    //find number of walls by hashtag
    //get their images
    //if user exits gym page just destroy all from array
    PFQuery* gymWallQuery = [PFQuery queryWithClassName:@"Route"];
    #warning distance need to change back to 1
    [gymWallQuery whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:5.];
    [gymWallQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [gymWallQuery whereKeyExists:@"hashtag"];
    [gymWallQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        //NSLog(@"objects = %@",objects);
        //prepare arrays
        for (NSString* key in [self.gymSections allKeys]) {
            [[self.gymSections objectForKey:key] removeAllObjects];
        }
        for (PFObject* object in objects) {
            NSString* sectionToInsert =  [object objectForKey:@"hashtag"];
            BOOL found = NO;
            for (NSString *str in [self.gymSections allKeys])
            {
                if ([str isEqualToString:sectionToInsert])
                {
                    found = YES;
                }
            }
            if (!found && sectionToInsert!=NULL)
            {
                
                [self.gymSections setValue:[[[NSMutableArray alloc] init]autorelease] forKey:sectionToInsert];
            }
        }
        
        for (PFObject* object in objects) {
            if ([object objectForKey:@"hashtag"]) {
                
                RouteObject* route = [[RouteObject alloc]init];
                route.pfobj = object;
                
                [[self.gymSections objectForKey:[object objectForKey:@"hashtag"]] addObject:route];
                [route release];
            }
        }
        
        [self.gymTags addObjectsFromArray:[self.gymSections allKeys]];
        [self.gymTags sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
        for(int i=0; i<[self.gymTags count] ;i++)
        {
            NSArray* hashtaggedRoutes = [self.gymSections objectForKey:[[self.gymSections allKeys]objectAtIndex:i]];
            
            PFObject* firstRoute = ((RouteObject*)[hashtaggedRoutes objectAtIndex:0]).pfobj;
     //       NSLog(@"imagefile =%@",((PFFile*)[firstRoute objectForKey:@"imageFile"]).url);
    //#warning need better alert for download completed here and also change to gym no arrows
            [[firstRoute objectForKey:@"imageFile"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                UIView* wallView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
                wallView.backgroundColor = [UIColor clearColor];
                
                
                UILabel* wallLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
                wallLabel.textAlignment = UITextAlignmentCenter;
                wallLabel.text = [NSString stringWithFormat:@"%@",[[self.gymSections allKeys]objectAtIndex:i]];
                wallLabel.textColor = [UIColor whiteColor];
                wallLabel.backgroundColor = [UIColor clearColor];
                [wallView addSubview:wallLabel];
                [wallLabel release];
                

                UIImageView* wallimage = [[UIImageView alloc]initWithImage:[UIImage imageWithData:data]];
                wallimage.contentMode = UIViewContentModeScaleAspectFit;
                wallimage.frame = CGRectMake(16.5, 35, 287, 287);
//                wallimage.layer.cornerRadius = 20.0;
                wallimage.layer.borderWidth = 1.0;
                wallimage.layer.borderColor = [UIColor blackColor].CGColor;
                // wallimage.frame = CGRectMake(0,0,320,320);
                wallimage.userInteractionEnabled = YES;
                UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
                doubleTapGesture.delegate = self;
                [doubleTapGesture setNumberOfTapsRequired : 2];
                [wallimage addGestureRecognizer:doubleTapGesture];
                [doubleTapGesture release];
                
//                UIView* wallShadowView = [[UIView alloc]initWithFrame:CGRectMake(16.5, 35, 287, 287)];
//                wallShadowView.backgroundColor = [UIColor whiteColor];
//                wallShadowView.layer.cornerRadius = 5;
//                [wallView addSubview:wallShadowView];
//                [wallShadowView release];
//                
                [wallView addSubview:wallimage];
                
                [wallViewArrays addObject:wallView];
                [wallView release];
                [wallimage release];
                downloadedRouteCount++;
                NSLog(@"retrieved 1 image, count at %d/%d",downloadedRouteCount,[self.gymTags count]);
                if (downloadedRouteCount==[self.gymTags count]) {
                    ourRoutesButton.enabled = true;
                }
            }];
            
        }
    }];
    

    
    if (gymObject) {
        [self furthurinit];
    }else{
        PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
        [gymQuery whereKey:@"name" equalTo:gymName];
        [gymQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
         gymObject = object;
        [self furthurinit];
         }];
    }
    // Do any additional setup after loading the view from its nib.
}
-(void)handleDoubleTap:(id)sender
{
    NSLog(@"page tapped on = %d",self.pageControl.currentPage);
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    UIImageView* imgView = [[UIImageView alloc]initWithFrame:CGRectMake(16.5, 35, 287, 287)];
    imgView.userInteractionEnabled = YES;
    UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reverseHandleDoubleTap:)];
    
    doubleTapGesture.delegate = self;
    [doubleTapGesture setNumberOfTapsRequired : 2];
    [imgView addGestureRecognizer:doubleTapGesture];
    [doubleTapGesture release];
    [self.view addSubview:imgView];
    [imgView release];
    for (UIView* view in ((UIView*)[wallViewArrays objectAtIndex:self.pageControl.currentPage]).subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
           [imgView setImage:((UIImageView*)view).image];
        }
    }
    
    self.gymWallScroll.hidden = YES;
    self.pageControl.hidden = YES;
    CGRect slideViewFinalFrame = CGRectMake(0,23.5,320,320);
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         imgView.frame = slideViewFinalFrame;
                     } 
                     completion:^(BOOL finished){
                         maskbgView.hidden=NO;
                         maskbgView.alpha = 0.8;
                         [self performSelectorOnMainThread:@selector(drawArrowOverlays) withObject:nil waitUntilDone:YES];
                     }];
    
}

-(void)reverseHandleDoubleTap:(UITapGestureRecognizer*)sender
{
    if (self.navigationItem.leftBarButtonItem ==nil) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]] style:UIBarButtonItemStylePlain target:self action:@selector(returnToGym:)];
    }

    maskbgView.hidden=NO;
    maskbgView.image = nil;
    maskbgView.alpha = 0.8;
   
    CGRect slideViewFinalFrame = CGRectMake(16.5,35,287,287);
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         sender.view.frame = slideViewFinalFrame;
                     }
                     completion:^(BOOL finished){
                         gymWallScroll.hidden = NO;
                         self.pageControl.hidden = NO;
                         
                       
                         [sender.view removeFromSuperview];
                     }];

}
-(void)drawArrowOverlays
{

    for (RouteObject* route in [self.gymSections objectForKey:[[self.gymSections allKeys] objectAtIndex:self.pageControl.currentPage]]) {
        //  NSLog(@"arrowarray = %@ , arrowtypearray = %@ ",[route.pfobj objectForKey:@"arrowarray"],[route.pfobj objectForKey:@"arrowtypearray"]);
        
        UIImageView* arrowOverlay = [[UIImageView alloc]initWithFrame:CGRectMake(0, 23.5, 320, 320)];
        [arrowOverlay setImage:[UIImage imageNamed:@"walltest.jpg"]];
        arrowOverlay.contentMode =UIViewContentModeScaleAspectFit;
        arrowOverlay.backgroundColor = [UIColor clearColor];
        NSArray* routearrowarray = [route.pfobj objectForKey:@"arrowarray"];
        NSArray* arrowtypearray = [route.pfobj objectForKey:@"arrowtypearray"];
        UIImage* pastedimage;
        NSLog(@"routearrowarray = %@",routearrowarray);
        for (int i=0; i<[routearrowarray count]; i++) {
            
            
            CGRect routearrowrect = CGRectFromString([routearrowarray objectAtIndex:i]);
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:0]])
                pastedimage = [UIImage imageNamed:@"arrow1.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:1]])
                pastedimage = [UIImage imageNamed:@"start1.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:2]])
                pastedimage = [UIImage imageNamed:@"end1.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:3]])
                pastedimage = [UIImage imageNamed:@"arrow2.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:4]])
                pastedimage = [UIImage imageNamed:@"start2.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:5]])
                pastedimage = [UIImage imageNamed:@"end2.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:6]])
                pastedimage = [UIImage imageNamed:@"arrow3.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:7]])
                pastedimage = [UIImage imageNamed:@"start3.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:8]])
                pastedimage = [UIImage imageNamed:@"end3.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:9]])
                pastedimage = [UIImage imageNamed:@"arrow4.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:10]])
                pastedimage = [UIImage imageNamed:@"start4.png"];
            if([[arrowtypearray objectAtIndex:i]isEqualToNumber:[NSNumber numberWithInt:11]])
                pastedimage = [UIImage imageNamed:@"end4.png"];
            
            if (i==0) {
              arrowOverlay.image = [self blankImageByDrawingImage:pastedimage OnImage:arrowOverlay.image inRect:routearrowrect ];
            }else{
                arrowOverlay.image = [self imageByDrawingImage:pastedimage OnImage:arrowOverlay.image inRect:routearrowrect ];
            }
                                  
            // [pastedimage release];
            
        } //adding arrows to imageview
        [wallRoutesArrowArray addObject:arrowOverlay];
        [arrowOverlay release];
        
    }

}
- (UIImage *)imageByDrawingImage:(UIImage*)pastedImage OnImage:(UIImage *)image inRect:(CGRect)rect
{
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1);
//	UIGraphicsBeginImageContext(image.size);
    
	// draw original image into the context
	[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
	
    [pastedImage drawInRect:rect];
    
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
}
- (UIImage *)blankImageByDrawingImage:(UIImage*)pastedImage OnImage:(UIImage *)image inRect:(CGRect)rect
{
    
    
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 1);
    //	UIGraphicsBeginImageContext(image.size);
    
	// draw original image into the context
	//[image drawAtPoint:CGPointZero];
    
	// get the context for CoreGraphics
	
    [pastedImage drawInRect:rect];
    
    
	// make image out of bitmap context
	UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
	// free the context
	UIGraphicsEndImageContext();
    
	return retImage;
}
-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    //ideally should check if facebook liked and subscribed here
}

-(void)furthurinit
{
    
    imageViewContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    imageViewContainer.layer.borderWidth = 3;
    
    profileshadow.layer.shadowRadius=2;
    profileshadow.layer.shadowOpacity = 0.3;
    profileshadow.layer.shadowColor = [UIColor blackColor].CGColor;
    profileshadow.layer.shadowOffset = CGSizeMake(0, 2);
    
    profileshadow.layer.shadowPath = [self renderPaperCurl:profileshadow];
    
    
    gymNameLabel.text = [NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]];
    gymMapView.layer.borderColor = [UIColor whiteColor].CGColor;
    gymMapView.layer.borderWidth = 3;
    PFGeoPoint* gymgeopoint = ((PFGeoPoint*)[gymObject objectForKey:@"gymlocation"]);
    
    CLLocationCoordinate2D gymLoc = CLLocationCoordinate2DMake(gymgeopoint.latitude,gymgeopoint.longitude);
    [gymMapView setCenterCoordinate:gymLoc zoomLevel:14 animated:NO];
    
    
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]];
    
    
    ASIHTTPRequest* coverrequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[gymObject objectForKey:@"coverimagelink"]] ];
    [coverrequest setCompletionBlock:^{
        gymCoverImageView.image = [UIImage imageWithData:[coverrequest responseData]];
        
    }];
    [coverrequest setFailedBlock:^{}];
    [coverrequest startAsynchronous];
    
    ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[gymObject objectForKey:@"imagelink"]] ];
    [request setCompletionBlock:^{
        
        gymProfileImageView.image = [UIImage imageWithData:[request responseData]];
        NSLog(@"size ht = %f",gymProfileImageView.image.size.height);
        NSLog(@"size wd = %f",gymProfileImageView.image.size.width);
        if (gymProfileImageView.image.size.height>=gymProfileImageView.image.size.width) {
            [gymProfileImageView setFrame:CGRectMake(0, 0, 75, gymProfileImageView.image.size.height/(gymProfileImageView.image.size.width/75))];
        }
       
    }];
    [request setFailedBlock:^{}];
    [request startAsynchronous];
    
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.gymWallScroll.frame.size.width;
		page = floor((self.gymWallScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;

	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[[self.gymSections allKeys]objectAtIndex:self.pageControl.currentPage]];
}


- (CGPathRef)renderPaperCurl:(UIView*)imgView
{
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 10.0f;
	CGFloat shadowDepth = 5.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.0f, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
	[path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
			controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
			controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
	return path.CGPath;
}
-(void)returnToGym:(id)sender
{
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         gymWallScroll.alpha = 0;
                         maskbgView.alpha=0;
                         self.pageControl.alpha=0;
                     }
                     completion:^(BOOL finished){
                         
                         gymWallScroll.hidden=YES;
                         maskbgView.hidden=YES;
                         self.pageControl.hidden = YES;
                         //                         [sender.view removeFromSuperview];
                     }];

   
    
    self.navigationItem.leftBarButtonItem = self.navigationItem.backBarButtonItem;
}
- (IBAction)ShowWallViewController:(id)sender {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]] style:UIBarButtonItemStylePlain target:self action:@selector(returnToGym:)];
        pageControlBeingUsed = NO;
    for (int i = 0; i < wallViewArrays.count; i++) {
		CGRect frame;
		frame.origin.x = self.gymWallScroll.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.gymWallScroll.frame.size;
        
        ((UIView*)[wallViewArrays objectAtIndex:i]).frame = frame;
		[self.gymWallScroll addSubview:((UIView*)[wallViewArrays objectAtIndex:i])];
        
		//[pageOneImageView release];
	}
	
	self.gymWallScroll.contentSize = CGSizeMake(self.gymWallScroll.frame.size.width * wallViewArrays.count, self.gymWallScroll.frame.size.height);
	
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = wallViewArrays.count;
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[[self.gymSections allKeys]objectAtIndex:self.pageControl.currentPage]];
    self.gymWallScroll.hidden=NO;
    self.pageControl.hidden =NO;
    self.maskbgView.image = nil;
    self.maskbgView.hidden=NO;
    self.gymWallScroll.alpha=0;
    self.pageControl.alpha =0;
    self.maskbgView.image = nil;
    self.maskbgView.alpha=0;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         gymWallScroll.alpha = 1;
                         maskbgView.alpha=0.8;
                         self.pageControl.alpha=1;
                     }
                     completion:^(BOOL finished){
                        
                        
                     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [wallRoutesArrowArray release];
    [imageViewContainer release];
    [gymProfileImageView release];
    [gymNameLabel release];
    [profileshadow release];
    [gymCoverImageView release];
    [gymMapView release];
    [gymWallScroll release];
    [wallImageViews release];
    [pageControl release];
    [maskbgView release];
    [ourRoutesButton release];
    [gymRouteScroll release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setImageViewContainer:nil];
    [self setGymProfileImageView:nil];
    [self setGymNameLabel:nil];
    [self setProfileshadow:nil];
    [self setGymCoverImageView:nil];
    [self setGymMapView:nil];
    [self setGymWallScroll:nil];
    [self setWallImageViews:nil];
    [self setPageControl:nil];
    [self setMaskbgView:nil];
    [self setOurRoutesButton:nil];
    [self setGymRouteScroll:nil];
    [super viewDidUnload];
}
@end
