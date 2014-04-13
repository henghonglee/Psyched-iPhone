#import "MyTableController.h"
#import "InstagramViewController.h"
#import "FeedsViewController.h"
#import "NewsViewController.h"
#import "ProfileViewController.h"
#import "FlurryAnalytics.h"

#import <Parse/Parse.h>
@implementation InstagramViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  MyTableController * demoViewController = [[[MyTableController alloc] initWithNibName:nil bundle:nil] autorelease];
  UINavigationController* mainNav = [[UINavigationController alloc]initWithRootViewController:demoViewController];
  [mainNav.navigationBar setBarStyle:UIBarStyleBlack];
  demoViewController.navigationController.navigationBarHidden = YES;
  [FlurryAnalytics logAllPageViews:mainNav];
    
  ProfileViewController* profileVC = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
  UINavigationController* profilenav = [[UINavigationController alloc]initWithRootViewController:profileVC];
  [profileVC release];
  self.viewControllers = [NSArray arrayWithObjects:mainNav,
                          [self viewControllerWithTabTitle:@"" image:nil],
                          profilenav, nil];
  [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem copy.png"] highlightImage:nil];
  [mainNav release];
  [profilenav release];
    
}

-(void)willAppearIn:(UINavigationController *)navigationController
{
    
  
}



@end
