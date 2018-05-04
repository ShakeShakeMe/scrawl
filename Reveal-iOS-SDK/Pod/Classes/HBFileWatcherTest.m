//
//  HBFileWatcherTest.m
//  BBBaseLibs
//
//  Created by dl on 2017/11/29.
//

#import "HBFileWatcherTest.h"

NSString * const kHBFileWatcherFileChangedNotification          = @"kHBFileWatcherFileChangedNotification";
NSString * const kHBFileWatcherFileChangedUseInfoFilePath       = @"kHBFileWatcherFileChangedUseInfoFilePath";
@interface HBFileWatcherTest ()
@property (strong, nonatomic) NSMutableSet<NSString *> *watchFiles;  //需要监视的文件路径
@property (strong, nonatomic) NSSet<NSString *> *watchExtensions;    //需要监视的后缀
@end
@implementation HBFileWatcherTest

#pragma mark - life cycle
+ (instancetype)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self new];
    });
    return sharedInstance;
}
#pragma mark - action
- (void)watchFilePath:(NSString *)filePath {
    
    if (!filePath) return;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:filePath isDirectory:&isDirectory]) return;
    
    NSUInteger preCnt = self.watchFiles.count;
    if (!isDirectory && [self.watchExtensions containsObject:filePath.pathExtension.lowercaseString]) {
        
        [self.watchFiles addObject:filePath];
    }
    else {
        if (!isDirectory) {
            filePath = [filePath stringByDeletingLastPathComponent];
        }
        [[fileManager subpathsAtPath:filePath] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (![self.watchExtensions containsObject:obj.pathExtension.lowercaseString]) return;
            [self.watchFiles addObject:[filePath stringByAppendingPathComponent:obj]];
        }];
    }
    if (preCnt == self.watchFiles.count) {
        return;
    }
    [self.watchFiles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [self watchFile:obj];
    }];
}
- (void)watchFile:(NSString *)file {
    
    int fileHandle = open(file.UTF8String, O_EVTONLY);
    if (fileHandle) {
        
        unsigned long mask = DISPATCH_VNODE_WRITE | DISPATCH_VNODE_EXTEND;
        __block dispatch_queue_t queue = dispatch_queue_create("com.beibei.watcher", DISPATCH_QUEUE_CONCURRENT);
        __block dispatch_source_t source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, fileHandle, mask, queue);
        
        __weak typeof(self) _weak_self = self;
        dispatch_source_set_event_handler(source, ^{
            
            unsigned long flags = dispatch_source_get_data(source);
            if (flags) {
                dispatch_source_cancel(source);
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSDictionary *userInfo = @{kHBFileWatcherFileChangedUseInfoFilePath:    file};
                    [[NSNotificationCenter defaultCenter] postNotificationName:kHBFileWatcherFileChangedNotification object:_weak_self userInfo:userInfo];
                });
                [_weak_self watchFile:file];
            }
        });
        dispatch_source_set_cancel_handler(source, ^{
            close(fileHandle);
        });
        dispatch_resume(source);
    }
}
#pragma mark - extension
- (void)setExtensions:(NSSet<NSString *> *)extensions {
    self.watchExtensions = extensions;
}
#pragma mark - getter & setter
- (NSMutableSet<NSString *> *)watchFiles {
    if (!_watchFiles) {
        _watchFiles = [NSMutableSet set];
    }
    return _watchFiles;
}
- (NSSet<NSString *> *)watchExtensions {
    if (!_watchExtensions) {
        _watchExtensions = [NSSet setWithArray:@[@"json", @"html", @"css", @"js", @"txt"]];
    }
    return _watchExtensions;
}
@end
