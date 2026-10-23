//
//  NCRebind.h
//  符号重绑定（fishhook 思路的自实现）
//
//  通过改写 __DATA / __DATA_CONST 中的间接符号指针（__got、__la_symbol_ptr），
//  把对某个符号的调用重定向到新实现。配合链接参数 -interposable，
//  可覆盖 C / C++ 自由函数和 Swift 静态派发函数。
//

#import <Foundation/Foundation.h>
#import "NCMachO.h"

NS_ASSUME_NONNULL_BEGIN

/// 一条重绑定：把名为 name 的符号指针替换为 replacement
typedef struct {
    const char *name;       // 含前导下划线
    void *replacement;
} NCRebinding;

/// 对单个镜像应用重绑定，返回实际改写的指针数量
NSUInteger NCRebindImage(NCImage *image, const NCRebinding *rebindings, NSUInteger count);

/// 对所有 App 镜像应用重绑定，返回实际改写的指针总数
NSUInteger NCRebindAllAppImages(const NCRebinding *rebindings, NSUInteger count);

NS_ASSUME_NONNULL_END
