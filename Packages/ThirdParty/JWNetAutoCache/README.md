# UIWebview使用缓存并且保证实时性

标签（空格分隔）： iOS 缓存 UIWebview 实时更新

---
## webview缓存策略的介绍 ##
使用webview加载页面的时候，最理想的情况是： 资源文件没有更新，就只加载缓存文件。如果有更新，则第一时间使用新的文件。

**UIWebview中提供的缓存策略**

 - NSURLRequestUseProtocolCachePolicy 缓存策略定义在 web
   协议实现中，用于请求特定的URL。是默认的URL缓存策略。
 - NSURLRequestReloadIgnoringLocalCacheData 从服务端获取数据，忽略本地缓存
 - NSURLRequestReloadIgnoringLocalAndRemoteCacheData //源文件注释中写到没有实现
 - NSURLRequestReloadIgnoringCacheData
   被NSURLRequestReloadIgnoringLocalCacheData替换了
 - NSURLRequestReturnCacheDataElseLoad
   已经存在的缓存数据用于请求返回，不管它的过期日期和已经存在了多久。如果没有请求对应的缓存数据，从数据源读取
 - NSURLRequestReturnCacheDataDontLoad
   已经存在的缓存数据用于请求返回，不管它的过期日期和已经存在了多久。如果没有请求对应的缓存数据，不要去数据源读取，该请求被设置为失败，这种情况多用于离线模式
 - NSURLRequestReloadRevalidatingCacheData //源文件中写到没有实现
  

> 其中我觉得最接近理想状态的就是默认的缓存策略了-NSURLRequestUseProtocolCachePolicy。 这个缓存策略的缓存模式，经过探究，如下图所示：
![默认缓存策略的流程图][1]
我们会遇到两个问题：
&nbsp;&nbsp;&nbsp;&nbsp;1.在“是否过期”这个判断的地方，倘若后端开发人员没有设置过期时间，那么将会导致立马过期，即使有缓存的情况下，都会无法加载资源。尽管服务器资源没有更新。
&nbsp;&nbsp;&nbsp;&nbsp;2.当网络差的时候，缓存已经过期，则向服务器发出询问是否有更新，通常返回304的状态码的情况比较多，返回304则又会使用缓存。而这种情况在网络差的时候，发出请求这个部分时间非常的耗时。也就容易造成白屏了。

## application cache ##
这个是h5中用到的一个缓存方式。使用manifest配置文件，告知客户端哪些需要更新，哪些不需要更新。使用这种方式，需要枚举出所有需要缓存的配置文件，每次打开页面都要去请求配置文件是否有更新，如果配置文件有更新，则更新配置文件中列出的资源文件。
缺点：多个页面引用同一个js，将会缓存两份js文件。需要服务端配合
优点：快速的展现缓存的内容，后台去更新缓存，下次再打开该资源时将使用最新的。

## 自定义一种较为优的缓存策略 ##
既可以快速的加载缓存的内容，又可以实时的更新。
跟application cache的方式差不多，快速加载缓存，后台去异步更新，但是没有它的缺点。不会缓存多份文件，不需要服务端配合，意味着不需要改变服务端的东西。客户端开发人员就可以搞定。成本很小。快速又节约流量。
![自定义cache策略图][2]

> 如上图所示，发出网络请求后，会优先加载本地的缓存内容。使得资源得以实施的加载，杜绝白屏现象。然后异步去更新缓存。
这里的缓存策略依赖于自己的设定，使用webview自带的缓存策略即可。然后根据  当前时间 - 上一次更新时间 > 设定更新间隔时间按  这个条件来选择是否更新。
&nbsp;&nbsp;&nbsp;&nbsp;这样做的好处是防止白屏，又能实时更新。

附上github demo的地址：[demo地址][3]

使用方法：
在需要开启的时候调用
`[JWCacheURLProtocol startListeningNetWorking];`
 使用结束后调用   
`[JWCacheURLProtocol cancelListeningNetWorking];`


  [1]: http://7xrj9d.com1.z0.glb.clouddn.com/cache%E5%9B%BE.png
  [2]: http://7xrj9d.com1.z0.glb.clouddn.com/%E8%87%AA%E5%AE%9A%E4%B9%89cache%E7%AD%96%E7%95%A5.png
  [3]: https://github.com/dengjunwen/JWNetAutoCache
