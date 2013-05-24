# Dropbox Browser
Dropbox Browser provides a simple and effective way to browse, view, and download files using the iOS Dropbox SDK. Add the required files to your Xcode iOS project, setup Dropbox, add one simple method and a navigation controller and now you've got a wonderful View Controller that lets users browse their Dropbox files and folders, and even download them.

<img width=750 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/Screenshot.png?raw=true"/>

If you like the project, please <a href=https://github.com/iRareMedia/DropboxBrowser>star it</a> on GitHub!

##Integration & Setup
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
4. Setup your Dropbox App Key and Secret. This includes customizing your Info.plist file and your App Delegate. Instructions from Dropbox are <a href=https://www.dropbox.com/developers/start/authentication#ios>available here</a>  
5. Add all of the DropboxBrowser files to your project
	- `DropboxBrowserViewController` Implementation (.m) and Header (.h)
	- Make sure to include the "Graphics" and "Utilities" folders
6. In your ViewController's header file, add the following import statement: `#import "DropboxBrowserViewController.h"`. Also add the following delegate: `DropboxBrowserDelegate`.
7. Edit the required interface files. In your storyboard, add the following UI Objects from the Objects Library:
    - Navigation Controller  
8.  Select the Table View Controller just added along with the Navigation Controller and change the class to `DropboxRootViewController` using the Identity Inspector.  
9. Click on the first cell of the Table View and change its identifier to `DropboxBrowserCell` and change the cell style to `Subtitle`.  
10. In your Implementation File (.m), add a method / action that displays the Dropbox Browser Navigation Controller. You do not need to check if the user is logged into Dropbox. Dropbox Browser handles authentication and login.  

## Delegates, Methods, and Properties
Dropbox Browser provides many paths to customization and control. DropboxBrowser has seven delegate methods available for use - they are all optional. There are multiple properties which can easily be retrieved and set. A handful of methods are available for you to call on your own - however they are not required for use. 

Keep in mind that all content listed below is optional. DropboxBrowser will work perfectly out of the box using only the steps described in the *Integration and Setup* portion of this document.

<table>
  <tr><th colspan="2" style="text-align:center;">Delegates</th></tr>
  <tr>
    <td>Downloaded File</td>
    <td>Optional delegate method called when the selected file is successfully downloaded from Dropbox. The fileName <tt>NSString</tt> object contains the filename of the downloaded file.
    <br /><br />
           ```- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)fileName```
    </td>
  </tr>
 <tr>
    <td>Selected File</td>
    <td>Optional delegate method called when the user selects a file from the <tt>UITableView</tt>. When implemented, DropboxBrowser will make this method responsible for downloading the file and updating the UI as the file downloads and when the download completes. If this delegate method is not implemented, DropboxBrowser will download the file and update the UI normally. The file <tt>DBMetadata</tt> object contains the metadata about the selected file.
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser selectedFile:(DBMetadata *)file</tt>
    </td>
  </tr>
  <tr>
    <td>File Download Failed</td>
    <td>Optional delegate method called when the selected file could not be downloaded from Dropbox. The fileName <tt>NSString</tt> object contains the file name of the file which could not be downloaded.
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedToDownloadFile:(NSString *)fileName</tt>
    </td>
  </tr>
  <tr>
    <td>File Conflict Error</td>
    <td>Called when there is an issue downloading a file because it already exists in the local Documents Directory.  The conflict `NSDictionary` contains two values. The first value, file, contains the `DBMetadata` for the Dropbox File. You can access properties such as file name, modified date, and size using the `DBMetadata` properties. The second value is a human-readable error message called `message`. 
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictError:(NSDictionary *)conflict</tt>
    </td>
  </tr>
 <tr>
    <td>Created Share Link</td>
    <td>Called when a file share link is successfully created for the selected file.  You can create a link for a file by calling the `loadShareLinkForFile` method. 
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didLoadShareLink:(NSString *)link</tt>
    </td>
  </tr>
  <tr>
    <td>Share Link Error</td>
    <td>Called when a there is an error loading or creating a share link for the selected file or directory.  You can create a share link for a file by calling the `loadShareLinkForFile` method. The error `NSError` contains an error message detailing the issue.
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedLoadingShareLinkWithError:(NSError *)error</tt>
    </td>
  </tr>
    <tr>
    <td>Dropbox Browser was Dismissed</td>
    <td>Called when the DropboxBrowser is dismissed by the user. **Do NOT** use this method to dismiss the DropboxBrowser - it has already been dismissed by the time this method is called (hence the past-tense method name).
    <br /><br />
       <tt>- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser</tt>
    </td>
  </tr>
  
  <tr><th colspan="2" style="text-align:center;">Properties</th></tr>

  <tr>
    <td>`currentPath`</td>
    <td>An `NSString` containing the path of the directory the user is currently viewing.</td>
  </tr>
  <tr>
    <td>`list`</td>
    <td>An `NSMutableArray` containing the list of files currently being viewed by the user.</td>
  </tr>
  <tr>
    <tr>
    <td>`fileName`</td>
    <td>An `NSString` containing the file last selected by the user.</td>
  </tr>
   <tr>
    <tr>
    <td>`allowedFileTypes`</td>
    <td>Coming Soon. Allows you to set the file types which can be displayed (like a filter).</td>
  </tr>

  <tr><th colspan="2" style="text-align:center;">Methods</th></tr>
  <tr>
    <td>Download File</td>
    <td>Download a file from Dropbox to the Documents Directory. Returns a `BOOL` value of YES if the download is successful, NO if it is not. You may also want to implement the file `failedToDownloadFile` delegate method for more information on failed file downloads.
    <br /><br />
       <tt>- (BOOL)downloadFile:(DBMetadata *)file</tt>
    </td>
  </tr>
  <tr>
    <td>Create Share Link</td>
    <td>Create a share link for the specified file in Dropbox. You'll need to implement the `didLoadShareLink` delegate method to get the share link of the specified file. You may also want to implement the `failedLoadingShareLinkWithError` delegate method for more information on share link creation errors.
    <br /><br />
       <tt>- (void)loadShareLinkForFile:(DBMetadata*)file</tt>
    </td>
  </tr>
    <tr>
    <td>Update Download Progress</td>
    <td>Use this method to update the download progress of a currently downloading file. This method is only needed if you implement the `selectedFile` delegate method.
    <br /><br />
       <tt>- (void)updateDownloadProgressTo:(CGFloat)progress</tt>
    </td>
  </tr>
