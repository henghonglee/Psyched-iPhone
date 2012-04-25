//
//  GymCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "GymCell.h"

@implementation GymCell
@synthesize gymThumbnailView;
@synthesize gymNameLabel;
@synthesize gymAboutLabel;

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
    [gymThumbnailView release];
    [gymNameLabel release];
    [gymAboutLabel release];
    [super dealloc];
}
@end
