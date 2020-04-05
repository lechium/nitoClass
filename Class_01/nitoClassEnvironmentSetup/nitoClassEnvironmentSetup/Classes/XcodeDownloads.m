//
//  XcodeDownloads.m
//  nitoClassEnvironmentSetup
//
//  Created by Kevin Bradley on 3/28/20.
//  Copyright © 2020 nito. All rights reserved.
//

#import "XcodeDownloads.h"
#import "HelperClass.h"


@implementation XcodeDownload

- (NSString *)description {
    
    NSString *orig = [super description];
    return [NSString stringWithFormat:@"%@ url: %@ type: %u", orig, self.downloadURL, self.downloadType];
    
}

@end

@implementation XcodeDownloads {
    NSMutableArray *_backingArray;
    XcodeDownload *_currentDownload;
}

- (instancetype)init {
    self = [super init];
    if (self){
        _backingArray = [NSMutableArray new];
        _sytemVersion = [HelperClass currentVersion];
        [self _populateInfo];
        _xcodeInstalled = [HelperClass xcodeInstalled];
        _cliInstalled = [HelperClass commandLineToolsInstalled];
        _operationQueue = [NSOperationQueue mainQueue];
    }
    return self;
}

- (void)_populateInfo {
    
    switch (_sytemVersion) {
        case NCSystemVersionTypeCatalina:
        {
            _systemVersionCodename = @"Catalina or Later";
            if (![HelperClass commandLineToolsInstalled]){
                XcodeDownload *xcD = [XcodeDownload new];
                xcD.downloadURL = @"https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.4/Command_Line_Tools_for_Xcode_11.4.dmg";
                xcD.SHA = @"e25d10afdc87922f0fc7da2ca6f08d3b54a55c1f";
                xcD.expectedSize =  260497052;
                xcD.extractedSize = 0;
                xcD.downloadType = FileDownloadTypeCLI;
                [_backingArray addObject:xcD];
            }
            if (![HelperClass xcodeInstalled]){
                XcodeDownload *xcD = [XcodeDownload new];
                xcD.downloadURL = @"https://download.developer.apple.com/Developer_Tools/Xcode_11.4/Xcode_11.4.xip";
                xcD.SHA = @"7c1151670760be55c5c8b09be1aa2a17291dc468";
                xcD.expectedSize =  8111919274;
                xcD.extractedSize = 16830997095;
                //26430173184
                //16830997095
                //8111919274
                xcD.downloadType = FileDownloadTypeXcode;
                [_backingArray addObject:xcD];
            }
          
            self.downloads = _backingArray;
            _xcodeDownloadURL = @"https://download.developer.apple.com/Developer_Tools/Xcode_11.4/Xcode_11.4.xip"; //8.11 GB compressed + 9.43 extracted
            _commandLineURL = @"https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.4/Command_Line_Tools_for_Xcode_11.4.dmg"; //248 MB
        }
            break;
            
        case NCSystemVersionTypeMojave:{
            _systemVersionCodename = @"Mojave";
            if (![HelperClass commandLineToolsInstalled]){
                XcodeDownload *xcD = [XcodeDownload new];
                xcD.downloadType = FileDownloadTypeCLI;
                xcD.SHA = @"cec5824d127bba2d2a3ba8e5343ae7a32214e62c";
                xcD.downloadURL = @"https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.3.1/Command_Line_Tools_for_Xcode_11.3.1.dmg";
                xcD.expectedSize = 230414298;
                xcD.extractedSize = 0;
                [_backingArray addObject:xcD];
            }
            if (![HelperClass xcodeInstalled]){
                XcodeDownload *xcD = [XcodeDownload new];
                xcD.downloadURL = @"https://download.developer.apple.com/Developer_Tools/Xcode_11.3.1/Xcode_11.3.1.xip";
                xcD.SHA = @"d5773e61189595cbb639c3e1c460b38d8c1e19ae";
                xcD.expectedSize =  7843352719;
                xcD.extractedSize = 16153777856;
                xcD.downloadType = FileDownloadTypeXcode;
                [_backingArray addObject:xcD];
            }
        
            self.downloads = _backingArray;
            _xcodeDownloadURL = @"https://download.developer.apple.com/Developer_Tools/Xcode_11.3.1/Xcode_11.3.1.xip"; //7.3 GB compressed
            _commandLineURL = @"https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.3.1/Command_Line_Tools_for_Xcode_11.3.1.dmg"; //219.7 MB
        }
            break;
            
        case NCSystemVersionTypeHighSierra:{
            _systemVersionCodename = @"High Sierra";
            if (![HelperClass commandLineToolsInstalled]){
                XcodeDownload *xcD = [XcodeDownload new];
                xcD.downloadType = FileDownloadTypeCLI;
                xcD.SHA = @"e4084bece08e6af1c2e3c44381a0fec54ff0639c";
                //e4084bece08e6af1c2e3c44381a0fec54ff0639c
                xcD.downloadURL = @"https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.13_for_Xcode_10/Command_Line_Tools_macOS_10.13_for_Xcode_10.dmg";
                xcD.expectedSize = 195780760;
                xcD.extractedSize = 0;
                [_backingArray addObject:xcD];
            }
            if (![HelperClass xcodeInstalled]){
                XcodeDownload *xcD = [XcodeDownload new];
                xcD.downloadURL = @"https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip";
                xcD.SHA = @"6a6667303750ce9c238da8a4ea76d54eefe2bbc4";
                xcD.expectedSize =  6047806709;
                xcD.extractedSize = 12474773249;
                xcD.downloadType = FileDownloadTypeXcode;
                [_backingArray addObject:xcD];
            }
       
            self.downloads = _backingArray;
            _xcodeDownloadURL  = @"https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip"; //5.6 GB compressed
            _commandLineURL = @"https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.13_for_Xcode_10/Command_Line_Tools_macOS_10.13_for_Xcode_10.dmg"; //186.7 MB
        }
        default:
            break;
    }
    
}

