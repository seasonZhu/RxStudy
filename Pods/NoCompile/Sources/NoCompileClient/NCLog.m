//
//  NCLog.m
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCLog.h"

static NCLogForwarder gForwarder;

void NCLogSetForwarder(NCLogForwarder forwarder) {
    gForwarder = [forwarder copy];
}

/// 打印到本地控制台：「[NoCompile] 级别 emoji 正文」
static void NCPrint(NCLogLevel level, NSString *message) {
    static NSArray<NSString *> *prefixes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        prefixes = @[@"ℹ️", @"✅", @"⚠️", @"❌"];
    });
    NSString *prefix = (level >= 0 && level < (NCLogLevel)prefixes.count) ? prefixes[level] : @"";
    NSLog(@"[NoCompile] %@ %@", prefix, message);
}

void NCLogMessage(NCLogLevel level, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NCPrint(level, message);

    NCLogForwarder forwarder = gForwarder;
    if (forwarder) {
        forwarder(level, message);
    }
}

void NCLogLocal(NCLogLevel level, NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    NCPrint(level, message);
}

#endif
