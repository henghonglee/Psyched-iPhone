
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
@synthesize imageBackgroundView;
@synthesize isFetchingGym;
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
- (IBAction)approveOutdate:(id)sender {
    
    // maybe we should just delete the route
    [routePFObject setObject:@"approved" forKey:@"approvalstatus"];
    [routePFObject setObject:[NSNumber numberWithBool:YES] forKey:@"outdated"];
    [routePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        approvalView.hidden =YES;
       
        if ([routePFObject objectForKey:@"approvalreqFBid"]) {
            
            if (![[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"facebookid"]]isEqualToString:[routePFObject objectForKey:@"approvalreqFBid"]]) {
                NSMutableDictionary *data = [NSMutableDictionary dictionary];
                [data setObject:routePFObject.objectId forKey:@"linkedroute"];
                [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
                [data setObject:[NSString stringWithFormat:@"%@ approved your outdate request",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
                [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
                [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[routePFObject objectForKey:@"approvalreqFBid"]] withData:data];
            }
        }
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
    [imageBackgroundView release];
    [super dealloc];
}
@end
