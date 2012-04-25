//
//  SettingsViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 25/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"
#import "ParseStarterProjectAppDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(IBAction)dismissSettings:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(IBAction)LogOut:(id)sender
{
    [PFUser logOut];
    [[PFFacebookUtils facebook] logout];
    [[PFFacebookUtils facebook] setAccessToken:nil];
    ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
    applicationDelegate.badgeView.text = @"0";
   
        [self dismissViewControllerAnimated:YES completion:^{
            
            
        LoginViewController* viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        applicationDelegate.window.rootViewController = viewController;
        [viewController release];
        }];
        
    
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
