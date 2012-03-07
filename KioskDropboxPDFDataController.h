//
//  KioskDropboxPDFDataController.h
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DBRestClient;
@class DBMetadata;

@protocol KioskDropboxPDFDataControllerDelegate;

@interface KioskDropboxPDFDataController : NSObject {
    DBRestClient *restClient;
}

@property (nonatomic, weak) id <KioskDropboxPDFDataControllerDelegate> dataDelegate;

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
 * ok, file was downloaded - tell delegate about it
 */
- (void) downloadedFile;
@end

