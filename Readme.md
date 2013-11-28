# Dropbox Browser
Dropbox Browser provides a simple and effective way to browse, view, and download files using the iOS Dropbox SDK. Add the required files to your Xcode iOS project, setup Dropbox, add one simple method and a navigation controller and now you've got a wonderful View Controller that lets users browse their Dropbox files and folders, and even download them. 

<img width=750 src="https://github.com/iRareMedia/DropboxBrowser/blob/master/Screenshot.png?raw=true"/>

If you like the project, please <a href=https://github.com/iRareMedia/DropboxBrowser>star it</a> on GitHub!

##Integration & Setup
To properly integrate DropboxBrowser into your project follow the instructions below. Use the included Sample Project (inside of the "Example" folder) as a guide for setting up your project. 
 
1. Add the following Frameworks, already available in Xcode, to your project:  
    - Security  
    - QuartzCore  
    - DropboxSDK Framework The latest version of the SDK can be <a href=https://www.dropbox.com/developers>downloaded here</a> | DropboxBrowser uses version 1.3.9 of the Dropbox SDK  
2. Register as a developer on Dropbox and setup your App. If you've already done this, skip this step. If you haven't already done this, <a href=https://www.dropbox.com/developers/start/setup#ios>get setup</a>.  
3. Setup your Dropbox App Key and Secret. This includes customizing your Info.plist file and your App Delegate. Instructions from Dropbox are <a href=https://www.dropbox.com/developers/start/authentication#ios>available here</a>  
4. Add all of the DropboxBrowser files to your project
	- `DropboxBrowserViewController` Implementation (.m) and Header (.h)
	- Make sure to include the "Graphics" and "Utilities" folders
5. In your ViewController's header file, add the following import statement: `#import "DropboxBrowserViewController.h"`. Also add the following delegate: `DropboxBrowserDelegate`.
6. Edit the required interface files. In your storyboard, add the following UI Objects from the Objects Library:
    - Navigation Controller  
7.  Select the Table View Controller just added along with the Navigation Controller and change the class to `DropboxRootViewController` using the Identity Inspector.  
8. In your Implementation File (.m), add a method / action that displays the Dropbox Browser Navigation Controller. You do not need to check if the user is logged into Dropbox. Dropbox Browser handles authentication and login.  

## Delegates, Methods, and Properties
Dropbox Browser provides many paths to customization and control. DropboxBrowser has seven delegate methods available for use - they are all optional. There are multiple properties which can easily be retrieved and set. A handful of methods are available for you to call on your own - however they are not required for use. 

Keep in mind that all content listed below is optional. DropboxBrowser will work perfectly out of the box using only the steps described in the *Integration and Setup* portion of this document.

<table>
  <tr><th colspan="2" style="text-align:center;">Delegates</th></tr>
  <tr>
    <td>Downloaded File</td>
    <td>Optional delegate method called when the selected file is successfully downloaded from Dropbox. The fileName <tt>NSString</tt> object contains the filename of the downloaded file.
    <br /><br />
           <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser downloadedFile:(NSString *)fileName</tt>
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
    <td>Called when there is an issue downloading a file because it already exists in the local Documents Directory.  The conflict <tt>NSDictionary</tt> contains two values. The first value, file, contains the <tt>DBMetadata</tt> for the Dropbox File. You can access properties such as file name, modified date, and size using the <tt>DBMetadata</tt> properties. The second value is a human-readable error message called <tt>message</tt>. 
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser fileConflictError:(NSDictionary *)conflict</tt>
    </td>
  </tr>
 <tr>
    <td>Created Share Link</td>
    <td>Called when a file share link is successfully created for the selected file.  You can create a link for a file by calling the <tt>loadShareLinkForFile</tt> method. 
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser didLoadShareLink:(NSString *)link</tt>
    </td>
  </tr>
  <tr>
    <td>Share Link Error</td>
    <td>Called when a there is an error loading or creating a share link for the selected file or directory.  You can create a share link for a file by calling the <tt>loadShareLinkForFile</tt> method. The error <tt>NSError</tt> contains an error message detailing the issue.
    <br /><br />
       <tt>- (void)dropboxBrowser:(DropboxBrowserViewController *)browser failedLoadingShareLinkWithError:(NSError *)error</tt>
    </td>
  </tr>
    <tr>
    <td>Dropbox Browser was Dismissed</td>
    <td>Called when the DropboxBrowser is dismissed by the user. <strong>Do NOT</strong> use this method to dismiss the DropboxBrowser - it has already been dismissed by the time this method is called (hence the past-tense method name).
    <br /><br />
       <tt>- (void)dropboxBrowserDismissed:(DropboxBrowserViewController *)browser</tt>
    </td>
  </tr>
  
  <tr><th colspan="2" style="text-align:center;">Properties</th></tr>

  <tr>
    <td><tt>currentPath</tt></td>
    <td>An <tt>NSString</tt> containing the path of the directory the user is currently viewing.</td>
  </tr>
  <tr>
    <td><tt>list</tt></td>
    <td>An <tt>NSMutableArray</tt> containing the list of files currently being viewed by the user.</td>
  </tr>
  <tr>
    <tr>
    <td><tt>fileName</tt></td>
    <td>An <tt>NSString</tt> containing the file last selected by the user.</td>
  </tr>
   <tr>
    <tr>
    <td><tt>allowedFileTypes</tt></td>
    <td>Coming Soon. Allows you to set the file types which can be displayed (like a filter).</td>
  </tr>

  <tr><th colspan="2" style="text-align:center;">Methods</th></tr>
  <tr>
    <td>Download File</td>
    <td>Download a file from Dropbox to the Documents Directory. Returns a <tt>BOOL</tt> value of YES if the download is successful, NO if it is not. You may also want to implement the file <tt>failedToDownloadFile</tt> delegate method for more information on failed file downloads.
    <br /><br />
       <tt>- (BOOL)downloadFile:(DBMetadata *)file</tt>
    </td>
  </tr>
  <tr>
    <td>Create Share Link</td>
    <td>Create a share link for the specified file in Dropbox. You'll need to implement the <tt>didLoadShareLink</tt> delegate method to get the share link of the specified file. You may also want to implement the <tt>failedLoadingShareLinkWithError</tt> delegate method for more information on share link creation errors.
    <br /><br />
       <tt>- (void)loadShareLinkForFile:(DBMetadata*)file</tt>
    </td>
  </tr>
    <tr>
    <td>Update Download Progress</td>
    <td>Use this method to update the download progress of a currently downloading file. This method is only needed if you implement the <tt>selectedFile</tt> delegate method.
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