//
//  CommentsCell.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 12/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *commenterImageView;
@property (retain, nonatomic) IBOutlet UILabel *commenterNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentTime;

@end
