//
//  SearchUserCell.h
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
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
@property (retain, nonatomic) UIViewController *owner;
@end
