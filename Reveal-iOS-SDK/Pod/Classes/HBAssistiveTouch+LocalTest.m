//
//  HBAssistiveTouch+LocalTest.m
//  BBBaseLibs
//
//  Created by dl on 2017/11/28.
//

#import "HBAssistiveTouch+LocalTest.h"
#import <JRSwizzle/JRSwizzle.h>
#import <HBNavigator/HBNavigator.h>
#import <BlocksKit/BlocksKit.h>
#import <SAMKeychain/SAMKeychain.h>
#import <HBUserDefaults/HBUserDefaults.h>
#import <HBFoundation/HBFoundation.h>
#import <HBNavigator/HBPageRouter.h>
#import "HusorClick.h"

#import <objc/runtime.h>

@interface BlockHolder : NSObject
@property (nonatomic, strong) id block1;
@end
@implementation BlockHolder
@end

@implementation HBAssistiveTouch (LocalTest)

+ (void) load {
    [HBAssistiveTouch jr_swizzleMethod:@selector(needShow) withMethod:@selector(__test_needShow) error:nil];
    [HBAssistiveTouch jr_swizzleMethod:@selector(show) withMethod:@selector(__test_show) error:nil];

    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb bk_addObserverForKeyPath:@"string" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSLog(@"------------------- change: %@", change);
    }];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UIPasteboardChangedNotification" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        NSLog(@"------------------- note: %@", note.userInfo);
    }];

//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *productDetailClsName = [[NSUserDefaults standardUserDefaults] boolForKey:@"__product_detail_is_new__"] ? @"BBProductDetailNewViewController" : @"BBProductDetailViewController";
//        [[HBPageRouter router] registerUrl:@"detail" toControllerClass:NSClassFromString(productDetailClsName)];
//        [[HBPageRouter router] registerUrl:@"bb/base/product" toControllerClass:NSClassFromString(productDetailClsName)];
//    });
}

- (BOOL) __test_needShow {
    return YES;
}

static void *BlockHolderAssociatedKey = &BlockHolderAssociatedKey;

- (void) __test_show {

    BlockHolder *blockHander = [[BlockHolder alloc] init];
    objc_setAssociatedObject(self, BlockHolderAssociatedKey, blockHander, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    HBAssistiveTouch *at = [HBAssistiveTouch sharedInstance];
    [at registAction:^{
        [HusorClick instance].debug = YES;
    } title:@"开启控制台打点" inParentNode:nil];

    [at registAction:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"BBVipInfoTriggleFetchData" object:nil];
    } title:@"模拟BBVipInfoTriggleFetchData通知" inParentNode:nil];
    
    [at registAction:^{
        [[HBNavigator instance] pushViewControllerByDict:@{@"target": @"bb/base/product", @"iid": @"26839680"} animated:YES];
    } title:@"商品详情" inParentNode:nil];

    [at registAction:^{
        BOOL isNew = [[NSUserDefaults standardUserDefaults] boolForKey:@"__product_detail_is_new__"];
        NSString *productDetailClsName = !isNew ? @"BBProductDetailNewViewController" : @"BBProductDetailViewController";
        [[HBPageRouter router] registerUrl:@"detail" toControllerClass:NSClassFromString(productDetailClsName)];
        [[HBPageRouter router] registerUrl:@"bb/base/product" toControllerClass:NSClassFromString(productDetailClsName)];
        [[NSUserDefaults standardUserDefaults] setBool:!isNew forKey:@"__product_detail_is_new__"];
    } title:@"切换新老商详" inParentNode:nil];

    [at registAction:^{
        [[HBNavigator instance] pushViewControllerByDict:@{@"target": @"bb/pintuan/home"} animated:YES];
    } title:@"拼团主页" inParentNode:nil];

    [at registAction:^{
        [HBURLHandler openURLString:@"nezha://127.0.0.1:3000"];
    } title:@"连接nezha" inParentNode:nil];

//    [at registAction:^{
//        [SAMKeychain deletePasswordForService:@"kAppVersionKey" account:@"kAppVersionKey"];
//        [[HBUserDefaults standardUserDefaults] removeObjectForKey:@"kAppVersionKey"];
//    } title:@"清除本地版本信息" inParentNode:nil];
//
    [at registAction:^{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kHomeAlertAdsStoredKey"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"kSplashAdsRecordKey"];
    } title:@"清除闪屏&弹窗缓存" inParentNode:nil];
//
//    [at registAction:^{
//        [[HBPageRouter router] registerUrl:@"bb/store/home" toControllerClass:NSClassFromString(@"BBStoreHomeViewController")];
//    } title:@"开启H5店铺" inParentNode:nil];
//    [at registAction:^{
//        [[HBPageRouter router] registerUrl:@"bb/store/home" toControllerClass:NSClassFromString(@"BBStoreHomeViewControllerNative")];
//    } title:@"开启原生店铺" inParentNode:nil];
//
//    [at registAction:^{
//        [self patchTest];
//    } title:@"Patch Test" inParentNode:nil];

    [self __test_show];
}
static int sInt = 0;
//
- (void) patchTest {
    BlockHolder *blockHander = objc_getAssociatedObject(self, BlockHolderAssociatedKey);
//    BlockHolder *blockHander = [[BlockHolder alloc] init];

    // 局部变量
    NSArray *a = @[@"txt"];
    __block int aa = 0;
    void (^block1)(void) = ^void(void) {
        aa ++;
        NSLog(@"block 1 exec: %@", a);
        sInt ++;
    };
    blockHander.block1 = block1;
    NSLog(@"Block 1 retain count: %ld", CFGetRetainCount((__bridge CFTypeRef)block1));

//    [block1 copy];

//    void (^block2)(void) = [block1 copy];
//    CFRelease((__bridge CFTypeRef)block1);
//    CFRelease((__bridge CFTypeRef)block2);
//
//    NSLog(@"Block 2 retain count: %ld", CFGetRetainCount((__bridge CFTypeRef)block2));
//    NSLog(@"Block 1 retain count: %ld", CFGetRetainCount((__bridge CFTypeRef)block1));
}

@end










