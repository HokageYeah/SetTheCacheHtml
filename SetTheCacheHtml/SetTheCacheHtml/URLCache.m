//
//  URLCache.m
//  SetTheCacheHtml
//
//  Created by 余晔 on 2017/6/30.
//  Copyright © 2017年 余晔. All rights reserved.
//

#import "URLCache.h"
#import <CommonCrypto/CommonDigest.h>


static inline char hexChar(unsigned char c) {
    return c < 10 ? '0' + c : 'a' + c - 10;
}

static inline void hexString(unsigned char *from, char *to, NSUInteger length) {
    for (NSUInteger i = 0; i < length; ++i) {
        unsigned char c = from[i];
        unsigned char cHigh = c >> 4;
        unsigned char cLow = c & 0xf;
        to[2 * i] = hexChar(cHigh);
        to[2 * i + 1] = hexChar(cLow);
    }
    to[2 * length] = '\0';
}
NSString * md5(const char *string) {
    static const NSUInteger LENGTH = 16;
    unsigned char result[LENGTH];
    CC_MD5(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}

NSString * sha1(const char *string) {
    static const NSUInteger LENGTH = 20;
    unsigned char result[LENGTH];
    CC_SHA1(string, (CC_LONG)strlen(string), result);
    
    char hexResult[2 * LENGTH + 1];
    hexString(result, hexResult, LENGTH);
    
    return [NSString stringWithUTF8String:hexResult];
}

static NSString *cacheDirectory;

static NSSet *supportSchemes;


@implementation URLCache

@synthesize cachedResponses, responsesInfo;

- (void)removeCachedResponseForRequest:(NSURLRequest *)request {
    NSLog(@"removeCachedResponseForRequest:%@", request.URL.absoluteString);
    [cachedResponses removeObjectForKey:request.URL.absoluteString];
    [super removeCachedResponseForRequest:request];
}

- (void)removeAllCachedResponses {
    NSLog(@"removeAllObjects");
    [cachedResponses removeAllObjects];
    [super removeAllCachedResponses];
}

- (void)dealloc {
    cachedResponses = nil;
    responsesInfo = nil;
}


+ (void)initialize {
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    cacheDirectory = [paths objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    cacheDirectory = [paths objectAtIndex:0];
    supportSchemes = [NSSet setWithObjects:@"http", @"https", @"ftp", nil];
}

- (void)saveInfo {
    if ([responsesInfo count]) {
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        [responsesInfo writeToFile:path atomically: YES];
    }
}



- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path {
    if (self = [super initWithMemoryCapacity:memoryCapacity diskCapacity:diskCapacity diskPath:path]) {
        cachedResponses = [[NSMutableDictionary alloc] init];
        NSString *path = [cacheDirectory stringByAppendingString:@"responsesInfo.plist"];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            responsesInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        } else {
            responsesInfo = [[NSMutableDictionary alloc] init];
        }
    }
    return self;
}


- (NSCachedURLResponse *)cachedResponseForRequest:(NSURLRequest *)request {
    if ([request.HTTPMethod compare:@"GET"] != NSOrderedSame) {
        return [super cachedResponseForRequest:request];
    }
    
    NSURL *url = request.URL;
    if (![supportSchemes containsObject:url.scheme]) {
        return [super cachedResponseForRequest:request];
    }
    
    NSString *absoluteString = url.absoluteString;
    NSLog(@"%@", absoluteString);
    NSCachedURLResponse *cachedResponse = [cachedResponses objectForKey:absoluteString];
    if (cachedResponse) {
        NSLog(@"cached: %@", absoluteString);
        return cachedResponse;
    }
    
    NSDictionary *responseInfo = [responsesInfo objectForKey:absoluteString];
    if (responseInfo) {
        NSString *path = [cacheDirectory stringByAppendingString:[responseInfo objectForKey:@"filename"]];
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            NSURLResponse *response = [[NSURLResponse alloc] initWithURL:request.URL MIMEType:[responseInfo objectForKey:@"MIMEType"] expectedContentLength:data.length textEncodingName:nil];
            cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:response data:data];
            
            [cachedResponses setObject:cachedResponse forKey:absoluteString];
            NSLog(@"cached: %@", absoluteString);
            return cachedResponse;
        }
    }
    
    
//    NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:request.timeoutInterval];
//    newRequest.allHTTPHeaderFields = request.allHTTPHeaderFields;
//    newRequest.HTTPShouldHandleCookies = request.HTTPShouldHandleCookies;
//    NSError *error = nil;
//    NSURLResponse *response = nil;
//    NSData *data = [NSURLConnection sendSynchronousRequest:newRequest returningResponse:&response error:&error];
//    if (error) {
//        NSLog(@"%@", error);
//        NSLog(@"not cached: %@", absoluteString);
//        return nil;
//    }
    

//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
//    NSMutableURLRequest *newRequesst = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://prebk.youjuke.com/redemption/index?platform=app&userId=1050"]];
//    [newRequesst setHTTPMethod:@"GET"];
//    [newRequesst setTimeoutInterval:15];
//    NSError *error = nil;
//    NSURLResponse *responses = nil;
//    NSData *datasx;
//    NSURLSession *session = [NSURLSession sharedSession];
//
//    NSURLSessionDataTask *task = [session dataTaskWithRequest:newRequesst completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        
//        if (error) {
//               NSLog(@"%@", error);
//                NSLog(@"not cached: %@", absoluteString);
//        }
//        else {
//            id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
//        
//        }
//        dispatch_semaphore_signal(semaphore);   //发送信号
//    }];
//    
//    [task resume];//执行任务
//    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
//    NSLog(@"数据加载完成！");
    
    
    
    
//    NSString *filename = sha1([absoluteString UTF8String]);
//    NSString *path = [cacheDirectory stringByAppendingString:filename];
//    NSFileManager *fileManager = [[NSFileManager alloc] init];
//    [fileManager createFileAtPath:path contents:data attributes:nil];
//    
////    return request;
//    
//    NSURLResponse *newResponse = [[NSURLResponse alloc] initWithURL:response.URL MIMEType:response.MIMEType expectedContentLength:data.length textEncodingName:nil];
//    responseInfo = [NSDictionary dictionaryWithObjectsAndKeys:filename, @"filename", newResponse.MIMEType, @"MIMEType", nil];
//    [responsesInfo setObject:responseInfo forKey:absoluteString];
//    NSLog(@"saved: %@", absoluteString);
//    
//    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse data:data];
//    [cachedResponses setObject:cachedResponse forKey:absoluteString];
    return cachedResponse;

}


@end
