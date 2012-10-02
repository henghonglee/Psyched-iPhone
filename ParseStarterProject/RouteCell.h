//
//  RouteCell.h
//  PsychedApp
//
//  Created by HengHong on 1/10/12.
//
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
@interface RouteCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *todoTextLabel;
@property (retain, nonatomic) IBOutlet UIImageView *routeImageView;
@property (retain, nonatomic) IBOutlet UIView *imageBackgroundView;
@property (retain, nonatomic) IBOutlet UILabel *ownerNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *ownerImage;
@property (retain, nonatomic) IBOutlet UILabel *commentcount;
@property (retain, nonatomic) IBOutlet UILabel *likecount;
@property (retain, nonatomic) IBOutlet UILabel *viewcount;
@property (retain, nonatomic) IBOutlet UILabel *routeLocationLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *difficultyLabel;
@property (nonatomic) BOOL isFetchingGym;
@property (retain,nonatomic) PFObject* routePFObject;
@end

