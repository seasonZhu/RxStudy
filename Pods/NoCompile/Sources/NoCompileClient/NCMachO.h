//
//  NCMachO.h
//  进程内 Mach-O 镜像与符号表工具
//

#import <Foundation/Foundation.h>
#include <mach-o/loader.h>
#include <mach-o/nlist.h>

NS_ASSUME_NONNULL_BEGIN

/// 一个已加载镜像的描述
@interface NCImage : NSObject
@property (nonatomic, readonly) const struct mach_header_64 *header;
@property (nonatomic, readonly) intptr_t slide;
@property (nonatomic, readonly, copy) NSString *path;
- (instancetype)initWithHeader:(const struct mach_header_64 *)header slide:(intptr_t)slide path:(NSString *)path;
@end

/// 符号遍历回调。name 含前导下划线；sectionName 为符号所在节名（未定义符号为 NULL）
typedef void (^NCSymbolBlock)(const char *name, uintptr_t address, uint8_t type,
                              const struct section_64 *_Nullable section, BOOL *stop);

/// 带 n_desc 的符号遍历回调（desc 中 N_WEAK_DEF 表示弱定义，如 C++ 模板 / inline 函数）
typedef void (^NCSymbolDescBlock)(const char *name, uintptr_t address, uint8_t type, uint16_t desc,
                                  const struct section_64 *_Nullable section, BOOL *stop);

/// 所有"属于 App 自身"的镜像：主程序、App 包内的 framework / dylib、DerivedData 中的产物、
/// 以及此前注入过的镜像。系统库和 NoCompile 客户端自身被排除
NSArray<NCImage *> *NCAppImages(void);

/// 根据路径查找已加载的镜像
NCImage *_Nullable NCImageForPath(NSString *path);

/// 遍历镜像的完整符号表（含 local 符号，Debug 产物通常不 strip）
void NCEnumerateSymbols(NCImage *image, NCSymbolBlock block);

/// 同 NCEnumerateSymbols，额外提供 n_desc
void NCEnumerateSymbolsWithDesc(NCImage *image, NCSymbolDescBlock block);

/// 遍历镜像的所有节
void NCEnumerateSections(NCImage *image, void (^block)(const struct segment_command_64 *segment,
                                                       const struct section_64 *section, BOOL *stop));

/// 取指定节在内存中的地址与大小，segmentName 传 NULL 表示任意段
void *_Nullable NCSectionData(NCImage *image, const char *_Nullable segmentName, const char *sectionName, size_t *size);

/// 让一段数据内存临时可写，执行 block 后恢复原保护属性。只用于数据段（__DATA / __DATA_CONST）
BOOL NCWithWritableMemory(void *address, size_t size, void (NS_NOESCAPE ^block)(void));

/// 判断地址是否落在镜像的某个段内
BOOL NCImageContainsAddress(NCImage *image, const void *address);

/// 记录一个注入镜像，使其在之后被视为 App 镜像
void NCRegisterInjectedImagePath(NSString *path);

/// 是否为此前注入过的镜像
BOOL NCIsInjectedImagePath(NSString *path);

/// 镜像路径是否属于 App 自身（主程序、App 内的 framework、DerivedData 产物、注入镜像），系统库返回 NO
BOOL NCPathIsAppImage(const char *_Nullable path);

NS_ASSUME_NONNULL_END
