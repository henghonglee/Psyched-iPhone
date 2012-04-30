//
//  CommentTableCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 26/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentTableCell.h"

@implementation CommentTableCell
@synthesize routeImageView;
@synthesize userImageView;
@synthesize commentTextLabel;
@synthesize userNameLabel;
@synthesize timeLabel;
@synthesize imageBackgroundView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
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
    [routeImageView release];
    [userImageView release];
    [commentTextLabel release];
    [userNameLabel release];
    [timeLabel release];
    [imageBackgroundView release];
    [super dealloc];
}
@end
