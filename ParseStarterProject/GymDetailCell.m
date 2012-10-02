//
//  GymDetailCell.m
//  PsychedApp
//
//  Created by HengHong Lee on 19/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "GymDetailCell.h"
#import <Parse/Parse.h>
#import "MapViewController.h"
@implementation GymDetailCell
@synthesize facebookid;
@synthesize routeCountLabel;
@synthesize likeCountLabel;
@synthesize FollowCountLabel;
@synthesize gymMapView;
@synthesize routeCount;
@synthesize likeCount;
@synthesize owner;
@synthesize followingCount;
@synthesize pfObject;
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
- (IBAction)showGym:(id)sender {
    MapViewController* mapVC = [[MapViewController alloc]initWithNibName:@"MapViewController" bundle:nil];
    mapVC.geopoint = (PFGeoPoint*)[pfObject objectForKey:@"gymlocation"];
    mapVC.gymName = [pfObject objectForKey:@"name"];
    [self.owner.navigationController pushViewController:mapVC animated:YES];
    
    [mapVC release];
}
- (IBAction)FollowUS:(id)sender {
    NSArray* adminArray = [[pfObject fetchIfNeeded] objectForKey:@"admin"];
    if (![adminArray containsObject:[[PFUser currentUser] objectForKey:@"name"]]) {
    PFQuery* followedQuery = [PFQuery queryWithClassName:@"Follow"];
    [followedQuery whereKey:@"follower" equalTo:[PFUser currentUser]];
    [followedQuery whereKey:@"followed" containedIn:adminArray];
    [followedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //if user followed any admin, each admin follow is detailed here
        for (NSString* adminName in adminArray) {
            BOOL isfollowed = NO;
            for (PFObject* followobj in objects) {
                if([adminName isEqualToString:[followobj objectForKey:@"followed"]]){
                    isfollowed =YES;
                }
            }
            if (!isfollowed) {
                NSLog(@"added new follow");
                PFObject* newFollow = [PFObject objectWithClassName:@"Follow"];
                [newFollow setObject:adminName forKey:@"followed"];
                [newFollow setObject:[PFUser currentUser] forKey:@"follower"];
                [newFollow saveInBackground];
            }
        }
        
    }];
        
        
    }
    [PFPush subscribeToChannelInBackground:[NSString stringWithFormat:@"channel%@",pfObject.objectId] block:^(BOOL succeeded, NSError *error) {
        NSLog(@"subscribed to channel for gym"); 
    }];
}
- (IBAction)LikeUs:(id)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"fb://page/%@",[pfObject objectForKey:@"facebookid"]]]];
}

- (void)dealloc {
    [routeCountLabel release];
    [likeCountLabel release];
    [FollowCountLabel release];

    [routeCount release];
    [likeCount release];
    [followingCount release];
    [gymMapView release];
    [super dealloc];
}
@end
