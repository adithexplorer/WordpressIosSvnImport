//
//  EditPageViewController.h
//  WordPress
//
//  Created by Janakiram on 01/11/08.
//

#import <UIKit/UIKit.h>
#import "CustomFieldsTableView.h"

@class WPNavigationLeftButtonView;
@class WPSelectionTableViewController;
@class PagePhotosViewController;
@class WPPhotosListViewController;

@interface EditPageViewController : UIViewController<UIActionSheetDelegate, UITextViewDelegate>  {
	IBOutlet UITextView *pageContentTextView;
	IBOutlet UITextField *titleTextField;
	IBOutlet UIView *contentView;
	IBOutlet UIView *subView;
	IBOutlet UITextField *statusTextField;
	IBOutlet UITextField *categoriesTextField;
	IBOutlet UILabel *statusLabel;
	IBOutlet UILabel *categoriesLabel;
	IBOutlet UILabel *titleLabel;
	IBOutlet UIView *textViewContentView;
	IBOutlet UITextField *textViewPlaceHolderField;
	IBOutlet UITableViewCell *customFieldsEditCell;
	
	UITextField *infoText;
	UITextField *urlField;
	WPSelectionTableViewController *selectionTableViewController;
	PagePhotosViewController *pageDetailsController;
	
	CustomFieldsTableView *customFieldsTableView;
	WPPhotosListViewController *photosListController;
	
	BOOL dismiss;
	BOOL isEditing;
	int mode;	//0 new, 1 edit, 2 autorecovery, 3 refresh
	BOOL hasChanges;
	BOOL isTextViewEditing;
	NSRange selectedLinkRange;
	UITextField *currentEditingTextField;
	BOOL isCustomFieldsEnabledForThisPage;
	
	//also for Custom Fields to move text view up and down appropriately
	NSUInteger originY;
}

@property (nonatomic, retain) PagePhotosViewController *pageDetailsController;
@property (nonatomic, retain) WPSelectionTableViewController *selectionTableViewController;
@property (nonatomic) int mode;
@property (nonatomic, retain) CustomFieldsTableView *customFieldsTableView;
@property (nonatomic, assign) WPPhotosListViewController *photosListController;
@property (nonatomic, retain) UITextField *infoText;
@property (nonatomic, retain) UITextField *urlField;
@property (nonatomic) NSRange selectedLinkRange;
@property (nonatomic, assign) UITextField *currentEditingTextField;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isCustomFieldsEnabledForThisPage;

@property (nonatomic, retain) UITableViewCell *customFieldsEditCell;


- (IBAction)showStatusViewAction:(id)sender;
- (IBAction)showCustomFieldsTableView:(id)sender;
- (void) populateCustomFieldsTableViewControllerWithCustomFields;
- (void)endEditingAction:(id)sender;
- (void)refreshUIForCurrentPage;
- (void)refreshUIForNewPage;

- (NSString *)validateNewLinkInfo:(NSString *)urlText;
- (void)showLinkView;
- (void)setTextViewHeight:(float)height;


#pragma mark -
#pragma mark Custom Fields Methods

- (BOOL) checkCustomFieldsMinusMetadata;
- (void)  postionTextViewContentView;

#pragma mark -
#pragma mark Custom Fields Methods

- (BOOL) checkCustomFieldsMinusMetadata;
- (void)  postionTextViewContentView;

@end
