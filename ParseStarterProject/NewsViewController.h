//
//  NewsViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 18/1/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCell.h"
#import "NewsObject.h"
#import "DAReloadActivityButton.h"
@interface NewsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* newsArray;
    NSMutableArray* queryArray;
    PFGeoPoint* currentGeoPoint;
}
@property (retain, nonatomic) IBOutlet UITableView *newsTable;
@property (nonatomic, strong) DAReloadActivityButton *navigationBarItem;
@property (nonatomic, strong) NSMutableArray *newsArray;
@property (nonatomic, strong) NSMutableArray *queryArray;
@end
