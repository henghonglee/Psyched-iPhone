//
//  SearchUserCell.m
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//
#import "ASIFormDataRequest.h"
#import "SearchUserCell.h"
#import <Parse/Parse.h>
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
        PFQuery* userQueryByName = [PFQuery queryForUser];
        [userQueryByName whereKey:@"name" equalTo:nameLabel.text];
        NSLog(@"nameLabel = %@",nameLabel.text);
        [userQueryByName getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:@"ogshare"]) {
                ASIHTTPRequest* newOGPost = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/me/og.follows?access_token=%@&profile=%@",[PFFacebookUtils facebook].accessToken,[object objectForKey:@"facebookid"]]]];
                NSLog(@"ogpost = %@",newOGPost.url);
                [newOGPost setRequestMethod:@"POST"];
                [newOGPost setCompletionBlock:^{
                    SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
                    NSDictionary *jsonObjects = [jsonParser objectWithString:[newOGPost responseString]];
                    [jsonParser release];
                    jsonParser = nil;
                    if ([jsonObjects objectForKey:@"id"]) {
                        [self followClickedUserWithOGid:[jsonObjects objectForKey:@"id"]];
                      
                    }else{
                        NSLog(@"most likely authentication failed , %@",[newOGPost responseString]);
                    }
                    
                }];
                [newOGPost setFailedBlock:^{
                    NSLog(@"failed");
                }];
                [newOGPost startAsynchronous];
            }else{
                [self followClickedUserWithOGid:nil];
            }
         
            
            
            
            
        }];
        
    }else{
        
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
        ASIHTTPRequest* newOGDelete = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@?access_token=%@",idstring,[PFFacebookUtils facebook].accessToken]]];
        [newOGDelete setRequestMethod:@"DELETE"];
        NSLog(@"deleting %@",newOGDelete.url);
        [newOGDelete setCompletionBlock:^{
            NSLog(@"newOGDelete posted, %@",[newOGDelete responseString]);
        }];
        [newOGDelete setFailedBlock:^{
            NSLog(@"newOGDelete failed");
        }];
        [newOGDelete startAsynchronous];
        
    }
}

-(void)followClickedUserWithOGid:(NSString*)idstring
{
    NSLog(@"now following %@",nameLabel.text);
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
