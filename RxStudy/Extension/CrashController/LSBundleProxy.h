//
//  LSBundleProxy.h
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSApplicationProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface LSBundleProxy : NSObject

+ (nonnull LSApplicationProxy *)bundleProxyForCurrentProcess;

@end

NS_ASSUME_NONNULL_END
