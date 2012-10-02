//
//  NewsCell.h
//  PsychedApp
//
//  Created by HengHong Lee on 19/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UIImageView *newsImage;
@property (retain, nonatomic) IBOutlet UITextView *newsText;
@property (retain, nonatomic) IBOutlet UILabel *newsTitle;

@end
