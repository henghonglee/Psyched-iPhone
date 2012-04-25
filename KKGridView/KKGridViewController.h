//
//  KKGridViewController.h
//  KKGridView
//
//  Created by Kolin Krewinkel on 10.22.11.
//  Copyright (c) 2011 Kolin Krewinkel. All rights reserved.
//

#import "KKGridView.h"
#import "DAReloadActivityButton.h"
@interface KKGridViewController : UIViewController <KKGridViewDataSource, KKGridViewDelegate>
@property (nonatomic) BOOL isLoadingMore;
@property (nonatomic, strong) KKGridView *gridView;
@property (nonatomic,strong) NSMutableArray* popularRouteArray;
@property (nonatomic,strong) DAReloadActivityButton* navigationBarItem;
@end
