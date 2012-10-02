//
//  SendUserViewController.m
//  PsychedApp
//
//  Created by HengHong Lee on 22/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "SendUserViewController.h"
#import "SearchUserCell.h"
#import <Parse/Parse.h>
#import "ASIHTTPRequest.h"
@implementation SendUserViewController
@synthesize searchBar;
@synthesize searchTable;
@synthesize sendStatus;
@synthesize route;
@synthesize queryArray;
@synthesize searchArray,tempArray,followedArray;
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
    self.navigationItem.title = sendStatus;
    tempArray = [[NSMutableArray alloc]init];
    searchArray = [[NSMutableArray alloc]init];
    queryArray = [[NSMutableArray alloc]init];
    followedArray = [[NSMutableArray alloc]init];
    PFQuery* query = [PFQuery queryWithClassName:sendStatus];
    [query whereKey:@"route" equalTo:route];
    [queryArray addObject:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:query];
        [searchArray removeAllObjects];
        [tempArray removeAllObjects];
        if ([objects count]){
        for (PFObject* sender in objects) {
            PFUser* user = [sender objectForKey:@"user"];
            [searchArray addObject:user];
            [tempArray addObject:user];
        }

        }
    }];
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [queryArray addObject:followedquery];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"user followed = %@",objects);    
            [queryArray removeObject:followedquery];
            [followedArray addObjectsFromArray:objects];
                    [searchTable reloadData];
    }];

}
-(void)viewWillAppear:(BOOL)animated
{
    //    [tempArray removeAllObjects];
    //    [searchArray removeAllObjects];
    //    [followedArray removeAllObjects];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
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
- (void)viewDidUnload
{
    [self setSearchTable:nil];
    [self setSearchBar:nil];
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
    [queryArray  release];
    [followedArray release];
    [tempArray release];
    [searchArray release];
    [searchTable release];
    [searchBar release];
    [super dealloc];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *SearchUserCellIdentifier = @"SearchUserCell";
    SearchUserCell* cell = (SearchUserCell*) [tableView dequeueReusableCellWithIdentifier:SearchUserCellIdentifier]; 
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SearchUserCell" owner:nil options:nil];
        for(id currentObject in topLevelObjects){
            if([currentObject isKindOfClass:[UITableViewCell class]]){
                cell = (SearchUserCell*)currentObject;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
        }
    }
    if ([searchArray count]) {
        cell.owner = self;
        
        cell.nameLabel.text = [([(PFObject*)[searchArray objectAtIndex:indexPath.row]fetchIfNeeded]) objectForKey:@"name"];    
        NSString* urlstring = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] objectForKey:@"profilepicture"]];
        if([cell.nameLabel.text isEqualToString:[[PFUser currentUser] objectForKey:@"name"]]){
            cell.followButton.hidden =YES;
        }else{
            cell.followButton.hidden =NO;
        }
        BOOL isFollowing=NO;
        NSLog(@"followed array - %@",followedArray);
        
        for (PFObject* obj in followedArray) {
            if ([cell.nameLabel.text isEqualToString:[obj objectForKey:@"followed"]]) {
                isFollowing = YES;
              
            }
        }
            if (isFollowing){
                NSLog(@"isfollowing %@",cell.nameLabel.text);

                    [cell.followButton setBackgroundImage:[UIImage imageNamed:@"following_text.png"] forState:UIControlStateNormal];
            }else{
                NSLog(@"is not following %@",cell.nameLabel.text);
                [cell.followButton setBackgroundImage:[UIImage imageNamed:@"follow_text.png"] forState:UIControlStateNormal];
            }
        
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [request setCompletionBlock:^{
            
            cell.userImageView.image = [UIImage imageWithData:[request responseData]];
        }];
        [request setFailedBlock:^{}];
        [request startAsynchronous];
        
    }
    
    
    return cell;
}
//-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
//{
//    [_searchBar resignFirstResponder];
//}
//
//-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    [searchArray removeAllObjects];
//    NSRange textRange;
//    for (PFUser* user in tempArray) {
//        
//        textRange =[[[user objectForKey:@"name"] lowercaseString] rangeOfString:[searchText lowercaseString]];
//        if(textRange.location != NSNotFound)
//        {
//            [searchArray addObject:user];
//        }
//        
//    }
//    if ([searchText isEqualToString:@""]) {
//        [searchArray addObjectsFromArray:tempArray];
//        // [searchBar resignFirstResponder];
//    }
//    [searchTable reloadData]; 
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    viewController.username= [([(PFObject*)[searchArray objectAtIndex:indexPath.row]fetchIfNeeded]) objectForKey:@"name"]; 
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchArray count];
}

@end
