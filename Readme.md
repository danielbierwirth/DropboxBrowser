# Dropbox Browser
Dropbox Browser provides a simple and effective way to browse, view, and download files using the iOS Dropbox SDK. Add the required files to your Xcode iOS project, setup Dropbox, add one simple method and a navigation controller and now you've got a wonderful View Controller that lets users browse their Dropbox files and folders, and even download them.

<img width=750 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/Screenshot.png?raw=true"/>

If you like the project, please <a href=https://github.com/iRareMedia/DropboxBrowser/star>star it</a> on GitHub!

##Integration
To properly integrate DropboxBrowser into your project follow the instructions below. Use the included Sample Project (inside of the "Example" folder) as a guide for setting up your project. 
 
1. Add the following Frameworks, already available in Xcode, to your project:  
    - Security  
    - QuartzCore  
    - AssetsLibrary  
    - UIKit  
    - Foundation  
    - CoreGraphics  
2. Add the DropboxSDK Framework to your project. The latest version of the SDK can be <a href=https://www.dropbox.com/developers>downloaded here</a> | DropboxBrowser uses version 1.3.4 of the Dropbox SDK  
3. Register as a developer on Dropbox and setup your App. If you've already done this, skip this step. If you haven't already done this, <a href=https://www.dropbox.com/developers/start/setup#ios>get setup</a>.  
4. Setup and add the required methods used by Dropbox for authenticating. This includes customizing your Info.plist file and your App Delegate. Instructions from Dropbox are <a href=https://www.dropbox.com/developers/start/authentication#ios>available here</a>  
5. Add all of the DropboxBrowser files to your project
	- `DropboxBrowserViewController` Implementation (.m) and Header (.h)
	- Make sure to include the "Graphics" and "Utilities" folders
6. In your ViewController's header file, add the following import statement: `#import "DropboxBrowserViewController.h"`. Also add the following delegate: `DropboxBrowserDelegate`.
7. In your Implementation File (.m) add the method listed below. This project (and its code) assumes you're using Xcode 4, iOS 5+, and Storyboards. If you aren't using storyboards, you'll need to present the Navigation Controller with your own code.

        - (IBAction)browseDropbox {
            //Check if Dropbox is Setup
            if (![[DBSession sharedSession] isLinked]) {
                 //Dropbox is not setup
                [[DBSession sharedSession] linkFromController:self];
           } else {
                //Dropbox has already been setup - display the navigation controller (modally)
           }
        }

8. Edit the required interface files. In your storyboard, add the following UI Objects from the Objects Library:
    - Navigation Controller  
9.  Select the Table View Controller just added along with the Navigation Controller and change the class to `DropboxRootViewController` using the Identity Inspector.  
13. Click on the first cell of the Table View and change its identifier to `DropboxBrowserCell` and change the cell style to `Subtitle`.

## Delegates & Results
There are four optional delegate methods available with DropboxBrowser (not Dropbox SDK). Here is a list of all the methods and descriptions:  
    - `downloadedFileFromDropbox:(NSString *)fileName` called when a file is **successfully** downloaded from Dropbox. The `fileName` property contains an NSString with the downloaded file's name.  
    - `failedToDownloadDropboxFile:(NSString *)fileName`  called when there is an issue while downloading a file from Dropbox. The `fileName` property contains an NSString with the downloaded file's name.  
    - `fileDownloadConflictError:(NSDictionary *)conflict` called when there is an issue downloading a file because it already exists in the local Documents Directory.  The `conflict` NSDictionary contains two values. The first value, `file`, contains the DBMetadata for the Dropbox File. You can access properties such as file name, modified date, and size using the DBMetadata properties. The second value is a human-readable error message called `message`.  
    - `dismissedDropboxBrowser` called when the DropboxBrowser is dismissed by the user. **Do NOT use this method to dismiss the DropboxBrowser** - it has already been dismissed by the time this method is called (hence the past-tense method name).  

The next function allows you to retrieve the file name of the last file selected. Simply call this function:  
    NSString *fileName = [DropboxRootViewController fileName];
  
