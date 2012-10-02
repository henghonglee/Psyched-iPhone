//
//  SettingsViewController.m
//  PsychedApp
//
//  Created by HengHong Lee on 25/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "SettingsViewController.h"
#import "ParseStarterProjectAppDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
@interface SettingsViewController ()

@end

@implementation SettingsViewController
@synthesize distanceSlider;
@synthesize distanceLabel;
@synthesize LoggedInUser;

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
    [self dismissModalViewControllerAnimated:NO];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [distanceSlider setValue:[[[NSUserDefaults standardUserDefaults]objectForKey:@"NearbyDistance"]floatValue]];
    distanceLabel.text = [NSString stringWithFormat:@"%.0f",[[[NSUserDefaults standardUserDefaults]objectForKey:@"NearbyDistance"]floatValue]];
    LoggedInUser.text = [NSString stringWithFormat:@"Signed in as:%@",[[PFUser currentUser]objectForKey:@"name"]];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)OGswitchDidChange:(UISwitch*)sender {
    NSLog(@"setting ogshare");
    [[NSUserDefaults standardUserDefaults]setBool:sender.on forKey:@"ogshare"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(IBAction)LogOut:(id)sender
{
    [PFUser logOut];
    [[PFFacebookUtils facebook] logout];
    [[PFFacebookUtils facebook] setAccessToken:nil];
    
    ParseStarterProjectAppDelegate* applicationDelegate = ((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication]delegate]);
    applicationDelegate.badgeView.text = @"0";
   ((UIButton*) sender).hidden = true;
    LoggedInUser.text = @"";
        [self dismissViewControllerAnimated:YES completion:^{
            
            
        LoginViewController* viewController = [[LoginViewController alloc]initWithNibName:@"LoginViewController" bundle:nil];
        applicationDelegate.window.rootViewController = viewController;
        [viewController release];
        }];
        
    
}
- (IBAction)distanceSliderChanged:(UISlider*)sender {
    NSLog(@"slider did change");
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%f",sender.value] forKey:@"NearbyDistance"];
    
    distanceLabel.text = [NSString stringWithFormat:@"%.0f",sender.value];
}
- (void)viewDidUnload
{
    [self setDistanceSlider:nil];
    [self setDistanceLabel:nil];
    [self setLoggedInUser:nil];
    [self setOGswitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc {
    [distanceSlider release];
    [distanceLabel release];
    [LoggedInUser release];
    [_OGswitch release];
    [super dealloc];
}
@end
