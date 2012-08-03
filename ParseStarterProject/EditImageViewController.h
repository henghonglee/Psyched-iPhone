//
//  EditImageViewController.h
//  ParseStarterProject
//
//  Created by Shaun Tan on 11/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#import "CreateRouteViewController.h"
#import <UIKit/UIKit.h>
#import "JHNotificationManager.h"
#import "UIImage+Resize.h"
#import <ImageIO/ImageIO.h>

@protocol EditImageDelegate;

@interface EditImageViewController : UIViewController<UIScrollViewDelegate,UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>
{
    id <EditImageDelegate> delegate;
    CGRect originalArrowFrame;
    UIScrollView* scrollView;
    CGPoint locationinscroll;
    NSMutableDictionary* imageMetaData;
    NSNumber* selectedArrowType;
}
@property (retain, nonatomic)PFObject* reusePFObject;
@property (retain, nonatomic) NSMutableArray* CGPointsArray;
@property (retain, nonatomic) NSMutableArray* arrowTypeArray;
@property (retain, nonatomic) IBOutlet UIView *moreArrowsView;
@property (retain, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (retain, nonatomic) IBOutlet UIImageView *startImageView;
@property (retain, nonatomic) IBOutlet UIImageView *endImageView;
@property (retain, nonatomic) IBOutlet UITableView *arrowTable;
@property (retain, nonatomic) IBOutlet UIButton *button1;
@property (retain, nonatomic) IBOutlet UIButton *button2;
@property (retain, nonatomic) IBOutlet UIButton *button3;
@property (retain, nonatomic) NSMutableDictionary* imageMetaData;
@property (retain, nonatomic) IBOutlet UIButton *confButton;
@property (retain, nonatomic) IBOutlet UIView *sliderView;
@property (retain, nonatomic) NSMutableArray* imageStack;
@property (retain, nonatomic) IBOutlet UIImageView *draggableImageView;
@property (nonatomic , retain) UIImageView* imageToEdit;
@property (nonatomic , retain) UIImage* imageInView;
@property (retain, nonatomic) IBOutlet UIButton *instructionButton;
@property (nonatomic, assign) id <EditImageDelegate> delegate;
- (UIImage *)imageByDrawingCircleOnImage:(UIImage *)image;
- (IBAction)selectArrow:(UIButton*)sender ;
@end
@protocol EditImageDelegate <NSObject>
- (void)EditImagedidFinishWithImage:(UIImage *)image;

@end