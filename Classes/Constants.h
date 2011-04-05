//
//  Constants.h
//  WordPress
//
//  Created by Ganesh Ramachandran on 6/6/08.
//

// Blog archive file name
#define BLOG_ARCHIVE_NAME       WordPress_Blogs

// control dimensions
#define kStdButtonWidth         106.0
#define kStdButtonHeight        40.0

#define kTextFieldHeight        20.0
#define kTextFieldFontSize      18.0
#define kTextFieldFont          @"Arial"
#define kTextViewPlaceholder	@"Tap here to begin writing."
#define kAppStoreURL			@"http://itunes.apple.com/us/app/wordpress/id335703880?mt=8"

#define kDisabledTextColor      [UIColor grayColor]

#define kLabelHeight            20.0
#define kLabelWidth             90.0
#define kLabelFont              @"Arial"

#define kProgressIndicatorSize  40.0
#define kToolbarHeight          40.0
#define kSegmentedControlHeight 40.0

// table view cell
#define kCellLeftOffset         4.0
#define kCellTopOffset          12.0
#define kCellRightOffset        32.0
#define kCellFieldSpacer        14.0
#define kCellWidth              300.0
#define kCellHeight             44.0
#define kSectionHeaderHight     25.0

#define REFRESH_BUTTON_HEIGHT   50

#define TABLE_VIEW_BACKGROUND_COLOR          [UIColor whiteColor]
#define TABLE_VIEW_CELL_BACKGROUND_COLOR     [UIColor whiteColor]
#define PENDING_COMMENT_TABLE_VIEW_CELL_BACKGROUND_COLOR     [UIColor colorWithRed:1.0 green:1.0 blue:215.0 / 255.0 alpha:1.0]
#define PENDING_COMMENT_TABLE_VIEW_CELL_BORDER_COLOR     [UIColor colorWithRed:226.0 / 255.0 green:215.0 / 255.0 blue:58.0 / 255.0 alpha:1.0]
#define LOAD_MORE_DATA_TEXT_COLOR [UIColor colorWithRed:35.0 / 255.0 green:112.0 / 255.0 blue:216.0 / 255.0 alpha:1.0]
#define WRONG_FIELD_COLOR [UIColor colorWithRed:0.7 green:0.0 blue:0.0 alpha:1.0]
#define GOOD_FIELD_COLOR [UIColor blackColor]

//R: 35, G: 112, B: 216 | #2370D8 | ΔX: 1378, ΔY: 29 | img

#ifdef DEBUGMODE
#define WPLog NSLog
#else
#define WPLog //NSLog
#endif
#define CGRectToString(rect) [NSString stringWithFormat:@"%f,%f:%fx%f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height]
#define CGPointToString(point) [NSString stringWithFormat:@"%f,%f", point.x, point.y]
#define _(str) NSLocalizedString(str, @"")

#define kBlogId                                 @"blogid"
#define kBlogHostName                           @"blog_host_name"
#define kCurrentBlogIndex                       @"CurrentBlogIndex"
#define kResizePhotoSetting                     @"ResizePhotoSetting"
#define kGeolocationSetting						@"GeolocationSetting"
#define kLocationSetting						@"LocationSetting"
#define kSupportsVideoPress						@"SupportsVideoPress"
#define kAsyncPostFlag                          @"async_post"
#define kVersionAlertShown                      @"VersionAlertShown"
#define kResizePhotoSettingHintLabel            @"Resizing will result in faster publishing \n but smaller photos. Resized photos \n will be no larger than 640 x 480."
#define kPasswordHintLabel                      @"Setting a password will require visitors to \n enter the above password to view this \n post and its comments."
#define kLocationOnSetting						@"LocationOnSetting"

#pragma mark Error Messages

#define kNoInternetErrorMessage                 @"No internet connection."
#define kBlogExistsErrorMessage                 @"Blog '%@' already configured on this iPhone."

#define PictureObjectUploadedNotificationName @"PictureObjectUploadedNotificationName"
#define VideoSaved @"VideoSavedNotification"
#define VideoUploadChunk @"VideoUploadChunk"
#define ImageUploadSuccessful @"ImageUploadSuccessful"
#define ImageUploadFailed @"ImageUploadFailed"
#define VideoUploadSuccessful @"VideoUploadSuccessful"
#define VideoUploadFailed @"VideoUploadFailed"
#define WPNewCategoryCreatedAndUpdatedInBlogNotificationName @"WPNewCategoryCreatedAndUpdatedInBlog"
#define kXML_RPC_ERROR_OCCURS @"kXML_RPC_ERROR_OCCURS"
#define kURL @"URL"
#define kMETHOD @"METHOD"
#define kMETHODARGS @"METHODARGS"
#define BlavatarLoaded @"BlavatarLoaded"

#define kPostsDownloadCount @"postsDownloadCount"
//#define kPagesDownloadCount @"pagesDownloadCount"
#define kDraftsBlogIdStr @"localDrafts"
#define kDraftsHostName @"iPhone"

#define kUnsupportedWordpressVersionTag 900
#define kRSDErrorTag 901
#define kCrashAlertTag 902
#define kNoXMLPrefix 903

typedef enum {
	kImage,
	kVideo
} MediaType;

typedef enum {
	kResizeSmall,
	kResizeMedium,
	kResizeLarge,
	kResizeOriginal
} MediaResize;

typedef enum {
	kPortrait,
	kLandscape
} MediaOrientation;

typedef enum {
	kNewPost,
	kEditPost,
	kAutorecoverPost,
	kRefreshPost
} EditPostMode;

typedef enum {
	kNewPage,
	kEditPage,
	kAutorecoverPage,
	kRefreshPage
} EditPageMode;
