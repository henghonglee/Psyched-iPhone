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
    if ([followButton backgroundImageForState:UIControlStateNormal]==[UIImage imageNamed:@"followbuttonup.png"]) {
        
        NSLog(@"now following %@",nameLabel.text);
        PFObject* pfObj = [PFObject objectWithClassName:@"Follow"];
        [pfObj setObject:[PFUser currentUser] forKey:@"follower"];
        [pfObj setObject:nameLabel.text forKey:@"followed"];
        [pfObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [followButton setBackgroundImage:[UIImage imageNamed:@"followbuttondown.png"] forState:UIControlStateNormal];
        }];
        NSLog(@"owner.followed array = %@",owner.followedArray);
        [owner.followedArray addObject:pfObj];
    }else{
        
        NSLog(@"stopped following %@",nameLabel.text);    
        PFQuery* query = [PFQuery queryWithClassName:@"Follow"];
        [query whereKey:@"followed" equalTo:nameLabel.text];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            for (PFObject* obj in objects) {
                [obj deleteInBackground];
          [followButton setBackgroundImage:[UIImage imageNamed:@"followbuttonup.png"] forState:UIControlStateNormal];      
                
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
