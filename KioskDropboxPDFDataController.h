//
//  KioskDropboxPDFDataController.h
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license. 

// Copyright (c) 2013 Daniel Bierwirth
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.


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

