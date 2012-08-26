//  Created by Jason Morrissey

#import <UIKit/UIKit.h>
#import "JMTabConstants.h"
#import "JMTabItem.h"
#import "JMSelectionView.h"
#import "LKBadgeView.h"
@class JMTabView;

#pragma Mark -
#pragma Mark - JMTabViewDelegate

@protocol JMTabViewDelegate <UIScrollViewDelegate>
-(void)tabView:(JMTabView *)tabView didSelectTabAtIndex:(NSUInteger)itemIndex;


@end

#pragma Mark -
#pragma Mark - JMTabView

@interface JMTabView : UIScrollView 
- (void)centraliseSubviews;
- (void)setMomentary:(BOOL)momentary;
- (void)didSelectItemAtIndex:(NSUInteger)itemIndex;
- (void)addTabItem:(JMTabItem *)tabItem;
- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon;
- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon badge:(LKBadgeView*)badge;
- (void)setSelectedIndex:(NSUInteger)itemIndex;
@property (nonatomic,assign) id<JMTabViewDelegate> delegate;
@property (nonatomic,assign) NSInteger segmentIndex;

#if NS_BLOCKS_AVAILABLE
- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon executeBlock:(JMTabExecutionBlock)executeBlock;
#endif

#pragma Mark -
#pragma Mark - Customisation

- (void)setSelectionView:(JMSelectionView *)selectionView;
- (void)setItemSpacing:(CGFloat)itemSpacing;
- (void)setBackgroundLayer:(CALayer *)backgroundLayer;


@end
