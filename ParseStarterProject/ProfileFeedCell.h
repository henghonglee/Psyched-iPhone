//
//  ProfileFeedCell.h
//  PsychedApp
//
//  Created by HengHong on 10/10/12.
//
//

#import <UIKit/UIKit.h>

@interface ProfileFeedCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *feedLabel;
@property (retain, nonatomic) IBOutlet UIImageView *senderImage;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *readSphereView;
@end
