//
//  ODBoxHandler.h
//  OpenDropboxBrowser
//
//  Created by Sam Spencer on 2/10/17.
//  Copyright © 2017 Spencer Software. All rights reserved.
//

@import Foundation;
@import Security;
@import ObjectiveDropboxOfficial;


NS_ASSUME_NONNULL_BEGIN

struct ODBFileDictionaryKeys {
    __unsafe_unretained NSString * const kDropboxFileType;
    __unsafe_unretained NSString * const kDropboxFileTypeFile;
    __unsafe_unretained NSString * const kDropboxFileTypeFolder;
    __unsafe_unretained NSString * const kDropboxFileName;
    __unsafe_unretained NSString * const kDropboxFileSize;
    __unsafe_unretained NSString * const kDropboxFileModifiedDate;
    __unsafe_unretained NSString * const kDropboxFileIcon;
};

extern const struct ODBFileDictionaryKeys ODBFileKeys;

@protocol ODBoxDelegate;

/// A high-level object to handle correspondence with the Dropbox SDK. Functions necessary for proper Dropbox integration are available here (i.e. authentication).
NS_CLASS_AVAILABLE_IOS(8_0) @interface ODBoxHandler : NSObject


// MARK: - 
// MARK: Object

/// Represents the single shared ODBHandler object.
+ (ODBoxHandler *)sharedHandler;

/// Delegate object for handling responses from requests.
@property (nonatomic, weak) id <ODBoxDelegate> delegate;


// MARK: - 
// MARK: Session & Authentication

/// Let Dropbox know that your app is interested in using Dropbox. Call this as soon as possible in your app's delegate didFinishLaunchingWithOptions: method.
- (void)prepareForPotentialSessionWithKey:(NSString *)appKey;

/// When the user finishes authentication, your app may be launched via URL. Supply the authentication URL here and ODBoxHandler will take care of the rest by appropriately updating.
- (void)handleDropboxAuthenticationResponse:(NSURL *)applicationReceivedURL;

/// Check if the current user is authenticated. May return NO in the event of an error or if the user is not authenticated.
- (BOOL)clientIsAuthenticated;

/// Call this method if the user has explicitly requested to revoke access to his or her account.
- (void)clientRequestedLogout;

/** Check if your application is properly configured to handle authentication and display Dropbox data. 
 @discussion You should call this message shortly after calling prepareForPotentialSessionWithKey: to ensure that Dropbox functionality will work in your app. There are three checks that this method makes to ensure proper configuration. First, your app must have a non-nil app key provided from Dropbox. Second, two schemes must be added to the LSApplicationQueriesSchemes in your app's Info.plist (dbapi-8-emm and dbapi-2). Lastly, your app must register its app key URL in the CFBundleURLTypes of the Info.plist.
 
 @warning Failure to meet all of these requirements in a shipping application will trigger a non-compatibility warning that may be presented to your user. In a non-shipping app, configuration failure will throw an exception. If you have properly configured everything this method should always return YES.
 
 @return YES if your application has been properly configured to use Dropbox. NO if there are issues with your configuration (please check the log for specific details on what went wrong).*/
- (BOOL)applicationIsConfiguredForAuthorization;


// MARK: - 
// MARK: Downloads

/// Optionally set a custom directory within your application's sandbox to which any selected files should be downloaded. This must be a local NSURL object on the file system and must be within your application's sandbox. If you supply an invalid file URL, or one for which your app does not have write permissions files will be downloaded to the application's cache directory. The cache directory is, from time to time, purged by the system so it is your app's responsibility to process any files downloaded to the cache.
@property (nonatomic, strong, nullable) NSURL *customDownloadDirectory;

/// Set to YES to overwrite local files that are conflicting with a new download from the Dropbox server. Defaults to NO, which returns an error and stops when there is a conflict.
@property (nonatomic, assign) BOOL downloadsOverwriteLocalConflicts;

/** Download the specified file (using its Dropbox path) to local storage.
 @param file The Dropbox file's relevant path. 
 @seealso customDownloadDirectory
 @seealso downloadsOverwriteLocalConflicts */
- (void)downloadDropboxFile:(NSString *)file completion:(void (^)(NSURL *filePath, NSError *error))finishBlock updateProgress:(void (^)(NSNumber *progress))progressChanged;

/** Download the specified file (using its Dropbox path) to an NSData object. 
 @param file The Dropbox file's relevant path. */
- (void)downloadDropboxFileData:(NSString *)file completion:(void (^)(NSData *fileData, NSError *error))finishBlock updateProgress:(void (^)(NSNumber *progress))progressChanged;


// MARK: - 
// MARK: Files

/** Fetch a list of files in a specified Dropbox directory.
 @param parentDirectory The directory in Dropbox for which to retrieve a list of files. */
- (void)fetchFileListsInDirectory:(NSString *)parentDirectory completion:(void (^)(NSArray *files, NSError *error))finishBlock;

/** Fetch a list of files in a specified Dropbox directory.
 @param parentDirectory The directory in Dropbox for which to retrieve a list of files. 
 @param query The search query. */
- (void)searchFileListsInDirectory:(NSString *)parentDirectory query:(NSString *)query completion:(void (^)(NSArray *files, NSError *error))finishBlock;

+ (NSString *)encodeFolderPath:(NSString *)folder currentPath:(NSString *)path;

@end

@protocol ODBoxDelegate <NSObject>

/// Sent to the delegate when there is a successful file download
- (void)dropboxHandler:(ODBoxHandler *)handler didFinishDownloadingFile:(NSString *)fileName atURL:(nullable NSURL *)localFileDownload data:(nullable NSData *)fileData;

/// Sent to the delegate if ODBoxHandler failed to download file from Dropbox
- (void)dropboxHandler:(ODBoxHandler *)handler didFailToDownloadFile:(NSString *)fileName error:(NSError *)error;

/// Sent to the delegate if the selected file already exists locally
// - (void)dropboxHandler:(ODBoxHandler *)handler fileConflictWithLocalFile:(NSURL *)localFileURL dropboxFile:(NSDictionary *)dropboxFile error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
