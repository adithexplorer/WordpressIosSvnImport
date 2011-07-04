//
//  AboutViewController.h
//  WordPress
//-
//  Created by Dan Roundhill on 2/15/11.
//  Copyright 2011 WordPress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WordPressAppDelegate.h"

@interface AboutViewController : UIViewController <MFMailComposeViewControllerDelegate> {
}
-(IBAction)viewTermsOfService:(id)sender;
-(IBAction)viewPrivacyPolicy:(id)sender;
-(IBAction)viewWebsite:(id)sender;

@end
