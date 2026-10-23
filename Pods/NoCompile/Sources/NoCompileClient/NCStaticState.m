//
//  NCStaticState.m
//  迁移 C / ObjC 文件作用域的 static 变量状态
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCStaticState.h"
#import "NCLog.h"
#include <mach-o/stab.h>
#include <string.h>
#include <stdlib.h>

/// 一个 static 变量
@interface NCStaticVar : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) uintptr_t address;
/// 到下一个同节符号（新镜像）或下一个同编译单元 static（旧镜像）的字节数，0 表示未知
@property (nonatomic, assign) size_t span;
@end

@implementation NCStaticVar
@end

/// 取符号表与字符串表
static BOOL NCSymbolTables(NCImage *image, const struct nlist_64 **symbols, uint32_t *count, const char **strings, uint32_t *strsize) {
    const struct symtab_command *symtab = NULL;
    const struct segment_command_64 *linkedit = NULL;
    const struct load_command *command = (const struct load_command *)((const uint8_t *)image.header + sizeof(struct mach_header_64));
    for (uint32_t i = 0; i < image.header->ncmds; i++) {
        if (command->cmd == LC_SYMTAB) {
            symtab = (const struct symtab_command *)command;
        } else if (command->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *segment = (const struct segment_command_64 *)command;
            if (strcmp(segment->segname, SEG_LINKEDIT) == 0) {
                linkedit = segment;
            }
        }
        command = (const struct load_command *)((const uint8_t *)command + command->cmdsize);
    }
    if (!symtab || !linkedit) {
        return NO;
    }
    uintptr_t base = (uintptr_t)image.slide + linkedit->vmaddr - linkedit->fileoff;
    *symbols = (const struct nlist_64 *)(base + symtab->symoff);
    *count = symtab->nsyms;
    *strings = (const char *)(base + symtab->stroff);
    *strsize = symtab->strsize;
    return YES;
}

/// 规范化路径比较用：去掉 /private 前缀、解析符号链接
static NSString *NCCanonicalPath(NSString *path) {
    return path.stringByResolvingSymlinksInPath;
}

/// 旧镜像里属于 sourcePaths 这些源文件的 static 变量（来自调试符号），键为变量名
static NSDictionary<NSString *, NSArray<NCStaticVar *> *> *NCStabStatics(NCImage *image, NSSet<NSString *> *sourcePaths,
                                                                      NSSet<NSString *> *sourceNames) {
    const struct nlist_64 *symbols = NULL;
    uint32_t count = 0;
    const char *strings = NULL;
    uint32_t strsize = 0;
    if (!NCSymbolTables(image, &symbols, &count, &strings, &strsize)) {
        return @{};
    }
    NSMutableDictionary<NSString *, NSMutableArray<NCStaticVar *> *> *result = [NSMutableDictionary dictionary];
    NSString *directory = nil;
    BOOL inMatchedUnit = NO;
    NCStaticVar *previous = nil;
    for (uint32_t i = 0; i < count; i++) {
        const struct nlist_64 *symbol = &symbols[i];
        if (!(symbol->n_type & N_STAB)) {
            continue;
        }
        if (symbol->n_un.n_strx == 0 || symbol->n_un.n_strx >= strsize) {
            if (symbol->n_type == N_SO) {
                // 空的 N_SO 标记一个编译单元结束
                inMatchedUnit = NO;
                previous = nil;
            }
            continue;
        }
        const char *name = strings + symbol->n_un.n_strx;
        if (symbol->n_type == N_SO) {
            if (name[0] == '\0') {
                inMatchedUnit = NO;
                previous = nil;
                continue;
            }
            size_t len = strlen(name);
            if (name[len - 1] == '/') {
                directory = @(name);
                continue;
            }
            // 文件名：先按文件名粗筛，再用完整路径确认（不同目录下可能有同名文件）
            NSString *file = @(name);
            if (![sourceNames containsObject:file.lastPathComponent]) {
                inMatchedUnit = NO;
                continue;
            }
            NSString *full = [file hasPrefix:@"/"] || directory.length == 0 ? file : [directory stringByAppendingString:file];
            inMatchedUnit = [sourcePaths containsObject:NCCanonicalPath(full)];
            previous = nil;
            continue;
        }
        if (!inMatchedUnit || symbol->n_type != N_STSYM) {
            continue;
        }
        NCStaticVar *var = [NCStaticVar new];
        var.name = @(name);
        var.address = (uintptr_t)(symbol->n_value + image.slide);
        // 同一编译单元内按地址递增排列，相邻两个 static 的间距就是前一个的最大尺寸
        if (previous && var.address > previous.address) {
            previous.span = var.address - previous.address;
        }
        previous = var;
        NSMutableArray *list = result[var.name];
        if (!list) {
            list = [NSMutableArray array];
            result[var.name] = list;
        }
        [list addObject:var];
    }
    return result;
}

