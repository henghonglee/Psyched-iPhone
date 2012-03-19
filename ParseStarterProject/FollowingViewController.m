//
//  FollowFriendsViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FollowingViewController.h"
#import "SearchUserCell.h"
#import <Parse/Parse.h>
#import "SearchFriendsViewController.h"
#import "ASIHTTPRequest.h"
@implementation FollowingViewController
@synthesize searchBar;
@synthesize searchTable;
@synthesize selectedUser;
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
    self.navigationItem.title = @"Following";
    tempArray = [[NSMutableArray alloc]init];
    searchArray = [[NSMutableArray alloc]init];
    followedArray = [[NSMutableArray alloc]init];
    if ([[selectedUser objectForKey:@"name"] isEqualToString:[[PFUser currentUser] objectForKey:@"name"]]) 
    {
        //display + sign
        UIBarButtonItem *yourBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFollowers)];
        self.navigationItem.rightBarButtonItem = yourBarButtonItem;
        [yourBarButtonItem release];
    }
    
    
    
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [followedArray addObjectsFromArray:[followedquery findObjects]];
    
    
    PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
    [query whereKey:@"follower" equalTo:selectedUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [searchArray removeAllObjects];
        [tempArray removeAllObjects];
        for (PFObject* follower in objects) {
            
            PFQuery* userquery = [PFQuery queryForUser];
            [userquery whereKey:@"name" equalTo:[follower objectForKey:@"followed"]];
            [userquery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                NSLog(@"object = %@",object );
                if (object) {
                    [searchArray addObject:(PFUser*)object];
                    [tempArray addObject:(PFUser*)object];    
                } 
                [searchTable reloadData];
            }];
            
        }
    }];
    
    // Do any additional setup after loading the view from its nib.
}
-(void)addFollowers{
    SearchFriendsViewController* viewController = [[SearchFriendsViewController alloc]initWithNibName:@"SearchFriendsViewController" bundle:nil];
    viewController.selectedUser = selectedUser;

    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}
-(void)viewWillAppear:(BOOL)animated
{
    //    [tempArray removeAllObjects];
    //    [searchArray removeAllObjects];
    //    [followedArray removeAllObjects];
    
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
    [selectedUser release];
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
        
        cell.nameLabel.text = [((PFObject*)[searchArray objectAtIndex:indexPath.row]) objectForKey:@"name"];
        if([cell.nameLabel.text isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]){
            cell.followButton.hidden=YES;
        }else{
            cell.followButton.hidden=NO;
        }
        NSString* urlstring = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] objectForKey:@"profilepicture"]];
        BOOL isFollowing=NO;
        
        for (PFObject* obj in followedArray) {
            if ([cell.nameLabel.text isEqualToString:[obj objectForKey:@"followed"]]) {
                isFollowing = YES;
                NSLog(@"is a follower");
                [cell.followButton setBackgroundImage:[UIImage imageNamed:@"following_text.png"] forState:UIControlStateNormal];
            }
            if (!isFollowing){
                isFollowing = NO;
                [cell.followButton setBackgroundImage:[UIImage imageNamed:@"follow_text.png"] forState:UIControlStateNormal];
            }
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
-(void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
    [_searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [searchArray removeAllObjects];
    NSRange textRange;
    for (PFUser* user in tempArray) {
        
        textRange =[[[user objectForKey:@"name"] lowercaseString] rangeOfString:[searchText lowercaseString]];
        if(textRange.location != NSNotFound)
        {
            [searchArray addObject:user];
        }
        
    }
    if ([searchText isEqualToString:@""]) {
        [searchArray addObjectsFromArray:tempArray];
        // [searchBar resignFirstResponder];
    }
    [searchTable reloadData]; 
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfileViewController* viewController = [[ProfileViewController alloc]initWithNibName:@"ProfileViewController" bundle:nil];
    viewController.username= [((PFObject*)[searchArray objectAtIndex:indexPath.row]) objectForKey:@"name"]; 
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchArray count];
}

@end
