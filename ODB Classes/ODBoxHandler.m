//
//  ODBoxHandler.m
//  OpenDropboxBrowser
//
//  Created by Sam Spencer on 2/10/17.
//  Copyright © 2017 Spencer Software. All rights reserved.
//

#import "ODBoxHandler.h"

@import MobileCoreServices;

const struct ODBFileDictionaryKeys ODBFileKeys = {
    .kDropboxFileType = @"type",
    .kDropboxFileTypeFile = @"file",
    .kDropboxFileTypeFolder = @"folder",
    .kDropboxFileName = @"name",
    .kDropboxFileSize = @"size",
    .kDropboxFileModifiedDate = @"modified",
    .kDropboxFileIcon = @"icon"
};

@interface ODBoxHandler ()

/// The client object returned from the SDK's authentication process if it was successful. This value may be nil if the client is not authenticated or there was an error.
@property (nonatomic, strong, nullable) DBUserClient *mainClient;

/// The app's Dropbox Authorization key.
@property (nonatomic, strong, nullable) NSString *appAuthorizationKey;

@end

@implementation ODBoxHandler

// MARK: -
// MARK: Object lifecycle

+ (ODBoxHandler *)sharedHandler {
    static ODBoxHandler *singleton;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        // Perform setup operations
        _mainClient = [DBClientsManager authorizedClient];
    }
    
    return self;
}

// MARK: -
// MARK: Authentication

- (void)prepareForPotentialSessionWithKey:(NSString *)appKey {
    [DBClientsManager setupWithAppKey:appKey];
    self.appAuthorizationKey = appKey;
    self.mainClient = [DBClientsManager authorizedClient];
}

- (void)handleDropboxAuthenticationResponse:(NSURL *)applicationReceivedURL {
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:applicationReceivedURL];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"[ODBoxHandler] Authorization success. User is logged into Dropbox.");
            self.mainClient = [DBClientsManager authorizedClient];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ODBoxHandler.authentication.success" object:nil];
        } else if ([authResult isCancel]) {
            NSLog(@"[ODBoxHandler] Authorization cancelled. Flow was manually canceled by user.");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ODBoxHandler.authentication.cancelled" object:nil];
        } else if ([authResult isError]) {
            NSLog(@"[ODBoxHandler] Authorization error. %@", authResult);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ODBoxHandler.authentication.error" object:nil];
        }
    }
}

- (BOOL)clientIsAuthenticated {
    self.mainClient = [DBClientsManager authorizedClient];
    
    if (self.mainClient) return YES;
    else return NO;
}

- (void)clientRequestedLogout {
    NSLog(@"[ODBoxHandler] Unlinking accounts and logging out of Dropbox...");
    [DBClientsManager unlinkAndResetClients];
}

