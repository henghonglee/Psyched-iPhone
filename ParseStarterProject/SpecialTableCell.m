//
//  SpecialTableCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "SpecialTableCell.h"

@implementation SpecialTableCell
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
@synthesize approvalView;
@synthesize routePFObject;
@synthesize isFetchingGym;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        cellbgimageview.layer.cornerRadius = 10;
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)approveOutdate:(id)sender {
    [routePFObject setObject:@"approved" forKey:@"approvalstatus"];
    [routePFObject setObject:[NSNumber numberWithBool:YES] forKey:@"outdated"];
    [routePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        approvalView.hidden =YES;
    }];
}
- (IBAction)disapproveOutdate:(id)sender {
    [routePFObject setObject:@"disapproved" forKey:@"approvalstatus"];
    [routePFObject setObject:[NSNumber numberWithBool:NO] forKey:@"outdated"];
    [routePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
           approvalView.hidden =YES;
    }];
}

- (void)dealloc {
    [routePFObject release];
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
    [approvalView release];
    [super dealloc];
}
@end
