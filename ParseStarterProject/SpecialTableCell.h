//
//  SpecialTableCell.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface SpecialTableCell : UITableViewCell
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
@property (nonatomic) BOOL isFetchingGym;
@property (retain, nonatomic) IBOutlet UIView *approvalView;
@property (retain,nonatomic) PFObject* routePFObject;
@property (retain, nonatomic) IBOutlet UIView *imageBackgroundView;
@end
