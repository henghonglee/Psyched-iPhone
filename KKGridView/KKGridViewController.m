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
#import "ASIHTTPRequest.h"
@implementation KKGridViewController
@synthesize gridView = _gridView;
@synthesize popularRouteArray;
@synthesize isLoadingMore;
@synthesize navigationBarItem;
@synthesize userDictionary;
@synthesize picDictionary;
@synthesize followedPosters;
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
 //   self.userDictionary = [[NSMutableDictionary alloc]init];
 //       self.picDictionary = [[NSMutableDictionary alloc]init];
    
    PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
    [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
    [popularQuery orderByDescending:@"likecount"];
    [popularQuery addDescendingOrder:@"commentcount"];
    [popularQuery addDescendingOrder:@"viewcount"];
    [popularQuery addDescendingOrder:@"createdAt"];
    [popularQuery setLimit:50];
    popularQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    popularRouteArray = [[NSMutableArray alloc]init ];
    
    NSLog(@"fetching popular");
    [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
    //    NSLog(@"found popular =%@",objects);
        for (PFObject* popRoute in objects) {
            RouteObject* newRoute = [[RouteObject alloc]init];
            newRoute.pfobj = popRoute;
            [popularRouteArray addObject:newRoute];
     
        }
        [self.gridView reloadData];
    }];
//    
//    
//    followedPosters = [[NSMutableArray alloc]init ];
//    PFQuery* followedquery = [PFQuery queryWithClassName:@"Follow"];
//    [followedquery whereKey:@"follower" equalTo:[PFUser currentUser]];
//    [followedquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        for (PFObject* follow in objects) {
//            [followedPosters addObject:[follow objectForKey:@"followed"]];
//        }
//
//     PFQuery* feedQuery = [PFQuery queryWithClassName:@"Feed"];
//     [feedQuery whereKey:@"sender" containedIn:followedPosters];
//     NSArray* arrayActions = [NSArray arrayWithObjects:@"sent",@"flash",@"project",@"like",@"recommend", nil];
//     [feedQuery whereKey:@"action" containedIn:arrayActions];
//     NSDate *newDate = [[NSDate date] addTimeInterval:-604800];
//       [feedQuery whereKey:@"createdAt" lessThan:[NSDate date]]; 
//     //[feedQuery whereKey:@"createdAt" greaterThan:newDate];
//        [feedQuery orderByDescending:@"createdAt"];
//     [feedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//         NSLog(@"found feeds =%@",objects);
//         for (PFObject* feedObject in objects) {
//             
//             NSString *sectionHeader = [feedObject objectForKey:@"sender"];
//             found = NO;
//             
//             for (NSString *str in [self.userDictionary allKeys])
//             {
//                 if ([str isEqualToString:sectionHeader])
//                 {
//                     found = YES;
//                 }
//             }
//             
//             if (!found)
//             {
//                 
//                 [self.userDictionary setValue:[[NSMutableArray alloc] init] forKey:sectionHeader];
//                 ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:[feedObject objectForKey:@"senderimagelink"]]];
//                 __unsafe_unretained ASIHTTPRequest* _request = request;
//                 [_request setCompletionBlock:^{
//                     [self.picDictionary setObject:[UIImage imageWithData:[_request responseData]] forKey:sectionHeader];
//                 }];
//                 [_request startAsynchronous];
//                                 
//             }
//         }
//         
//         for (PFObject *feedObject in objects)
//         {
//             RouteObject* routeObj = [[RouteObject alloc]init];
//              [[feedObject objectForKey:@"linkedroute"] fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
//                  routeObj.pfobj = object;
//                 if ([[feedObject objectForKey:@"action"] isEqualToString:@"like"]) {
//                      routeObj.stampImage = [UIImage imageNamed:@"likeribbon.png"];
//                  }else if ([[feedObject objectForKey:@"action"] isEqualToString:@"flash"]) {
//                      routeObj.stampImage = [UIImage imageNamed:@"flashribbon.png"];
//                  }else if ([[feedObject objectForKey:@"action"] isEqualToString:@"sent"]) {
//                      routeObj.stampImage = [UIImage imageNamed:@"sentribbon.png"];
//                  }else if ([[feedObject objectForKey:@"action"] isEqualToString:@"project"]) {
//                      routeObj.stampImage = [UIImage imageNamed:@"projectribbon.png"];
//                  }
//                  
//                  
//                  
//                   [[self.userDictionary objectForKey:[feedObject objectForKey:@"sender"]] addObject:routeObj];
//                  [self.gridView reloadData];
//             } ];
//             
//           
//         }
//         
//    }];
//        
//        
//    }];
//    
    
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

