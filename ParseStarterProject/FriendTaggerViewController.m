//
//  FriendTaggerViewController.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 21/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FriendTaggerViewController.h"
#import <Parse/Parse.h>
@implementation FriendTaggerViewController
@synthesize taggerTextField;
@synthesize taggerTable;
@synthesize FBfriendsArray;
@synthesize friendsArray;
@synthesize recommendArray;
@synthesize delegate;
@synthesize myRequest;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        FBfriendsArray = [[NSMutableArray alloc]init ];
        friendsArray = [[NSMutableArray alloc]init];
        recommendArray = [[NSMutableArray alloc]init ];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    taggerTable.hidden=YES;
    PF_MBProgressHUD* hud = [PF_MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Fetching Facebook Friends...";
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];   
        [self apiGraphFriends];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [PF_FBRequest cancelPreviousPerformRequestsWithTarget:self];
}
-(void)dismissView:(id)sender
{
    [self.delegate TaggerDidReturnWithRecommendedArray:recommendArray];
    [self.navigationController popViewControllerAnimated:YES];
    
    
}
-(void)apiGraphFriends
{ 
   
    self.myRequest = [[PFFacebookUtils facebook] requestWithGraphPath:@"me/friends" andDelegate:self];
}
-(void)request:(PF_FBRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"%@",response);
    
   
    
}
- (void)request:(PF_FBRequest *)request didLoad:(id)result {
    //NSString* photoid;
    
            NSLog(@"result");
            NSArray* fbfriends = [result objectForKey:@"data"];
            [FBfriendsArray removeAllObjects];
            for (NSDictionary* obj in fbfriends) {
                FBfriend* newFBfriend = [[FBfriend alloc]init];
                newFBfriend.uid = [obj objectForKey:@"id"];
                newFBfriend.name = [obj objectForKey:@"name"];
                [FBfriendsArray addObject:newFBfriend];
                [newFBfriend release];
            }
            //  NSLog(@"fbfriends array = %@",FBfriendsArray);
            [friendsArray addObjectsFromArray:FBfriendsArray];
    [taggerTable reloadData];
            [PF_MBProgressHUD hideHUDForView:self.view animated:YES];
    taggerTable.hidden=NO;
        [taggerTextField becomeFirstResponder];
            
         
}
- (void)viewDidUnload
{
    [self setTaggerTextField:nil];
    [self setTaggerTable:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else {
        return NO;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell* cellselected = [tableView cellForRowAtIndexPath:indexPath];
    if(cellselected.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        cellselected.accessoryType = UITableViewCellAccessoryNone;
        for (FBfriend* user in FBfriendsArray) {
            if ([user.name isEqualToString:cellselected.textLabel.text]) {
                FBfriend* friendtoremove= [[FBfriend alloc]init];
                for (FBfriend* friend in recommendArray) {
                    if ([friend.name isEqualToString:user.name]) {
                        friendtoremove = friend;
                    }
                }
        [recommendArray removeObject:friendtoremove];

            }
        }
    }else{
        cellselected.accessoryType = UITableViewCellAccessoryCheckmark;
        
        for (FBfriend* user in FBfriendsArray) {
            if ([user.name isEqualToString:cellselected.textLabel.text]) {
                [recommendArray addObject:user]; 
                                NSLog(@"recommendArray =%@",recommendArray);
            }
        }
        
        
    }
    NSLog(@"done");
    taggerTextField.text = @"";
    
}
- (BOOL) textField: (UITextField *) textField shouldChangeCharactersInRange: (NSRange) range replacementString: (NSString *) string
{
    
    [friendsArray removeAllObjects];
    NSRange textRange;
    for (FBfriend* user in FBfriendsArray) {
        
        textRange =[[user.name lowercaseString] rangeOfString:[taggerTextField.text lowercaseString]];
        if(textRange.location != NSNotFound)
        {
            [friendsArray addObject:user];
        }
        
    }
    if ([taggerTextField.text isEqualToString:@""]) {
        [friendsArray addObjectsFromArray:FBfriendsArray];
        
    }
    [taggerTable reloadData]; 
    
    return YES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"mycell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    for (FBfriend*user in recommendArray) {
        if ([user.name isEqualToString:((FBfriend*)[friendsArray objectAtIndex:indexPath.row]).name]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    // cell.textLabel.text = [[friendsArray objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.textLabel.text = ((FBfriend*)[friendsArray objectAtIndex:indexPath.row]).name;    
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [friendsArray count];
}



- (void)dealloc {
    if( myRequest ) {
        [[myRequest connection] cancel];
        [myRequest release];
    }
    [FBfriendsArray release];
    [friendsArray release];
    [recommendArray release];
    [taggerTextField release];
    [taggerTable release];
    [super dealloc];
}
@end
