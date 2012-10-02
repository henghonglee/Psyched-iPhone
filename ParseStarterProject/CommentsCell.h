//
//  CommentsCell.h
//  PsychedApp
//
//  Created by HengHong Lee on 12/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *commenterImageView;
@property (retain, nonatomic) IBOutlet UILabel *commenterNameLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentLabel;
@property (retain, nonatomic) IBOutlet UILabel *commentTime;

@end
