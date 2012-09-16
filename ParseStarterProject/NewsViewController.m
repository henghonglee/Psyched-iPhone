//
//  NewsViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "SVModalWebViewController.h"
#import "SVWebViewController.h"
//#import "FlurryAnalytics.h"
#import "ParseStarterProjectAppDelegate.h"
@implementation NewsViewController
@synthesize newsTable;
@synthesize navigationBarItem;
@synthesize newsArray,queryArray;
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
    self.navigationItem.title = @"News";
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
    self.navigationController.navigationBar.layer.shadowColor = [UIColor blackColor].CGColor;
    self.navigationController.navigationBar.layer.shadowOpacity = 0.5;
    self.navigationController.navigationBar.layer.shadowOffset = CGSizeMake(0, 4);
    // Do any additional setup after loading the view from its nib.
    queryArray = [[NSMutableArray alloc]init];
    newsArray = [[NSMutableArray alloc]init];
    newsTable.backgroundColor = [UIColor darkGrayColor];
    navigationBarItem = [[DAReloadActivityButton alloc] init];
    navigationBarItem.showsTouchWhenHighlighted = NO;
    [navigationBarItem addTarget:self action:@selector(reloadUserData) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationBarItem];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];

    currentGeoPoint = [PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude];
    PFQuery* query = [PFQuery queryWithClassName:@"News"];
    [query whereKey:@"location" nearGeoPoint:currentGeoPoint];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
                if ([objects count]) {
        [newsArray removeAllObjects];
        NSLog(@"objects = %@",objects);
        for (PFObject* object in objects) {
            NewsObject* newNewsObject = [[NewsObject alloc]init];
            newNewsObject.newsTitle =[object objectForKey:@"newsTitle"]; 
            newNewsObject.newsImageURL = [object objectForKey:@"newsImageURL"];
            newNewsObject.newsId = object.objectId;
            newNewsObject.newsCallbackURL = [object objectForKey:@"newsCallbackURL"];
            newNewsObject.distanceInKm = [[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] distanceInKilometersTo:[object objectForKey:@"location"]];
           newNewsObject.newsText = [[object objectForKey:@"newsText"] stringByReplacingOccurrencesOfString:@"<distance>" withString:[NSString stringWithFormat:@"%.0f",newNewsObject.distanceInKm]];
            if(newNewsObject.distanceInKm < [[object objectForKey:@"radiusInKm"] doubleValue]){
            [newsArray addObject:newNewsObject];
            }
            [newNewsObject release];
            
        }
        [newsTable reloadData];
                }
    }];
}
-(void)reloadUserData
{
    [navigationBarItem startAnimating];

    PFQuery* query = [PFQuery queryWithClassName:@"News"];
    [query whereKey:@"location" nearGeoPoint:[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count]) {
        [newsArray removeAllObjects];
        NSLog(@"objects = %@",objects);
        for (PFObject* object in objects) {
            NewsObject* newNewsObject = [[NewsObject alloc]init];
            newNewsObject.newsTitle =[object objectForKey:@"newsTitle"];
            newNewsObject.newsImageURL = [object objectForKey:@"newsImageURL"];
            newNewsObject.newsCallbackURL = [object objectForKey:@"newsCallbackURL"];
            newNewsObject.newsId = object.objectId;
            newNewsObject.distanceInKm = [[PFGeoPoint geoPointWithLatitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude longitude:((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude] distanceInKilometersTo:[object objectForKey:@"location"]];
            newNewsObject.newsText = [[object objectForKey:@"newsText"] stringByReplacingOccurrencesOfString:@"<distance>" withString:[NSString stringWithFormat:@"%.0fKm",newNewsObject.distanceInKm]];
            
            
          
            if(newNewsObject.distanceInKm < [[object objectForKey:@"radiusInKm"] doubleValue]){
                [newsArray addObject:newNewsObject];
            }
            
            [newNewsObject release];
            
        }
        [navigationBarItem stopAnimating];
        [newsTable reloadData];
        }
    }];
}
- (void)viewDidUnload
{
    [self setNewsTable:nil];
    [self setNavigationBarItem:nil];
    [self setNewsArray:nil];
    [self setQueryArray:nil];
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
    [newsTable release];
    [super dealloc];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  
    return [newsArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 320;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    //if ([self numberOfSectionsInTableView:tableView] == (section+1)){
        return [[UIView new] autorelease];
//    }       
//    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *FromCellIdentifier = @"FromCell";
NewsCell* cell = (NewsCell*) [tableView dequeueReusableCellWithIdentifier:FromCellIdentifier]; 
if (cell == nil) {
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NewsCell" owner:nil options:nil];
    for(id currentObject in topLevelObjects){
        if([currentObject isKindOfClass:[UITableViewCell class]]){
            cell = (NewsCell*)currentObject;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}
    if ([newsArray count]>0) {
    NewsObject* selectedNewsObject = [newsArray objectAtIndex:indexPath.row];
        cell.newsTitle.text=selectedNewsObject.newsTitle;
        cell.newsText.text =selectedNewsObject.newsText;
        
        if (!selectedNewsObject.newsImage) {
    ASIHTTPRequest* imageReq = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: selectedNewsObject.newsImageURL]];
        [imageReq setCompletionBlock:^{
    //        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"%@ viewed",selectedNewsObject.newsId]];
            selectedNewsObject.newsImage = [UIImage imageWithData:[imageReq responseData]];
            cell.newsImage.alpha = 0.0;
            cell.newsImage.image = selectedNewsObject.newsImage;
            
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 cell.newsImage.alpha = 1.0;
                             } 
                             completion:^(BOOL finished){
                                 
                             }];

        }];
        [imageReq setFailedBlock:^{}];
        [imageReq startAsynchronous];
        }else{
      //  [FlurryAnalytics logEvent:[NSString stringWithFormat:@"%@ viewed",selectedNewsObject.newsId]];
         cell.newsImage.image = selectedNewsObject.newsImage;
        }
    
}
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsObject* selectedNewsObject = [newsArray objectAtIndex:indexPath.row];
    
    NSString* latlon = [NSString stringWithFormat:@"%f,%f",((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.latitude,((ParseStarterProjectAppDelegate*)[[UIApplication sharedApplication] delegate]).currentLocation.coordinate.longitude];
    NSLog(@"latlon = %@",latlon);
     NSDictionary *dictionary = 
     [NSDictionary dictionaryWithObjectsAndKeys:[[PFUser currentUser] objectForKey:@"sex"],@"sex",[[[PFUser currentUser] objectForKey:@"age"]stringValue],@"age",latlon,@"latlon",nil];
    
  //  [FlurryAnalytics logEvent:[NSString stringWithFormat:@"%@ clicked",selectedNewsObject.newsId] withParameters:dictionary timed:YES];
    
    
    
    NSURL *URL = [NSURL URLWithString:selectedNewsObject.newsCallbackURL];
    SVModalWebViewController *webViewController = [[[SVModalWebViewController alloc] initWithURL:URL] autorelease];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    webViewController.newsId = selectedNewsObject.newsId;
    webViewController.dictionary = dictionary;
    webViewController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink; 
	[self presentModalViewController:webViewController animated:NO];	
}
@end