##Files
Just a quick note on files and downloads. Files from DropboxBrowser are **always** downloaded to your **application's Documents Directory**.

## User Interface
DropboxBrowser has a nice UI that can easily be customized. All graphics have been Retina-Display, and iPhone 5 optimized. A quick preview of what the UI looks like can be seen below. 

<img width=750 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/Screenshot.png?raw=true"/>

Here are a few simple ways to customize the interface:  
 - Swap any images (PNGs) included with Dropbox Browser with your own. Use the same size image with the exact same name.  
 - Use UITableView Prototype Cells to customize the TableView appearance. It is recommended that you set the cell type to `Subtitle`. This will allow DropboxBrowser to display file / folder names, last modified dates, and file sizes.  
 - Change the colors and properties in DropboxBrowserViewController's viewDidLoad method you can change the tint of the UINavigationBar, UIRefreshControl, and the position of the UIProgressView.  
 
## Change Log
This project is ready for primetime use in any iOS application. Just follow the steps above to integrate Dropbox Browser. Make sure to get your app approved for Production Status from the Dropbox Team before submitting to the AppStore. Here are a few key changes in the project:

**Version 4.0**  
	- Code reorganized, cleaned-up, and condensed. DropboxBrowser is now one easy-to-use class (previously three classes with complex delegate calls)  
	- New icon, graphics, and help menu for example project  
	- Added Icons for over 100 types of files and folders supported by Dropbox - proper icon is shown next to each file  
	- Added four new delegate methods and depreciated older methods  
	- New TableView animations - changes in directories are now animated  
	- New Navigation Bar - new design, also shows title of current folder  
	- Simplified Navigation Controller customization. Please refer to the new setup and integration procedures  
	- Updated Refresh Control - now the refresh control actually fetches updates from Dropbox and displays them  
	- Removed Loading HUD for iOS 6+ users - the refresh control now appears instead of the black overlay. If you support versions lower than iOS 6, the HUD will be used.  
	- Fixed Done Button Bug where it may randomly disappear or reappear
	- Fixed Back Button issue where the user could back up past the Root Directory  
	- Fixed TableView Subtitle information. Formatting now mimics the Dropbox App
	- Fixed Download Progress View issue where the download progress would not reset after each download  
	- Major Performance Improvements
	- Added open-source license (MIT license)  

**Version 3.0**  
	- Code reorganized, cleaned-up, and many comments have been added  
	- Back button now goes up one level instead of returning to the Root Directory. Back button also only appears when the user is not in the Root Directory (i.e. they have somewhere to back up to).
	- Improved Download Progress View. Now centered in the Navigation Bar and hides NavBar title when shown.
	- Any file type is shown in DropboxBrowser - no file types are excluded
	- Duplicate `@implementation` calls have been removed and condensed into one implementation  
	- New iOS 6 features including `UIRefreshControl` have been added  
	- New design. Removed accessory buttons from UITableViewCells. Updated graphics. Added Dropbox-esque tint to `UINavgationBar` and `UIRefreshControl`  
	- Sample project now has an icon and uses Autolayout instead of Autosizing (may have caused build errors for iOS 5 in older versions of DropboxBrowser)  
	- Dropbox SDK updated to version 1.3.4  
	- Renamed classes. Generally removed `Kiosk` and `PDF` from all class names and delegates.
	- Numerous minor bug fixes and improvements
	- Improved performance  

**Version 2.3**  
	- Condenses presentation of DropboxBrowser to four lines (compared to a previous 40+ lines of code) using one simple method  
	- New convenience method.  
**Version 2.2**  
	- Dropbox Browser now fits all screen sizes using Autosizing instead of defined sizes - in other words, iPhone 5 compatibility  
**Version 2.1**  
	- Updated Documentation  
	- New Methods  
	- Improved Selection  
**Version 2.0**  
	- Added Sample Project  
	- iOS 6 Support  
	- ARC Support  
	- New Documentation  
	- Improved ReadMe  
	- Improved UI  
	- More!  

**Version 1.2**  
	- Added Download Indicator  
**Version 1.1**  
	- Added Sync Functionality  
**Version 1.0**  
	- Initial Commit
