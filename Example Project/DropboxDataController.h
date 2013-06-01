//
//  DropboxDataController.h
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@class DBRestClient;
@class DBMetadata;

@protocol DropboxDataControllerDelegate;

@interface DropboxDataController : NSObject {
    DBRestClient *restClient;
}

@property (nonatomic) id <DropboxDataControllerDelegate> dataDelegate;

@property (nonatomic, copy, readwrite) NSMutableArray *list;

//Ask dropbox to list the content of our home '/' directory
- (BOOL)listHomeDirectory;

//List content of specific subdirectories
- (BOOL)listDirectoryAtPath:(NSString*)path;

//Check if app is linked to dropbox
- (BOOL) isDropboxLinked;

//Called on download button press - see root controller
- (BOOL) downloadFile:(DBMetadata *)file;

@end

@protocol DropboxDataControllerDelegate <NSObject>

//Dropbox returned new info, update the tableview to reflect those changes
- (void) updateTableData;

//Started file download - show progressbar
- (void) startDownloadFile;

//File was downloaded - tell delegate about it
- (void) downloadedFile;

//Something went wrong - hide progressbar
- (void) downloadedFileFailed;

//Update progressbar to reflect current download progress
- (void) updateDownloadProgressTo:(CGFloat) progress;

@end

