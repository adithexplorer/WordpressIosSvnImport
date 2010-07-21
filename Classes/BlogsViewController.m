#import "BlogsViewController.h"

@interface BlogsViewController (Private)

- (void)showBlogDetailModalViewForNewBlog:(id)inSender;
- (void)showBlogDetailModalViewWithAnimation:(BOOL)animate;
- (void)showBlogWithoutAnimation;
- (void)edit:(id)sender;
- (void)cancel:(id)sender;
- (BOOL)canChangeCurrentBlog;
@end

@implementation BlogsViewController
@synthesize appDelegate;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    self.title = NSLocalizedString(@"Blogs", @"RootViewController_Title");
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
																							target:self
																							action:@selector(showAddBlogView:)] autorelease];
    self.tableView.allowsSelectionDuringEditing = YES;
	appDelegate = [WordPressAppDelegate sharedWordPressApp];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blogsRefreshNotificationReceived:) name:@"BlogsRefreshNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showBlogWithoutAnimation) name:@"NewBlogAdded" object:nil];
    
	// restore blog for iPad
	if (DeviceIsPad() == YES) {
		if (appDelegate.shouldLoadBlogFromUserDefaults) {
			[self showBlog:NO];
		}
	}
}

- (void)viewDidDisappear:(BOOL)animated {
    [self cancel:self];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[[WordPressAppDelegate sharedWordPressApp] resetCurrentBlogInUserDefaults];
	//[[WordPressAppDelegate sharedWordPressApp] setAutoRefreshMarkers];
}

- (void)viewWillAppear:(BOOL)animated {
	if([[BlogDataManager sharedDataManager] countOfBlogs] > 0)
		self.navigationItem.leftBarButtonItem = self.editButtonItem;
	[self.tableView reloadData];
	[self.tableView endEditing:YES];
}

- (void)blogsRefreshNotificationReceived:(id)notification {
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableView Delegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[BlogDataManager sharedDataManager] countOfBlogs];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BlogCell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
#if defined __IPHONE_3_0
    cell.textLabel.text = [NSString decodeXMLCharactersIn:[[[BlogDataManager sharedDataManager] blogAtIndex:(indexPath.row)] valueForKey:@"blogName"]];
    cell.imageView.image = [[[[Blog alloc] initWithIndex:indexPath.row] autorelease] favicon];
#else if defined __IPHONE_2_0
    cell.text = [NSString decodeXMLCharactersIn:[[[BlogDataManager sharedDataManager] blogAtIndex:(indexPath.row)] valueForKey:@"blogName"]];
    cell.image = [[[[Blog alloc] initWithIndex:indexPath.row] autorelease] favicon];
#endif

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    return cell;
}

- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//	if (DeviceIsPad() == YES)
//		[[CPopoverManager instance] setCurrentPopoverController:NULL];

    BlogDataManager *dataManager = [BlogDataManager sharedDataManager];

    if ([self.tableView cellForRowAtIndexPath:indexPath].editing) {
        [[BlogDataManager sharedDataManager] copyBlogAtIndexCurrent:(indexPath.row)];
        [self showBlogDetailModalViewWithAnimation:YES];
		
    } else {
        //if ([[[dataManager blogAtIndex:indexPath.row] valueForKey:@"kIsSyncProcessRunning"] intValue] == 1) {
        //    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        //} else {
			if ([self canChangeCurrentBlog]) {
				[dataManager makeBlogAtIndexCurrent:(indexPath.row)];
				[self showBlog:YES];
			}
        //}
    }
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [self canChangeCurrentBlog]) {
        [[BlogDataManager sharedDataManager] makeBlogAtIndexCurrent:indexPath.row];
        [[BlogDataManager sharedDataManager] removeCurrentBlog];

        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];

        if ([[BlogDataManager sharedDataManager] countOfBlogs] == 0) {
            self.navigationItem.leftBarButtonItem = nil;
        }
    }
}

- (void)edit:(id)sender {
	if ([self canChangeCurrentBlog]) {
		UIBarButtonItem *cancelButton = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
																		  style:UIBarButtonItemStyleDone
																		 target:self
																		 action:@selector(cancel:)] autorelease];
		[self.navigationItem setLeftBarButtonItem:cancelButton animated:YES];
		[self.tableView setEditing:YES animated:YES];
	}
}

- (void)cancel:(id)sender {
    UIBarButtonItem *editButton = [[[UIBarButtonItem alloc] initWithTitle:@"Edit"
																	style:UIBarButtonItemStylePlain
																   target:self
																   action:@selector(edit:)] autorelease];
    [self.navigationItem setLeftBarButtonItem:editButton animated:YES];
    [self.tableView setEditing:NO animated:YES];
}

#pragma mark -
#pragma mark Custom methods

- (BOOL)canChangeCurrentBlog {
	if ([UIApplication sharedApplication].networkActivityIndicatorVisible) {
		UIAlertView *currentlyUpdatingAlert = [[UIAlertView alloc] initWithTitle:@"Currently Syncing" message:@"Please wait a few seconds and try again" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[currentlyUpdatingAlert show];
		[currentlyUpdatingAlert release];
		return NO;
	}
	return YES;
}


- (void)showBlogDetailModalViewForNewBlog:(id)inSender {
    [self showBlogDetailModalViewForNewBlogWithAnimation:YES];
}

- (void)showAddBlogView:(id)sender {
	WelcomeViewController *welcomeView = [[WelcomeViewController alloc] initWithNibName:@"WelcomeViewController" bundle:nil];
	[self.navigationController pushViewController:welcomeView animated:YES];
	[welcomeView release];
}

- (void)showBlogDetailModalViewForNewBlogWithAnimation:(BOOL)animate {
	if ([self canChangeCurrentBlog]) {
		[[BlogDataManager sharedDataManager] makeNewBlogCurrent];
		[self showBlogDetailModalViewWithAnimation:animate];
	}
}

- (void)showBlogDetailModalViewWithAnimation:(BOOL)animate {
	
	EditBlogViewController *blogDetailViewController = [[[EditBlogViewController alloc] initWithNibName:@"EditBlogViewController" bundle:nil] autorelease];
	UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:blogDetailViewController];
	if (DeviceIsPad() == YES)
	{
		modalNavigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		modalNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
		[[CPopoverManager instance] setCurrentPopoverController:NULL];
		[[WordPressAppDelegate sharedWordPressApp].splitViewController presentModalViewController:modalNavigationController animated:animate];
	}
	else
	{
		[[WordPressAppDelegate sharedWordPressApp].navigationController presentModalViewController:modalNavigationController animated:animate];
	}
	
	
	[modalNavigationController release];
}

- (void)showBlogWithoutAnimation {
    [self showBlog:NO];
}

- (void)showBlog:(BOOL)animated {
    BlogDataManager *dataManager = [BlogDataManager sharedDataManager];
    NSString *url = [dataManager.currentBlog valueForKey:@"url"];
	
    if (url != nil &&[url length] >= 7 &&[url hasPrefix:@"http://"]) {
        url = [url substringFromIndex:7];
    }
	
    if (url != nil &&[url length]) {
        url = @"wordpress.com";
    }
	
    [Reachability sharedReachability].hostName = url;
	
	BlogViewController *blogViewController = [[BlogViewController alloc] initWithNibName:@"BlogViewController" bundle:nil];
	[self.navigationController pushViewController:blogViewController animated:animated];
	[blogViewController release];
}

#pragma mark -
#pragma mark Memory Management

- (void)didReceiveMemoryWarning {
    WPLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"BlogsRefreshNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NewBlogAdded" object:nil];
    [super dealloc];
}

@end
