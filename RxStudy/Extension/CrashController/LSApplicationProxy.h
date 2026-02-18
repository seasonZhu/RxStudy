//
//  LSApplicationProxy.h
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LSApplicationProxy : NSObject

- (void)setAlternateIconName:(nullable NSString *)name
                  withResult:(void (^_Nonnull)(BOOL success, NSError *_Nullable))result;

@end

NS_ASSUME_NONNULL_END