</table>

  
##Files
Just a quick note on files and downloads. Files from DropboxBrowser are **always** downloaded to your **application's Documents Directory**. If a conflict arises between a local and remote file, you can use the `fileConflictError` delegate method.

## User Interface
DropboxBrowser has a nice UI that can easily be customized. All graphics have been Retina-Display, and iPhone 5 optimized. A quick preview of what the UI looks like can be seen below. 

<img width=750 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/Interface.png?raw=true"/>

Here are a few simple ways to customize the interface:  
 - Swap any images (PNGs) included with Dropbox Browser with your own. Use the same size image with the exact same name.  
 - Use UITableView Prototype Cells to customize the TableView appearance. It is recommended that you set the cell type to `Subtitle`. This will allow DropboxBrowser to display file / folder names, last modified dates, and file sizes.  
 - Change the colors and properties in DropboxBrowserViewController's viewDidLoad method you can change the tint of the UINavigationBar, UIRefreshControl, and the position of the UIProgressView.  
 
## Change Log
This project is ready for primetime use in any iOS application. Just follow the steps above to integrate Dropbox Browser. Make sure to get your app approved for Production Status from the Dropbox Team before submitting to the AppStore. Here are a few key changes in the project:  

**Version 4.2**  
 - Create file share links using the `loadShareLinkForFile` method. Added by <a href=https://github.com/ekurutepe>ekurutepe</a>.  
 - New delegate methods help create and process share links. Added by <a href=https://github.com/ekurutepe>ekurutepe</a>.  
 - Updated delegate names and properties. Now delegates have more conventional names and provide more information. Make sure you re-implement the updated delegate methods. The old ones have been marked as depreciated.  
 - Fixed a major bug where subdirectories were not loaded properly. Thank you <a href=https://github.com/ekurutepe>ekurutepe</a>!
 
**Version 4.1**  
 - DropboxBrowser now handles authentication and login with Dropbox. There is no need to check if the user is logged in to Dropbox before presenting the DropboxBrowser. If the user is not logged in, DropboxBrowser will prompt the user to do so. If the user opts-out of login then DropboxBrowser will dismiss itself. However, you may still handle login operations yourself.  
 - Updated delegate names  
 - Added code comments and standardized header definitions

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
