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
#import "NSObject+SBJSON.h"
#import "NSString+SBJSON.h"
@implementation LoginViewController
@synthesize titleLabel;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
          

    [titleLabel setFont:[UIFont fontWithName:@"Old Stamper" size:50.0]];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    titleLabel.layer.shadowOffset = CGSizeMake(0, -1);
    titleLabel.layer.shadowOpacity = 0.8;
    titleLabel.layer.shadowRadius = 1;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)fblogin:(id)sender {
    
    if (![PFFacebookUtils facebook].accessToken) {

        NSArray* permissions = [[NSArray alloc]initWithObjects:@"user_about_me",@"email",@"user_photos",@"publish_stream",@"offline_access",nil];
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            if (!user) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"username = %@",user.username);
                NSLog(@"User with facebook id %@ signed up and logged in!", [PFFacebookUtils facebook].accessToken);
                [self apiFQLIMe];
            } else {
                NSLog(@"username = %@",user.username);
                NSLog(@"%@",[PFUser currentUser]);
           //     NSLog(@"User with facebook id %@ logged in!", user.facebookId); //call graph "me" for facebook id
                InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
                viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentModalViewController:viewController animated:YES];
                [viewController release];
                //        [self apiGraphUserPhotosPost];
            }
        }];
        [permissions release];
    }else{
        InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
    }
       
   }


- (void)apiFQLIMe {
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, pic , email FROM user WHERE uid=me()", @"query",
                                   nil];
    [[PFFacebookUtils facebook] requestWithMethodName:@"fql.query"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
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

        [[PFUser currentUser] setObject:[result objectForKey:@"email"] forKey:@"email"];
        [[PFUser currentUser] setObject:[result objectForKey:@"pic"] forKey:@"profilepicture"]; 
        [[PFUser currentUser] setObject:[result objectForKey:@"name"] forKey:@"name"]; 
        [[PFUser currentUser] setObject:[result objectForKey:@"uid"] forKey:@"facebookid"]; 
        [[PFUser currentUser] saveInBackground];
        [JHNotificationManager notificationWithMessage:[NSString stringWithFormat:@"Logged in as %@",[result objectForKey:@"name"]]];
        
        
        InstagramViewController* viewController = [[InstagramViewController alloc]initWithNibName:@"InstagramViewController" bundle:nil];
        viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:viewController animated:YES];
        [viewController release];
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
    [super dealloc];
}
@end
