//
//  NCSwiftMetadata.h
//  Swift 类元数据布局（仅取 vtable 覆写所需字段）
//
//  Swift 类的内存布局：前半部分与 ObjC 类兼容（isa、superclass、cache、data），
//  其后是 Swift 专有字段，再往后紧跟 vtable（函数指针数组）。
//  vtable 起点为 IVarDestroyer 字段之后，终点为 classAddressPoint + classSize。
//  参考 swift 源码 include/swift/ABI/Metadata.h 的 TargetClassMetadata。
//

#ifndef NCSwiftMetadata_h
#define NCSwiftMetadata_h

#include <stdint.h>
#include <objc/objc.h>

/// Swift 函数指针（vtable 槽位）
typedef void (*NCSwiftImpl)(void);

/// 与 ObjC 兼容的 Swift 类元数据头
typedef struct NCSwiftClassMetadata {
    // --- ObjC 兼容部分 ---
    struct NCSwiftClassMetadata *isa;
    struct NCSwiftClassMetadata *superclass;
    uintptr_t cacheData[2];
    uintptr_t data;             // 低位标志：& 0x1 或 & 0x3 != 0 表示 Swift 类
    // --- Swift 专有部分 ---
    uint32_t flags;
    uint32_t instanceAddressPoint;
    uint32_t instanceSize;
    uint16_t instanceAlignMask;
    uint16_t reserved;
    uint32_t classSize;
    uint32_t classAddressPoint;
    uintptr_t typeDescriptor;
    uintptr_t iVarDestroyer;
    // 其后为 vtable 槽位
} NCSwiftClassMetadata;

/// data 字段的 Swift 类标志位
#define NC_SWIFT_CLASS_IS_SWIFT_MASK 0x3UL

static inline BOOL NCIsSwiftClass(Class cls) {
    NCSwiftClassMetadata *meta = (__bridge NCSwiftClassMetadata *)cls;
    return (meta->data & NC_SWIFT_CLASS_IS_SWIFT_MASK) != 0;
}

/// 取 vtable 起始指针（紧跟 iVarDestroyer）
static inline NCSwiftImpl *NCSwiftVTable(NCSwiftClassMetadata *meta) {
    return (NCSwiftImpl *)(&meta->iVarDestroyer + 1);
}

/// 取 vtable 槽位数量
static inline long NCSwiftVTableSlotCount(NCSwiftClassMetadata *meta) {
    uintptr_t start = (uintptr_t)NCSwiftVTable(meta);
    uintptr_t end = (uintptr_t)meta - meta->classAddressPoint + meta->classSize;
    if (end <= start) {
        return 0;
    }
    return (long)((end - start) / sizeof(NCSwiftImpl));
}

#endif /* NCSwiftMetadata_h */
