//
//  DropboxDataController.m
//  epaper
//
//  Created by daniel bierwirth on 3/6/12.
//  Copyright (c) 2013 iRare Media. All rights reserved.
//

#import "DropboxDataController.h"

@interface DropboxDataController () <DBRestClientDelegate>

- (DBRestClient *)restClient;

@end

@implementation DropboxDataController
@synthesize dataDelegate, list;

//------------------------------------------------------------------------------------------------------------//
//Region: Setup ----------------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Setup

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (id)init
{
    if (self = [super init]) {
        
    }
    return self;
}

- (void)setList:(NSMutableArray *)newList {
    if (list != newList) {
        list = [newList mutableCopy];
    }
}

//------------------------------------------------------------------------------------------------------------//
//Region: Files and Directories ------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - Dropbox File and Directory Functions

- (BOOL)listDirectoryAtPath:(NSString *)path
{
    if ([self isDropboxLinked]) {
        [[self restClient] loadMetadata:path];
        return TRUE;
    } else {
        return FALSE;
    }
}
- (BOOL)listHomeDirectory
{
    return [self listDirectoryAtPath:@"/"];
}

- (BOOL)isDropboxLinked
{
    return [[DBSession sharedSession] isLinked];
}

- (BOOL)downloadFile:(DBMetadata *)file {
    
    BOOL res = FALSE;

    if (!file.isDirectory) {
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *localPath = [documentsPath stringByAppendingPathComponent:file.filename];
        if(![[NSFileManager defaultManager] fileExistsAtPath:localPath]) {
            if ([[self dataDelegate] respondsToSelector:@selector(startDownloadFile)])
                [[self dataDelegate] startDownloadFile];
            
            res = TRUE;
            [[self restClient] loadFile:file.path intoPath:localPath];
        } else {
            NSURL *fileUrl = [NSURL URLWithString:localPath];
            NSDate *fileDate;
            NSError *error;
            [fileUrl getResourceValue:&fileDate forKey:NSURLContentModificationDateKey error:&error];
            if (!error) {
                #warning Handle any file conflicts here
                NSComparisonResult result; //has three possible values: NSOrderedSame,NSOrderedDescending, NSOrderedAscending
                result = [file.lastModifiedDate compare:fileDate]; //Compare the Dates
                if (result == NSOrderedAscending || result == NSOrderedSame) {
                    //Dropbox File is older than local file
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Already Downloaded"
                                                                        message:[NSString stringWithFormat:@"%@ is already in your Documents folder.", file.filename]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                    [alertView show];
                } else if (result == NSOrderedDescending) {
                    //Dropbox File is newer than local file
                    NSLog(@"Dropbox File is newer than local file");
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"File Conflict"
                                                                        message:[NSString stringWithFormat:@"%@ exists in both your Dropbox and in your Documents folder. The one in Dropbox is newer.", file.filename]
                                                                       delegate:nil
                                                              cancelButtonTitle:@"Okay"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                
                if ([[self dataDelegate] respondsToSelector:@selector(updateTableData)])
                    [[self dataDelegate] updateTableData];
            }
        }
    }
        
    return res;
}

//------------------------------------------------------------------------------------------------------------//
//Region: Dropbox Delegate -----------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------------------------------//
#pragma mark - DBRestClientDelegate methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    NSMutableArray *dirList = [[NSMutableArray alloc] init];
    
    if (metadata.isDirectory) {
        for (DBMetadata *file in metadata.contents) {
            //Check if directory or document
            if ([file isDirectory] || ![file.filename hasSuffix:@".exe"]) {
                //Push new tableviewcontroller
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

@end
