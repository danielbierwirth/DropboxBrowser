//
//  KioskDropboxPDFDataController.h
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

@class DBRestClient;
@class DBMetadata;

@protocol KioskDropboxPDFDataControllerDelegate;

@interface KioskDropboxPDFDataController : NSObject {
    DBRestClient *restClient;
}

@property (nonatomic) id <KioskDropboxPDFDataControllerDelegate> dataDelegate;

@property (nonatomic, copy, readwrite) NSMutableArray *list;

/**
 * ask dropbox to list the content of our home '/' directory
 */
- (BOOL) listHomeDirectory;
/**
 * list content of specific i.e. subdirectories
 */
- (BOOL) listDirectoryAtPath:(NSString*)path;
/**
 * ok, let's check if app is linked to dropbox
 */
- (BOOL) isDropboxLinked;

/**
 * called on download button press - see root controller
 */
- (BOOL) downloadFile:(DBMetadata *)file;

@end

@protocol KioskDropboxPDFDataControllerDelegate <NSObject>
/**
 * ok, dropbox returned new infos. let's update the tableview to
 * reflect those changes
 */
- (void) updateTableData;
/**
 * started file download - show progressbar
 */
- (void) startDownloadFile;
/**
 * ok, file was downloaded - tell delegate about it
 */
- (void) downloadedFile;
/**
 * Ups, something went wrong - hide progressbar
 */
- (void) downloadedFileFailed;
/**
 * update progressbar to reflect current download progress
 */
- (void) updateDownloadProgressTo:(CGFloat) progress;
@end

