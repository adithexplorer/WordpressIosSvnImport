//
//  ReplyToCommentViewController.m
//  WordPress
//
//  Created by John Bickerstaff on 12/20/09.
//  
//

#import "ReplyToCommentViewController.h"
#import "BlogDataManager.h"
#import "WPProgressHUD.h"
#import "WPReachability.h"

NSTimeInterval kAnimationDuration2 = 0.3f;

@interface ReplyToCommentViewController (Private)

- (BOOL)isConnectedToHost;
- (void)initiateSaveCommentReply:(id)sender;
- (void)saveReplyBackgroundMethod:(id)sender;
- (void)callBDMSaveCommentReply:(SEL)selector;
- (void)endTextEnteringButtonAction:(id)sender;
- (void)testStringAccess;
-(void) receivedRotate: (NSNotification*) notification;


@end



@implementation ReplyToCommentViewController

@synthesize commentViewController, saveButton, doneButton, comment;
@synthesize cancelButton, label, hasChanges, textViewText, isTransitioning;

//TODO: Make sure to give this class a connection to commentDetails and currentIndex from CommentViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


- (void)testStringAccess{
	//NSLog(@"%@",foo);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	//foo = [[NSString alloc] initWithString: textView.text];
		
	if (!saveButton) {
	saveButton = [[UIBarButtonItem alloc] 
				  initWithTitle:@"Reply" 
				  style:UIBarButtonItemStyleDone
				  target:self 
				  action:@selector(initiateSaveCommentReply:)];
	}
	
}


- (void)viewWillAppear:(BOOL)animated {
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];

	
	self.hasChanges = NO;
	//foo = textView.text;//so we can compare to set hasChanges correctly
	textViewText = [[NSString alloc] initWithString: textView.text];
	cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelView:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
    [cancelButton release];
	cancelButton = nil;
	
	if ([self.comment.status isEqualToString:@"hold"]) {
		label.backgroundColor = PENDING_COMMENT_TABLE_VIEW_CELL_BACKGROUND_COLOR;
		label.hidden = NO;
	} else {
		label.hidden = YES;
		//TODO: JOHNB - code movement of text view upward if this is not a pending comment
		
	}
	
	[textView becomeFirstResponder];
	[self testStringAccess];
}

-(void) viewWillDisappear: (BOOL) animated{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[saveButton release];
	saveButton = nil;
	[doneButton release];
	doneButton = nil;
	[cancelButton release];
	cancelButton = nil;
	self.comment = nil;
	[textViewText release];
	textViewText = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Button Override Methods

- (void)cancelView:(id)sender {
    [commentViewController cancelView:self];
}

#pragma mark -
#pragma mark Helper Methods

- (void)test {
	NSLog(@"inside replyTOCommentViewController:test");
}

- (void)endTextEnteringButtonAction:(id)sender {
    [textView resignFirstResponder];
	UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		isTransitioning = YES;
		UIViewController *garbageController = [[[UIViewController alloc] init] autorelease]; 
		[self.navigationController pushViewController:garbageController animated:NO]; 
		[self.navigationController popViewControllerAnimated:NO];
		self.isTransitioning = NO;
		[textView resignFirstResponder];	
	}
}

