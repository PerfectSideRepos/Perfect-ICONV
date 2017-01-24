# Perfect ICONV [English](README.md)

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="https://gitter.im/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_2_Git.jpg" alt="Chat on Gitter" />
    </a>  
    <a href="https://twitter.com/perfectlysoft" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_3_twit.jpg" alt="Follow Perfect on Twitter" />
    </a>  
    <a href="http://perfect.ly" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_4_slack.jpg" alt="Join the Perfect Slack" />
    </a>
</p>

<p align="center">
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat" alt="Swift 3.0">
    </a>
    <a href="https://developer.apple.com/swift/" target="_blank">
        <img src="https://img.shields.io/badge/Platforms-OS%20X%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms OS X | Linux">
    </a>
    <a href="http://perfect.org/licensing.html" target="_blank">
        <img src="https://img.shields.io/badge/License-Apache-lightgrey.svg?style=flat" alt="License Apache">
    </a>
    <a href="http://twitter.com/PerfectlySoft" target="_blank">
        <img src="https://img.shields.io/badge/Twitter-@PerfectlySoft-blue.svg?style=flat" alt="PerfectlySoft Twitter">
    </a>
    <a href="https://gitter.im/PerfectlySoft/Perfect?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge" target="_blank">
        <img src="https://img.shields.io/badge/Gitter-Join%20Chat-brightgreen.svg" alt="Join the chat at https://gitter.im/PerfectlySoft/Perfect">
    </a>
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>


本项目是受Yasuhiro Hatta的 Iconv项目启发而实现的Swift ICONV 类库。详见[https://github.com/yaslab/Iconv](https://github.com/yaslab/Iconv)

本项目通过SPM进行编译，是[Perfect](https://github.com/PerfectlySoft/Perfect) 项目的一个组成部分。


## Demo

``` swift
import PerfectICONV

do {
  let i = try Iconv()
  let bytes:[UInt8] =  [0xd6, 0xd0, 0xb9, 0xfa, 0x0a]
  guard let cn = i.utf8(buf: bytes) else {
    XCTFail("fault")
    return
  }//end guard
  print(cn)
  XCTAssertTrue(cn.hasPrefix("中国"))
}catch(let err) {
  XCTFail("ERROR: \(err)")
}
```

## 快速上手

### SPM软件包管理器

请在您的项目的Pacakge.swift 文件中增加如下依存关系：

``` swift
.Package(url: "https://github.com/PerfectSideRepos/Perfect-ICONV.git", majorVersion:1)
```

### 头文件定义

随后请将iconv库函数声明到您的源代码：

``` swift
import PerfectICONV
```

### 函数库初始化

在进行文字转码之前，请首先初始化函数库：

``` swift
do {
  let iconv = try Iconv(from: .GB2312, to: .UTF_8)
}catch(let err) {
  /// 如果编码协议名称无效，则可能会出错
}
```
⚠️注意⚠️ 编码所用常量字符串可以在本项目源代码中找到，输入关键字`enum`即可：

``` swift
  public enum CodePage: String {
    case US = "US"
    case US_ASCII = "US-ASCII"
    case CSASCII = "CSASCII"
    case UTF_8 = "UTF-8"
    case UTF8 = "UTF8"
    ...
  }
```

### 转码

PerfectICONV 提供了若干中方便的转码方法：

- `iconv.utf8(bytes: [Int8])` 或者 `iconv.utf8(bytes: [UInt8])`: 直接将有符号或者无符号的二进制码流转换为UTF8字符串

``` swift
let bytes:[UInt8] =  [0xd6, 0xd0, 0xb9, 0xfa, 0x0a]
guard let china = iconv.utf8(buf: bytes) else {
  /// 出错了！
}//end guard
// 如果没错，会显示 "中国"
print(china)
```

- `iconv.convert(buf: [Int8]) -> [Int8]` or `iconv.convert(buf: [UInt8]) -> [UInt8]`: 在二进制码流之间互相转换

``` swift
let bytes:[UInt8] =  [0xd6, 0xd0, 0xb9, 0xfa, 0x0a]
let chinaBytes = iconv.convert(buf: bytes)
// 如果没错的话，chinaBytes内容就是一个新的二进制码流
```

- `iconv.convert(buf: UnsafePointer<Int8>, length: Int) -> (UnsafeMutablePointer<Int8>?, Int)`: 与Hatta原项目函数设计类似，将原码流以指针和长度为参数，转换为一个新的指针和新长度构成的元组。
 ⚠️注意⚠️ 如果使用指针，请务必手动释放内存！

### 问题报告、内容贡献和客户支持

我们目前正在过渡到使用JIRA来处理所有源代码资源合并申请、修复漏洞以及其它有关问题。因此，GitHub 的“issues”问题报告功能已经被禁用了。

如果您发现了问题，或者希望为改进本文提供意见和建议，[请在这里指出](http://jira.perfect.org:8080/servicedesk/customer/portal/1).

在您开始之前，请参阅[目前待解决的问题清单](http://jira.perfect.org:8080/projects/ISS/issues).

## 更多信息
关于本项目更多内容，请参考[perfect.org](http://perfect.org).
