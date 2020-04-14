
#import "RNDynamicBundle.h"

static NSString * const kBundleRegistryStoreFilename = @"_RNDynamicBundle.plist";

@implementation RNDynamicBundle

static NSURL *_defaultBundleURL = nil;

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}

+ (NSMutableDictionary *)loadRegistry
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *path = [directory stringByAppendingPathComponent:kBundleRegistryStoreFilename];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        NSDictionary *defaults = @{
                                   @"bundles": [NSMutableDictionary dictionary],
                                   @"activeBundle": @"",
                                   @"assetsPath": @"",
                                   };
        return [defaults mutableCopy];
    } else {
        return [NSMutableDictionary dictionaryWithContentsOfFile:path];
    }
}

+ (void)storeRegistry:(NSDictionary *)dict
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *path = [directory stringByAppendingPathComponent:kBundleRegistryStoreFilename];
    
    [dict writeToFile:path atomically:YES];
}

+ (NSURL *)deployBundle:(NSString *)path
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    NSString *assetsPath = dict[@"assetsPath"];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager isReadableFileAtPath:path] && ![assetsPath isEqualToString:@""]) {
        NSError *error = nil;
        NSString *fromPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:assetsPath];
        NSString *deployPath = [[path stringByDeletingLastPathComponent] stringByAppendingPathComponent:assetsPath];
        [defaultManager removeItemAtPath:deployPath error:&error];
        if (![defaultManager copyItemAtPath:fromPath toPath:deployPath error:&error]) {
            NSLog(@"deployBundleToMainBundle copyItemAtURL: %@", error);
        }
//        [defaultManager createDirectoryAtPath:deployPath withIntermediateDirectories:YES attributes:nil error:NULL];
        return [NSURL fileURLWithPath:path];
    }
    return _defaultBundleURL;
}

+ (NSURL *)deployBundleToMainBundleV0:(NSString *)path
{
    NSURL *fromURL = [[NSURL alloc]initFileURLWithPath:path];
    NSURL *toURL = [[NSURL alloc]initWithString:@"current.jsbundle" relativeToURL:[[NSBundle mainBundle] bundleURL]];
//    NSURL *toURL = [[NSBundle mainBundle] URLForResource:@"current" withExtension:@"jsbundle"];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    if ([defaultManager isReadableFileAtPath:path]) {
        NSError *error = nil;
        if ([defaultManager fileExistsAtPath:[toURL path]]) {
            [defaultManager removeItemAtURL:toURL error:&error];
            if (error) {
                NSLog(@"deployBundleToMainBundle removeItemAtURL: %@", error);
            }
        }
        [defaultManager copyItemAtURL:fromURL toURL:toURL error:&error];
        if (error) {
            NSLog(@"deployBundleToMainBundle copyItemAtURL: %@", error);
        }
        return [[NSURL alloc]initWithString:@"current.jsbundle" relativeToURL:[[NSBundle mainBundle] bundleURL]];
//        return [[NSBundle mainBundle] URLForResource:@"current" withExtension:@"jsbundle"];
    }
    return [NSURL fileURLWithPath:path];
}

+ (NSURL *)resolveBundleURL
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    NSString *activeBundle = dict[@"activeBundle"];
    if ([activeBundle isEqualToString:@""]) {
        return _defaultBundleURL;
    }
    NSString *bundleRelativePath = dict[@"bundles"][activeBundle];
    if (bundleRelativePath == nil) {
        return _defaultBundleURL;
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths firstObject];
    NSString *path = [directory stringByAppendingPathComponent:bundleRelativePath];
    
    return [RNDynamicBundle deployBundle:path];
//    NSLog(@"resolveBundleURL: %@", [NSURL fileURLWithPath:path]);
//    return [NSURL fileURLWithPath:path];
}

+ (void)setAssetsPath:(NSString *)path
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    dict[@"assetsPath"] = path;
    [RNDynamicBundle storeRegistry:dict];
}

+ (void)setDefaultBundleURL:(NSURL *)URL
{
    _defaultBundleURL = URL;
}

- (void)reloadBundle
{
    [self.delegate dynamicBundle:self
      requestsReloadForBundleURL:[RNDynamicBundle resolveBundleURL]];
}

- (void)registerBundle:(NSString *)bundleId atRelativePath:(NSString *)relativePath
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    dict[@"bundles"][bundleId] = relativePath;
    [RNDynamicBundle storeRegistry:dict];
}

- (void)unregisterBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    NSMutableDictionary *bundlesDict = dict[@"bundles"];
    [bundlesDict removeObjectForKey:bundleId];
    [RNDynamicBundle storeRegistry:dict];
}

- (void)setActiveBundle:(NSString *)bundleId
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    dict[@"activeBundle"] = bundleId == nil ? @"" : bundleId;

    [RNDynamicBundle storeRegistry:dict];
}

- (NSDictionary *)getBundles
{
    NSMutableDictionary *bundles = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    for (NSString *bundleId in dict[@"bundles"]) {
        NSString *relativePath = dict[bundleId];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *directory = [paths firstObject];
        NSString *path = [directory stringByAppendingPathComponent:relativePath];
        NSURL *URL = [NSURL fileURLWithPath:path];
        
        bundles[bundleId] = [URL absoluteString];
    }
    
    return bundles;
}

- (NSString *)getActiveBundle
{
    NSMutableDictionary *dict = [RNDynamicBundle loadRegistry];
    NSString *activeBundle = dict[@"activeBundle"];
    if ([activeBundle isEqualToString:@""]) {
        return nil;
    }
    
    return activeBundle;
}

/* Make wrappers for everything that is exported to the JS side. We want this
 * because we want to call some of the methods in this module from the native side
 * as well, which requires us to put them into the header file. Since RCT_EXPORT_METHOD
 * is largely a black box it would become rather brittle and unpredictable which method
 * definitions exactly to put in the header.
 */
RCT_REMAP_METHOD(setAssetsPath, exportedSetAssetsPath:(NSString *)path)
{
    [RNDynamicBundle setAssetsPath:path];
}

RCT_REMAP_METHOD(reloadBundle, exportedReloadBundle)
{
    [self reloadBundle];
}

RCT_REMAP_METHOD(registerBundle, exportedRegisterBundle:(NSString *)bundleId atRelativePath:(NSString *)path)
{
    [self registerBundle:bundleId atRelativePath:path];
}

RCT_REMAP_METHOD(unregisterBundle, exportedUnregisterBundle:(NSString *)bundleId)
{
    [self unregisterBundle:bundleId];
}

RCT_REMAP_METHOD(setActiveBundle, exportedSetActiveBundle:(NSString *)bundleId)
{
    [self setActiveBundle:bundleId];
}

RCT_REMAP_METHOD(getBundles,
                 exportedGetBundlesWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    resolve([self getBundles]);
}

RCT_REMAP_METHOD(getActiveBundle,
                 exportedGetActiveBundleWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *activeBundle = [self getActiveBundle];
    if (activeBundle == nil) {
        resolve([NSNull null]);
    } else {
        resolve(activeBundle);
    }
}

RCT_EXPORT_MODULE()

@end
  
