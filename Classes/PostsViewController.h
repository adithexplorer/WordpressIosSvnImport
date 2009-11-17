#import <Foundation/Foundation.h>
#import "RefreshButtonView.h"

#define newPost 0
#define editPost 1
#define autorecoverPost 2
#define refreshPost 3

@class BlogDataManager, PostViewController, EditPostViewController;

@interface PostsViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate> {
@private
    UIBarButtonItem *newButtonItem;

//    IBOutlet UITableView *postsTableView;

    PostViewController *postDetailViewController;
    EditPostViewController *postDetailEditController;
    RefreshButtonView *refreshButton;
	UIAlertView *progressAlert;
}

@property (readonly) UIBarButtonItem *newButtonItem;
@property (nonatomic, retain) PostViewController *postDetailViewController;
@property (nonatomic, retain) EditPostViewController *postDetailEditController;

@end
