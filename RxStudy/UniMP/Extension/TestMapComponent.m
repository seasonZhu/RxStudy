//
//  TestComponent.m
//  HelloUniMPDemo
//
//  Created by XHY on 2020/2/14.
//  Copyright © 2020 DCloud. All rights reserved.
//

#import "TestMapComponent.h"
#import <MapKit/MapKit.h>
#import "WXConvert.h"

@interface TestMapComponent ()<MKMapViewDelegate>
@property (nonatomic, assign) BOOL mapLoadedEvent;
@property (nonatomic, assign) BOOL showsTraffic;
@end

@implementation TestMapComponent

- (instancetype)initWithRef:(NSString *)ref type:(NSString *)type styles:(NSDictionary *)styles attributes:(NSDictionary *)attributes events:(NSArray *)events weexInstance:(WXSDKInstance *)weexInstance {
    self = [super initWithRef:ref type:type styles:styles attributes:attributes events:events weexInstance:weexInstance];
    if (self) {
        // 解析属性，前端的属性都会包含在 attributes 中
        if (attributes[@"showsTraffic"]) {
            _showsTraffic = [WXConvert BOOL: attributes[@"showsTraffic"]];
        }
    }
    
    return self;
}


/// 前端更新属性回调方法
/// @param attributes 更新的属性
- (void)updateAttributes:(NSDictionary *)attributes {
    // 解析属性
    if (attributes[@"showsTraffic"]) {
        _showsTraffic = [WXConvert BOOL: attributes[@"showsTraffic"]];
//        ((MKMapView*)self.view).showsTraffic = _showsTraffic;
    }
}

/// 返回自定义 view
- (UIView *)loadView {
    return [MKMapView new];
}


/// 在 viewDidLoad 对组件 view 可以做一些配置
- (void)viewDidLoad {
    ((MKMapView*)self.view).delegate = self;
    ((MKMapView*)self.view).showsTraffic = _showsTraffic;
}


/// 前端注册的事件会调用此方法
/// @param eventName 事件名称
- (void)addEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"mapLoaded"]) {
        _mapLoadedEvent = YES;
    }
}

/// 对应的移除事件回调方法
/// @param eventName 事件名称
- (void)removeEvent:(NSString *)eventName {
    if ([eventName isEqualToString:@"mapLoaded"]) {
        _mapLoadedEvent = NO;
    }
}

// 通过 WX_EXPORT_METHOD 将方法暴露给前端
WX_EXPORT_METHOD(@selector(focus:))

- (void)focus:(NSString *)options {
    // options 为前端传递的参数
    NSLog(@"%@",options);
}

#pragma mark - MKMapViewDelegate
- (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView {
    if (_mapLoadedEvent) {
        // 想前端发送事件 params：传给前端的数据
        [self fireEvent:@"mapLoaded" params:@{@"detail":@{@"mapLoaded":@"success"}} domChanges:nil];
    }
}

@end
