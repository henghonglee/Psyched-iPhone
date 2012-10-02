//
//  SendUserViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 22/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SendUserViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UISearchBarDelegate>
@property (retain, nonatomic) IBOutlet UITableView *searchTable;
@property (retain,nonatomic) NSMutableArray* searchArray;
@property (retain,nonatomic) NSMutableArray* queryArray;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain,nonatomic) NSMutableArray* tempArray;
@property (retain,nonatomic) NSMutableArray* followedArray;
@property (retain,nonatomic) NSString* sendStatus;
@property (retain,nonatomic) PFObject* route;
@end
