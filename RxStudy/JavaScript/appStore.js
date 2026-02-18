/// 下载的注入
function downloadInject() {
    /// 包含zlink,就通过掘金的div的class名字去找按钮,并注入点击事件,跳转到AppStore的下载
    juejinDownloadOnClickOnButton();
    return "downloadInject success"
}

/// 在掘金网页的 立即下载 这个按钮添加点击事件
function juejinDownloadOnClickOnButton() {
    var button = document.querySelector('.d-btn');
    console.log(button);
    button.onclick = function (e) {
        window.webkit.messageHandlers.wanAndroid.postMessage('download');
    };
}


