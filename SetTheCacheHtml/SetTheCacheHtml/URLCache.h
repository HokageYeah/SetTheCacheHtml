//
//  URLCache.h
//  SetTheCacheHtml
//
//  Created by 余晔 on 2017/6/30.
//  Copyright © 2017年 余晔. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface URLCache : NSURLCache{
    NSMutableDictionary *cachedResponses;
    NSMutableDictionary *responsesInfo;
}

@property (nonatomic, retain) NSMutableDictionary *cachedResponses;
@property (nonatomic, retain) NSMutableDictionary *responsesInfo;
- (void)saveInfo;

@end
