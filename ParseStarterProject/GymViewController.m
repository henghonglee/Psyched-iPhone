//
//  GymViewViewController.m
//  PsychedApp
//
//  Created by HengHong on 31/7/12.
//
//
#import "BaseViewController.h"
#import "GymViewController.h"
#import "GradientButton.h"
#import <QuartzCore/QuartzCore.h>
@implementation GymViewController
@synthesize loadRoutesActivityIndicator;
@synthesize pageControl;
@synthesize gymWallScroll;
@synthesize footerView;
@synthesize footerUserImageView;
@synthesize footerLabel;
@synthesize footerDifficultyLabel;
@synthesize likeButton;
@synthesize followButton;
@synthesize maskbgView;
@synthesize wallImageViews;
@synthesize routePageControl;
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
@synthesize wallRoutesArrowArray,wallRoutesArrowTypeArray;
@synthesize imageDataArray;
@synthesize gymRouteScroll;
@synthesize queryArray;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)didChangePage:(id)sender
{
    // Update the scroll view to the appropriate page
    NSLog(@"changing page");
	CGRect frame;
	frame.origin.x = self.gymWallScroll.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.gymWallScroll.frame.size;
	[self.gymWallScroll scrollRectToVisible:frame animated:YES];
	
	pageControlBeingUsed = YES;
}
- (IBAction)didChangeRoutePage:(id)sender
{
    // Update the scroll view to the appropriate page
    NSLog(@"changing route page");
	CGRect frame;
	frame.origin.x = self.gymRouteScroll.frame.size.width * self.routePageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.gymRouteScroll.frame.size;
	[self.gymRouteScroll scrollRectToVisible:frame animated:YES];
    
	pageControlBeingUsed = YES;
}
- (IBAction)likeButton:(id)sender
{
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://page/%@",[gymObject objectForKey:@"facebookid"]]]];

}
- (IBAction)followUsButton:(id)sender
{
    followButton.enabled = NO;
    [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet *channels, NSError *error) {
        if ([channels containsObject:[NSString stringWithFormat:@"channel%@",gymObject.objectId]]) {
            NSLog(@"isSubscribedToThisGym");
            [PFPush unsubscribeFromChannelInBackground:[NSString stringWithFormat:@"channel%@",gymObject.objectId] block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@"unsubed from channel channel+gymobject.objectid ");
                    [followButton setTitle:@"Follow Us!" forState:UIControlStateNormal];
                    followButton.enabled = YES;
                }
            }];
        }else{
            [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",gymObject.objectId] block:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                NSLog(@"subscribed to channel channel+gymobject.objectid ");
                [followButton setTitle:@"Following!" forState:UIControlStateNormal];
                 followButton.enabled = YES;
                                    }
            }];
            
        }
       
    }];

   /* 
    NSArray* adminArray = [[gymObject fetchIfNeeded] objectForKey:@"admin"];
    if (![adminArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
        PFQuery* followedQuery = [PFQuery queryWithClassName:@"Follow"];
        [followedQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
        [followedQuery whereKey:@"followed" containedIn:adminArray];
        [followedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            //if user followed any admin, each admin follow is detailed here
            for (NSString* adminName in adminArray) {
                BOOL isfollowed = NO;
                for (PFObject* followobj in objects) {
                    if([adminName isEqualToString:[followobj objectForKey:@"followed"]]){
                        isfollowed =YES;
                    }
                }
                if (!isfollowed) {
                    NSLog(@"added new follow");
                    PFObject* newFollow = [PFObject objectWithClassName:@"Follow"];
                    [newFollow setObject:adminName forKey:@"followed"];
                    [newFollow setObject:[PFUser currentUser] forKey:@"follower"];
                    [newFollow saveInBackground];
                }
            }
            
        }];
        
        
    }
    */
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    wallViewArrays = [[NSMutableArray alloc]init];
    gymTags = [[NSMutableArray alloc]init];
    gymSections = [[NSMutableDictionary alloc]init ];
    wallRoutesArrowArray = [[NSMutableArray alloc]init];
        wallRoutesArrowTypeArray = [[NSMutableArray alloc]init];
    imageDataArray =[[NSMutableArray alloc]init];
    queryArray =[[NSMutableArray alloc]init];
     followButton.enabled = NO;
    [PFPush getSubscribedChannelsInBackgroundWithBlock:^(NSSet *channels, NSError *error) {
        if ([channels containsObject:[NSString stringWithFormat:@"channel%@",gymObject.objectId]]) {
            NSLog(@"isSubscribedToThisGym");
            [followButton setTitle:@"Following!" forState:UIControlStateNormal];

        }else{
            [followButton setTitle:@"Follow Us!" forState:UIControlStateNormal];
        }
                    followButton.enabled = YES;
    }];
    
    __block int downloadedRouteCount=0;
    //find number of walls by hashtag
    //get their images
    //if user exits gym page just destroy all from array
    [loadRoutesActivityIndicator startAnimating];
    PFQuery* gymWallQuery = [PFQuery queryWithClassName:@"Route"];
    [gymWallQuery whereKey:@"routelocation" nearGeoPoint:[gymObject objectForKey:@"gymlocation"] withinKilometers:0.5];
    [gymWallQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [gymWallQuery whereKeyExists:@"hashtag"];
    [queryArray addObject:gymWallQuery];
    [gymWallQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:gymWallQuery];
       
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
//        [self.gymTags sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
        for(int i=0; i<[self.gymTags count] ;i++)
        {
            NSArray* hashtaggedRoutes = [self.gymSections objectForKey:[[self.gymSections allKeys]objectAtIndex:i]];
            
            PFObject* firstRoute = ((RouteObject*)[hashtaggedRoutes objectAtIndex:0]).pfobj;
     //       NSLog(@"imagefile =%@",((PFFile*)[firstRoute objectForKey:@"imageFile"]).url);
    //#warning need better alert for download completed here and also change to gym no arrows
            [queryArray addObject:[firstRoute objectForKey:@"imageFile"]];
            [[firstRoute objectForKey:@"imageFile"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [queryArray removeObject:[firstRoute objectForKey:@"imageFile"]];
                UIView* wallView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
                wallView.backgroundColor = [UIColor clearColor];
                
                UILabel* wallLabel = [[UILabel alloc]initWithFrame:CGRectMake(16.5, 0, 287, 35)];
                wallLabel.textAlignment = UITextAlignmentCenter;
                wallLabel.font = [UIFont fontWithName:@"Futura" size:25.0f];
                wallLabel.text = [NSString stringWithFormat:@"%@",[[self.gymSections allKeys]objectAtIndex:i]];
                wallLabel.textColor = [UIColor whiteColor];
                wallLabel.backgroundColor = [UIColor blackColor];
                wallLabel.alpha = 1;
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
                [wallView addSubview:wallimage];
                
                
                
                UILabel* wallFooterLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,257, 287, 30)];
                wallFooterLabel.textAlignment = UITextAlignmentCenter;
                wallFooterLabel.font = [UIFont fontWithName:@"Futura" size:15.0f];
                NSString* wallname = [[self.gymSections allKeys] objectAtIndex:i];
                NSArray* arrayForSection = [self.gymSections objectForKey:wallname];
                if([arrayForSection count]>1){
                wallFooterLabel.text = [NSString stringWithFormat:@"%d routes",[arrayForSection count]];
                }else{
                wallFooterLabel.text = [NSString stringWithFormat:@"%d route",[arrayForSection count]];    
                }
                wallFooterLabel.textColor = [UIColor whiteColor];
                wallFooterLabel.backgroundColor = [UIColor blackColor];
                wallFooterLabel.alpha = 0.8;
                [wallimage addSubview:wallFooterLabel];
                [wallFooterLabel release];
                
                
                [wallViewArrays addObject:wallView];
                [wallView release];
                [wallimage release];
                downloadedRouteCount++;
                NSLog(@"retrieved 1 image, count at %d/%d",downloadedRouteCount,[self.gymTags count]);
                if (downloadedRouteCount==[self.gymTags count]) {
                    ourRoutesButton.enabled = true;
                     [loadRoutesActivityIndicator stopAnimating];
                }
            }];
            
        }
    }];
    

    
    if (gymObject) {
        [self furthurinit];
    }else{
        PFQuery* gymQuery = [PFQuery queryWithClassName:@"Gym"];
        [gymQuery whereKey:@"name" equalTo:gymName];
        [queryArray addObject:gymQuery];
        [gymQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            [queryArray removeObject:gymQuery];
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
    NSLog(@"tag = %@",[self.gymTags objectAtIndex:self.pageControl.currentPage]);
    RouteObject* firstRouteObj = ((RouteObject*)[[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:0]);
    [self setImagesWithRouteObject:firstRouteObj];
    footerLabel.text = [NSString stringWithFormat:@"%@",[firstRouteObj.pfobj objectForKey:@"description"]];
    footerDifficultyLabel.text = [NSString stringWithFormat:@"%@",[firstRouteObj.pfobj objectForKey:@"difficultydescription"]];
    footerView.hidden=NO;
    CGRect slideViewFinalFrame = CGRectMake(0,0,320,320);
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         imgView.frame = slideViewFinalFrame;
                         footerView.alpha = 0.7;
                     } 
                     completion:^(BOOL finished){
                         
                         [self performSelectorOnMainThread:@selector(addGymScrollToAugmentedImageView:) withObject:imgView waitUntilDone:YES];
                         
                         
                         [UIView animateWithDuration:0.2
                                               delay:0.0
                                             options: UIViewAnimationCurveEaseOut
                                          animations:^{
                                              gymRouteScroll.alpha=1;
                                              
                                          }completion:^(BOOL finished){}];

                     }];
    
}
-(void)reverseHandleDoubleTap:(UITapGestureRecognizer*)sender
{
    if (self.navigationItem.leftBarButtonItem ==nil) {
       UIBarButtonItem* newLeftButton  = [[UIBarButtonItem alloc] initWithTitle:@"Gym" style:UIBarButtonItemStylePlain target:self action:@selector(returnToGym:)];
        self.navigationItem.leftBarButtonItem = newLeftButton;
        [newLeftButton release];
    }
    self.navigationItem.rightBarButtonItem = nil;
   
    maskbgView.hidden=NO;
    maskbgView.image = nil;
    maskbgView.alpha = 0.8;
    CGRect arrowsSlideViewFinalFrame = CGRectMake(0,0,287,287);
    CGRect slideViewFinalFrame = CGRectMake(16.5,35,287,287);
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         sender.view.alpha =0;
                         sender.view.frame = arrowsSlideViewFinalFrame;
                         sender.view.superview.superview.frame = slideViewFinalFrame;
                         footerView.alpha=0;
                     }
                     completion:^(BOOL finished){
                         gymWallScroll.hidden = NO;
                         self.pageControl.hidden = NO;
                         self.routePageControl.hidden=YES;
                         footerView.hidden =YES;
                      //   [sender.view removeFromSuperview]; // remove arrowoverlayimageview that was tapped on
                       //  [sender.view.superview removeFromSuperview];//remove uiscrollview from augmented uiimageview
                         
                         [sender.view.superview.superview removeFromSuperview];//remove the augmented uiimageview from the self.view
                     }];

}
-(IBAction)showRoute:(id)sender
{
    
    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
    viewController.routeObject = [[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:self.routePageControl.currentPage];
    
    //   viewController.routeObject = [((NSMutableArray*)[self.userDictionary objectForKey:[[self.userDictionary allKeys]objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.index];
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}
-(UIImageView*)drawArrowsWithImageView:(UIImageView*)arrowOverlay withIndex:(int)index
{
 arrowOverlay.image = nil;
 arrowOverlay.userInteractionEnabled = YES;
 UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reverseHandleDoubleTap:)];
 
 doubleTapGesture.delegate = self;
 [doubleTapGesture setNumberOfTapsRequired : 2];
 [arrowOverlay addGestureRecognizer:doubleTapGesture];
 [doubleTapGesture release];
 for (UIView* view in ((UIView*)[wallViewArrays objectAtIndex:self.pageControl.currentPage]).subviews) {
 if ([view isKindOfClass:[UIImageView class]]) {
 [arrowOverlay setImage:((UIImageView*)view).image];
 }
 }
 arrowOverlay.contentMode =UIViewContentModeScaleAspectFit;
 arrowOverlay.backgroundColor = [UIColor clearColor];
 
 UIImage* pastedimage = nil;
    NSArray*gymsection =[self.gymSections objectForKey:[[self.gymSections allKeys]objectAtIndex:self.pageControl.currentPage]];
    
    RouteObject* route = [gymsection objectAtIndex:self.routePageControl.currentPage];
        NSArray* routearrowarray = [route.pfobj objectForKey:@"arrowarray"];
        NSArray* arrowtypearray = [route.pfobj objectForKey:@"arrowtypearray"];
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
 }
    return arrowOverlay;
}
-(void)addGymScrollToAugmentedImageView:(UIImageView*)imgView
{
    maskbgView.hidden=NO;
    maskbgView.alpha = 1;
    gymRouteScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    gymRouteScroll.userInteractionEnabled =YES;
    gymRouteScroll.pagingEnabled = YES;
    gymRouteScroll.delegate = self;
    gymRouteScroll.showsHorizontalScrollIndicator = NO;
    gymRouteScroll.showsVerticalScrollIndicator = NO;
    
     UIBarButtonItem* newRightButton = [[UIBarButtonItem alloc] initWithTitle:@"Details" style:UIBarButtonItemStylePlain target:self action:@selector(showRoute:)];
    self.navigationItem.rightBarButtonItem = newRightButton;
    [newRightButton release];
    self.routePageControl.hidden=NO;
    
    [self.view bringSubviewToFront:self.routePageControl];
    [imgView addSubview:gymRouteScroll];
    gymRouteScroll.alpha=0;
    
    [self.view bringSubviewToFront:footerView];
    [gymRouteScroll release];
    
    
    
    [wallRoutesArrowArray removeAllObjects];
    for (RouteObject* route in [self.gymSections objectForKey:[[self.gymSections allKeys] objectAtIndex:self.pageControl.currentPage]]) {
        NSArray* routearrowarray = [route.pfobj objectForKey:@"arrowarray"];
        NSArray* arrowtypearray = [route.pfobj objectForKey:@"arrowtypearray"];
        [wallRoutesArrowArray addObject:routearrowarray];
        [wallRoutesArrowTypeArray addObject:arrowtypearray];
        
    }
      
    pageControlBeingUsed = NO;
    self.routePageControl.currentPage = 0;
	self.routePageControl.numberOfPages = wallRoutesArrowArray.count;
//    CGRect frame;
//    frame.origin.x = gymRouteScroll.frame.size.width * self.routePageControl.currentPage;
//    frame.origin.y = 0;
//    frame.size = gymRouteScroll.frame.size;
        
//        UIImageView* imageViewForRoute =[wallRoutesArrowArray objectAtIndex:self.routePageControl.currentPage];
//        imageViewForRoute.frame = frame;
//        [imgView addSubview:imageViewForRoute];
    
    gymRouteScroll.contentSize = CGSizeMake(imgView.frame.size.width * wallRoutesArrowArray.count, imgView.frame.size.height);
    UIImageView* arrowOverlay = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    [gymRouteScroll addSubview:[self drawArrowsWithImageView:arrowOverlay withIndex:0]];
    [arrowOverlay release];
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
    
    
    if (!self.pageControl.hidden && !self.routePageControl.hidden) {
        ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
        for (UIView* view in ((UIView*)[wallViewArrays objectAtIndex:self.pageControl.currentPage]).subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = UIImageJPEGRepresentation(((UIImageView*)view).image,1.0) ;
                ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = ((RouteObject*)[[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:0]).pfobj;
                
            }
        }
    }
    
}
-(void)viewDidAppear:(BOOL)animated
{
    if(self.pageControl.hidden==NO || self.routePageControl.hidden==NO)
    {
        ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
        for (UIView* view in ((UIView*)[wallViewArrays objectAtIndex:self.pageControl.currentPage]).subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = UIImageJPEGRepresentation(((UIImageView*)view).image,1.0) ;
                ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = ((RouteObject*)[[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:0]).pfobj;
                
            }
        }
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    //set reusedata to nil
    ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
    ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = nil;
    ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = nil;
    
    
    NSLog(@"canceling %d queries",[queryArray count]);
    for (id pfobject in queryArray) {
        if ([pfobject isKindOfClass:[PFFile class]]) {
            NSLog(@"cancelling pffile upload/download");
            [((PFFile*)pfobject) cancel];
        }
        if ([pfobject isKindOfClass:[PFQuery class]]) {
            NSLog(@"cancelling pfquery ");
            [((PFQuery*)pfobject) cancel];
        }
    }
    [queryArray removeAllObjects];
    
    NSLog(@"done canceling queries");
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
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
        if (self.pageControl.hidden) {
            CGFloat pageWidth = self.gymRouteScroll.frame.size.width;
            page = floor((self.gymRouteScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
            self.routePageControl.currentPage = page;
        }else{
		CGFloat pageWidth = self.gymWallScroll.frame.size.width;
		page = floor((self.gymWallScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
        }
	}
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	pageControlBeingUsed = NO;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	pageControlBeingUsed = NO;

    if(self.pageControl.hidden==NO)
    {
        ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
        for (UIView* view in ((UIView*)[wallViewArrays objectAtIndex:self.pageControl.currentPage]).subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
        ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = UIImageJPEGRepresentation(((UIImageView*)view).image,1.0) ;
                ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = ((RouteObject*)[[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:0]).pfobj;
                
            }
        }

    }else if (self.pageControl.hidden&&!self.routePageControl.hidden)
    {
        RouteObject* firstRouteObj = ((RouteObject*)[[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:self.routePageControl.currentPage]);
        [self setImagesWithRouteObject:firstRouteObj];
        footerLabel.text = [NSString stringWithFormat:@"%@",[firstRouteObj.pfobj objectForKey:@"description"]];
        footerDifficultyLabel.text = [NSString stringWithFormat:@"%@",[firstRouteObj.pfobj objectForKey:@"difficultydescription"]];
        CGRect frame;

        UIImageView* imgView = ((UIImageView*)[gymRouteScroll.subviews objectAtIndex:0]);
        imgView.alpha =0;
        frame.origin.x = gymRouteScroll.frame.size.width * self.routePageControl.currentPage;
        frame.origin.y = 0;
        frame.size = imgView.frame.size;
        
        imgView = [self drawArrowsWithImageView:imgView withIndex:self.routePageControl.currentPage];
        imgView.frame = frame;

        [UIView animateWithDuration:0.5
                              delay:0.4
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             imgView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                              NSLog(@"Done!");
                         }];
        
    }
    
}
-(void)setImagesWithRouteObject:(RouteObject*)object
{
    __block NSString* imagelink;
    
    if ([object.pfobj objectForKey:@"isPage"]==[NSNumber numberWithBool:YES]) {
        
        imagelink=[gymObject objectForKey:@"imagelink"];
        if (object.ownerImage) {
            footerUserImageView.image = object.ownerImage;
        }else{
            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
            [request setCompletionBlock:^{
                UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                if (ownerImage == nil) {
                    ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                }
                footerUserImageView.image = ownerImage;
                object.ownerImage= ownerImage;
                footerUserImageView.alpha =0.0;
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options: UIViewAnimationCurveEaseOut
                                 animations:^{
                                     footerUserImageView.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished){
                                     // NSLog(@"Done!");
                                 }];
            }];
            [request setFailedBlock:^{}];
            [request startAsynchronous];
        }
        
        
    }else{
        imagelink = [object.pfobj objectForKey:@"userimage"];
        if (object.ownerImage) {
            footerUserImageView.image = object.ownerImage;
        }else{
            ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:imagelink]];
            [request setCompletionBlock:^{
                UIImage* ownerImage = [UIImage imageWithData:[request responseData]];
                if (ownerImage == nil) {
                    ownerImage = [UIImage imageNamed:@"placeholder_user.png"];
                }
                footerUserImageView.image = ownerImage;
                object.ownerImage= ownerImage;
                footerUserImageView.alpha =0.0;
                [UIView animateWithDuration:0.3
                                      delay:0.0
                                    options: UIViewAnimationCurveEaseOut
                                 animations:^{
                                     footerUserImageView.alpha = 1.0;
                                 }
                                 completion:^(BOOL finished){
                                     // NSLog(@"Done!");
                                 }];
            }];
            [request setFailedBlock:^{}];
            [request startAsynchronous];
        }
    }
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
-(void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)showGym:(id)sender {
    MapViewController* mapVC = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    mapVC.geopoint = (PFGeoPoint*)[gymObject objectForKey:@"gymlocation"];
    mapVC.gymName = [gymObject objectForKey:@"name"];
    [self.navigationController pushViewController:mapVC animated:YES];
    
    [mapVC release];
}
-(void)returnToGym:(id)sender
{
    self.navigationItem.title = [NSString stringWithFormat:@"%@",[gymObject objectForKey:@"name"]];
    for (UIView* view in gymWallScroll.subviews) {
        [view removeFromSuperview];
    }
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
                         self.routePageControl.hidden = YES;
                         UIBarButtonItem* newLeftButton = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction:)];
                         self.navigationItem.leftBarButtonItem = newLeftButton;
                         [newLeftButton release];
                         //                         [sender.view removeFromSuperview];
                     }];

   
    
  
}
- (IBAction)ShowWallViewController:(id)sender
{
   UIBarButtonItem*newLeftButton = [[UIBarButtonItem alloc] initWithTitle:@"Gym" style:UIBarButtonItemStylePlain target:self action:@selector(returnToGym:)];
    self.navigationItem.leftBarButtonItem = newLeftButton;
    [newLeftButton release];
        pageControlBeingUsed = NO;
    for (UIView* view in gymWallScroll.subviews) {
        [view removeFromSuperview];
    }
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
	

	self.pageControl.numberOfPages = wallViewArrays.count;
    
    self.gymWallScroll.hidden=NO;
    self.pageControl.hidden =NO;
    self.routePageControl.hidden =YES;
    self.maskbgView.image = nil;
    self.maskbgView.hidden=NO;
    self.gymWallScroll.alpha=0;
    self.pageControl.alpha =0;
    self.maskbgView.image = nil;
    self.maskbgView.alpha=0;
    
    ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
    for (UIView* view in ((UIView*)[wallViewArrays objectAtIndex:self.pageControl.currentPage]).subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            ((BaseViewController*)applicationDelegate.window.rootViewController).reuseImageData = UIImageJPEGRepresentation(((UIImageView*)view).image,1.0) ;
            ((BaseViewController*)applicationDelegate.window.rootViewController).reusePFObject = ((RouteObject*)[[self.gymSections objectForKey:[self.gymTags objectAtIndex:self.pageControl.currentPage]]objectAtIndex:0]).pfobj;
            
        }
    }
    

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
- (void)dealloc
{
    [wallRoutesArrowTypeArray release];
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
    [routePageControl release];
    [footerView release];
    [footerUserImageView release];
    [footerLabel release];
    [footerDifficultyLabel release];
    [likeButton release];
    [followButton release];
    [loadRoutesActivityIndicator release];
    [super dealloc];
}
- (void)viewDidUnload
{
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
    [self setRoutePageControl:nil];
    [self setFooterView:nil];
    [self setFooterUserImageView:nil];
    [self setFooterLabel:nil];
    [self setFooterDifficultyLabel:nil];
    [self setLikeButton:nil];
    [self setFollowButton:nil];
    [self setLoadRoutesActivityIndicator:nil];
    [super viewDidUnload];
}
@end
