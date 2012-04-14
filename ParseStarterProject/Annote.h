
#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Annote : NSObject <MKAnnotation>
{
}
@property (nonatomic, retain) NSString* companyId;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly, copy) NSString *title;
- (id) initWithCoordinate:(CLLocationCoordinate2D)coord title:(NSString*)titlestring subtitle:(NSString*)subtitlestring;
@end
