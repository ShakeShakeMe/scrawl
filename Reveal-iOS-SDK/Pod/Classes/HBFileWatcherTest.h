//
//  HBFileWatcherTest.h
//  BBBaseLibs
//
//  Created by dl on 2017/11/29.
//

#import <Foundation/Foundation.h>

extern NSString * const kHBFileWatcherFileChangedNotification;
extern NSString * const kHBFileWatcherFileChangedUseInfoFilePath;
/**
 用来监视文件是否改变
 */
@interface HBFileWatcherTest : NSObject

+ (instancetype)sharedInstance;
/**
 需要监视的文件路径 是mac上的路径
 @param filePath mac上的文件路径
 */
- (void)watchFilePath:(NSString *)filePath;
/**
 设置需要监视的文件后缀
 @param extensions 文件后缀
 */
- (void)setExtensions:(NSSet<NSString *> *)extensions;
@end
