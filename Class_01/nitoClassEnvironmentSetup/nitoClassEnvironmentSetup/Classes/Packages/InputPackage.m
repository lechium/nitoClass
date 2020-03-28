#import "InputPackage.h"
#import "ErrorReturn.h"
#import "HelperClass.h"

@implementation InputPackage

- (NSString*) description {
    
    NSString *orig = [super description];
    NSMutableDictionary *details = [NSMutableDictionary new];
    NSArray *props = [self properties];
    [props enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *cv = [self valueForKey:obj];
        if (cv){
            details[obj] = cv;
        }
        
    }];
    return [NSString stringWithFormat:@"%@ = %@", orig, details];
    
}

- (NSString *)listfile {
    
    __block NSMutableArray *outFiles = [NSMutableArray new];
    [self.files enumerateObjectsUsingBlock:^(InputPackageFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.fileType isEqualToString:@"link"]){ //does this need to handle things differently?
            [outFiles addObject:obj.path];
        } else {
            [outFiles addObject:obj.path];
        }
    }];
    return [outFiles componentsJoinedByString:@"\n"];
    
}


- (BOOL)fileIsSymbolicLink:(NSString *)file {
    
    NSString *fileType = [[NSFileManager defaultManager] attributesOfItemAtPath:file error:nil][NSFileType];
    return ([fileType isEqualToString:NSFileTypeSymbolicLink] || [fileType isEqualToString:NSFileTypeDirectory]);
}

- (void)flattenIfNecessary:(NSString *)file {
    if ([self fileIsSymbolicLink:file]){
        DLog(@"skipping symbolic link: %@", file);
        return;
    }
    NSFileManager *man = [NSFileManager defaultManager];
    NSString *fat = [HelperClass singleLineReturnForProcess:[NSString stringWithFormat:@"/usr/bin/lipo -info %@",file]];
    if ([fat containsString:@"Architectures"]){
        NSString *newFile = [file stringByAppendingPathExtension:@"thin"];
        [HelperClass singleLineReturnForProcess:[NSString stringWithFormat:@"/usr/bin/lipo -thin arm64 %@ -output %@",file, newFile]];
        if ([man fileExistsAtPath:newFile]){
            
            [man removeItemAtPath:file error:nil];
            [man moveItemAtPath:newFile toPath:file error:nil];
        }
     
        // @"sudo lipo -thin arm64 $input.og -output $input";
    }
}

- (void)codesignRetainingSignature:(NSString *)file {
    
    NSString *jtp = [HelperClass singleLineReturnForProcess:@"/usr/bin/which jtool"];
    if (jtp){
        
        [[NSFileManager defaultManager] removeItemAtPath:@"/tmp/ent.plist" error:nil];
        [HelperClass singleLineReturnForProcess:[NSString stringWithFormat:@"%@ %@ --ent > /tmp/ent.plist", jtp, file]];
        NSString *ents = [HelperClass singleLineReturnForProcess:@"/bin/cat /tmp/ent.plist"];
        DLog(@"ents: %@", ents);
        NSString *runCommand = [NSString stringWithFormat:@"%@ --sign platform %@ --ent /tmp/ent.plist --inplace", jtp, file];
        
        DLog(@"running codesign command: %@", runCommand);
        
        NSString *returnValue = [HelperClass singleLineReturnForProcess:runCommand];
        
        DLog(@"returnValue: %@", returnValue);
        
    }
}

- (void)codesignIfNecessary:(NSString *)file {
    
    if (![[[file pathExtension] lowercaseString] isEqualToString:@"dylib"]){
        return;
    }
    
    NSString *jtp = [HelperClass singleLineReturnForProcess:@"/usr/bin/which jtool"];
    if (jtp){
        
        NSString *proc = [[HelperClass arrayReturnForTask:jtp withArguments:@[@"--sig", file]] componentsJoinedByString:@"\n"];
        
        NSLog(@"proc: %@", proc);
        
        if ([proc containsString:@"No Code Signing blob detected in this file"]){
            
            NSString *runCommand = [NSString stringWithFormat:@"%@ --sign platform %@ --inplace", jtp, file];
            
            NSLog(@"running codesign command: %@", runCommand);
            
            NSString *returnValue = [HelperClass singleLineReturnForProcess:runCommand];
            
            NSLog(@"returnValue: %@", returnValue);
        }
    }
}

- (void)flattenInPath:(NSString *)thePath {
    
    [self.files enumerateObjectsUsingBlock:^(InputPackageFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *file = [thePath stringByAppendingPathComponent:obj.path];
        NSLog(@"check sig file: %@", file);
        [self flattenIfNecessary:file];
    }];
    
}

