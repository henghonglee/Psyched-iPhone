//
//  RouteCell.m
//  PsychedApp
//
//  Created by HengHong on 1/10/12.
//
//

#import "RouteCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation RouteCell
@synthesize todoTextLabel;
@synthesize routeImageView;
@synthesize ownerNameLabel;
@synthesize ownerImage;
@synthesize commentcount;
@synthesize likecount;
@synthesize viewcount;
@synthesize routeLocationLabel;
@synthesize timeLabel;
@synthesize difficultyLabel;
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
//- (IBAction)approveOutdate:(id)sender {
//    
//    // maybe we should just delete the route
//    [routePFObject setObject:@"approved" forKey:@"approvalstatus"];
//    [routePFObject setObject:[NSNumber numberWithBool:YES] forKey:@"outdated"];
//    [routePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        approvalView.hidden =YES;
//        
//        if ([routePFObject objectForKey:@"approvalreqFBid"]) {
//            
//            if (![[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"facebookid"]]isEqualToString:[routePFObject objectForKey:@"approvalreqFBid"]]) {
//                NSMutableDictionary *data = [NSMutableDictionary dictionary];
//                [data setObject:routePFObject.objectId forKey:@"linkedroute"];
//                [data setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
//                [data setObject:[NSString stringWithFormat:@"%@ approved your outdate request",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"alert"];
//                [data setObject:[NSString stringWithFormat:@"%@",[[PFUser currentUser] objectForKey:@"name"]] forKey:@"sender"];
//                [PFPush sendPushDataToChannelInBackground:[NSString stringWithFormat:@"channel%@",[routePFObject objectForKey:@"approvalreqFBid"]] withData:data];
//            }
//        }
//    }];
//}
//- (IBAction)disapproveOutdate:(id)sender {
//    [routePFObject setObject:@"disapproved" forKey:@"approvalstatus"];
//    [routePFObject setObject:[NSNumber numberWithBool:NO] forKey:@"outdated"];
//    [routePFObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//        approvalView.hidden =YES;
//    }];
//}

- (void)dealloc {
    [routePFObject release];

    [todoTextLabel release];
    [routeImageView release];
    [ownerNameLabel release];
    [ownerImage release];

    [commentcount release];
    [likecount release];
    [viewcount release];

    [routeLocationLabel release];

    [timeLabel release];

    [difficultyLabel release];

    [imageBackgroundView release];
    [super dealloc];
}
@end
