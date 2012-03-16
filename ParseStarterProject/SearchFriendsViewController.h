

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"
#import "Parse/Parse.h"
@interface SearchFriendsViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,PF_FBRequestDelegate,UISearchBarDelegate>
{
    int currentAPIcall;
}
@property (retain,nonatomic)PFUser* selectedUser;
@property (retain, nonatomic) IBOutlet UITableView *searchTable;
@property (retain,nonatomic) NSMutableArray* searchArray;
@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (retain,nonatomic) NSMutableArray* tempArray;
@property (retain,nonatomic) NSMutableArray* followedArray;
@property (nonatomic, retain) PF_FBRequest *myRequest;
@property (retain, nonatomic) IBOutlet UIView *emptyView;
@end
