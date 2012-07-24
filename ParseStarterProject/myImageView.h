// MyImageView.h
#import <UIKit/UIKit.h>

@interface myImageView : UIView {
    UIImageView *               _imageView;
}

@property (nonatomic, assign)       UIImage *                   image;

@end