- (void)validateSignaturesInPath:(NSString *)thePath {
    
    [self.files enumerateObjectsUsingBlock:^(InputPackageFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *file = [thePath stringByAppendingPathComponent:obj.path];
        NSLog(@"check sig file: %@", file);
        [self codesignIfNecessary:file];
    }];
    
}

- (void)bumpVersionInCurrentDirectory {
    
    NSString *fakeRoot = [HelperClass singleLineReturnForProcess:@"/usr/bin/which fakeroot"];
    NSString *pwd = [HelperClass singleLineReturnForProcess:@"/bin/pwd"];
    DLog(@"\nProcessing file: %@\n", self.path);
    InputPackage *output = self;
    
    DLog(@"\nFound package: '%@' at version: '%@'...\n", output.packageName, output.version );
    
    NSString *tmpPath = [pwd stringByAppendingPathComponent:output.packageName];
    NSString *debian = [tmpPath stringByAppendingPathComponent:@"DEBIAN"];
    [FM createDirectoryAtPath:tmpPath withIntermediateDirectories:TRUE attributes:nil error:nil];
    DLog(@"\nExtracting package contents for processing...\n");
    [HelperClass returnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -x %@ %@", self.path, tmpPath]];
    [FM createDirectoryAtPath:debian withIntermediateDirectories:TRUE attributes:nil error:nil];
    DLog(@"\nExtracting DEBIAN files for processing...\n");
    [HelperClass returnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -e %@ %@", self.path, debian]];
    
    
    NSString *controlPath = [debian stringByAppendingPathComponent:@"control"];
    
    NSMutableString *controlFile = [[NSMutableString alloc] initWithContentsOfFile:controlPath encoding:NSASCIIStringEncoding error:nil];
    //@"appletvos-arm64"
    [controlFile replaceOccurrencesOfString:self.version withString:[self.version nextVersionNumber] options:NSLiteralSearch range:NSMakeRange(0, [controlFile length])];
    
    [controlFile writeToFile:controlPath atomically:TRUE];
    
    //at this point we have the files extracted, time to determine what needs to be changed
    
    NSArray *ignoreFiles = @[@".fauxsu", @".DS_Store"];
    NSArray *forbiddenRoots = @[@"etc", @"var", @"tmp"];
    
    [self validateSignaturesInPath:tmpPath];
    
    //__block NSMutableArray *_overwriteArray = [NSMutableArray new];
    [self.files enumerateObjectsUsingBlock:^(InputPackageFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.type == BSPackageFileTypeFile || obj.type == BSPackageFileTypeDirectory){
            
            //DLog(@"processing path: %@", obj.path);
            if ([obj.path isEqualToString:@"/private/var/mobile/Applications/"]){
                
                NSString *badPath = [tmpPath stringByAppendingPathComponent:obj.path];
                NSString *newPath = [tmpPath stringByAppendingPathComponent:@"Applications"];
                DLog(@"\n [INFO] Moving %@ to %@...", badPath, newPath);
                [FM moveItemAtPath:badPath toPath:newPath error:nil];
                [FM removeItemAtPath:[tmpPath stringByAppendingPathComponent:@"private"] error:nil];
                *stop = TRUE;
            }
            
            NSString *fullPath = [tmpPath stringByAppendingPathComponent:obj.path];
            
            if ([ignoreFiles containsObject:obj.path.lastPathComponent]){
                
                DLog(@"in ignore file list, purge");
                [FM removeItemAtPath:fullPath error:nil];
                
            }
            
            NSArray *pathComponents = [obj.path pathComponents];
            if ([pathComponents count] > 1)
            {
                
                NSString *rootPath = [pathComponents objectAtIndex:1];
                //DLog(@"\n Checking root path: %@ for file %@\n", rootPath, obj.path);
                if ([forbiddenRoots containsObject:rootPath])
                {
                    DLog(@"\n [WARNING] package file: '%@' would overwrite symbolic link at '%@'\n", obj.path, rootPath);
                    NSString *privateDir = [tmpPath stringByAppendingPathComponent:@"private"];
                    if (![FM fileExistsAtPath:privateDir]){
                        [FM createDirectoryAtPath:privateDir withIntermediateDirectories:TRUE attributes:nil error:nil];
                        
                    }
                    //take <package_name>/[rootPath] (could be etc, var, tmp) and move to <package_name>/private/[rootPath]
                    NSString *badPath = [tmpPath stringByAppendingPathComponent:rootPath];
                    NSString *newPath = [privateDir stringByAppendingPathComponent:rootPath];
                    DLog(@"\n [INFO] Moving %@ to %@...", badPath, newPath);
                    [FM moveItemAtPath:badPath toPath:newPath error:nil];
                    
                    
                }
            }
            
            
        }
        
        
    }];
    
    
    NSString *depArchiveInfo = [NSString stringWithFormat:@"/usr/local/bin/dpkg -b %@", self.packageName];
    
    if (fakeRoot) {
        
        depArchiveInfo = [NSString stringWithFormat:@"%@ /usr/local/bin/dpkg -b %@", fakeRoot, self.packageName];
        
        
    }
    
    [[HelperClass returnForProcess:depArchiveInfo] componentsJoinedByString:@"\n"];
    
    
    
    DLog(@"\nDone!\n\n");
    
    //return er;
}

- (void)repackageInCurrentDirectoryWithArch:(NSString *)newArch {
    
    NSString *fakeRoot = [HelperClass singleLineReturnForProcess:@"/usr/bin/which fakeroot"];
    NSString *pwd = [HelperClass singleLineReturnForProcess:@"/bin/pwd"];
    DLog(@"\nProcessing file: %@\n", self.path);
    InputPackage *output = self;
    
    DLog(@"\nFound package: '%@' at version: '%@'...\n", output.packageName, output.version );
    
    NSString *tmpPath = [pwd stringByAppendingPathComponent:output.packageName];
    NSString *debian = [tmpPath stringByAppendingPathComponent:@"DEBIAN"];
    [FM createDirectoryAtPath:tmpPath withIntermediateDirectories:TRUE attributes:nil error:nil];
    DLog(@"\nExtracting package contents for processing...\n");
    [HelperClass returnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -x %@ %@", self.path, tmpPath]];
    [FM createDirectoryAtPath:debian withIntermediateDirectories:TRUE attributes:nil error:nil];
    DLog(@"\nExtracting DEBIAN files for processing...\n");
    [HelperClass returnForProcess:[NSString stringWithFormat:@"/usr/local/bin/dpkg -e %@ %@", self.path, debian]];
    
    //clean up any calls to uicache
    
    NSString *postinst = [debian stringByAppendingPathComponent:@"postinst"];
    
    //DLog(@"post inst: %@", postinst);
    
    if ([FM fileExistsAtPath:postinst]){
        NSString *postinstSource = [NSString stringWithContentsOfFile:postinst encoding:NSUTF8StringEncoding error:nil];
        if (postinstSource.length > 0){
            if ([postinstSource rangeOfString:@"uicache"].location != NSNotFound){
                
                NSMutableArray *lines = [[postinstSource componentsSeparatedByString:@"\n"] mutableCopy];
                
                //DLog(@"lines: %@", lines);
                
                __block NSInteger markedForDeath = NSNotFound;
                [lines enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    //  DLog(@"obj: %@", obj);
                    
                    if ([obj rangeOfString:@"uicache"].location != NSNotFound){
                        
                        if ([obj rangeOfString:@"echo"].location == NSNotFound){
                            DLog(@"\n");
                            DLog(@"found uicache instance '%@' on line: %lu", obj, idx);
                            markedForDeath = idx;
                        }
                        *stop = TRUE;
                        
                    }
                    
                }];
                
                if (markedForDeath != NSNotFound){
                    
                    [lines removeObjectAtIndex:markedForDeath];
                    NSString *newString = [lines componentsJoinedByString:@"\n"];
                    [newString writeToFile:postinst atomically:TRUE];
                    
                }
                
            }
        }
        
        
    }
    
    if (newArch != nil) {
        
        NSString *controlPath = [debian stringByAppendingPathComponent:@"control"];
        NSMutableString *controlFile = [[NSMutableString alloc] initWithContentsOfFile:controlPath encoding:NSASCIIStringEncoding error:nil];
        //@"appletvos-arm64"
        
        //this is hacky but should be fine, only one of the two should exist so only one will get overwritten.
        
        [controlFile replaceOccurrencesOfString:@"iphoneos-arm" withString:newArch options:NSLiteralSearch range:NSMakeRange(0, [controlFile length])];
        
        [controlFile replaceOccurrencesOfString:@"darwin-arm64" withString:newArch options:NSLiteralSearch range:NSMakeRange(0, [controlFile length])];
        
        
        [controlFile writeToFile:controlPath atomically:TRUE];
    }
    
    //at this point we have the files extracted, time to determine what needs to be changed
    
    NSArray *ignoreFiles = @[@".fauxsu", @".DS_Store"];
    NSArray *forbiddenRoots = @[@"etc", @"var", @"tmp"];
    [self flattenInPath:tmpPath];
    //__block NSMutableArray *_overwriteArray = [NSMutableArray new];
    [self.files enumerateObjectsUsingBlock:^(InputPackageFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.type == BSPackageFileTypeFile || obj.type == BSPackageFileTypeDirectory){
            
            //DLog(@"processing path: %@", obj.path);
            if ([obj.path isEqualToString:@"/private/var/mobile/Applications/"]){
                
                NSString *badPath = [tmpPath stringByAppendingPathComponent:obj.path];
                NSString *newPath = [tmpPath stringByAppendingPathComponent:@"Applications"];
                DLog(@"\n [INFO] Moving %@ to %@...", badPath, newPath);
                [FM moveItemAtPath:badPath toPath:newPath error:nil];
                [FM removeItemAtPath:[tmpPath stringByAppendingPathComponent:@"private"] error:nil];
                *stop = TRUE;
            }
            
            NSString *fullPath = [tmpPath stringByAppendingPathComponent:obj.path];
            
            if ([ignoreFiles containsObject:obj.path.lastPathComponent]){
                
                DLog(@"in ignore file list, purge");
                [FM removeItemAtPath:fullPath error:nil];
                
            }
            
            NSArray *pathComponents = [obj.path pathComponents];
            if ([pathComponents count] > 1)
            {
                
                NSString *rootPath = [pathComponents objectAtIndex:1];
                //DLog(@"\n Checking root path: %@ for file %@\n", rootPath, obj.path);
                if ([forbiddenRoots containsObject:rootPath])
                {
                    DLog(@"\n [WARNING] package file: '%@' would overwrite symbolic link at '%@'\n", obj.path, rootPath);
                    NSString *privateDir = [tmpPath stringByAppendingPathComponent:@"private"];
                    if (![FM fileExistsAtPath:privateDir]){
                        [FM createDirectoryAtPath:privateDir withIntermediateDirectories:TRUE attributes:nil error:nil];
                        
                    }
                    //take <package_name>/[rootPath] (could be etc, var, tmp) and move to <package_name>/private/[rootPath]
                    NSString *badPath = [tmpPath stringByAppendingPathComponent:rootPath];
                    NSString *newPath = [privateDir stringByAppendingPathComponent:rootPath];
                    DLog(@"\n [INFO] Moving %@ to %@...", badPath, newPath);
                    [FM moveItemAtPath:badPath toPath:newPath error:nil];
                    
                    
                }
            }
            
            
        }
        
        
    }];
    
    
    NSString *depArchiveInfo = [NSString stringWithFormat:@"/usr/local/bin/dpkg -b %@", self.packageName];
    
    if (fakeRoot) {
        
        depArchiveInfo = [NSString stringWithFormat:@"%@ /usr/local/bin/dpkg -b %@", fakeRoot, self.packageName];
        
        
    }
    
    [[HelperClass returnForProcess:depArchiveInfo] componentsJoinedByString:@"\n"];
    
    
    
    DLog(@"\nDone!\n\n");
    
    //return er;
}

