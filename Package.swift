import PackageDescription

let vendor = "PerfectSideRepos"
#if os(Linux)
let ext = "-linux"
#else
let ext = ""
#endif

let package = Package(
    name: "PerfectICONV",
    dependencies: [
      .Package(url: "https://github.com/\(vendor)/Iconv-Support\(ext).git", majorVersion: 1)
    ]
)
