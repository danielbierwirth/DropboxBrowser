//
//  KioskDropboxPDFDataController.m
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2012 iRare Media. All rights reserved.
//

#import "KioskDropboxPDFDataController.h"

@interface KioskDropboxPDFDataController () <DBRestClientDelegate>

@end

@interface KioskDropboxPDFDataController (fileimport)
- (DBRestClient *)restClient;
@end

@implementation KioskDropboxPDFDataController (fileimport)
- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = 
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}
@end

@implementation KioskDropboxPDFDataController

#pragma mark - public functions
- (BOOL) listDirectoryAtPath:(NSString*)path {
    if ([self isDropboxLinked]) {
        [[self restClient] loadMetadata:path];
        return TRUE;
    }
    else {
        return FALSE;
    }
}
- (BOOL) listHomeDirectory {
    return [self listDirectoryAtPath:@"/"];
}

- (BOOL) isDropboxLinked {
    return [[DBSession sharedSession] isLinked];
}

- (BOOL) downloadFile:(DBMetadata *)file {
    BOOL res = FALSE;

    if (!file.isDirectory) {
        
        NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString* localPath = [documentsPath stringByAppendingPathComponent:file.filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            
            if ([[self dataDelegate] respondsToSelector:@selector(startDownloadFile)])
                [[self dataDelegate] startDownloadFile];
            
            res = TRUE;
            [[self restClient] loadFile:file.path intoPath:localPath];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Note"
                                                                message:@"That file was already downloaded. It exists locally."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
            [alertView show];
        }
    }
        
    return res;
}

#pragma mark - init 
- (id)init {
    if (self = [super init]) {
    }
    return self;
}

- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        list = [newList mutableCopy];
    }
}

#pragma mark DBRestClientDelegate methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            // check if directory or pdf document
            if ([file isDirectory] || ![file.filename hasSuffix:@".exe"]) {
                // push new tableviewcontroller
                [dirList addObject:file];
            }
        }
    }
    
    self.list = dirList;
    
    if ([[self dataDelegate] respondsToSelector:@selector(updateTableData)])
        [[self dataDelegate] updateTableData];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    if ([[self dataDelegate] respondsToSelector:@selector(updateTableData)])
        [[self dataDelegate] updateTableData];
    
}

- (void)restClient:(DBRestClient*)client loadedFile:(NSString*)localPath {

    if ([[self dataDelegate] respondsToSelector:@selector(downloadedFile)])
        [[self dataDelegate] downloadedFile];

}

- (void)restClient:(DBRestClient*)client loadFileFailedWithError:(NSError*)error {
    if ([[self dataDelegate] respondsToSelector:@selector(downloadedFileFailed)])
        [[self dataDelegate] downloadedFileFailed];
}

- (void)restClient:(DBRestClient*)client loadProgress:(CGFloat)progress forFile:(NSString*)destPath {
    
    if ([[self dataDelegate] respondsToSelector:@selector(updateDownloadProgressTo:)])
        [[self dataDelegate] updateDownloadProgressTo:progress];
}


#pragma mark - synthesize stuff
@synthesize dataDelegate;
@synthesize list;

@end