- (BOOL)applicationIsConfiguredForAuthorization {
    // First, check if there is a valid authoirzation key.
    if (self.appAuthorizationKey == nil || [self.appAuthorizationKey isEqualToString:@""] || [self.appAuthorizationKey isEqualToString:@"APP_KEY"]) {
        NSLog(@"\n\n[ODBoxHandler] WARNING: The application has not specified an authorization key to be used with the Dropbox API. If you have not done so already, please visit https://www.dropbox.com/developers/apps and register your application. To set your app key for OpenDropboxBrowser, call prepareForPotentialSessionWithKey: in your app's didFinishLaunchingWithOptions: callback and supply your key in the method parameter.\n\n Failure to properly setup OpenDropboxBrowser before displaying the Browser Controller to the user will result in an incompatibility alert.\n\n");
        return NO;
    }
    
    // Check if the app's Transport Security Protocols are up to date.
    NSArray *appQuerySchemes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"LSApplicationQueriesSchemes"];
    if (appQuerySchemes == nil || appQuerySchemes.count == 0) {
        // No LSApplicationQueriesSchemes have been added.
        NSLog(@"\n\n[ODBoxHandler] WARNING: The application has not specified any LSApplicationQueriesSchemes in its Info.plist file. Add the following entry to your Info.plist file:\n    <key>LSApplicationQueriesSchemes</key>\n    <array>\n        <string>dbapi-8-emm</string>\n        <string>dbapi-2</string>\n    </array>\n\n Failure to properly setup OpenDropboxBrowser before displaying the Browser Controller to the user will result in an incompatibility alert.\n\n");
        return NO;
    } else {
        // Some LSApplicationQueriesSchemes have been added. We need to check if they are the correct entries.
        NSInteger appropriateAppQueryEntries = 0;
        for (NSString *entry in appQuerySchemes) {
            if ([entry isEqualToString:@"dbapi-8-emm"]) appropriateAppQueryEntries++;
            else if ([entry isEqualToString:@"dbapi-2"]) appropriateAppQueryEntries++;
        }
        
        if (appropriateAppQueryEntries < 2) {
            // The app has not supplied the correct entries in the Info.plist file.
            NSLog(@"\n\n[ODBoxHandler] WARNING: The application has not specified the correct entries for LSApplicationQueriesSchemes in its Info.plist file. Ensure the following two entries have been added to the LSApplicationQueriesSchemes array in your Info.plist file:\n    <string>dbapi-8-emm</string>\n    <string>dbapi-2</string>\n\n Failure to properly setup OpenDropboxBrowser before displaying the Browser Controller to the user will result in an incompatibility alert.\n\n");
            return NO;
        }
    }
    
    // Check if the app's URL callbacks match its app key.
    NSArray *appURLTypes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"];
    if (appURLTypes == nil || appURLTypes.count == 0) {
        // No CFBundleURLTypes have been added.
        NSLog(@"\n\n[ODBoxHandler] WARNING: The application has not specified any CFBundleURLTypes in its Info.plist file. Add the following entry to your Info.plist file:\n    <key>CFBundleURLTypes</key>\n    <dict>\n        <key>CFBundleURLSchemes</key>\n        <array>\n            <string>db-<APP_KEY></string>\n        </array>\n        <key>CFBundleURLName</key>\n        <string></string>\n    </dict>\n    </array>\n\n Failure to properly setup OpenDropboxBrowser before displaying the Browser Controller to the user will result in an incompatibility alert.\n\n");
        return NO;
    } else {
        // Some CFBundleURLTypes have been added. We need to check if there is a correct entry.
        BOOL appropriateAppURLEntry = NO;
        NSString *appropriateURLScheme = [NSString stringWithFormat:@"db-%@", self.appAuthorizationKey];
        for (NSDictionary *URLSchema in appURLTypes) {
            NSArray *URLSchemes = URLSchema[@"CFBundleURLSchemes"];
            for (NSString *URLScheme in URLSchemes) {
                if ([URLScheme isEqualToString:appropriateURLScheme]) {
                    appropriateAppURLEntry = YES;
                    break;
                }
            }
            
            // If we've found the right entry we can stop looping.
            if (appropriateAppURLEntry == YES) break;
        }
        
        if (appropriateAppURLEntry == NO) {
            // The app has not supplied the correct entries in the Info.plist file.
            NSLog(@"\n\n[ODBoxHandler] WARNING: The application has not specified the correct URL for CFBundleURLTypes in its Info.plist file. Ensure the following entry has been added to a CFBundleURLScheme in the CFBundleURLTypes array in your Info.plist file:\n    <string>db-%@</string>\n\n Failure to properly setup OpenDropboxBrowser before displaying the Browser Controller to the user will result in an incompatibility alert.\n\n", self.appAuthorizationKey);
            return NO;
        }
    }
    
    // At this point, if the method has not already returned NO, the app should be capable of passing authorization.
    return YES;
}

// MARK: -
// MARK: Downloads

- (void)downloadDropboxFile:(NSString *)file completion:(void (^)(NSURL *filePath, NSError *error))finishBlock updateProgress:(void (^)(NSNumber *progress))progressChanged {
    // Download to NSURL
    NSURL *outputDirectory = nil;
    if (self.customDownloadDirectory == nil)
        outputDirectory = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask][0];
    else
        outputDirectory = self.customDownloadDirectory;
    
    NSString *fileName = [[file lastPathComponent] stringByDeletingPathExtension];
    NSURL *outputURL = [outputDirectory URLByAppendingPathComponent:fileName];

    [[[self.mainClient.filesRoutes downloadUrl:file overwrite:self.downloadsOverwriteLocalConflicts destination:outputURL] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSURL * _Nonnull destination) {
        if (result) {
            NSLog(@"%@\n", result);
            NSData *data = [[NSFileManager defaultManager] contentsAtPath:[destination path]];
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"%@\n", dataStr);

            finishBlock(outputURL, nil);

            if ([self.delegate respondsToSelector:@selector(dropboxHandler:didFinishDownloadingFile:atURL:data:)])
                [self.delegate dropboxHandler:self didFinishDownloadingFile:fileName atURL:outputURL data:nil];
        } else {
            NSLog(@"%@\n%@\n", routeError, networkError);

            finishBlock(nil, networkError.nsError);

            if ([self.delegate respondsToSelector:@selector(dropboxHandler:didFailToDownloadFile:error:)])
                [self.delegate dropboxHandler:self didFailToDownloadFile:fileName error:networkError.nsError];

            // if ([self.delegate respondsToSelector:@selector(finishedDownloadingFileToLocalURL:)])
            // [self.delegate downloadEncounteredError:error];
        }
    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%lld\n%lld\n%lld\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        int64_t progress = totalBytesWritten / totalBytesExpectedToWrite;
        NSNumber *downloadProgress = [NSNumber numberWithUnsignedLongLong:progress];
        progressChanged(downloadProgress);
    }];
}

