//
//  HBLogger+LocalTest.m
//  BBBaseLibs
//
//  Created by dl on 2018/3/22.
//

#import "HBLogger+LocalTest.h"
#import <JRSwizzle/JRSwizzle.h>

@implementation HBLogger (LocalTest)

+ (void) load {
    [HBLogger jr_swizzleClassMethod:NSSelectorFromString(@"shouldReportExceptionOnLevel:")
                    withClassMethod:@selector(__test_shouldReportExceptionOnLevel:) error:nil];
}

+ (BOOL) __test_shouldReportExceptionOnLevel:(NSString *)level {
    return NO;
}


@end
