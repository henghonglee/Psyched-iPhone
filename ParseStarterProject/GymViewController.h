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
//#import "DACircularProgressView.h"
@interface GymViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
	int page;
	BOOL pageControlBeingUsed;
    BOOL isLoadingRoutes;
    int currentRoutePage;
}
- (IBAction)didChangeRoutePage:(id)sender;
//@property (strong, nonatomic) DACircularProgressView *progressView;
@property (retain, nonatomic) IBOutlet UIProgressView *progress;
@property (retain, nonatomic) NSMutableArray* wallRoutesArrowArray;
@property (retain, nonatomic) IBOutlet UILabel *loadingLabel;
@property (retain, nonatomic) NSMutableArray* wallRoutesArrowTypeArray;
@property (retain, nonatomic) NSMutableArray* wallViewArrays;
@property (retain, nonatomic) NSMutableArray* imageDataArray;
@property (retain, nonatomic) NSMutableArray* queryArray;
@property (retain, nonatomic) UIScrollView *gymRouteScroll;
@property (nonatomic,retain) NSString* gymName;
@property (retain,nonatomic) PFObject* gymObject;
@property (retain, nonatomic) IBOutlet UIActivityIndicatorView *loadRoutesActivityIndicator;
@property (retain, nonatomic) IBOutlet UIImageView *bluepin;

@property (nonatomic,retain) NSMutableArray* gymTags;
@property (nonatomic,retain) NSMutableDictionary* gymSections;
@property (retain, nonatomic) IBOutlet UIView *footerView;
@property (retain, nonatomic) IBOutlet UIImageView *footerUserImageView;
@property (retain, nonatomic) IBOutlet UILabel *footerLabel;
@property (retain, nonatomic) IBOutlet UILabel *footerDifficultyLabel;
@property (retain, nonatomic) IBOutlet UIButton *likeButton;
@property (retain, nonatomic) IBOutlet UIButton *followButton;

@property (retain, nonatomic) IBOutlet UIView *maskbgView;
@property (retain, nonatomic) IBOutletCollection(UIImageView) NSArray *wallImageViews;
@property (retain, nonatomic) IBOutlet UIPageControl *routePageControl;
@property (retain, nonatomic) IBOutlet UIImageView *gymProfileImageView;
@property (retain, nonatomic) IBOutlet UIButton *ourRoutesButton;
@property (retain, nonatomic) IBOutlet UILabel *gymNameLabel;
@property (retain, nonatomic) IBOutlet UIImageView *gymCoverImageView;
@property (retain, nonatomic) IBOutlet MKMapView *gymMapView;
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *gymWallScroll;

@end