- (void)downloadDropboxFileData:(NSString *)file completion:(void (^)(NSData *fileData, NSError *error))finishBlock updateProgress:(void (^)(NSNumber *progress))progressChanged {
    NSString *fileName = [[file lastPathComponent] stringByDeletingPathExtension];
    
    // Download to NSData
    [[[self.mainClient.filesRoutes downloadData:file] setResponseBlock:^(DBFILESFileMetadata * _Nullable result, DBFILESDownloadError * _Nullable routeError, DBRequestError * _Nullable networkError, NSData * _Nullable fileData) {
        if (result) {
            NSLog(@"%@\n", result);
            NSString *dataStr = [[NSString alloc] initWithData:fileData encoding:NSUTF8StringEncoding];
            NSLog(@"%@\n", dataStr);

            finishBlock(fileData, nil);

            if ([self.delegate respondsToSelector:@selector(dropboxHandler:didFinishDownloadingFile:atURL:data:)])
                [self.delegate dropboxHandler:self didFinishDownloadingFile:fileName atURL:nil data:fileData];
        } else {
            finishBlock(nil, networkError.nsError);
            NSLog(@"%@\n%@\n", routeError, networkError);

            if ([self.delegate respondsToSelector:@selector(dropboxHandler:didFailToDownloadFile:error:)])
                [self.delegate dropboxHandler:self didFailToDownloadFile:fileName error:networkError.nsError];
        }
    }] setProgressBlock:^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%lld\n%lld\n%lld\n", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
        int64_t progress = totalBytesWritten / totalBytesExpectedToWrite;
        NSNumber *downloadProgress = [NSNumber numberWithUnsignedLongLong:progress];
        progressChanged(downloadProgress);
    }];
}

// MARK: -
// MARK: Files

- (void)fetchFileListsInDirectory:(NSString *)parentDirectory completion:(void (^)(NSArray *files, NSError *error))finishBlock {
    NSLog(@"[ODBoxHandler] Beginning file fetch...");
    
    if ([parentDirectory isEqualToString:@"/"]) parentDirectory = @"";
    [[self.mainClient.filesRoutes listFolder:parentDirectory recursive:@NO includeMediaInfo:@NO includeDeleted:@NO includeHasExplicitSharedMembers:@NO] setResponseBlock:^(DBFILESListFolderResult * _Nullable result, DBFILESListFolderError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        NSLog(@"[ODBoxHandler] Returned from file fetch.");
        if (result) {
            NSLog(@"[ODBoxHandler] New file list with %i entries", (int)result.entries.count);
            NSMutableArray *newFileList = [NSMutableArray arrayWithCapacity:result.entries.count];
            for (DBFILESMetadata *file in result.entries) {
                NSDictionary *fileEntry;
                if ([file isKindOfClass:[DBFILESFileMetadata class]]) {
                    // We have a file
                    DBFILESFileMetadata *fileObject = (DBFILESFileMetadata *)file;
                    NSString *fileIconName = [self fileIconForFileName:fileObject.name];
                    fileEntry = @{ODBFileKeys.kDropboxFileType : ODBFileKeys.kDropboxFileTypeFile, ODBFileKeys.kDropboxFileName : fileObject.name, ODBFileKeys.kDropboxFileSize : fileObject.size, ODBFileKeys.kDropboxFileModifiedDate : fileObject.serverModified, ODBFileKeys.kDropboxFileIcon : fileIconName};
                } else {
                    // We have a directory
                    DBFILESFolderMetadata *folder = (DBFILESFolderMetadata *)file;
                    fileEntry = @{ODBFileKeys.kDropboxFileType : ODBFileKeys.kDropboxFileTypeFolder, ODBFileKeys.kDropboxFileName : folder.name, ODBFileKeys.kDropboxFileIcon : @"folder"};
                }
                [newFileList addObject:fileEntry];
            }
            finishBlock(newFileList.copy, nil);
        } else {
            NSLog(@"[ODBoxHandler] Error fetching files: %@", networkError);
            finishBlock(nil, networkError.nsError);
        }
    }];
}