//- (NSUInteger)numberOfSectionsInGridView:(KKGridView *)gridView
//{
//
//    return [[self.userDictionary allKeys]count];
//}

- (NSUInteger)gridView:(KKGridView *)gridView numberOfItemsInSection:(NSUInteger)section
{
    //return  [[self.userDictionary objectForKey:[[self.userDictionary allKeys]objectAtIndex:section]] count];
    return [popularRouteArray count];
}
//- (NSString *)gridView:(KKGridView *)gridView titleForHeaderInSection:(NSUInteger)section
//{
//    return [[self.userDictionary allKeys]objectAtIndex:section];
//}

- (KKGridViewCell *)gridView:(KKGridView *)gridView cellForItemAtIndexPath:(KKIndexPath *)indexPath
{
 
    KKGridViewCell *cell = [KKGridViewCell cellForGridView:gridView];
    cell.selectedBackgroundView = [UIView new];
  
    

    RouteObject* selectedRoute = [popularRouteArray objectAtIndex:indexPath.index];
//    RouteObject* selectedRoute = [((NSMutableArray*)[self.userDictionary objectForKey:[[self.userDictionary allKeys]objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.index];
   
    cell.stampImageView.image = selectedRoute.stampImage;
    
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
//    if (indexPath.index == ([popularRouteArray count]-1)&& !isLoadingMore) {
//        NSLog(@"loading more");
//        isLoadingMore = YES;
//        PFQuery* popularQuery = [PFQuery queryWithClassName:@"Route"];
//        [popularQuery whereKey:@"outdated" notEqualTo:[NSNumber numberWithBool:true]];
//        [popularQuery orderByDescending:@"likecount"];
//        [popularQuery addDescendingOrder:@"commentcount"];
//        [popularQuery addDescendingOrder:@"viewcount"];
//        [popularQuery addDescendingOrder:@"createdAt"];
//        [popularQuery setLimit:50];
//        [popularQuery setSkip:[popularRouteArray count]];
//        popularQuery.cachePolicy = kPFCachePolicyNetworkElseCache;
//
//        NSLog(@"fetching popular");
//        [popularQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//            if ([objects count]) {
//            for (PFObject* popRoute in objects) {
//                RouteObject* newRoute = [[RouteObject alloc]init];
//                newRoute.pfobj = popRoute;
//                [popularRouteArray addObject:newRoute];
//                
//            }
//            [self.gridView reloadData];
//                isLoadingMore = NO;
//            }else{
//                isLoadingMore = YES;
//            }
//            
//        }];
//
//    }
    
    return cell;
        
}
-(void)gridView:(KKGridView *)gridView didSelectItemAtIndexPath:(KKIndexPath *)indexPath
{
    [gridView deselectAll:YES];
    RouteDetailViewController* viewController = [[RouteDetailViewController alloc]initWithNibName:@"RouteDetailViewController" bundle:nil];
    viewController.routeObject = [popularRouteArray objectAtIndex:indexPath.index];
    
 //   viewController.routeObject = [((NSMutableArray*)[self.userDictionary objectForKey:[[self.userDictionary allKeys]objectAtIndex:indexPath.section]]) objectAtIndex:indexPath.index];
    [self.navigationController pushViewController:viewController animated:YES];
   
    
}
/*
- (CGFloat)gridView:(KKGridView *)gridView heightForHeaderInSection:(NSUInteger)section
{
    return 44;
}
-(UIView *)gridView:(KKGridView *)gridView viewForHeaderInSection:(NSUInteger)section
{
    UIView* headerView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    headerView.backgroundColor = [UIColor whiteColor];
    headerView.alpha = 0.9;
    UILabel* userLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 10, 250, 24)];
    userLabel.text = [[self.userDictionary allKeys]objectAtIndex:section];
    userLabel.textColor = [UIColor colorWithRed:70.0/255.0 green:130.0/255.0 blue:180.0/255.0 alpha:1.0];
    userLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0f];
    userLabel.backgroundColor = [UIColor clearColor];
    UIImageView* profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, 34, 34)];
    if ([self.picDictionary objectForKey:userLabel.text]) {
        profileImageView.image = [self.picDictionary objectForKey:userLabel.text];
    }    
    [headerView addSubview:userLabel];
    [headerView addSubview:profileImageView];
    return headerView;
}

*/


@end
