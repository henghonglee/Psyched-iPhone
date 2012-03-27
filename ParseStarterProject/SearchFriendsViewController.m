

#import "SearchFriendsViewController.h"
#import "SearchUserCell.h"
#import <Parse/Parse.h>
#import "ASIHTTPRequest.h"
typedef enum apiCall {
kAPIGetAppUsersFriendsUsing,
kAPIGraphUserFriends,
kAPIGraphUserPhotosPost,
} apiCall;
@implementation SearchFriendsViewController
@synthesize searchBar;
@synthesize searchTable;
@synthesize selectedUser;
@synthesize myRequest;
@synthesize emptyView;
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
    self.navigationItem.title = @"Add Friends";
    tempArray = [[NSMutableArray alloc]init];
    searchArray = [[NSMutableArray alloc]init];
    followedArray = [[NSMutableArray alloc]init];
    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [followedArray addObjectsFromArray:objects]; 
    [self apiGraphFriends];
        
    }];
//    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"Follow All" style:UIBarButtonItemStylePlain target:self action:@selector(followAll:)];          
//    self.navigationItem.rightBarButtonItem = anotherButton;
//    [anotherButton release];
}
-(void)apiGraphFriends
{ 
    currentAPIcall = kAPIGetAppUsersFriendsUsing;
    self.myRequest = [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends?fields=installed" andDelegate:self];
    PF_MBProgressHUD* hud = [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Finding friends on Psyched!...";
    
}
-(void)followAll:(id)sender
{
    if([searchArray count]>0){
        for (int i=0; i<[searchArray count]; i++) {
            NSIndexPath* path = [NSIndexPath indexPathForRow:i inSection:0];
            SearchUserCell* cell = (SearchUserCell*)[searchTable cellForRowAtIndexPath:path];
            if ([((SearchUserCell*)cell).followButton backgroundImageForState:UIControlStateNormal]==[UIImage imageNamed:@"followbuttonup.png"]) {
            [(SearchUserCell*)cell setFollow:nil];
            }
        }
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    emptyView.hidden =YES;
    self.navigationController.navigationBarHidden = NO;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[myRequest connection] cancel];
    [PF_FBRequest cancelPreviousPerformRequestsWithTarget:self];
}

-(void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@",response);
    
    switch (currentAPIcall) {
        case kAPIGraphUserFriends:
            
            break;
        case kAPIGraphUserPhotosPost:
            break;
        default:
            break;
            
    }
    
}
- (void)request:(PF_FBRequest *)request didLoad:(id)result {

            NSArray* fbfriends = [result objectForKey:@"data"];
            [searchArray removeAllObjects];
            [tempArray removeAllObjects];
            //[FBfriendsArray removeAllObjects];
            NSMutableArray* fbidArray = [[NSMutableArray alloc]init];
            for (NSDictionary* obj in fbfriends) {
                if ([obj objectForKey:@"installed"]) {
                    [fbidArray addObject:[NSNumber numberWithInt:[[obj objectForKey:@"id"]intValue]]];
                
                }
            }
    if ([fbidArray count]==0) {
       
    }else{
                PFQuery* userquery = [PFQuery queryForUser];
                [userquery whereKey:@"facebookid" containedIn:fbidArray];
                [userquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    NSLog(@"%@",objects);
                    [searchArray addObjectsFromArray:objects];  
                    [tempArray addObjectsFromArray:objects];
                    
                    [searchTable reloadData];
                     [PF_MBProgressHUD hideHUDForView:self.view animated:YES];
                }];
    }      
                //[FBfriendsArray addObject:newFBfriend];
                
           
}

- (void)viewDidUnload
{
    [self setSearchTable:nil];
    [self setSearchBar:nil];
    [self setEmptyView:nil];
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
    if( myRequest ) {
        [[myRequest connection] cancel];
        [myRequest release];
    }
    [selectedUser release];
    [followedArray release];
    [tempArray release];
    [searchArray release];
    [searchTable release];
    [searchBar release];
    [emptyView release];
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
        NSString* urlstring = [NSString stringWithFormat:@"%@",[[searchArray objectAtIndex:indexPath.row] objectForKey:@"profilepicture"]];
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

-(void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
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
         [_searchBar resignFirstResponder];
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