- (void)searchFileListsInDirectory:(NSString *)parentDirectory query:(NSString *)query completion:(void (^)(NSArray *files, NSError *error))finishBlock {
    [[self.mainClient.filesRoutes search:parentDirectory query:query] setResponseBlock:^(DBFILESSearchResult * _Nullable result, DBFILESSearchError * _Nullable routeError, DBRequestError * _Nullable networkError) {
        if (result) {
            NSMutableArray *matchList = [NSMutableArray arrayWithCapacity:result.matches.count];
            for (DBFILESSearchMatch *match in result.matches) {
                NSDictionary *fileEntry;
                if ([match.metadata isKindOfClass:[DBFILESFileMetadata class]]) {
                    // We have a file
                    DBFILESFileMetadata *fileObject = (DBFILESFileMetadata *)match.metadata;
                    NSString *fileIconName = [self fileIconForFileName:fileObject.name];
                    fileEntry = @{ODBFileKeys.kDropboxFileType : ODBFileKeys.kDropboxFileTypeFile, ODBFileKeys.kDropboxFileName: fileObject.name, ODBFileKeys.kDropboxFileSize : fileObject.size, ODBFileKeys.kDropboxFileModifiedDate : fileObject.serverModified,  ODBFileKeys.kDropboxFileIcon : fileIconName};
                } else {
                    // We have a directory
                    DBFILESFolderMetadata *folder = (DBFILESFolderMetadata *)match.metadata;
                    fileEntry = @{ODBFileKeys.kDropboxFileType : ODBFileKeys.kDropboxFileTypeFolder, ODBFileKeys.kDropboxFileName : folder.name,  ODBFileKeys.kDropboxFileIcon : @"folder"};
                }
                [matchList addObject:fileEntry];
            }

            finishBlock(matchList.copy, nil);
        } else {
            finishBlock(nil, networkError.nsError);
        }
    }];
}

+ (NSString *)encodeFolderPath:(NSString *)folder currentPath:(NSString *)path {
    return [NSString stringWithFormat:@"%@/%@", path, folder];;
}

- (NSString *)fileIconForFileName:(NSString *)fileName {
    CFStringRef fileExtension = (__bridge CFStringRef)[fileName pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    
    NSString *fileIconName;
    
    if (UTTypeConformsTo(fileUTI, kUTTypeImage)) fileIconName = @"image";
    else if (UTTypeConformsTo(fileUTI, kUTTypeMovie)) fileIconName = @"movie";
    else if (UTTypeConformsTo(fileUTI, kUTTypeAudio)) fileIconName = @"audio";
    else if (UTTypeConformsTo(fileUTI, kUTTypeText)) fileIconName = @"text";
    else if (UTTypeConformsTo(fileUTI, kUTTypeSpreadsheet)) fileIconName = @"spreadsheet";
    else if (UTTypeConformsTo(fileUTI, kUTTypePresentation)) fileIconName = @"presentation";
    else if (UTTypeConformsTo(fileUTI, kUTTypePDF)) fileIconName = @"pdf";
    else if (UTTypeConformsTo(fileUTI, kUTTypeScalableVectorGraphics)) fileIconName = @"vector";
    else if (UTTypeConformsTo(fileUTI, kUTTypeArchive)) fileIconName = @"package";
    else if (UTTypeConformsTo(fileUTI, kUTTypeDiskImage)) fileIconName = @"disc";
    else if (UTTypeConformsTo(fileUTI, kUTTypeSourceCode)) fileIconName = @"developer";
    else if (UTTypeConformsTo(fileUTI, kUTTypeSystemPreferencesPane)) fileIconName = @"settings";
    else fileIconName = @"text";
    
    CFRelease(fileUTI);
    
    return fileIconName;
}

@end
