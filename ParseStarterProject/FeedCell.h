//
//  FeedCell.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 15/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeedCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *feedLabel;
@property (retain, nonatomic) IBOutlet UIImageView *senderImage;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;

@end
