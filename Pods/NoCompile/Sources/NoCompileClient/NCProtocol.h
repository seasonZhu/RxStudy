//
//  NCProtocol.h
//  客户端与 Mac 端之间的通信协议
//
//  帧格式（全部小端）：
//  +--------+--------+----------+----------+-----------+-----------+
//  | "NCMP" | type   | jsonLen  | dataLen  | json(UTF8)| data      |
//  | 4 字节 | uint32 | uint32   | uint64   | jsonLen   | dataLen   |
//  +--------+--------+----------+----------+-----------+-----------+
//  json 描述消息内容，data 携带二进制（dylib、资源文件等）。
//  Mac 端的 Swift 实现见 Sources/NoCompileKit/Protocol.swift，两边必须保持一致。
//

#ifndef NCProtocol_h
#define NCProtocol_h

#import <Foundation/Foundation.h>
#include <stdint.h>

#define NC_PROTOCOL_MAGIC 0x504D434EU   // "NCMP" 的小端表示
#define NC_PROTOCOL_VERSION 1
/// 客户端版本：须与 Sources/NoCompileKit/Protocol.swift 的 NCProtocol.clientVersion 同步更新。
/// 仅用于展示与诊断，不参与兼容性判断
#define NC_CLIENT_VERSION @"0.2.9"
/// 客户端修订号：须与 NCProtocol.clientRevision 一致。握手时上报，不一致时 Mac 端提示重新编译 App
/// （例如 App 包内拷贝的仍是旧 bundle）。只有客户端行为或与 Mac 端的交互发生不兼容变化时才递增
#define NC_CLIENT_REVISION 1

/// 模拟器 / macOS 客户端主动连接的 Mac 端口
#define NC_MAC_PORT 21890
/// 真机客户端在回环地址上监听的端口，Mac 端经 usbmuxd 连入
#define NC_DEVICE_PORT 21891

/// 单帧中 JSON 的最大长度，防止异常数据导致超大内存分配
#define NC_MAX_JSON_LENGTH (16U * 1024U * 1024U)
/// 单帧中二进制数据的最大长度
#define NC_MAX_DATA_LENGTH (1024ULL * 1024ULL * 1024ULL)

typedef NS_ENUM(uint32_t, NCMessageType) {
    /// 客户端 → Mac：握手，携带进程、平台、镜像等信息
    NCMessageTypeHello = 1,
    /// Mac → 客户端：握手应答，携带 Mac 端版本与配置
    NCMessageTypeHelloAck = 2,
    /// 客户端 → Mac：日志转发
    NCMessageTypeLog = 3,
    /// Mac → 客户端：状态提示（编译中、编译失败等），用于浮层展示
    NCMessageTypeStatus = 4,
    /// Mac → 客户端：下发偏好设置（自动刷新、保留静态状态、浮层等），握手应答中也会携带
    NCMessageTypeConfig = 5,
    /// Mac → 客户端：注入请求，data 为 dylib 与资源文件的拼接
    NCMessageTypeInject = 10,
    /// 客户端 → Mac：注入结果
    NCMessageTypeInjectResult = 11,
    /// Mac → 客户端：资源更新（storyboard / xib 编译产物、图片），data 为各文件内容的拼接
    NCMessageTypeResource = 12,
    /// 客户端 → Mac：资源更新结果
    NCMessageTypeResourceResult = 13,
    /// 双向心跳
    NCMessageTypePing = 20,
    NCMessageTypePong = 21,
};

#pragma pack(push, 1)
typedef struct {
    uint32_t magic;
    uint32_t type;
    uint32_t jsonLength;
    uint64_t dataLength;
} NCFrameHeader;
#pragma pack(pop)

#endif /* NCProtocol_h */
