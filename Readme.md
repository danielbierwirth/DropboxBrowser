<img width=750 src="https://raw.github.com/danielbierwirth/DropboxBrowser/master/Banner.png" align="center"/>

Dropbox Browser provides a simple and effective way to browse, view, and download files using the iOS Dropbox SDK. Follow the simple setup steps and in under ten minutes you'll have a working Dropbox File Browser in your app that lets users browse and download their Dropbox files and folders. 

If you like the project, please <a href=https://github.com/iRareMedia/DropboxBrowser>star it</a> on GitHub! Watch the project on GitHub for updates. If you use DropboxBrowser in your app, send an email to contact@iraremedia.com or let us know on Twitter @iRareMedia.

# Features
Project highlights and key features are listed below. Dropbox Browser has a great interface built for iOS 7, solid file handling features, notification integration, background support, and file search capability.

## User Interface
DropboxBrowser has a beautiful and simple interface similar to that of the actual Dropbox App. The interface is built for the latest iOS technologies and can also be easily customized.

<img width=750 src="https://raw.github.com/danielbierwirth/DropboxBrowser/master/Interface.png" align="center"/>

## Files
When a user taps on a file, DropboxBrowser checks to see if the file is already download. If the file hasn't been downloaded, it's downloaded to your application's **Documents Directory**. If a conflict arises between a local and remote file, DropboxBrowser will attempt to resolve it. In the event that a conflict can't be resolved, you'll be notified via delegate methods and have the chance to handle the download youself.

## Notifications
Dropbox can store really big files that take a long time to download. When a file download starts, DropboxBrowser is prepared to continue downloading even if the user exits your app. As soon as the download is complete, the user will recieve a notification in Notification Center that their download has finished.

## File Search
Users can quickly get to the files they need by using the built-in search features. Just scroll to the top and start typing for instant search results. Download files directly from search results.

# Project Details
Learn more about the project requirements, licensing, contributions, and setup.

## Requirements
Requires at least Xcode 6.0 for use in any iOS Project. Requires a minimum of iOS 8.0 as the deployment target. The sample project is only compatible with Xcode 6.3 and higher.

| Current Build Target 	| Earliest Supported Build Target 	| Earliest Compatible Build Target 	|
|:--------------------:	|:-------------------------------:	|:--------------------------------:	|
|      iOS 10.3beta   	|            iOS 8.0              	|             iOS 6.0              	|
|     Xcode 8.3beta     |          Xcode 6.3            	|           Xcode 6.0            	|
|      LLVM 8.0        	|           LLVM 6.0            	|            LLVM 5.0             	|

> REQUIREMENTS NOTE  
*Supported* means that the library has been tested with this version. *Compatible* means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.

## Contributions
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

## Setup
To properly integrate DropboxBrowser into your project follow the instructions below. Use the included Example Project as a guide for setting up your own project. 
 
1. Add the following Frameworks, already available in Xcode, to your project:  
    * Security
    * QuartzCore
    * DropboxSDK Framework The latest version of the SDK can be <a href=https://www.dropbox.com/developers>downloaded here</a> | DropboxBrowser uses version 1.3.11 of the Dropbox SDK
