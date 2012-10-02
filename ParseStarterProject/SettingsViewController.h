//
//  SettingsViewController.h
//  PsychedApp
//
//  Created by HengHong Lee on 25/4/12.
//  Copyright (c) 2012 Psyched!. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UIViewController
-(IBAction)dismissSettings:(id)sender;
@property (retain, nonatomic) IBOutlet UISlider *distanceSlider;
@property (retain, nonatomic) IBOutlet UILabel *distanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *LoggedInUser;
@property (retain, nonatomic) IBOutlet UISwitch *OGswitch;
@end
