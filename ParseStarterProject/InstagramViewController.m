//
//  InstagramViewController.m
//  RaisedCenterTabBar
//
//  Created by Peter Boctor on 12/15/10.
//
// Copyright (c) 2011 Peter Boctor
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE
//
#import "MyTableController.h"
#import "InstagramViewController.h"
#import "FeedsViewController.h"
#import "NewsViewController.h"
#import "ProfileViewController.h"
#import "FlurryAnalytics.h"
#import "KKGridView.h"
#import <Parse/Parse.h>
@implementation InstagramViewController
@synthesize KKviewController;
@synthesize popularRouteArray;
- (void)viewDidLoad
{
  [super viewDidLoad];
    
    
   //feeds navigation controller
   // KKGridViewController* feedsViewController =KKviewController;
  
    
//    KKGridViewController* feedsViewController = [[KKGridViewController alloc]init];
//    feedsViewController.gridView.delegate = self;
//    feedsViewController.gridView.dataSource = self;
//    UINavigationController* feedsNav = [[UINavigationController alloc] initWithRootViewController:feedsViewController];
//  //  feedsViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Popular" image:[UIImage imageNamed:@"star.png"] tag:0] autorelease];
//    [FlurryAnalytics logAllPageViews:feedsNav];
    
    // get all popular routes
 
    
    //main navigation controller
    MyTableController * demoViewController = [[[MyTableController alloc] initWithNibName:nil bundle:nil] autorelease];
    UINavigationController* mainNav = [[UINavigationController alloc]initWithRootViewController:demoViewController];
   // mainNav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"29-heart.png"] tag:0] autorelease];
        [mainNav.navigationBar setBarStyle:UIBarStyleBlack];
    demoViewController.navigationController.navigationBarHidden = YES;
    [FlurryAnalytics logAllPageViews:mainNav];
    
    
    //news navigation cotnroller
//    NewsViewController* newsVC= [[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:nil];
//    UINavigationController* newsnav = [[UINavigationController alloc]initWithRootViewController:newsVC];
//    [newsVC release];
//newsnav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"news.png"] tag:0] autorelease];
//    [FlurryAnalytics logAllPageViews:newsnav];
    
    //profile navigation controller
    ProfileViewController* profileVC = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]; 
    UINavigationController* profilenav = [[UINavigationController alloc]initWithRootViewController:profileVC];
    [profileVC release];
    // profilenav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"123-id-card.png"] tag:0] autorelease];


  //  [tableNav setNavigationBarHidden:YES];
  self.viewControllers = [NSArray arrayWithObjects:
                            mainNav,
                          //feedsNav,
                            [self viewControllerWithTabTitle:@"" image:nil],
                           // newsnav,
                          profilenav, nil];
   
    
                            [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem copy.png"] highlightImage:nil];
    [mainNav release];
   // [newsnav release];
   // [feedsViewController release];
    [profilenav release];
   // [feedsNav release];
    
}

-(void)willAppearIn:(UINavigationController *)navigationController
{
    
  
}



@end
