//  Created by Jason Morrissey
#import "LKBadgeView.h"
#import "JMTabView.h"
#import "JMTabContainer.h"
#import "BarBackgroundLayer.h"
#import "UIView+Positioning.h"

@interface JMTabView()
@property (nonatomic,retain) JMTabContainer * tabContainer;
- (void)centraliseSubviews;
@end

@implementation JMTabView
@synthesize segmentIndex;
@synthesize tabContainer = tabContainer_;
@synthesize delegate = delegate_;

- (void)dealloc;
{
    self.tabContainer = nil;
    self.delegate = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        segmentIndex =0;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.tabContainer = [[[JMTabContainer alloc] initWithFrame:self.bounds]autorelease] ;
        [self addSubview:self.tabContainer];
    }
    return self;
}

- (void)setBackgroundLayer:(CALayer *)backgroundLayer;
{
        NSLog(@"obj at index here on self.layer sublayers");
    CALayer * oldBackground = [[self.layer sublayers] objectAtIndex:0];
    if (oldBackground)
    {
        [self.layer replaceSublayer:oldBackground with:backgroundLayer];
    }
    else
    {
        [self.layer insertSublayer:backgroundLayer atIndex:0];
    }
    
}

- (void)layoutSubviews;
{
 //   [self.tabContainer centerInSuperView];
}
- (void)centraliseSubviews;
{
    [self.tabContainer centerInSuperView];
}
#pragma Mark -
#pragma Mark Notifying Delegates

- (void)didSelectItemAtIndex:(NSUInteger)itemIndex;
{
    if (self.delegate)
    {
        NSLog(@"selectedindex = %d, %d",segmentIndex,itemIndex);
        if (!(segmentIndex==itemIndex)){
            segmentIndex = itemIndex;
        [self.delegate tabView:self didSelectTabAtIndex:itemIndex];
        }else{
            
        }
        
    }
}

#pragma Mark -
#pragma External Interface

- (void)setMomentary:(BOOL)momentary;
{
    [self.tabContainer setMomentary:momentary];
}

- (void)addTabItem:(JMTabItem *)tabItem;
{
    [self.tabContainer addTabItem:tabItem];
    [tabItem release];
}

- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon;
{
    JMTabItem * tabItem = [JMTabItem tabItemWithTitle:title icon:icon];
    
    [self addTabItem:tabItem];

}
- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon badge:(LKBadgeView*)badge
{
    JMTabItem * tabItem = [JMTabItem tabItemWithTitle:title icon:icon];
    [tabItem addSubview:badge];
    [self addTabItem:tabItem];

}
#if NS_BLOCKS_AVAILABLE
- (void)addTabItemWithTitle:(NSString *)title icon:(UIImage *)icon executeBlock:(JMTabExecutionBlock)executeBlock;
{
    JMTabItem * tabItem = [JMTabItem tabItemWithTitle:title icon:icon executeBlock:executeBlock];
    [self addTabItem:tabItem];

}
#endif

- (void)setSelectedIndex:(NSUInteger)itemIndex;
{
    NSLog(@"set selected index");
   
    [self.tabContainer layoutSubviews];
    [self.tabContainer animateSelectionToItemAtIndex:itemIndex];
     
}

#pragma Mark -
#pragma Customisation

- (void)setSelectionView:(JMSelectionView *)selectionView;
{
    [[self.tabContainer selectionView] removeFromSuperview];
    [self.tabContainer setSelectionView:selectionView];
    [self.tabContainer insertSubview:selectionView atIndex:0];
    [selectionView release];
}

- (void)setItemSpacing:(CGFloat)itemSpacing;
{
    [self.tabContainer setItemSpacing:itemSpacing];
    [self.tabContainer setNeedsLayout];
}

@end
