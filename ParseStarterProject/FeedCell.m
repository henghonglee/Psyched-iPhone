//
//  FeedCell.m
//  PsychedApp
//
//  Created by HengHong Lee on 15/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "FeedCell.h"

@implementation FeedCell
@synthesize feedLabel;
@synthesize senderImage;
@synthesize timeLabel;
@synthesize readSphereView;

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
    [readSphereView release];
    [super dealloc];
}
@end
