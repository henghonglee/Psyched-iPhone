//
//  FollowFriendsViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "Parse/Parse.h"
@interface FollowFriendsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UISearchBarDelegate>

@property (retain,nonatomic)PFUser* selectedUser;
@property (retain, nonatomic) IBOutlet UITableView *searchTable;
@property (retain,nonatomic) NSMutableArray* searchArray;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain,nonatomic) NSMutableArray* tempArray;
@property (retain,nonatomic) NSMutableArray* followedArray;

@end
