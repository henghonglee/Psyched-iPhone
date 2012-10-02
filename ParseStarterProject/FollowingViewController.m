//
//  FollowFriendsViewController.m
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
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
@synthesize searchArray,tempArray,followedArray,queryArray;
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
    queryArray = [[NSMutableArray alloc]init];
    if ([[selectedUser objectForKey:@"name"] isEqualToString:[[PFUser currentUser] objectForKey:@"name"]]) 
    {
        //display + sign
        UIBarButtonItem *yourBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFollowers)];
        self.navigationItem.rightBarButtonItem = yourBarButtonItem;
        [yourBarButtonItem release];
    }
    
    
    //retrieve who the user is following
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [queryArray addObject:followedquery];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [queryArray removeObject:followedquery];
    [followedArray addObjectsFromArray:objects];
    
    }];
    __block int numberOfdivs=10;
    PFQuery* numberQuery = [PFQuery queryWithClassName:@"Follow"];
    [numberQuery whereKey:@"follower" equalTo:selectedUser];
    [queryArray addObject:numberQuery];
    [numberQuery countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        [queryArray removeObject:numberQuery];
        int numberOfiterations = number/numberOfdivs;
        int numberOfremainder = number%numberOfdivs;
        [searchArray removeAllObjects];
        [tempArray removeAllObjects];
        for (int i=0; i<numberOfiterations; i++) {
            PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
            [query whereKey:@"follower" equalTo:selectedUser];
            [query orderByAscending:@"created_At"];
            [query setLimit:numberOfdivs];
            [query setSkip:numberOfdivs*i];
            [queryArray addObject:query];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                [queryArray removeObject:query];
                for (PFObject* follower in objects) {
                    PFQuery* userquery = [PFUser query];
                    [userquery whereKey:@"name" equalTo:[follower objectForKey:@"followed"]];
                    [queryArray addObject:userquery];
                    [userquery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [queryArray removeObject:userquery];
                        if (object) {
                            UserObject* userObj = [[UserObject alloc]init];
                            userObj.user = (PFUser*)object;
                            [searchArray addObject:userObj];
                            [tempArray addObject:userObj];    
                            [userObj release];
                        } 
                        [searchTable reloadData]; 
                    }];
                    
                }
            }];

        }
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"follower" equalTo:selectedUser];
        [query setLimit:numberOfremainder];
        [query setSkip:numberOfdivs*numberOfiterations];
        [query orderByAscending:@"created_At"];
        [queryArray addObject:query];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            [queryArray removeObject:query];
            for (PFObject* follower in objects) {
                PFQuery* userquery = [PFUser query];
                [userquery whereKey:@"name" equalTo:[follower objectForKey:@"followed"]];
                [queryArray addObject:userquery];
                [userquery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                    [queryArray removeObject:userquery];
                    if (object) {
                        UserObject* userObj = [[UserObject alloc]init];
                        userObj.user = (PFUser*)object;
                        [searchArray addObject:userObj];
                        [tempArray addObject:userObj];    
                        [userObj release];
                    } 
                    [searchTable reloadData]; 
                }];
                
            }
        }];

        
    }];
    
    //retrieve who the selecteduser is following
        
    // Do any additional setup after loading the view from its nib.
}
-(void)addFollowers{
    SearchFriendsViewController* viewController = [[SearchFriendsViewController alloc]initWithNibName:@"SearchFriendsViewController" bundle:nil];
    viewController.selectedUser = selectedUser;

    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
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
    [self setSearchArray:nil];
    [self setTempArray:nil];
    [self setFollowedArray:nil];
    [self viewDidDisappear:NO];
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
    [queryArray release];
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
        UserObject* userObjForRow = [searchArray objectAtIndex:indexPath.row];
        PFUser* userForRow = userObjForRow.user;
        
        cell.nameLabel.text = [userForRow objectForKey:@"name"];
        if([cell.nameLabel.text isEqualToString:[[PFUser currentUser]objectForKey:@"name"]]){
            cell.followButton.hidden=YES;
        }else{
            cell.followButton.hidden=NO;
        }
        NSString* urlstring = [NSString stringWithFormat:@"%@",[userForRow objectForKey:@"profilepicture"]];
        BOOL isFollowing=NO;
        
        for (PFObject* obj in followedArray) {
            if ([cell.nameLabel.text isEqualToString:[obj objectForKey:@"followed"]]) {
                isFollowing = YES;
                [cell.followButton setBackgroundImage:[UIImage imageNamed:@"following_text.png"] forState:UIControlStateNormal];
            }
            if (!isFollowing){
                isFollowing = NO;
                [cell.followButton setBackgroundImage:[UIImage imageNamed:@"follow_text.png"] forState:UIControlStateNormal];
            }
        }
        if (userObjForRow.userImage) {
            cell.userImageView.image = userObjForRow.userImage;
            if (cell.userImageView.image == nil) {
                cell.userImageView.image = [UIImage imageNamed:@"placeholder_user.png"];
            }
        }else{
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlstring]];
        [request setCompletionBlock:^{
            userObjForRow.userImage = [UIImage imageWithData:[request responseData]];
            cell.userImageView.image = userObjForRow.userImage;
            if (cell.userImageView.image == nil) {
                cell.userImageView.image = [UIImage imageNamed:@"placeholder_user.png"];
            }
        }];
        [request setFailedBlock:^{}];
        [request startAsynchronous];
        }
        
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
    for (UserObject* userObj in tempArray) {
        
        textRange =[[[userObj.user objectForKey:@"name"] lowercaseString] rangeOfString:[searchText lowercaseString]];
        if(textRange.location != NSNotFound)
        {
            [searchArray addObject:userObj];
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
    viewController.username= [((UserObject*)[searchArray objectAtIndex:indexPath.row]).user objectForKey:@"name"]; 
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchArray count];
}

@end
