# DJComponentHotfix

__DJComponentHotfix 是使用JSPatch做Hotfix的一种客户端方案.__

## 运行要求
* Xcode 7 or higher
* Apple LLVM compiler
* iOS 7.0 or higher
* ARC

## 例子

Build and run the `DJComponentHotfix.xcodeproj` in Xcode.


## 安装使用

###  CocoaPods
修改 Podfile 添加 DJComponentHotfix:

``` bash
pod 'DJComponentHotfix'
```


### API
* DJHotfixManager 提供了基本的补丁下载已经执行的逻辑。
* DJHotfixHelper 提供了简单的存储和数据校验。
* DJHotfixHelperProtocol <tt>DJHotfixHelper</tt> 实现了该协议。建议自己实现该协议来实现更安全的存储与校验策略。
* AppDelegate (DJLaunchProtect) 实现了启动崩溃保护机制。

##流程
![Image](https://github.com/Dokay/DJComponentHotfix/blob/master/hotfix_flow.png)

##JSPatch
    
JSPatch: [JSPatch](https://github.com/bang590/JSPatch)


## Contact

Dokay Dou

- https://github.com/Dokay
- http://www.douzhongxu.com
- dokay_dou@163.com

## License

DJComponentHotfix is available under the MIT license.

Copyright © 2016 Dokay Dou.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