- (BOOL)hasDownloads {
    return (self.downloads.count > 0);
}

- (XcodeDownload *)downloadFromURL:(NSURL *)url {
    //NLog(@"downloads: %@ downloadFromURL: %@", self.downloads, url.absoluteString);
    return [[self.downloads filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"downloadURL == %@", url.absoluteString]] lastObject];
}


- (void)downloadFile:(XcodeDownload *)download {
   
    NLog(@"downloading file: %@", download);
    DownloadOperation *downloadOp = [[DownloadOperation alloc] initWithURL:[NSURL URLWithString:download.downloadURL] progresss:^(NSString *name, double percentComplete, double writtenBytes, double expectedBytes) {
        if (self.FancyProgressBlock){
            self.FancyProgressBlock(name, percentComplete, writtenBytes, expectedBytes);
        }
    } completed:^(NSString *downloadedFile, XcodeDownload *object) {
        if (self.CompletedBlock){
            self.CompletedBlock(downloadedFile, object);
        }
    }];
    downloadOp.xcodeDownload = download;
    [self.operationQueue addOperation:downloadOp];
    downloadOp.completionBlock = ^{
        
        if (self.operationQueue.operationCount == 1){
            NLog(@"lastop, we out here!");
            if (self.DownloadsFinishedBlock){
                self.DownloadsFinishedBlock();
            }
        }
    };
}

- (void)downloadFileURL:(NSURL *)url {
    
    DownloadOperation *downloadOp = [[DownloadOperation alloc] initWithURL:url progresss:^(NSString *name, double percentComplete, double writtenBytes, double expectedBytes) {
        
        if (self.FancyProgressBlock){
            self.FancyProgressBlock(name, percentComplete, writtenBytes, expectedBytes);
        }
    } completed:^(NSString *downloadedFile, id object) {
        if (self.CompletedBlock){
            self.CompletedBlock(downloadedFile, nil);
        }
    }];
   
    [self.operationQueue addOperation:downloadOp];
    downloadOp.completionBlock = ^{
        
        if (self.operationQueue.operationCount == 1){
            NLog(@"lastop, we out here!");
            if (self.DownloadsFinishedBlock){
                self.DownloadsFinishedBlock();
            }
        }
    };
}

- (void)cancelAllDownloads {
    
    [[self.operationQueue operations] enumerateObjectsUsingBlock:^(__kindof NSOperation * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [obj cancel];
        DDLogInfo(@"cancelling: %@", obj);
    }];
    
}

@end