- (ErrorReturn *)errorReturnForBootstrap:(NSString *)bootstrapPath
{
    NSArray *ignoreFiles = @[@".fauxsu", @".DS_Store"];
    NSArray *forbiddenRoots = @[@"etc", @"var", @"tmp"];
    NSFileManager *man = [NSFileManager defaultManager];
    __block NSInteger returnValue = 0; //0 = good to go 1 = over write warning, 2 = no go
    __block NSMutableArray *_overwriteArray = [NSMutableArray new];
    [self.files enumerateObjectsUsingBlock:^(InputPackageFile * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.fileType isEqualToString:@"file"]){
            
            NSString *fullPath = [bootstrapPath stringByAppendingPathComponent:obj.path];
            if ([man fileExistsAtPath:fullPath] && ![ignoreFiles containsObject:obj.basename]){
                
                //DLog(@"[WARNING] overwriting a file that already exists and isn't DS_Store or .fauxsu: %@", fullPath);
                [_overwriteArray addObject:obj.path];
                //*stop = TRUE;//return FALSE;
                returnValue = 1;
            }
            
            NSArray *pathComponents = [obj.path pathComponents];
            if ([pathComponents count] > 1)
            {
                NSString *rootPath = [pathComponents objectAtIndex:1];
                if ([forbiddenRoots containsObject:rootPath])
                {
                    DLog(@"\n [ERROR] package file: '%@' would overwrite symbolic link at '%@'! Exiting!\n\n", obj.path, rootPath);
                    *stop = TRUE;
                    returnValue = 2;
                }
            }
            
            
        }
        
        
    }];
    
    ErrorReturn *er = [ErrorReturn new];
    er.returnStatus = returnValue;
    er.overwriteFiles = _overwriteArray;
    
    return er;
}


@end