- (void)setTextViewHeight:(float)height {
	[UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kAnimationDuration2];
    CGRect frame = textView.frame;
    frame.size.height = height;
    textView.frame = frame;
	[UIView commitAnimations];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (self.isTransitioning){
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
    else
        return YES;
}

-(void) receivedRotate: (NSNotification*) notification
{
	UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	if(UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
		if (DeviceIsPad())
			[self setTextViewHeight:360];
		else
			[self setTextViewHeight:130];
	}
	else {
		if (DeviceIsPad())
			[self setTextViewHeight:510];
		else
			[self setTextViewHeight:440];
	}
}
#pragma mark -
#pragma mark Text View Delegate Methods




- (void)textViewDidEndEditing:(UITextView *)aTextView {
	NSString *textString = textView.text;
	if (![textString isEqualToString:textViewText]) {
		self.hasChanges=YES;
	}
	
	//make the text view longer !!!! 
	[self setTextViewHeight:460];
	
	if (DeviceIsPad() == NO) {
		self.navigationItem.leftBarButtonItem =
		[[UIBarButtonItem alloc] initWithTitle:@"Cancel"
										 style: UIBarButtonItemStyleBordered
										target:self
										action:@selector(cancelView:)];
	}
}

- (void)textViewDidBeginEditing:(UITextView *)aTextView {
	
	
	
	self.navigationItem.rightBarButtonItem = saveButton;
	
	if (DeviceIsPad() == NO) {
		doneButton = [[UIBarButtonItem alloc] 
									   initWithTitle:@"Done" 
									   style:UIBarButtonItemStyleDone 
									   target:self 
									   action:@selector(endTextEnteringButtonAction:)];
		
		[self.navigationItem setLeftBarButtonItem:doneButton];
	}
}


//replace "&nbsp" with a space @"&#160;" before Apple's broken TextView handling can do so and break things
//this enables the "http helper" to work as expected
//important is capturing &nbsp BEFORE the semicolon is added.  Not doing so causes a crash in the textViewDidChange method due to array overrun
- (BOOL)textView:(UITextView *)aTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	//if nothing has been entered yet, return YES to prevent crash when hitting delete
	
    if (text.length == 0) {
		return YES;
    }
	
    // create final version of textView after the current text has been inserted
    NSMutableString *updatedText = [[NSMutableString alloc] initWithString:aTextView.text];
    [updatedText insertString:text atIndex:range.location];
	
    NSRange replaceRange = range, endRange = range;
	
    if (text.length > 1) {
        // handle paste
        replaceRange.length = text.length;
    } else {
        // handle normal typing
        replaceRange.length = 6;  // length of "&#160;" is 6 characters
        replaceRange.location -= 5; // look back one characters (length of "&#160;" minus one)
    }
	
    // replace "&nbsp" with "&#160;" for the inserted range
    int replaceCount = [updatedText replaceOccurrencesOfString:@"&nbsp" withString:@"&#160;" options:NSCaseInsensitiveSearch range:replaceRange];
	
    if (replaceCount > 0) {
        // update the textView's text
        aTextView.text = updatedText;
		
        // leave cursor at end of inserted text
        endRange.location += text.length + replaceCount * 1; // length diff of "&nbsp" and "&#160;" is 1 character
        aTextView.selectedRange = endRange; 
		
        [updatedText release];
		updatedText = nil;
		
        // let the textView know that it should ingore the inserted text
        return NO;
    }
	
    [updatedText release];
	updatedText = nil;
	
    // let the textView know that it should handle the inserted text
    return YES;
}


#pragma mark -
#pragma mark Comment Handling Methods

- (BOOL)isConnectedToHost {
    if (![[WPReachability sharedReachability] remoteHostStatus] != NotReachable) {
        UIAlertView *connectionFailAlert = [[UIAlertView alloc] initWithTitle:@"Connection Problem"
																	  message:@"The internet connection appears to be offline."
																	 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [connectionFailAlert show];
        [connectionFailAlert release];
        return NO;
    }
	
    return YES;
}

- (void)initiateSaveCommentReply:(id)sender {
	//we should call endTextEnteringButtonAction here, bc if you click on reply without clicking on the 'done' btn
	//within the keyboard, the textViewDidEndEditing is never called
	[self endTextEnteringButtonAction: sender];
	if(hasChanges == NO) {
		UIAlertView *connectionFailAlert = [[UIAlertView alloc] initWithTitle:@"Error."
																	  message:@"Please type a comment."
																	 delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [connectionFailAlert show];
        [connectionFailAlert release];
		return;
	}
	
    progressAlert = [[WPProgressHUD alloc] initWithLabel:@"Sending Reply..."];
    [progressAlert show];
    self.comment.content = textView.text;
    [self performSelectorInBackground:@selector(saveReplyBackgroundMethod:) withObject:nil];
}

- (void)saveReplyBackgroundMethod:(id)sender {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	BOOL res = NO;
    if ([self isConnectedToHost]) {
        res = [self.comment upload];
    }
    [progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    [progressAlert release];
    progressAlert = nil;
	if(res) {
		hasChanges = NO;
		[commentViewController performSelectorOnMainThread:@selector(dismissEditViewController) withObject:nil waitUntilDone:YES];
	} else {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"CommentUploadFailed" object:@"Sorry, something went wrong during comments moderation. Please try again."];	
	}
	
    [pool release];
}


@end
