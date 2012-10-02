//
//  ArrowChangeCell.m
//  PsychedApp
//
//  Created by HengHong Lee on 10/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "ArrowChangeCell.h"

@implementation ArrowChangeCell
@synthesize arrowImageView;
@synthesize startImageView;
@synthesize endImageView;

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
    [arrowImageView release];
    [startImageView release];
    [endImageView release];
    [super dealloc];
}
@end
