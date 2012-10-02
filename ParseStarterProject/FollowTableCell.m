//
//  FollowTableCell.m
//  PsychedApp
//
//  Created by HengHong Lee on 15/3/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "FollowTableCell.h"

@implementation FollowTableCell
@synthesize priorityLabel;
@synthesize todoTextLabel;
@synthesize routeImageView;
@synthesize ownerNameLabel;
@synthesize ownerImage;
@synthesize createdLabel;
@synthesize commentcount;
@synthesize likecount;
@synthesize viewcount;
@synthesize cellbgimageview;
@synthesize routeLocationLabel;
@synthesize pinImageView;
@synthesize timeLabel;
@synthesize stampImageView;
@synthesize difficultyLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
      //  cellbgimageview.layer.cornerRadius = 10;
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)dealloc {
    [priorityLabel release];
    [todoTextLabel release];
    [routeImageView release];
    [ownerNameLabel release];
    [ownerImage release];
    [createdLabel release];
    [commentcount release];
    [likecount release];
    [viewcount release];
    [cellbgimageview release];
    [routeLocationLabel release];
    [pinImageView release];
    [timeLabel release];
    [stampImageView release];
    [difficultyLabel release];
    [super dealloc];
}

@end
