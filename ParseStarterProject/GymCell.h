//
//  GymCell.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GymCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *gymThumbnailView;
@property (retain, nonatomic) IBOutlet UILabel *gymNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *gymAboutLabel;

@end
