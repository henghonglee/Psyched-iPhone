//
//  FollowTableCell.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 15/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowTableCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *priorityLabel;
@property (retain, nonatomic) IBOutlet UILabel *todoTextLabel;
@property (retain, nonatomic) IBOutlet UIImageView *routeImageView;
@property (retain, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *ownerImage;
@property (retain, nonatomic) IBOutlet UILabel *createdLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentcount;
@property (retain, nonatomic) IBOutlet UILabel *likecount;
@property (retain, nonatomic) IBOutlet UILabel *viewcount;
@property (retain, nonatomic) IBOutlet UIImageView *cellbgimageview;
@property (retain, nonatomic) IBOutlet UILabel *routeLocationLabel;
@property (retain, nonatomic) IBOutlet UIImageView *pinImageView;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *stampImageView;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@end
