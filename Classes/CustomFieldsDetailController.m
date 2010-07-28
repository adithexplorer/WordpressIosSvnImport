//
//  CustomFieldsDetailController.m
//  WordPress
//
//  Created by John Bickerstaff on 5/8/09.
//  
//

#import "CustomFieldsDetailController.h"

@implementation CustomFieldsDetailController

//@synthesize keyField, valueField, idField;
@synthesize leftView;
@synthesize textFieldBeingEdited;
@synthesize customFieldsDict;
@synthesize postDetailViewController, pageDetailsController, dm;
@synthesize isPost = _isPost;

#pragma mark -

- (IBAction)cancel:(id)sender {
    //this may be handled by the inherited navigation bar, we'll see...
}

- (IBAction)save:(id)sender {
    //if we implement this, this is where we'd "really" save
    //also note the stanza on pate 286 that handles popping the view controller
    //and reloading data - although we're doing that in CustomFieldsTableView
}

- (IBAction)textFieldDone:(id)sender {
    if (self.textFieldBeingEdited != nil) {
        [self textFieldDidEndEditing:textFieldBeingEdited];
        self.textFieldBeingEdited = nil;
    }

    [self writeCustomFieldsToCurrentPostOrPageUsingID];
    [sender resignFirstResponder];
}

#pragma mark -

- (void)viewDidLoad {
    self.title = @"Edit Custom Field";
    //possibly the cancel button here
    //possibly the save button here (see 286-289)
    [saveButtonItem retain];

    [super viewDidLoad];
}

- (void)viewWillAppear {
    [self.tableView reloadData];
    [super viewWillAppear:YES];
}

- (void)dealloc {
    [textFieldBeingEdited release];
	[leftView release];
    //[customFieldsDict release];
    [super dealloc];
}

#pragma mark  -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfEditableRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];

        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 75, 25)];
        label.textAlignment = UITextAlignmentLeft;
        label.tag = kLabelTag;
        label.font = [UIFont boldSystemFontOfSize:18];
        [cell.contentView addSubview:label];
        [label release];

        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(70, 12, 200, 25)];
        textField.clearsOnBeginEditing = NO;
        [textField setDelegate:self];
        //textField.returnKeyType = UIReturnKeyDone;
        [textField addTarget:self
         action:@selector(textFieldDone:)
         forControlEvents:UIControlEventEditingDidEndOnExit];
        [cell.contentView addSubview:textField];
    }

    NSUInteger row = [indexPath row];

    UILabel *label = (UILabel *)[cell viewWithTag:kLabelTag];

    //this won't work, it needs to be different...
    //label.text = [fieldLabels objectAtIndex:row];
    if (row == 0) {
        label.text = @"Name";
    } else if (row == 1) {
        label.text = @"Value";
    }

    UITextField *textField = nil;

    for (UIView *oneView in cell.contentView.subviews) {
        if ([oneView isMemberOfClass:[UITextField class]])
            textField = (UITextField *)oneView;
    }

    if (row == 0) {
        textField.text = [customFieldsDict valueForKey:@"key"];
    } else if (row == 1) {
        textField.text = [customFieldsDict valueForKey:@"value"];
    }

    if (textFieldBeingEdited == textField)
        textFieldBeingEdited = nil;

    textField.tag = row;

    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (NSIndexPath *)tableView:(UITableView *)tableView
willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark Text Field Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textFieldBeingEdited = textField;

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone
                                   target:self action:@selector(textFieldDone:)];
    postDetailViewController.navigationItem.leftBarButtonItem = doneButton;
    [doneButton release];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    dm = [BlogDataManager sharedDataManager];
    self.textFieldBeingEdited = nil;

    if (textField.tag == 0) {
        [customFieldsDict setValue:textField.text forKey:@"key"];
        [dm printDictToLog:customFieldsDict andDictName:@"test from textFieldDidEndEditing, CustomFieldsEditView... isn't it key and value"];
    } else if (textField.tag == 1) {
        [customFieldsDict setValue:textField.text forKey:@"value"];
        [dm printDictToLog:customFieldsDict andDictName:@"test from textFieldDidEndEditing, CustomFieldsEditView... isn't it key and value"];
    }

    postDetailViewController.hasChanges = YES;
    pageDetailsController.hasChanges = YES;
    self.navigationItem.rightBarButtonItem = saveButtonItem;
}

#pragma mark -
#pragma mark Data Handling Methods (load, save, etc)

- (void)loadData:(NSDictionary *)theDict andNewCustomFieldBool:(BOOL)theBool {
    isNewCustomField = theBool;
    customFieldsDict = [[NSMutableDictionary alloc] initWithDictionary:theDict];
    [self.tableView reloadData];
}

- (void)writeCustomFieldsToCurrentPostOrPageUsingID {
    NSString *testStringName = [customFieldsDict valueForKey:@"key"];

    //NSString * testStringValue = [customFieldsDict valueForKey:@"value"];
    if ([testStringName isEqualToString:@""]) {
        return;
    }

    //both parts of the if / else statement uses these
    dm = [BlogDataManager sharedDataManager];
    NSMutableArray *tempCustomFieldsArray = nil;

    if (_isPost == YES) {
        tempCustomFieldsArray = [dm.currentPost valueForKey:@"custom_fields"];
    } else if (_isPost == NO) {
        tempCustomFieldsArray = [dm.currentPage valueForKey:@"custom_fields"];
    }

    NSString *ID = [customFieldsDict valueForKey:@"id"];
    if (tempCustomFieldsArray.count >= 1) {
        int dictsCount = [tempCustomFieldsArray count];

        for (int i = 0; i < dictsCount; i++) {
            //if the match for ID is found in this particular dict inside the array
            if ([[tempCustomFieldsArray objectAtIndex:i] objectForKey:@"id"] == ID) {
                //replace the dict in the array with customFieldsDict (which holds any new values)
                [tempCustomFieldsArray replaceObjectAtIndex:i withObject:customFieldsDict];
            }
        }

        //replace the custom_fields array in currentPost or currentPage with tempCustomFieldsArray (which should persist the new values in memory)
        if (_isPost = YES) {
            [dm.currentPost setValue:tempCustomFieldsArray forKey:@"custom_fields"];
        } else {
            [dm.currentPage setValue:tempCustomFieldsArray forKey:@"custom_fields"];
        }

        //TODO:JOHNBCustomFields remove the next two lines, for testing and logging only
        NSArray *tempArray = [dm.currentPost valueForKey:@"custom_fields"];
        [dm printArrayToLog:tempArray andArrayName:@"copy of currentPost:custom_fields from CustomFieldsEditView AFTER edit. This SHOULD show changed values"];
    }
}

@end
