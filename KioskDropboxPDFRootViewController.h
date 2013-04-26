//
//  KioskDropboxPDFRootViewController.h
//  epaper
//
//  Created by Daniel Bierwirth on 3/5/12. Edited and Updated by iRare Media on 2/24/13
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


#import <UIKit/UIKit.h>
#import "KioskDropboxPDFDataController.h"
#import "MBProgressHUD.h"
#import "KioskDropboxPDFDataController.h"
#import <DropboxSDK/DropboxSDK.h>

typedef enum {
    DisclosureFileType
    , DisclosureDirType
} DisclosureType;

@protocol KioskDropboxPDFRootViewControllerDelegate;

@interface KioskDropboxPDFRootViewController : UITableViewController <KioskDropboxPDFDataControllerDelegate>


@property (nonatomic, weak) id <KioskDropboxPDFRootViewControllerDelegate>  rootViewDelegate;
@property (nonatomic, strong) KioskDropboxPDFDataController *dataController;

// Reflect current path and name
@property (nonatomic, strong) NSString *currentPath;
+ (NSString*)fileName;

// Display buisy indicator while loading new directory infos
@property (strong, nonatomic) MBProgressHUD *hud;
// Download indicator in toolbar to indicate progress of pdf file download
@property (strong, nonatomic) UIProgressView *downloadProgressView;
// List content of home directory inside rootview controller
- (BOOL) listHomeDirectory;

@end

@protocol KioskDropboxPDFRootViewControllerDelegate <NSObject>

- (void)loadedFileFromDropbox:(NSString *)fileName;

@end
