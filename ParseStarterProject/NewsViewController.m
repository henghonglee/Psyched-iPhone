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
@implementation NewsViewController
@synthesize newsTable;
@synthesize navigationBarItem;
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
    PFQuery* query = [PFQuery queryWithClassName:@"News"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        [newsArray removeAllObjects];
        NSLog(@"objects = %@",objects);
        for (PFObject* object in objects) {
            NewsObject* newNewsObject = [[NewsObject alloc]init];
            newNewsObject.newsText = [object objectForKey:@"newsText"];
            newNewsObject.newsTitle =[object objectForKey:@"newsTitle"]; 
            newNewsObject.newsImageURL = [object objectForKey:@"newsImageURL"];
            newNewsObject.newsCallbackURL = [object objectForKey:@"newsCallbackURL"];
            [newsArray addObject:newNewsObject];
            [newNewsObject release];
            
        }
        [newsTable reloadData];
    }];
}
-(void)reloadUserData
{
    [navigationBarItem startAnimating];

    PFQuery* query = [PFQuery queryWithClassName:@"News"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        
        [newsArray removeAllObjects];
        NSLog(@"objects = %@",objects);
        for (PFObject* object in objects) {
            NewsObject* newNewsObject = [[NewsObject alloc]init];
            newNewsObject.newsText = [object objectForKey:@"newsText"];
            newNewsObject.newsTitle =[object objectForKey:@"newsTitle"]; 
            newNewsObject.newsImageURL = [object objectForKey:@"newsImageURL"];
            newNewsObject.newsCallbackURL = [object objectForKey:@"newsCallbackURL"];
            [newsArray addObject:newNewsObject];
            [newNewsObject release];
            
        }
        [navigationBarItem stopAnimating];
        [newsTable reloadData];
    }];
}
- (void)viewDidUnload
{
    [self setNewsTable:nil];
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
    NSLog(@"count = %d",[newsArray count]);
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
         cell.newsImage.image = selectedNewsObject.newsImage;
        }
    
}
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewsObject* selectedNewsObject = [newsArray objectAtIndex:indexPath.row];
    NSURL *URL = [NSURL URLWithString:selectedNewsObject.newsCallbackURL];
    SVModalWebViewController *webViewController = [[[SVModalWebViewController alloc] initWithURL:URL] autorelease];
	webViewController.modalPresentationStyle = UIModalPresentationPageSheet;
    webViewController.availableActions = SVWebViewControllerAvailableActionsOpenInSafari | SVWebViewControllerAvailableActionsCopyLink | SVWebViewControllerAvailableActionsMailLink;
	[self presentModalViewController:webViewController animated:NO];	
}
@end
