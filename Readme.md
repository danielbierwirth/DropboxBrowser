[![CocoaPods](https://img.shields.io/cocoapods/v/DropboxBrowser.svg)](https://cocoapods.org/pods/DropboxBrowser) [![CocoaPods](https://img.shields.io/cocoapods/l/DropboxBrowser.svg)](https://github.com/danielbierwirth/DropboxBrowser/blob/master/LICENSE) [![CocoaPods](https://img.shields.io/cocoapods/p/DropboxBrowser.svg)]()
<p align="center"><img width=750 src="https://raw.github.com/danielbierwirth/DropboxBrowser/master/Banner.png" align="center"/></p>

Dropbox Browser provides a simple and effective way to browse, search, and download files using the Dropbox's API and SDK. In a few minutes you'll have a working Dropbox file browser in your app that lets users browse and download their files.  

If you like the project, please <a href=https://github.com/iRareMedia/DropboxBrowser>star it</a> on GitHub! Watch the project on GitHub for updates.

# Features
Project highlights and key features are listed below. Dropbox Browser has a great interface built for iOS 7, solid file handling features, notification integration, background support, and file search capability.

## User Interface
DropboxBrowser has a beautiful and simple interface similar to that of the actual Dropbox App. The interface is built for the latest iOS technologies and can also be easily customized.

<p align="center"><img width=750 src="https://raw.github.com/danielbierwirth/DropboxBrowser/master/Interface.png" align="center"/></p>

## Files
When a user taps on a file, DropboxBrowser checks to see if the file is already download. If the file hasn't been downloaded, it's downloaded to your application's **Cache Directory**. If a conflict arises between a local and remote file, DropboxBrowser will attempt to resolve it. In the event that a conflict can't be resolved, you'll be notified via delegate methods and have the chance to handle the download youself.

# Project Details
Learn more about the project requirements, licensing, contributions, and setup.

## Requirements
Requires at least Xcode 6.0 for use in any iOS Project. Requires a minimum of iOS 8.0 as the deployment target. The sample project is only compatible with Xcode 6.3 and higher.

| Current Build Target 	| Earliest Supported Build Target 	| Earliest Compatible Build Target 	|
|:--------------------:	|:-------------------------------:	|:--------------------------------:	|
|      iOS 10.3   	|            iOS 8.0              	|             iOS 6.0              	|
|     Xcode 8.3     |          Xcode 6.3            	|           Xcode 6.0            	|
|      LLVM 8.0        	|           LLVM 6.0            	|            LLVM 5.0             	|

> REQUIREMENTS NOTE  
*Supported* means that the library has been tested with this version. *Compatible* means that the library should work on this OS version (i.e. it doesn't rely on any unavailable SDK features) but is no longer being tested for compatibility and may require tweaking or bug fixes to run correctly.

## Contributions
Any contribution is more than welcome! You can contribute through pull requests and issues on GitHub.

## Installation & Setup
Follow the instructions below to properly integrate DropboxBrowser into your project. Use the included Example Project as a guide for setting up your own project.

### Installation - CocoaPods
Add the following line to your Podfile:

    pod 'DropboxBrowser'

### Installation - Manual
Download or clone this repo, then copy the "ODB Classes" folder and its enclosed classes to your Xcode project.

### Setup
1. Register as a [developer on Dropbox](https://www.dropbox.com/developers) and setup your app.
2. Update the following methods in your App Delegate with the correct callbacks (shown below). Replace "APP_KEY" with your app key from step 1:  

       [[ODBoxHandler sharedHandler] prepareForPotentialSessionWithKey:@"APP_KEY"];  
       
       - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
              // Override point for customization after application launch.
              
              // Setup Dropbox Here with YOUR OWN APP info
              [[ODBoxHandler sharedHandler] prepareForPotentialSessionWithKey:@"APP_KEY"];
              
              return YES;
       }
       
       - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
              [[ODBoxHandler sharedHandler] handleDropboxAuthenticationResponse:url];
    
              // Add whatever other url handling code your app requires here
              return YES;
       }
    
3. Edit your app's Info.plist using your new Dropbox App Key and Secret. Instructions from Dropbox are [available here](https://github.com/dropbox/dropbox-sdk-obj-c#configure-your-project)
4. Add a ODBTableViewController to your interface, either programmatically or in your storyboard. If you add it via your storyboard, some properties can be edited in interface builder.
5. Implement the `ODBoxDelegate` delegate for the Dropbox Handler. Once implemented, you'll recieve calls when a file is downloaded or fails to download.  

       [[ODBoxHandler sharedHandler] setDelegate:self];
      
5. At some point, when it is appropriate in your app's lifecycle, check the user's Dropbox status:  

        BOOL loggedIn = [[ODBoxHandler sharedHandler] clientIsAuthenticated];
        
6. Optionally, you may implement the `ODBTableViewControllerDelegate` delegate to override default downloading and view lifecycle functions.

# Documentation
Documentation is available inside of Xcode (Option-Click / Right Click a method or property for Quick Help). Some key methods and properties are detailed below.

## Properties
Properties must be setup before displaying the `ODBTableViewController`.

### Client Authentication Status
Check if the current user is authenticated. May return NO in the event of an error or if the user is not authenticated.

    - (BOOL)clientIsAuthenticated;

### Custom Download Directory
The `customDownloadDirectory` property allows you to specify the location for file downloads within your application's sandbox.  This must be a local NSURL object on the file system and must be within your application's sandbox. If you supply an invalid file URL, or one for which your app does not have write permissions, files will be downloaded to the application's cache directory. The cache directory is, from time to time, purged by the system so it is your app's responsibility to process any files downloaded to the cache.

    @property (nonatomic, strong, nullable) NSURL *customDownloadDirectory;

### Overwrite Existing Files
Set `downloadsOverwriteLocalConflicts` to YES to overwrite local files that are conflicting with a new download from the Dropbox server. Defaults to NO, which returns an error and stops when there is a conflict.

    @property (nonatomic, assign) BOOL downloadsOverwriteLocalConflicts;
    
 
## Methods
In some cases, you might need to manually download a file, check if the user is logged in, or do any number of tasks. DropboxBrowser provides a few methods just for that.

### Downloading Files
In some use-cases you may need to download a file without direct user input from `ODBTableViewController`. There are two methods available to trigger downloads independent of `ODBTableViewController`.

The first, `downloadDropboxFile`, downloads the provided file to a path within the specified downloads folder (either the app's cache or the custom download directory). A file path is provided in the completion handler.

    - (void)downloadDropboxFile:(NSString *)file completion:(void (^)(NSURL *filePath, NSError *error))finishBlock updateProgress:(void (^)(NSNumber *progress))progressChanged;

The other, `downloadDropboxFileData`, downloads the file data and passes it to the completion handler as an `NSData` object.

    - (void)downloadDropboxFileData:(NSString *)file completion:(void (^)(NSData *fileData, NSError *error))finishBlock updateProgress:(void (^)(NSNumber *progress))progressChanged;

### Logout
If the user has explicitly requested to revoke access to his or her account you need to call this method.

    - (void)clientRequestedLogout;
