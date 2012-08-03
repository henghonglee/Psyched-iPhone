//
//  GymViewController.h
//  PsychedApp
//
//  Created by HengHong on 31/7/12.
//
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "ASIHTTPRequest.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
#import "RouteObject.h"
#import "MKMapView+ZoomLevel.h"
#import "RouteDetailViewController.h"

@interface GymViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
	int page;
	BOOL pageControlBeingUsed;
    
}
- (IBAction)didChangeRoutePage:(id)sender;
@property (retain, nonatomic) NSMutableArray* wallRoutesArrowArray;
@property (retain, nonatomic) NSMutableArray* wallRoutesArrowTypeArray;
@property (retain, nonatomic) NSMutableArray* wallViewArrays;
@property (retain, nonatomic) NSMutableArray* imageDataArray;
@property (retain, nonatomic) NSMutableArray* queryArray;
@property (retain, nonatomic) UIScrollView *gymRouteScroll;
@property (nonatomic,retain) NSString* gymName;
@property (retain,nonatomic) PFObject* gymObject;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadRoutesActivityIndicator;

@property (nonatomic,retain) NSMutableArray* gymTags;
@property (nonatomic,retain) NSMutableDictionary* gymSections;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet UIImageView *footerUserImageView;
@property (retain, nonatomic) IBOutlet UILabel *footerLabel;
@property (retain, nonatomic) IBOutlet UILabel *footerDifficultyLabel;
@property (retain, nonatomic) IBOutlet UIButton *likeButton;
@property (retain, nonatomic) IBOutlet UIButton *followButton;

@property (retain, nonatomic) IBOutlet UIImageView *maskbgView;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *wallImageViews;
@property (retain, nonatomic) IBOutlet UIPageControl *routePageControl;
@property (retain, nonatomic) IBOutlet UIImageView *gymProfileImageView;
@property (retain, nonatomic) IBOutlet UIButton *ourRoutesButton;
@property (retain, nonatomic) IBOutlet UILabel *gymNameLabel;
@property (retain, nonatomic) IBOutlet UIView *profileshadow;
@property (retain, nonatomic) IBOutlet UIImageView *gymCoverImageView;
@property (retain, nonatomic) IBOutlet MKMapView *gymMapView;
@property (retain, nonatomic) IBOutlet UIView *imageViewContainer;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *gymWallScroll;

@end
