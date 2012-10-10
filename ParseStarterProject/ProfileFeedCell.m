//
//  ProfileFeedCell.m
//  PsychedApp
//
//  Created by HengHong on 10/10/12.
//
//

#import "ProfileFeedCell.h"

@implementation ProfileFeedCell

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