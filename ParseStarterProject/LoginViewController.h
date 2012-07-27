//
//  LoginViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 9/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@interface LoginViewController : UIViewController <UIScrollViewDelegate,PF_FBRequestDelegate>
{
    UIScrollView* scrollView;
	UIPageControl* pageControl;
	int page;
	BOOL pageControlBeingUsed;
}
- (void)apiFQLIMe;
- (IBAction)changePage;
@property (retain, nonatomic) IBOutletCollection(UIView) NSArray *pages;

@property (retain, nonatomic) IBOutlet UIImageView *updownarrow;
@property (retain, nonatomic) IBOutlet UIScrollView *instructionScroll;
@property (retain, nonatomic) IBOutlet UILabel *subtitleLabel;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (retain, nonatomic) IBOutlet UILabel *titleLabel;
@end
