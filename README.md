# Perfect ICONV [简体中文](README.zh_CN.md)

<p align="center">
    <a href="http://perfect.org/get-involved.html" target="_blank">
        <img src="http://perfect.org/assets/github/perfect_github_2_0_0.jpg" alt="Get Involed with Perfect!" width="854" />
    </a>
</p>

<p align="center">
    <a href="https://github.com/PerfectlySoft/Perfect" target="_blank">
        <img src="http://www.perfect.org/github/Perfect_GH_button_1_Star.jpg" alt="Star Perfect On Github" />
    </a>  
    <a href="http://stackoverflow.com/questions/tagged/perfect" target="_blank">
        <img src="http://www.perfect.org/github/perfect_gh_button_2_SO.jpg" alt="Stack Overflow" />
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
        <img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" alt="Swift 4.1">
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
    <a href="http://perfect.ly" target="_blank">
        <img src="http://perfect.ly/badge.svg" alt="Slack Status">
    </a>
</p>


Swift Class Wrapper for ICONV, inspired by Yasuhiro Hatta's Iconv Project. See [https://github.com/yaslab/Iconv](https://github.com/yaslab/Iconv) for details.

This package builds with Swift Package Manager and is part of the [Perfect](https://github.com/PerfectlySoft/Perfect) project.

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

## Quick Start

### Swift Package Manager

Add a dependency to Package.swift:

``` swift
.Package(url: "https://github.com/PerfectSideRepos/Perfect-ICONV.git", 
majorVersion:3)
```

### Header Declaration

Import iconv lib to your source code:

``` swift
import PerfectICONV
```

### Initialization

Set the code pages before transforming encoding from one to another:

``` swift
do {
  let iconv = try Iconv(from: .GB2312, to: .UTF_8)
}catch(let err) {
  /// something goes wrong here, e.g., invalid code page, etc.
}
```
*NOTE*: Code Page constants could be found on source code of this project with keyword of `enum`:
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
### Conversions

PerfectICONV has a few express ways of encoding conversions:

- `iconv.utf8(bytes: [Int8])` or `iconv.utf8(bytes: [UInt8])`: directly convert a signed or unsigned byte buffer from the source code page to utf-8

``` swift
let bytes:[UInt8] =  [0xd6, 0xd0, 0xb9, 0xfa, 0x0a]
guard let china = iconv.utf8(buf: bytes) else {
  /// something wrong
}//end guard
// if ok, it will print "中国"
print(china)
```

- `iconv.convert(buf: [Int8]) -> [Int8]` or `iconv.convert(buf: [UInt8]) -> [UInt8]`: convert codepages from one byte buffer to another

``` swift
let bytes:[UInt8] =  [0xd6, 0xd0, 0xb9, 0xfa, 0x0a]
let chinaBytes = iconv.convert(buf: bytes)
// if nothing wrong, the chinaBytes is now an array of UInt8 which contains the expected encoding.
```

- `iconv.convert(buf: UnsafePointer<Int8>, length: Int) -> (UnsafeMutablePointer<Int8>?, Int)`: similar to Mr. Hatta's api design, convert a source encoding from a pointer with length to the objective tuple.
 ⚠️*NOTE*⚠️ YOU MUST MANUALLY DEALLOCATE THE OUTCOME POINTER.


## Further Information
For more information on the Perfect project, please visit [perfect.org](http://perfect.org).
