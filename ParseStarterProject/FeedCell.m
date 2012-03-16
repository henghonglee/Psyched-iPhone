//
//  FeedCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 15/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell
@synthesize feedLabel;
@synthesize senderImage;
@synthesize timeLabel;

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
    [feedLabel release];
    [senderImage release];
    [timeLabel release];
    [super dealloc];
}
@end
