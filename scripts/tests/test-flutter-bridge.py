#!/usr/bin/env python3
"""用可控 Flutter/UIKit 替身测试真实桥接源码，不启动模拟器。"""
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parents[2]
STUBS = {
    "UIKit": r'''
import Foundation
public enum UIModalPresentationStyle { case fullScreen }
public final class UIView { public var window: NSObject? = NSObject() }
open class UIViewController: NSObject {
    public var presentedViewController: UIViewController?
    public weak var presentingViewController: UIViewController?
    public var viewIfLoaded: UIView? = UIView()
    public var modalPresentationStyle = UIModalPresentationStyle.fullScreen
    public func present(_ controller: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        presentedViewController = controller
        controller.presentingViewController = self
        completion?()
    }
    public func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        presentingViewController?.presentedViewController = nil
        presentingViewController = nil
        completion?()
    }
}
''',
    "Flutter": r'''
@_exported import Foundation
import UIKit
public typealias FlutterResult = (Any?) -> Void
public typealias FlutterEventSink = (Any?) -> Void
public let FlutterMethodNotImplemented = NSObject()
public final class FlutterError: NSObject {
    public let code: String
    public init(code: String, message: String?, details: Any?) { self.code = code }
}
public final class FlutterMethodCall {
    public let method: String
    public let arguments: Any?
    public init(method: String, arguments: Any?) { self.method = method; self.arguments = arguments }
}
public protocol FlutterBinaryMessenger: AnyObject {}
public final class Messenger: FlutterBinaryMessenger {}
public final class FlutterEngine {
    public let binaryMessenger: FlutterBinaryMessenger = Messenger()
    public weak var viewController: FlutterViewController?
    public var succeeds = true
    public var runs = 0
    public var destroys = 0
    public var arguments: [String] = []
    public init(name: String) {}
    public func run(withEntrypoint: String?, libraryURI: String?, initialRoute: String?, entrypointArgs: [String]) -> Bool {
        runs += 1; arguments = entrypointArgs; return succeeds
    }
    public func destroyContext() { destroys += 1 }
}
public final class FlutterViewController: UIViewController {
    public init(engine: FlutterEngine, nibName: String?, bundle: Bundle?) {
        super.init(); engine.viewController = self
    }
    public func setFlutterViewDidRenderCallback(_ callback: @escaping () -> Void) {}
}
public final class FlutterMethodChannel {
    public static var channels: [FlutterMethodChannel] = []
    public var handler: ((FlutterMethodCall, @escaping FlutterResult) -> Void)?
    public var sent: [(String, Any?, FlutterResult)] = []
    public init(name: String, binaryMessenger: FlutterBinaryMessenger) { Self.channels.append(self) }
    public func setMethodCallHandler(_ handler: ((FlutterMethodCall, @escaping FlutterResult) -> Void)?) { self.handler = handler }
    public func invokeMethod(_ method: String, arguments: Any?, result: @escaping FlutterResult) {
        sent.append((method, arguments, result))
    }
    public func receive(_ method: String, _ arguments: Any? = nil, result: @escaping FlutterResult) {
        handler?(FlutterMethodCall(method: method, arguments: arguments), result)
    }
}
public protocol FlutterStreamHandler: AnyObject {
    func onListen(withArguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError?
    func onCancel(withArguments: Any?) -> FlutterError?
}
public final class FlutterEventChannel {
    public static var channels: [FlutterEventChannel] = []
    public var handler: FlutterStreamHandler?
    public init(name: String, binaryMessenger: FlutterBinaryMessenger) { Self.channels.append(self) }
    public func setStreamHandler(_ handler: FlutterStreamHandler?) { self.handler = handler }
}
''',
    "FlutterPluginRegistrant": r'''
import Flutter
public enum GeneratedPluginRegistrant {
    public static var registrations = 0
    public static func register(with engine: FlutterEngine) { registrations += 1 }
}
''',
}


def main():
    with tempfile.TemporaryDirectory(prefix="rxstudy-flutter-bridge-") as directory:
        temporary = Path(directory)
        compiler = ["xcrun", "swiftc", "-swift-version", "5", "-module-cache-path", str(temporary / "ModuleCache"),
                    "-I", str(temporary), "-L", str(temporary), "-Xlinker", "-rpath", "-Xlinker", str(temporary)]
        libraries = []
        for name, source in STUBS.items():
            path = temporary / (name + ".swift")
            path.write_text(source)
            subprocess.run(compiler + libraries + ["-emit-library", "-emit-module", "-module-name", name, str(path),
                           "-emit-module-path", str(temporary / (name + ".swiftmodule")),
                           "-o", str(temporary / ("lib" + name + ".dylib"))], check=True)
            libraries.append("-l" + name)
        sources = ["RxStudy/FlutterManager/FlutterManager.swift", "RxStudy/FlutterManager/NativeEventChannel.swift",
                   "RxStudy/FlutterManager/FlutterMethodCallType.swift", "RxStudy/FlutterManager/InvokeMethodType.swift",
                   "RxStudy/HttpRequest/Model/AccountInfo.swift", "scripts/tests/flutter-bridge-tests.swift"]
        executable = temporary / "flutter-bridge-tests"
        subprocess.run(compiler + libraries + ["-parse-as-library"] + [str(ROOT / path) for path in sources]
                       + ["-o", str(executable)], check=True)
        subprocess.run([str(executable)], check=True, timeout=30)


if __name__ == "__main__":
    main()
