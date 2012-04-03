//
//  NewsViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 18/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsCell.h"
#import "NewsObject.h"
#import "ASIHTTPRequest.h"
#import "DAReloadActivityButton.h"
@interface NewsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* newsArray;
    NSMutableArray* queryArray;
    PFGeoPoint* currentGeoPoint;
}
@property (retain, nonatomic) IBOutlet UITableView *newsTable;
@property (nonatomic, strong) DAReloadActivityButton *navigationBarItem;
@end
