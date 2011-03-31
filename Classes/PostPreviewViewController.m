#import "PostPreviewViewController.h"
#import "WordPressAppDelegate.h"
#import "WPDataController.h"
#import "WPReachability.h"
#import "NSString+Helpers.h"

@interface PostPreviewViewController (Private)

- (void)addProgressIndicator;
- (NSString *)stringReplacingNewlinesWithBR:(NSString *)surString;
- (NSString *)buildSimplePreview:(NSString *)alertString;

@end

@implementation PostPreviewViewController

@synthesize postDetailViewController, webView;

#pragma mark -
#pragma mark Memory Management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Initialization code
		webView.delegate = self;
    }
    return self;
}
 

- (void)didReceiveMemoryWarning {
    WPLog(@"%@ %@", self, NSStringFromSelector(_cmd));
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark -
#pragma mark View Lifecycle Methods

- (void)viewDidLoad {
    [FileLogger log:@"%@ %@", self, NSStringFromSelector(_cmd)];
    [FlurryAPI logEvent:@"PostPreview"];
	webView.delegate = self;
	if (activityFooter == nil) {
		CGRect rect = CGRectMake(0, 0, 30, 30);
        activityFooter = [[UIActivityIndicatorView alloc] initWithFrame:rect];
        activityFooter.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        activityFooter.hidesWhenStopped = YES;
        activityFooter.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    }	
	
	[self.view addSubview:activityFooter];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	[self refreshWebView];
	if (DeviceIsPad())
		[activityFooter setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
	else
		[activityFooter setCenter:CGPointMake(self.view.center.x - 20, self.view.center.y - 20)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
	[webView stopLoading];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (DeviceIsPad() == YES) {
		return YES;
	}

    WordPressAppDelegate *delegate = (WordPressAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if ([delegate isAlertRunning] == YES)
        return NO;
    
    // Return YES for supported orientations
    return YES;
}


- (NSString *)buildSimplePreview:(NSString *)alertString {
	NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
	NSString *fpath = [NSString stringWithFormat:@"%@/defaultPostTemplate.html", resourcePath];
	NSString *str = [NSString stringWithContentsOfFile:fpath];
	
	if ([str length]) {
		
		//alert msg
		str = [str stringByReplacingOccurrencesOfString:@"!$alert_msg$!" withString:alertString];
		
		//Title
		NSString *title = postDetailViewController.apost.postTitle;
		title = (title == nil || ([title length] == 0) ? @"(no title)" : title);
		str = [str stringByReplacingOccurrencesOfString:@"!$title$!" withString:title];
		
		//Content
		NSString *desc = postDetailViewController.apost.content;
		if (!desc)
			desc = @"<h1>No Description available for this Post</h1>";else {
				desc = [self stringReplacingNewlinesWithBR:desc];
			}
		desc = [NSString stringWithFormat:@"<p>%@</p><br />", desc];
		str = [str stringByReplacingOccurrencesOfString:@"!$text$!" withString:desc];
		
		//Tags
		NSString *tags = postDetailViewController.post.tags;
		tags = (tags == nil ? @"" : tags);
		tags = [NSString stringWithFormat:@"Tags: %@", tags]; //desc = [NSString stringWithFormat:@"%@ \n <p>Tags: %@</p><br>", desc, tags];
		str = [str stringByReplacingOccurrencesOfString:@"!$mt_keywords$!" withString:tags];
		
		//Categories [selObjects count]
		NSArray *categories = [postDetailViewController.post.categories allObjects];
		NSString *catStr = @"";
		int i = 0, count = [categories count];
		for (i = 0; i < count; i++) {
			Category *category = [categories objectAtIndex:i];
			catStr = [catStr stringByAppendingString:category.categoryName];
			if(i < count-1)
				catStr = [catStr stringByAppendingString:@", "];
		}
		catStr = [NSString stringWithFormat:@"Categories: %@", catStr]; //desc = [NSString stringWithFormat:@"%@ \n <p>Categories: %@</p><br>", desc, catStr];
		str = [str stringByReplacingOccurrencesOfString:@"!$categories$!" withString:catStr];

	} else {
		str = @"";
	}
		
	return str;
}

#pragma mark -
#pragma mark Webkit View Delegate Methods

- (void)refreshWebView {
	
	BOOL edited = [self.postDetailViewController hasChanges];
	NSString *status = postDetailViewController.apost.status;
	
	//draft post
	BOOL isDraft = [self.postDetailViewController isAFreshlyCreatedDraft];
	BOOL isPrivate = NO;
	BOOL isPending = NO;
	
	if ([status isEqualToString:@"draft"])
		isDraft = YES;
	else if ([status isEqualToString:@"private"])
		isPrivate = YES;
	else if ([status isEqualToString:@"pending"])
		isPending = YES;
	
	if (edited) {
		[webView loadHTMLString:[self buildSimplePreview:@"Sorry, the post has changed, or it is not published. A simple preview is shown below."] baseURL:nil];
	} else {
		
		NSString *link = postDetailViewController.apost.permaLink;
		
		if([[WPReachability sharedReachability] internetConnectionStatus] == NotReachable) {
			[webView loadHTMLString:[self buildSimplePreview:@"Sorry, no connection to host. A simple preview is shown below."] baseURL:nil];
		} else if (link == nil ) {
			[webView loadHTMLString:[self buildSimplePreview:@"Sorry, the post has changed, or it is not published. A simple preview is shown below."] baseURL:nil];
		} else {
            
			/*checks if this a scheduled post*/
			NSDate *currentGMTDate = [DateUtils currentGMTDate];
			NSDate *postGMTDate = postDetailViewController.apost.date_created_gmt;
			NSDate *laterDate = [currentGMTDate laterDate:postGMTDate];
			
            //no onswipe!
            if ([postDetailViewController.apost.blog isWPcom]) {
                if ([link rangeOfString:@"?"].location == NSNotFound)
                    link = [link stringByAppendingString:@"?onswipe_opt=nay"];
                else
                    link = [link stringByAppendingString:@"%26onswipe_opt=nay"];
            }
            
			if(isDraft || isPending || isPrivate || (laterDate == postGMTDate)) {
                
				NSString *wpLoginURL = postDetailViewController.apost.blog.xmlrpc; 
				wpLoginURL = [wpLoginURL stringByReplacingOccurrencesOfRegex:@"/xmlrpc.php$" withString:@"/wp-login.php"];
				
				/*
				 i have used the blogURL and worked fine. but i preferred the xmlrpc url (that in most cases is on https).
				 
				if(![wpLoginURL hasPrefix:@"http"])
					wpLoginURL = [NSString stringWithFormat:@"http://%@/%@", postDetailViewController.apost.blog.url, @"wp-login.php"];
				else 
					wpLoginURL = [NSString stringWithFormat:@"%@/%@", postDetailViewController.apost.blog.url, @"wp-login.php"];
				
				*/
                
				NSURL *url = [NSURL URLWithString:wpLoginURL]; 
				NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
				[req setHTTPMethod:@"POST"];
				[req addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
				NSString *paramDataString = [NSString stringWithFormat:@"%@=%@&%@=%@&%@=%@", 
											 @"log", postDetailViewController.apost.blog.username,
											 @"pwd", [[[WPDataController sharedInstance] passwordForBlog:postDetailViewController.apost.blog] stringByUrlEncoding],
											 @"redirect_to", link];
			
				NSData *paramData = [paramDataString dataUsingEncoding:NSUTF8StringEncoding]; 
				[req setHTTPBody: paramData];
				[webView loadRequest:req];

			} else {
				[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:link]]];
			}
		}
	}
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[activityFooter startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)awebView {
	[activityFooter stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
	[activityFooter stopAnimating];
}

- (BOOL)webView:(UIWebView *)awebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
    //return isWebRefreshRequested || postDetailViewController.navigationItem.rightBarButtonItem != nil;
}

#pragma mark -

- (NSString *)stringReplacingNewlinesWithBR:(NSString *)surString {
    NSArray *comps = [surString componentsSeparatedByString:@"\n"];
    return [comps componentsJoinedByString:@"<br>"];
}


#pragma mark -
#pragma mark Dealloc

- (void)dealloc {
	[webView stopLoading];
	webView.delegate = nil;
	[webView release]; webView = nil;
    [activityFooter release];
    [super dealloc];
}
@end