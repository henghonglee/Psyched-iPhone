//
//  SearchUserCell.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "FollowFriendsViewController.h"
@interface SearchUserCell : UITableViewCell
{
    PFObject* tobedeleted;
}
- (IBAction)setFollow:(id)sender;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *userImageView;

@property (retain, nonatomic) IBOutlet UIButton *followButton;
@property (retain, nonatomic) FollowFriendsViewController *owner;
@end
