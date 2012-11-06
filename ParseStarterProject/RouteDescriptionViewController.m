//
//  RouteDescriptionViewController.m
//  PsychedApp
//
//  Created by HengHong Lee on 21/2/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import "RouteDescriptionViewController.h"
#import "FriendTaggerViewController.h"
@interface RouteDescriptionViewController ()

@end

@implementation RouteDescriptionViewController 
@synthesize descriptionTextField;
@synthesize descriptionText;
@synthesize instructionButton;
@synthesize delegate;
@synthesize taggedFriends;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.navigationItem.title = @"Route Description";
    descriptionTextField.text = descriptionText;
    [descriptionTextField becomeFirstResponder];
    UIBarButtonItem* rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
    self.navigationItem.rightBarButtonItem = rightButton;
    [rightButton release];   
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)addFriendAction:(id)sender {
    FriendTaggerViewController* viewController= [[FriendTaggerViewController alloc]initWithNibName:@"FriendTaggerViewController" bundle:nil];
    viewController.delegate = self;
    [self.navigationController pushViewController:viewController animated:YES];
    [viewController release];
}
-(void)TaggerDidReturnWithRecommendedArray:(NSMutableArray *)recommendedArray
{
    if (!taggedFriends) {
        taggedFriends = [[NSMutableArray alloc]init];
    }
    taggedFriends = recommendedArray;
    for (FBfriend* friend in recommendedArray) {
        descriptionTextField.text = [NSString stringWithFormat:@"%@ %@",descriptionTextField.text,friend.name];
    }
}
-(void)dismissView:(id)sender
{
       if (taggedFriends) {
        [self.delegate DescriptionDidReturnWithText:descriptionTextField.text andTaggedUsers:taggedFriends];
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.delegate DescriptionDidReturnWithText:descriptionTextField.text andTaggedUsers:nil];
        [self.navigationController popViewControllerAnimated:YES];

    }
}
- (IBAction)dismissInstruction:(id)sender {
    [sender removeFromSuperview];
}


- (void)viewDidUnload
{
    [self setDescriptionTextField:nil];
    [self setInstructionButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        return YES;
    }else {
        return NO;
    }
}

- (void)dealloc {
    [descriptionTextField release];
    [instructionButton release];
    [super dealloc];
}
@end
