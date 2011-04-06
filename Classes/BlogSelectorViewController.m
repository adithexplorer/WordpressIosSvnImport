//
//  BlogSelectorViewController.m
//  WordPress
//
//  Created by Jorge Bernal on 4/6/11.
//  Copyright 2011 WordPress. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BlogSelectorViewController.h"
#import "WordPressAppDelegate.h"
#import "BlogsTableViewCell.h"
#import "WPAsynchronousImageView.h"
#import "NSString+XMLExtensions.h" 

@interface BlogSelectorViewController (PrivateMethods)
- (NSFetchedResultsController *)resultsController;
@end

@implementation BlogSelectorViewController
@synthesize delegate;
@synthesize selectedBlog;

- (void)dealloc
{
    [FileLogger log:@"%@ %@", self, NSStringFromSelector(_cmd)];
    self.selectedBlog = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [FileLogger log:@"%@ %@", self, NSStringFromSelector(_cmd)];
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [FileLogger log:@"%@ %@", self, NSStringFromSelector(_cmd)];
    NSError *error = nil;
    [[self resultsController] performFetch:&error];
    [super viewDidLoad];
    NSLog(@"Blog selector delegate: %@", self.tableView.delegate);
    NSLog(@"Blog selector dataSource: %@", self.tableView.dataSource);
}

- (void)viewDidUnload
{
    [FileLogger log:@"%@ %@", self, NSStringFromSelector(_cmd)];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[resultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    sectionInfo = [[resultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BlogCell";
    BlogsTableViewCell *cell = (BlogsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    Blog *blog = [resultsController objectAtIndexPath:indexPath];
    
    CGRect frame = CGRectMake(8,8,35,35);
    WPAsynchronousImageView* asyncImage = [[[WPAsynchronousImageView alloc]
                                            initWithFrame:frame] autorelease];
    
    if (cell == nil) {
        cell = [[[BlogsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
        [cell.imageView removeFromSuperview];
    }
    else {
        WPAsynchronousImageView* oldImage = (WPAsynchronousImageView*)[cell.contentView viewWithTag:999];
        [oldImage removeFromSuperview];
    }
    
    asyncImage.isBlavatar = YES;
    if ([blog isWPcom])
        asyncImage.isWPCOM = YES;
	asyncImage.layer.cornerRadius = 4.0;
	asyncImage.layer.masksToBounds = YES;
	asyncImage.tag = 999;
	NSURL* url = [blog blavatarURL];
	[asyncImage loadImageFromURL:url];
	[cell.contentView addSubview:asyncImage];
	
    cell.textLabel.text = [NSString decodeXMLCharactersIn:[blog blogName]];
    cell.detailTextLabel.text = [blog hostURL];
    
    if ([blog isEqual:self.selectedBlog]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Blog *blog = [resultsController objectAtIndexPath:indexPath];
    self.selectedBlog = blog;
    [self.delegate blogSelectorViewController:self didSelectBlog:blog];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

#pragma mark - Fetched results controller delegate

- (NSFetchedResultsController *)resultsController {
    if (resultsController != nil) {
        return resultsController;
    }
    
    WordPressAppDelegate *appDelegate = [WordPressAppDelegate sharedWordPressApp];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Blog" inManagedObjectContext:appDelegate.managedObjectContext]];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"blogName" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // For some reasons, the cache sometimes gets corrupted
    // Since we don't really use sections we skip the cache here
    resultsController = [[NSFetchedResultsController alloc]
                                                       initWithFetchRequest:fetchRequest
                                                       managedObjectContext:appDelegate.managedObjectContext
                                                         sectionNameKeyPath:nil
                                                                  cacheName:nil];
    resultsController.delegate = self;
    
    [fetchRequest release];
    [sortDescriptor release]; sortDescriptor = nil;
    [sortDescriptors release]; sortDescriptors = nil;
    
    return resultsController;
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    [self.tableView reloadData];
}

@end
