//
//  CommentsCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 12/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CommentsCell.h"

@implementation CommentsCell
@synthesize commenterImageView;
@synthesize commenterNameLabel;
@synthesize commentLabel;
@synthesize commentTime;

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
    [commenterImageView release];
    [commenterNameLabel release];
    [commentLabel release];
    [commentTime release];
    [super dealloc];
}
@end