2. Register as a [developer on Dropbox](https://www.dropbox.com/developers/start/setup#ios) and setup your App.
3. Setup your Dropbox App Key and Secret. This includes customizing your Info.plist file and your App Delegate. Instructions from Dropbox are [available here](https://www.dropbox.com/developers/start/authentication#ios)
4. Add all of the DropboxBrowser files to your project
    * `DropboxBrowserViewController.m` and `DropboxBrowserViewController.h`
    * Add the `DropboxMedia` Xcode Asset Catalog to your project - this is the catalog with all the file icons
5. Import `#import "DropboxBrowserViewController.h"` and subscribe to the `DropboxBrowserDelegate` delegate.
6. Edit the required interface files. In your storyboard, add a UINavigationController (with the UITableViewController)
7. Select the UITableViewController that was just added (along with the UINavigationController) and change its class to `DropboxRootViewController` using the Identity Inspector.  
8. In your Implementation File (.m), add a method / action that displays the Dropbox Browser Navigation Controller. You do not need to check if the user is logged into Dropbox - authentication and login is handled for you.

# Documentation
All methods, properties, types, and delegate methods available with DropboxBrowser are documented below. If you're using Xcode 5 with DropboxBrowser, documentation is available directly within Xcode (just Option-Click any method for Quick Help). Although DropboxBrowser does have extensive properties, methods, and delegates - no coding is required. DropboxBrowser can be setup completely without using any code.

## Properties
You can customize DropboxBrowser using properties. Properties must be set in the `prepareForSegue:` method before display the DropboxBrowserViewController. Use the code example below as a guide for setup.  

    - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        if ([[segue identifier] isEqualToString:@"showDropboxBrowser"]) {
            // Get reference to the destination view controller
            UINavigationController *navigationController = [segue destinationViewController];
        
            // Pass any objects to the view controller here, like...
            DropboxBrowserViewController *dropboxBrowser = (DropboxBrowserViewController *)navigationController.topViewController;
        
            // Set properties here
            dropboxBrowser.property = propertySetting;
        
            // Set the delegate property to recieve delegate method calls
            dropboxBrowser.rootViewDelegate = self;
        }
    }

### Allowed File Types
The `allowedFileTypes` property allows you to filter the types of files which are displayed by DropboxBrowser.  If this property is set, DropboxBrowser will only display files with file types matching those set in this array. For example, if you only wanted to show PDFs, Word Documents, and Apple Pages then you might do this:

    dropboxBrowser.allowedFileTypes = @[@"pdf", @"docx", @"pages"];

### Table Cell ID
The `tableCellID` property allows for greater flexibility when creating your UITableViewController. By default, DropboxBrowser will use or create a UITableViewCell with the ID *DropboxBrowserCell*. If you'd like to use a different UITableViewCell ID, just set this property to the cooresponding ID.

    dropboxBrowser.tableCellID = @"CustomCellID";

### Notification Delivery
The `deliverDownloadNotifications` property simply lets you turn ON or OFF file download notifications. When a file is downloaded (either successfully or unsuccessfully) you can have DBBrowser notify the user with Notification Center. Default property is OFF.

    dropboxBrowser.deliverDownloadNotifications = YES;
    
### Search Bar Display
The `shouldDisplaySearchBar` property toggles the display of the file search bar. Dropbox Browser can display a UISearchBar to allow the user to search their Dropbox for a file or folder. Default property is NO.

    dropboxBrowser.shouldDisplaySearchBar = YES;
 
## Methods
In some cases, you might need to manually download a file, check if the user is logged in, or do any number of tasks. DropboxBrowser provides a few methods just for that.

### Download File
Download a file from Dropbox to the Documents Directory. Returns a `BOOL` value of YES if the download is successful, NO if it is not. You may also want to implement the `dropboxBrowser:didFailToDownloadFile:` delegate method for more information on failed file downloads.

    - (BOOL)downloadFile:(DBMetadata *)file replaceLocalVersion:(BOOL)replaceLocalVersion;

### Create Share Link
Create a share link for the specified file in Dropbox. You'll need to implement the `didLoadShareLink:` delegate method to get the share link of the specified file. You may also want to implement the `failedLoadingShareLinkWithError:` delegate method for more information on share link creation errors.

    - (void)loadShareLinkForFile:(DBMetadata *)file

### Dropbox Linked Status
Check if the current app is linked to dropbox. Returns YES if the app is properly setup and the user is logged in. Returns NO if the app is not setup or the user is not logged in.

    - (BOOL)isDropboxLinked;

### Dismiss DropboxBrowser
Manually dismiss the DropboxBrowser without any user consent. This is not recommended, but may be needed in some cases.

    - (void)removeDropboxBrowser;

## Delegates

### Downloaded File
Sent to the delegate when the selected file is successfully downloaded from Dropbox. The `fileName` NSString object contains the file name of the downloaded file. The `isLocalFileOverwritten` BOOL states whether or not the user chose to overwrite the local file.

    -- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didDownloadFile:(NSString *)fileName didOverwriteFile:(BOOL)isLocalFileOverwritten
    
### Selected File
Sent to the delegate when the user selects a file for download. When implemented, DropboxBrowser will make this method responsible for downloading the file and updating the UI as the file downloads and when the download completes. If this delegate method is not implemented, DropboxBrowser will download the file and update the UI normally. The `DBMetadata` object contains the metadata about the selected file.

    - (void)dropboxBrowser:(DropboxBrowserViewController *)browser didSelectFile:(DBMetadata *)file
    
### File Download Failed
Sent to the delegate when the selected file could not be downloaded from Dropbox. The `fileName` NSString object contains the file name of the file which could not be downloaded.

    - (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToDownloadFile:(NSString *)fileName

### File Conflict Error
Called when there is an issue downloading a file from Dropbox because it already exists in the local Documents Directory.  The `localFileURL` represents the local file which is preventing the download (the user may or may not choose to overwrite it). The `dropboxFile` is the Dropbox file which was selected for download. The `error` contains an error code (`kDBFileConflictError`), and error message, and a dictionary with information. In the error dictionary the first value, `file`, contains the DBMetadata for the Dropbox File. You can access properties such as file name, modified date, and size using the DBMetadata properties. The second value is a human-readable error message called `message`. 

    - (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictWithLocalFile:(NSURL *)localFileURL withDropboxFile:(DBMetadata *)dropboxFile withError:(NSError *)error
    
### Created Share Link
Called when a file share link is successfully created for the selected file.  You can create a link for a file by calling the `loadShareLinkForFile:` method. 

    - (void)dropboxBrowser:(DropboxBrowserViewController *)browser didLoadShareLink:(NSString *)link
    
### Share Link Error
Called when a there is an error loading or creating a share link for the selected file or directory.  You can create a share link for a file by calling the `loadShareLinkForFile` method. The `error` NSError contains an error message detailing the issue.

    - (void)dropboxBrowser:(DropboxBrowserViewController *)browser didFailToLoadShareLinkWithError:(NSError *)error
    
### Delivered File Notification
Sent to the delegate after a notification is posted to Notification Center about a file download from Dropbox. The `notification` parameter is a UILocalNotification object (which can be used to clear the notification, or handle it when it is opened by the user).

    - (void)dropboxBrowser:(DropboxBrowserViewController *)browser deliveredFileDownloadNotification:(UILocalNotification *)notification

### Dropbox Browser was Dismissed
Called when the DropboxBrowser is dismissed by the user. Do **NOT** use this method to dismiss the DropboxBrowser - it has already been dismissed by the time this method is called (hence the past-tense method name).

    - (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser
