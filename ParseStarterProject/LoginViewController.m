//
//  LoginViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>
#import "JHNotificationManager.h"
#import "InstagramViewController.h"
#import "SBJSON.h"
#import "FlurryAnalytics.h"
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
@implementation LoginViewController
@synthesize pages;
@synthesize updownarrow;
@synthesize instructionScroll;
@synthesize subtitleLabel;
@synthesize titleLabel;
@synthesize scrollView, pageControl;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
- (IBAction)setTitle:(id)sender {

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [titleLabel setFont:[UIFont fontWithName:@"Old Stamper" size:50.0]];
    titleLabel.textColor = [UIColor whiteColor];
    instructionScroll.contentSize = CGSizeMake(133,365);
    pageControlBeingUsed = NO;
	
	
	for (int i = 0; i < pages.count; i++) {
		CGRect frame;
		frame.origin.x = self.scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;

        ((UIImageView*)[pages objectAtIndex:i]).frame = frame;
		[self.scrollView addSubview:((UIImageView*)[pages objectAtIndex:i])];
            
		//[pageOneImageView release];
	}
	
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * pages.count, self.scrollView.frame.size.height);
	
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = pages.count-1;

    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        NSLog(@"page = %d",page);
		self.pageControl.currentPage = page;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
    NSLog(@"didend decelerating");
    if (page == 2) {
        [UIView animateWithDuration:0.3
                              delay:0.2
                            options: UIViewAnimationCurveEaseOut
                         animations:^{

                             updownarrow.alpha = 0.3;
                         } 
                         completion:^(BOOL finished){
                             [UIView animateWithDuration:0.3
                                                                           delay:0.2
                                                                         options: UIViewAnimationCurveEaseOut
                                                                      animations:^{
                                                                          updownarrow.alpha = 0;
                                                                      } 
                                                                      completion:^(BOOL finished){}];}];
        
        
    }else{
        
    }
    if (page == 3) {
        CGRect slideViewFinalFrame = CGRectMake(00, 00, 320, 410);
        [UIView animateWithDuration:0.3
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         titleLabel.frame = slideViewFinalFrame;
                     } 
                     completion:^(BOOL finished){
                         
    [UIView animateWithDuration:0.6
                          delay:0.2
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         subtitleLabel.alpha = 1;
                     } 
                     completion:^(BOOL finished){
                         NSLog(@"Done!");
                     }];
                     }];
    }else{
            subtitleLabel.alpha = 0;
        CGRect slideViewFinalFrame = CGRectMake(00, 4, 320, 77);
        [UIView animateWithDuration:0.8
                              delay:0.2
                            options: UIViewAnimationCurveEaseOut
                         animations:^{
                             titleLabel.frame = slideViewFinalFrame;
                         } 
                         completion:^(BOOL finished){
                                              
                                    
                         }];
    }
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	// Keep track of when scrolls happen in response to the page control
	// value changing. If we don't do this, a noticeable "flashing" occurs
	// as the the scroll delegate will temporarily switch back the page
	// number.
	pageControlBeingUsed = YES;
}


- (IBAction)fblogin:(id)sender {
   
//    if (![PFFacebookUtils facebook].accessToken) {

        NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",@"user_videos",@"user_birthday",@"email",@"user_photos",@"publish_stream",@"offline_access",nil];
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
           
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"username = %@",user.username);
                NSLog(@"User with facebook id %@ signed up and logged in!", [PFFacebookUtils facebook].accessToken);
                [self apiFQLIMe];
            } else {
               [self apiFQLIMe];
               
                //        [self apiGraphUserPhotosPost];
            }
        }];
        [permissions release];
//    }else{
//        InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
//        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//        [self presentModalViewController:viewController animated:YES];
//        [viewController release];
//    }
//       
   }


- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture

    
    NSLog(@"runnign fqlme");
    NSURL* reqURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/fql?q=SELECT+about_me,locale,birthday,birthday_date,sex,uid,name,pic,email+FROM+user+WHERE+uid=me()&access_token=%@",[PFFacebookUtils facebook].accessToken]];
    ASIHTTPRequest* fqlRequest = [ASIHTTPRequest requestWithURL:reqURL];
    [fqlRequest setCompletionBlock:^{
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSArray *jsonObjects = [[jsonParser objectWithString:[fqlRequest responseString]] objectForKey:@"data"];
        [jsonParser release];
        jsonParser = nil;
        
        NSLog(@"result = %@ class = %@",jsonObjects,[jsonObjects class]);
        if ([jsonObjects isKindOfClass:[NSArray class]]) {
            if([((NSArray*)jsonObjects) count]==0) {
                NSLog(@"couldnt get user values .. exiting");
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Couldnt retrieve your Facebook details" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
                return;
            }else{
                
                NSDictionary* result = [((NSArray*)jsonObjects) objectAtIndex:0];
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
                    
                   
                    [FlurryAnalytics setUserID:[[PFUser currentUser] objectForKey:@"name"]];
                            if ([[[PFUser currentUser] objectForKey:@"sex"] isEqualToString:@"male"]) {
                                [FlurryAnalytics setGender:@"m"];
                            }else{
                                [FlurryAnalytics setGender:@"f"];
                            }
                    [FlurryAnalytics setAge:age];
                    NSDictionary *dictionary = 
                    [NSDictionary dictionaryWithObjectsAndKeys:[result objectForKey:@"email"],@"email",[result objectForKey:@"birthday"],@"birthday",[result objectForKey:@"name"],@"name",[result objectForKey:@"sex"],@"sex",[result objectForKey:@"uid"],@"uid",[result objectForKey:@"about_me"],@"about_me", nil];
                    
                    [FlurryAnalytics logEvent:@"NEW_USER_LOGIN" withParameters:dictionary timed:YES];
                    
                    
                    NSLog(@"saving user");
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",[[PFUser currentUser] objectForKey:@"facebookid"]]block:^(BOOL succeeded, NSError *error) {

                            [JHNotificationManager notificationWithMessage:[NSString stringWithFormat:@"Logged in as %@",[result objectForKey:@"name"]]];
                            InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
                            viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                            ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
                            applicationDelegate.window.rootViewController = viewController;
                            [viewController release];

                        }];
                        
                    }];
                    
                    
                }
            }
        }
    }];
    [fqlRequest setFailedBlock:^{
        NSLog(@"fql req failed");
    }];
    [fqlRequest startAsynchronous];
}





#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */



- (void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */


- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    if ([result isKindOfClass:[NSArray class]]) {
        result = [((NSArray*)result) objectAtIndex:0];
    }
    // This callback can be a result of getting the user's basic
    // information or getting the user's permissions.
    if ([result objectForKey:@"name"]) {
        // If basic information callback, set the UI objects to
        // display this.
        NSLog(@"result = %@",result);
      //  NSLog(@"facebookid = %@",((PFUser*)[PFUser currentUser]).facebookId);
        
        
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(PF_FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setPages:nil];
    [self setSubtitleLabel:nil];
    [self setInstructionScroll:nil];
    [self setUpdownarrow:nil];
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

- (void)dealloc {
    [titleLabel release];
    [pages release];
    [subtitleLabel release];
    [instructionScroll release];
    [updownarrow release];
    [super dealloc];
}
@end
