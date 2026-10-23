//
//  NCRebind.m
//  符号重绑定（fishhook 思路的自实现）
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCRebind.h"
#include <mach-o/loader.h>
#include <mach-o/nlist.h>
#include <string.h>

/// 处理单个间接符号指针节（lazy / non-lazy）
static NSUInteger NCRebindSection(NCImage *image,
                                  const struct section_64 *section,
                                  const uint32_t *indirectSymtab,
                                  uint32_t indirectCount,
                                  const struct nlist_64 *symtab,
                                  uint32_t symbolCount,
                                  const char *strtab,
                                  uint32_t stringsSize,
                                  const NCRebinding *rebindings,
                                  NSUInteger count) {
    uint32_t type = section->flags & SECTION_TYPE;
    if (type != S_LAZY_SYMBOL_POINTERS && type != S_NON_LAZY_SYMBOL_POINTERS) {
        return 0;
    }
    void **indirectSlots = (void **)(section->addr + image.slide);
    uint32_t slotCount = (uint32_t)(section->size / sizeof(void *));
    // reserved1 是本节在间接符号表中的起始下标
    uint32_t indirectBase = section->reserved1;

    __block NSUInteger changed = 0;
    for (uint32_t i = 0; i < slotCount; i++) {
        // 越界保护：间接符号表 / 符号表 / 字符串表的下标都要校验
        if (indirectBase + i >= indirectCount) {
            break;
        }
        uint32_t symtabIndex = indirectSymtab[indirectBase + i];
        if (symtabIndex == INDIRECT_SYMBOL_ABS || symtabIndex == INDIRECT_SYMBOL_LOCAL ||
            symtabIndex == (INDIRECT_SYMBOL_LOCAL | INDIRECT_SYMBOL_ABS)) {
            continue;
        }
        if (symtabIndex >= symbolCount) {
            continue;
        }
        uint32_t strx = symtab[symtabIndex].n_un.n_strx;
        if (strx >= stringsSize) {
            continue;
        }
        const char *symbolName = strtab + strx;
        for (NSUInteger r = 0; r < count; r++) {
            if (strcmp(symbolName, rebindings[r].name) != 0) {
                continue;
            }
            if (indirectSlots[i] == rebindings[r].replacement) {
                break;
            }
            // 指针可能落在只读的 __DATA_CONST，需要临时开写
            void **slot = &indirectSlots[i];
            // 写入失败（页面无法改为可写）不计入，避免把没生效的替换报告成成功
            BOOL written = NCWithWritableMemory(slot, sizeof(void *), ^{
                *slot = rebindings[r].replacement;
            });
            if (written) {
                changed++;
            }
            break;
        }
    }
    return changed;
}

NSUInteger NCRebindImage(NCImage *image, const NCRebinding *rebindings, NSUInteger count) {
    if (count == 0) {
        return 0;
    }
    // 定位 LC_SYMTAB 与 LC_DYSYMTAB、__LINKEDIT 基址
    __block const struct symtab_command *symtabCommand = NULL;
    __block const struct dysymtab_command *dysymtabCommand = NULL;
    __block uintptr_t linkeditBase = 0;

    const struct mach_header_64 *header = image.header;
    const uint8_t *cursor = (const uint8_t *)header + sizeof(struct mach_header_64);
    for (uint32_t i = 0; i < header->ncmds; i++) {
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmd == LC_SYMTAB) {
            symtabCommand = (const struct symtab_command *)command;
        } else if (command->cmd == LC_DYSYMTAB) {
            dysymtabCommand = (const struct dysymtab_command *)command;
        } else if (command->cmd == LC_SEGMENT_64) {
            const struct segment_command_64 *segment = (const struct segment_command_64 *)command;
            if (strcmp(segment->segname, SEG_LINKEDIT) == 0) {
                linkeditBase = (uintptr_t)image.slide + segment->vmaddr - segment->fileoff;
            }
        }
        cursor += command->cmdsize;
    }
    if (!symtabCommand || !dysymtabCommand || linkeditBase == 0) {
        return 0;
    }

    const struct nlist_64 *symtab = (const struct nlist_64 *)(linkeditBase + symtabCommand->symoff);
    const char *strtab = (const char *)(linkeditBase + symtabCommand->stroff);
    const uint32_t *indirectSymtab = (const uint32_t *)(linkeditBase + dysymtabCommand->indirectsymoff);

    __block NSUInteger changed = 0;
    NCEnumerateSections(image, ^(const struct segment_command_64 *segment, const struct section_64 *section, BOOL *stop) {
        if (strcmp(segment->segname, SEG_DATA) != 0 && strcmp(segment->segname, "__DATA_CONST") != 0) {
            return;
        }
        changed += NCRebindSection(image, section, indirectSymtab, dysymtabCommand->nindirectsyms,
                                   symtab, symtabCommand->nsyms, strtab, symtabCommand->strsize, rebindings, count);
    });
    return changed;
}

NSUInteger NCRebindAllAppImages(const NCRebinding *rebindings, NSUInteger count) {
    NSUInteger total = 0;
    for (NCImage *image in NCAppImages()) {
        total += NCRebindImage(image, rebindings, count);
    }
    return total;
}

#endif
