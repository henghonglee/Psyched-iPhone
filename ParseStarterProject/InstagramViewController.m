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
@implementation InstagramViewController

- (void)viewDidLoad
{
  [super viewDidLoad];

    
   
    //tableNav.navigationController.navigationItem.title = @"feeds";
   
    
    FeedsViewController* feedsViewController = [[[FeedsViewController alloc]initWithNibName:@"FeedsViewController" bundle:nil] autorelease]; 
    UINavigationController* feedsNav = [[UINavigationController alloc] initWithRootViewController:feedsViewController];
    MyTableController * demoViewController = [[[MyTableController alloc] initWithNibName:nil bundle:nil] autorelease];
     UINavigationController* mainNav = [[UINavigationController alloc]initWithRootViewController:demoViewController];
    mainNav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Routes" image:[UIImage imageNamed:@"29-heart.png"] tag:0] autorelease];
        [mainNav.navigationBar setBarStyle:UIBarStyleBlack];
    feedsViewController.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Activity" image:[UIImage imageNamed:@"112-group.png"] tag:0] autorelease];
    demoViewController.navigationController.navigationBarHidden = YES;
    
    NewsViewController* newsVC= [[NewsViewController alloc] initWithNibName:@"NewsViewController" bundle:nil];
    UINavigationController* newsnav = [[UINavigationController alloc]initWithRootViewController:newsVC];
    [newsVC release];
     newsnav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"News" image:[UIImage imageNamed:@"news.png"] tag:0] autorelease];
    ProfileViewController* profileVC = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil]; 
    UINavigationController* profilenav = [[UINavigationController alloc]initWithRootViewController:profileVC];
    [profileVC release];
     profilenav.tabBarItem = [[[UITabBarItem alloc] initWithTitle:@"Profile" image:[UIImage imageNamed:@"123-id-card.png"] tag:0] autorelease];
    
    
    
    
  //  [tableNav setNavigationBarHidden:YES];
  self.viewControllers = [NSArray arrayWithObjects:
                            mainNav,feedsNav,
                            [self viewControllerWithTabTitle:@"Share" image:nil],
                            newsnav,profilenav, nil];
   
    
                            [self addCenterButtonWithImage:[UIImage imageNamed:@"cameraTabBarItem.png"] highlightImage:nil];
    [mainNav release];
    [newsnav release];
    [profilenav release];
    [feedsNav release];
}

-(void)willAppearIn:(UINavigationController *)navigationController
{
    
}

@end
