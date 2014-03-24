//
//  SearchUserCell.m
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//
#import "SearchUserCell.h"
#import <Parse/Parse.h>
#import "AFNetworking.h"
@implementation SearchUserCell
@synthesize nameLabel;
@synthesize userImageView;

@synthesize followButton;
@synthesize owner;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (IBAction)setFollow:(id)sender {
    followButton.userInteractionEnabled = NO;
    if ([followButton backgroundImageForState:UIControlStateNormal]==[UIImage imageNamed:@"follow_text.png"]) {
        // search users by name and find their facebookid
        PFQuery* userQueryByName = [PFUser query];
        [userQueryByName whereKey:@"name" equalTo:nameLabel.text];
        NSLog(@"nameLabel = %@",nameLabel.text);
        [userQueryByName getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
              NSURL *OGURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/og.follows?access_token=%@&profile=%@",[PFFacebookUtils session].accessToken,[object objectForKey:@"facebookid"]]];
                AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
                [manager POST:[OGURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                  NSLog(@"JSON: %@", responseObject);
                  SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                  NSDictionary *jsonObjects = [jsonParser objectWithString:[responseObject responseString]];
                  [jsonParser release];
                  jsonParser = nil;
                  if ([jsonObjects objectForKey:@"id"]) {
                    [self followClickedUserWithOGid:[jsonObjects objectForKey:@"id"]];

                  }else{
                    NSLog(@"most likely authentication failed , %@",[responseObject responseString]);
                  }

                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                  NSLog(@"Error: %@", error);
                }];

            }else{
                [self followClickedUserWithOGid:nil];
            }
        }];
    }else{
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"Confirm" message:[NSString stringWithFormat:@"Stop Following %@?",nameLabel.text] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes",nil];
        alert.delegate = self;
        [alert show];
        [alert release];
        
    }
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex) {
        NSLog(@"stopped following %@",nameLabel.text);
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"followed" equalTo:nameLabel.text];
        [query whereKey:@"follower" equalTo:[PFUser currentUser]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            for (PFObject* obj in objects) {
                if([obj objectForKey:@"subscriptionid"])
                    [self deleteOGwithId:[obj objectForKey:@"subscriptionid"]];
                [obj deleteInBackground];
                [followButton setBackgroundImage:[UIImage imageNamed:@"follow_text.png"] forState:UIControlStateNormal];
                
            }
            followButton.userInteractionEnabled = YES;
        }];
        PFQuery* followfeedquery = [PFQuery queryWithClassName:@"Feed"];
        [followfeedquery whereKey:@"message" equalTo:[NSString stringWithFormat:@"%@ started following %@",[[PFUser currentUser] objectForKey:@"name"],nameLabel.text]];
        [followfeedquery whereKey:@"sender" equalTo:[[PFUser currentUser] objectForKey:@"name"]];
        [followfeedquery findObjectsInBackgroundWithBlock:^(NSArray *retrievedobjects, NSError *error) {
            for (PFObject* pfobject in retrievedobjects) {
                [pfobject deleteInBackground];
            }
            
            
            
            
            
        }];
        
        
        for (PFObject* followobj in ((FollowFriendsViewController*)owner).followedArray) {
            NSLog(@"scanning object with owner = %@",[followobj objectForKey:@"followed"] );
            if([[followobj objectForKey:@"followed"] isEqualToString:nameLabel.text]){
                NSLog(@"deleted object with owner = %@",[followobj objectForKey:@"followed"] );
                tobedeleted = followobj;
                //   [owner.followedArray removeObject:followobj];
                
            }
        }
        [((FollowFriendsViewController*)owner).followedArray removeObject:tobedeleted];
    }
}
-(void)deleteOGwithId:(NSString*)idstring
{
  if (idstring) {
    NSURL *OGDelURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",idstring,[PFFacebookUtils session].accessToken]];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager DELETE:[OGDelURL absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
      NSLog(@"JSON: %@", responseObject);
      NSLog(@"newOGDelete posted, %@",[OGDelURL responseString]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
      NSLog(@"Error: %@", error);
    }];
  }
}

-(void)followClickedUserWithOGid:(NSString*)idstring
{
    NSLog(@"now following %@",nameLabel.text);
    PFQuery* userQ = [PFUser query];
    [userQ whereKey:@"name" equalTo:nameLabel.text];
    [userQ getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (object) {
        [PFPush sendPushMessageToChannelInBackground:[NSString stringWithFormat:@"channel%@",[object objectForKey:@"facebookid"]] withMessage:[NSString stringWithFormat:@"%@ is now following you on Psyched!",[[PFUser currentUser] objectForKey:@"name"]]];
        }else{
            NSLog(@"error = %@",error);
        }
    }];
    
    
    PFObject* pfObj = [PFObject objectWithClassName:@"Follow"];
    [pfObj setObject:[PFUser currentUser] forKey:@"follower"];
    [pfObj setObject:nameLabel.text forKey:@"followed"];
    if (idstring) {
        [pfObj setObject:idstring forKey:@"subscriptionid"];
    }
    [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [followButton setBackgroundImage:[UIImage imageNamed:@"following_text.png"] forState:UIControlStateNormal];
        followButton.userInteractionEnabled = YES;
    }];
    NSLog(@"owner.followed array = %@",((FollowFriendsViewController*)owner).followedArray);
    [((FollowFriendsViewController*)owner).followedArray addObject:pfObj];
    
    PFObject* newFeedObject = [PFObject objectWithClassName:@"Feed"];
    [newFeedObject setObject:[NSString stringWithFormat:@"%@ started following %@",[[PFUser currentUser] objectForKey:@"name"],nameLabel.text] forKey:@"message"];
    [newFeedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
    [newFeedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
    [newFeedObject saveInBackground];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [nameLabel release];
    [userImageView release];

    [followButton release];
    [super dealloc];
}
@end
