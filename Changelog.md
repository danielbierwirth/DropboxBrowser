## Change Log
This project is ready for primetime use in any iOS application. Here are a few key changes in the project:  

**Version 5.0**
Beta. Coming soon. Check the feature branch for the latest stuff!

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
