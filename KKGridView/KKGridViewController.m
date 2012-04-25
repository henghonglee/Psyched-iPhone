//
//  KKGridViewController.m
//  KKGridView
//
//  Created by Kolin Krewinkel on 10.22.11.
//  Copyright (c) 2011 Kolin Krewinkel. All rights reserved.
//

#import "KKGridViewController.h"
#import <Parse/Parse.h>
#import "RouteObject.h"
#import "RouteDetailViewController.h"
@implementation KKGridViewController
@synthesize gridView = _gridView;
@synthesize popularRouteArray;
@synthesize isLoadingMore;
@synthesize navigationBarItem;
#pragma mark - View lifecycle

- (void)loadView
{
    [super loadView];
    isLoadingMore = NO;
    _gridView = [[KKGridView alloc] initWithFrame:self.view.bounds];
    _gridView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    _gridView.delegate= self;
    _gridView.dataSource = self;
    self.view = _gridView;
    self.navigationItem.title = @"Popular Routes";
    navigationBarItem = [[DAReloadActivityButton alloc] init];
    navigationBarItem.showsTouchWhenHighlighted = NO;
    [navigationBarItem addTarget:self action:@selector(reloadUserData) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navigationBarItem];
    self.navigationItem.rightBarButtonItem = barButtonItem;

    
    PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
    [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [popularQuery orderByDescending:@"likecount"];
    [popularQuery addDescendingOrder:@"commentcount"];
    [popularQuery addDescendingOrder:@"viewcount"];
    [popularQuery addDescendingOrder:@"createdAt"];
    [popularQuery setLimit:50];
    popularQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    popularRouteArray = [[NSMutableArray alloc]init ];
    NSLog(@"fetching popular");
    [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"found popular =%@",objects);
        for (PFObject* popRoute in objects) {
            RouteObject* newRoute = [[RouteObject alloc]init];
            newRoute.pfobj = popRoute;
            [popularRouteArray addObject:newRoute];
     
        }
        [self.gridView reloadData];
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    isLoadingMore =NO;
}
#pragma mark - KKGridViewDataSource


-(void)reloadUserData
{
    [navigationBarItem startAnimating];
   
    PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
    [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [popularQuery orderByDescending:@"likecount"];
    [popularQuery addDescendingOrder:@"commentcount"];
    [popularQuery addDescendingOrder:@"viewcount"];
    [popularQuery addDescendingOrder:@"createdAt"];
    [popularQuery setLimit:[popularRouteArray count]==0?50:[popularRouteArray count]];
    popularQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
    popularRouteArray = [[NSMutableArray alloc]init ];
    NSLog(@"fetching popular");
    [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"found popular =%@",objects);
         [popularRouteArray removeAllObjects];
        for (PFObject* popRoute in objects) {
            RouteObject* newRoute = [[RouteObject alloc]init];
            newRoute.pfobj = popRoute;
            [popularRouteArray addObject:newRoute];
            
        }
        [navigationBarItem stopAnimating];
        [self.gridView reloadData];
    }];
}

- (NSUInteger)numberOfSectionsInGridView:(KKGridView *)gridView
{
    return 1;
}

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    return [popularRouteArray count];
}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
 
    KKGridViewCell *cell = [KKGridViewCell cellForGridView:gridView];
    cell.selectedBackgroundView = [UIView new];
    RouteObject* selectedRoute = [popularRouteArray objectAtIndex:indexPath.index];
   
    if (!selectedRoute.retrievedImage && !selectedRoute.isLoading) {
        selectedRoute.isLoading = YES;
        PFFile *imagefile = [selectedRoute.pfobj objectForKey:@"thumbImageFile"];
        //  [queryArray addObject:imagefile];
        [imagefile getDataInBackgroundWithBlock:^(NSData* imageData,NSError *error){
            //   [queryArray removeObject:imagefile];
            if ([selectedRoute isKindOfClass:[RouteObject class]]) {
                selectedRoute.isLoading = NO;     
            }
            UIImage* downloadedImage = [UIImage imageWithData:imageData];
            selectedRoute.retrievedImage = downloadedImage;
            cell.imageView.alpha = 0.0;
            cell.imageView.image = downloadedImage;
            
            [UIView animateWithDuration:0.3
                                  delay:0.0
                                options: UIViewAnimationCurveEaseOut
                             animations:^{
                                 cell.imageView.alpha = 1.0;
                             } 
                             completion:^(BOOL finished){
                                 // NSLog(@"Done!");
                             }];
        }];
        
        
    }else{
        cell.imageView.image = selectedRoute.retrievedImage;
        
    };
    
    //if cell is last cell load somore
    if (indexPath.index == ([popularRouteArray count]-1)&& !isLoadingMore) {
        NSLog(@"loading more");
        isLoadingMore = YES;
        PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
        [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
        [popularQuery orderByDescending:@"likecount"];
        [popularQuery addDescendingOrder:@"commentcount"];
        [popularQuery addDescendingOrder:@"viewcount"];
        [popularQuery addDescendingOrder:@"createdAt"];
        [popularQuery setLimit:50];
        [popularQuery setSkip:[popularRouteArray count]];
        popularQuery.cachePolicy = kPFCachePolicyNetworkElseCache;

        NSLog(@"fetching popular");
        [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if ([objects count]) {
            for (PFObject* popRoute in objects) {
                RouteObject* newRoute = [[RouteObject alloc]init];
                newRoute.pfobj = popRoute;
                [popularRouteArray addObject:newRoute];
                
            }
            [self.gridView reloadData];
                isLoadingMore = NO;
            }else{
                isLoadingMore = YES;
            }
            
        }];

    }
    
    return cell; 
}
-(void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath
{
    [gridView deselectAll:YES];
    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
    
    viewController.routeObject = [popularRouteArray objectAtIndex:indexPath.index];
    [self.navigationController pushViewController:viewController animated:YES];
   
    
}
- (CGFloat)gridView:(KKGridView *)gridView heightForHeaderInSection:(NSUInteger)section
{
    return 0;
}

- (NSString *)gridView:(KKGridView *)gridView titleForHeaderInSection:(NSUInteger)section
{
    return @"title for header";
}



@end
