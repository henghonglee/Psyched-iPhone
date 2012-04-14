//
//  SearchUserCell.m
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

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
        
        NSLog(@"now following %@",nameLabel.text);
        PFObject* pfObj = [PFObject objectWithClassName:@"Follow"];
        [pfObj setObject:[PFUser currentUser] forKey:@"follower"];
        [pfObj setObject:nameLabel.text forKey:@"followed"];
        [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [followButton setBackgroundImage:[UIImage imageNamed:@"following_text.png"] forState:UIControlStateNormal];
                followButton.userInteractionEnabled = YES;
        }];
        NSLog(@"owner.followed array = %@",owner.followedArray);
        [owner.followedArray addObject:pfObj];
        
        PFObject* newFeedObject = [PFObject objectWithClassName:@"Feed"];
        [newFeedObject setObject:[NSString stringWithFormat:@"%@ started following %@",[[PFUser currentUser] objectForKey:@"name"],nameLabel.text] forKey:@"message"];
        [newFeedObject setObject:[[PFUser currentUser] objectForKey:@"name"] forKey:@"sender"];
        [newFeedObject setObject:[[PFUser currentUser] objectForKey:@"profilepicture"] forKey:@"senderimagelink"];
        [newFeedObject saveInBackground];
        
    }else{
        
        NSLog(@"stopped following %@",nameLabel.text);    
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"followed" equalTo:nameLabel.text];
        [query whereKey:@"follower" equalTo:[PFUser currentUser]];
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            for (PFObject* obj in objects) {
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

        
        for (PFObject* followobj in owner.followedArray) {
             NSLog(@"scanning object with owner = %@",[followobj objectForKey:@"followed"] );
            if([[followobj objectForKey:@"followed"] isEqualToString:nameLabel.text]){
                NSLog(@"deleted object with owner = %@",[followobj objectForKey:@"followed"] );
              tobedeleted = followobj;
             //   [owner.followedArray removeObject:followobj];
              
            }
        }
           [owner.followedArray removeObject:tobedeleted];
    }
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