/// 新镜像里的零初始化 static 变量
static NSArray<NCStaticVar *> *NCZeroFillStatics(NCImage *image) {
    NSMutableArray<NCStaticVar *> *statics = [NSMutableArray array];
    // 每个节里所有符号的地址，用来估算变量尺寸
    NSMutableDictionary<NSValue *, NSMutableArray<NSNumber *> *> *addressesBySection = [NSMutableDictionary dictionary];
    NSMutableArray<NSDictionary *> *candidates = [NSMutableArray array];
    NCEnumerateSymbols(image, ^(const char *name, uintptr_t address, uint8_t type, const struct section_64 *section, BOOL *stop) {
        if (address == 0 || !section) {
            return;
        }
        NSValue *key = [NSValue valueWithPointer:section];
        NSMutableArray<NSNumber *> *addresses = addressesBySection[key];
        if (!addresses) {
            addresses = [NSMutableArray array];
            addressesBySection[key] = addresses;
        }
        [addresses addObject:@(address)];
        if (type & N_EXT) {
            return;
        }
        uint32_t sectionType = section->flags & SECTION_TYPE;
        if (sectionType != S_ZEROFILL && sectionType != S_GB_ZEROFILL) {
            return;
        }
        // 编译器生成的符号（字符串字面量、块字面量、ObjC 元数据）不是用户 static 变量。
        // C++ 的初始化守卫（__ZGV…）也不迁移：守卫标记「已初始化」被搬过去、对象本身却没搬（见下）时，新代码会直接使用全零对象
        if (strncmp(name, "_OBJC", 5) == 0 || strncmp(name, "__OBJC", 6) == 0 || strncmp(name, "___", 3) == 0
            || strncmp(name, "l_", 2) == 0 || strncmp(name, "L_", 2) == 0 || strncmp(name, "ltmp", 4) == 0
            || strncmp(name, "_$s", 3) == 0 || strncmp(name, "__ZGV", 5) == 0) {
            return;
        }
        [candidates addObject:@{@"name": @(name), @"address": @(address), @"section": key,
                                @"end": @((uintptr_t)(section->addr + image.slide + section->size))}];
    });
    for (NSMutableArray<NSNumber *> *addresses in addressesBySection.allValues) {
        [addresses sortUsingSelector:@selector(compare:)];
    }
    for (NSDictionary *candidate in candidates) {
        NCStaticVar *var = [NCStaticVar new];
        var.name = candidate[@"name"];
        var.address = [candidate[@"address"] unsignedLongValue];
        // 下一个更大的符号地址（或节末尾）与本变量起点的距离
        uintptr_t next = [candidate[@"end"] unsignedLongValue];
        for (NSNumber *other in addressesBySection[candidate[@"section"]]) {
            if (other.unsignedLongValue > var.address) {
                next = MIN(next, other.unsignedLongValue);
                break;
            }
        }
        var.span = next > var.address ? next - var.address : 0;
        [statics addObject:var];
    }
    return statics;
}

static BOOL NCIsAllZero(const uint8_t *bytes, size_t length) {
    for (size_t i = 0; i < length; i++) {
        if (bytes[i] != 0) {
            return NO;
        }
    }
    return YES;
}

NSUInteger NCTransferStaticState(NCImage *newImage, NSArray<NCImage *> *oldImages, NSArray<NSString *> *sourceFiles) {
    if (sourceFiles.count == 0) {
        return 0;
    }
    NSMutableSet<NSString *> *sourcePaths = [NSMutableSet set];
    NSMutableSet<NSString *> *sourceNames = [NSMutableSet set];
    for (NSString *file in sourceFiles) {
        [sourcePaths addObject:NCCanonicalPath(file)];
        [sourceNames addObject:file.lastPathComponent];
    }
    NSArray<NCStaticVar *> *newStatics = NCZeroFillStatics(newImage);
    if (newStatics.count == 0) {
        return 0;
    }

    // 旧镜像按加载顺序逆序查找：越晚加载的（此前注入的镜像）保存的状态越新
    NSMutableDictionary<NSString *, NSArray<NCStaticVar *> *> *oldByName = [NSMutableDictionary dictionary];
    for (NCImage *image in oldImages.reverseObjectEnumerator) {
        if (image.header == newImage.header) {
            continue;
        }
        NSDictionary<NSString *, NSArray<NCStaticVar *> *> *found = NCStabStatics(image, sourcePaths, sourceNames);
        for (NSString *name in found) {
            if (!oldByName[name]) {
                oldByName[name] = found[name];
            }
        }
    }
    if (oldByName.count == 0) {
        return 0;
    }

    NSUInteger transferred = 0;
    for (NCStaticVar *var in newStatics) {
        NCStaticVar *old = oldByName[var.name].firstObject;
        if (!old || var.span == 0 || var.span > 4096) {
            continue;
        }
        // C++ 函数内的 static 对象（__ZZ…，如 static std::map）可能含指向自身的内部指针，按字节搬到新地址后
        // 新对象的节点仍指回旧对象，遍历越界或死循环。只迁移指针 / 整数大小的变量（实例指针、dispatch_once_t 等）
        if ([var.name hasPrefix:@"__Z"] && var.span > sizeof(void *)) {
            continue;
        }
        size_t length = var.span;
        if (old.span > 0) {
            length = MIN(length, old.span);
        }
        const uint8_t *newBytes = (const uint8_t *)var.address;
        const uint8_t *oldBytes = (const uint8_t *)old.address;
        if (!NCIsAllZero(newBytes, length) || NCIsAllZero(oldBytes, length)) {
            continue;
        }
        memcpy((void *)var.address, oldBytes, length);
        transferred++;
    }
    return transferred;
}

#endif
