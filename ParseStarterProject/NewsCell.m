//
//  NewsCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 19/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell
@synthesize newsImage;
@synthesize newsText;
@synthesize newsTitle;

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
    [newsImage release];
    [newsText release];
    [newsTitle release];
    [super dealloc];
}
@end
