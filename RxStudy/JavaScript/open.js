/// 注入开始
function injectBegin(urlString) {
    
    /// 打印只能在浏览器里面能看见
    console.log(urlString);
    
    /// 包含掘金字段,就通过掘金的div的class名字去找按钮,并注入点击事件
    if (urlString.includes('juejin')) {
        juejinAddOnClickOnButton();
    }
    
    /// 包含CSDN字段,同掘金的逻辑,注入点击事件
    if (urlString.includes('csdn')) {
        csdnAddOnClickOnButton();
    }
    
    /// 包含CSDN字段,同掘金的逻辑,注入点击事件
    if (urlString.includes('jianshu')) {
        jianshuAddOnClickOnButton();
    }
    
    return "injectBegin的回调URL:" + urlString
}

/// 在掘金网页的 APP内打开 这个按钮添加点击事件
/// postMessage里面需要传值,可以传空串"",不能传JavaScript中的undefined和null或者不传
/// 传undefined和null报错如下 Optional(Error Domain=WKErrorDomain Code=4 "发生了JavaScript异常" UserInfo={WKJavaScriptExceptionLineNumber=29, WKJavaScriptExceptionMessage=TypeError: null is not an object
/// 不传报错如下 Optional(Error Domain=WKErrorDomain Code=4 "发生了JavaScript异常" UserInfo={WKJavaScriptExceptionLineNumber=0, WKJavaScriptExceptionMessage=TypeError: undefined is not a function, WKJavaScriptExceptionColumnNumber=0, NSLocalizedDescription=发生了JavaScript异常})
function juejinAddOnClickOnButton() {
    var button = document.querySelector('.open-button');
    console.log(button);
    button.onclick = function (e) {
        window.webkit.messageHandlers.wanAndroid.postMessage('goToApp');
    };
}

/// 在CSDN网页的 APP内打开 这个按钮添加点击事件
function csdnAddOnClickOnButton() {
    var button = document.querySelector('.open-app open-app-csdn open_app_channelCode');
    console.log(button);
    button.onclick = function (e) {
        window.webkit.messageHandlers.wanAndroid.postMessage('goToApp');
    };
}

/// 简书网页的 打开App,看更多相似好文 这个按钮添加点击事件
function jianshuAddOnClickOnButton() {
    var button = document.querySelector('.call-app-btn');
    console.log(button);
    button.onclick = function (e) {
        window.webkit.messageHandlers.wanAndroid.postMessage('goToApp');
    };
    
    var open = document.querySelector('.wrap-item-btn');
    open.onclick = function (e) {
        window.webkit.messageHandlers.wanAndroid.postMessage('goToApp');
    };
}
