//
// This is a generated file, do not edit!
// Generated by R.swift, see https://github.com/mac-cain13/R.swift
//

import Foundation
import Rswift
import UIKit

/// This `R` struct is generated and contains references to static resources.
struct R: Rswift.Validatable {
  fileprivate static let applicationLocale = hostingBundle.preferredLocalizations.first.flatMap { Locale(identifier: $0) } ?? Locale.current
  fileprivate static let hostingBundle = Bundle(for: R.Class.self)

  /// Find first language and bundle for which the table exists
  fileprivate static func localeBundle(tableName: String, preferredLanguages: [String]) -> (Foundation.Locale, Foundation.Bundle)? {
    // Filter preferredLanguages to localizations, use first locale
    var languages = preferredLanguages
      .map { Locale(identifier: $0) }
      .prefix(1)
      .flatMap { locale -> [String] in
        if hostingBundle.localizations.contains(locale.identifier) {
          if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
            return [locale.identifier, language]
          } else {
            return [locale.identifier]
          }
        } else if let language = locale.languageCode, hostingBundle.localizations.contains(language) {
          return [language]
        } else {
          return []
        }
      }

    // If there's no languages, use development language as backstop
    if languages.isEmpty {
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages = [developmentLocalization]
      }
    } else {
      // Insert Base as second item (between locale identifier and languageCode)
      languages.insert("Base", at: 1)

      // Add development language as backstop
      if let developmentLocalization = hostingBundle.developmentLocalization {
        languages.append(developmentLocalization)
      }
    }

    // Find first language for which table exists
    // Note: key might not exist in chosen language (in that case, key will be shown)
    for language in languages {
      if let lproj = hostingBundle.url(forResource: language, withExtension: "lproj"),
         let lbundle = Bundle(url: lproj)
      {
        let strings = lbundle.url(forResource: tableName, withExtension: "strings")
        let stringsdict = lbundle.url(forResource: tableName, withExtension: "stringsdict")

        if strings != nil || stringsdict != nil {
          return (Locale(identifier: language), lbundle)
        }
      }
    }

    // If table is available in main bundle, don't look for localized resources
    let strings = hostingBundle.url(forResource: tableName, withExtension: "strings", subdirectory: nil, localization: nil)
    let stringsdict = hostingBundle.url(forResource: tableName, withExtension: "stringsdict", subdirectory: nil, localization: nil)

    if strings != nil || stringsdict != nil {
      return (applicationLocale, hostingBundle)
    }

    // If table is not found for requested languages, key will be shown
    return nil
  }

  /// Load string from Info.plist file
  fileprivate static func infoPlistString(path: [String], key: String) -> String? {
    var dict = hostingBundle.infoDictionary
    for step in path {
      guard let obj = dict?[step] as? [String: Any] else { return nil }
      dict = obj
    }
    return dict?[key] as? String
  }

  static func validate() throws {
    try intern.validate()
  }

  #if os(iOS) || os(tvOS)
  /// This `R.storyboard` struct is generated, and contains static references to 2 storyboards.
  struct storyboard {
    /// Storyboard `LaunchScreen`.
    static let launchScreen = _R.storyboard.launchScreen()
    /// Storyboard `Main`.
    static let main = _R.storyboard.main()

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "LaunchScreen", bundle: ...)`
    static func launchScreen(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.launchScreen)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIStoryboard(name: "Main", bundle: ...)`
    static func main(_: Void = ()) -> UIKit.UIStoryboard {
      return UIKit.UIStoryboard(resource: R.storyboard.main)
    }
    #endif

    fileprivate init() {}
  }
  #endif

  /// This `R.color` struct is generated, and contains static references to 1 colors.
  struct color {
    /// Color `mainTheme`.
    static let mainTheme = Rswift.ColorResource(bundle: R.hostingBundle, name: "mainTheme")

    #if os(iOS) || os(tvOS)
    /// `UIColor(named: "mainTheme", bundle: ..., traitCollection: ...)`
    @available(tvOS 11.0, *)
    @available(iOS 11.0, *)
    static func mainTheme(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIColor? {
      return UIKit.UIColor(resource: R.color.mainTheme, compatibleWith: traitCollection)
    }
    #endif

    #if os(watchOS)
    /// `UIColor(named: "mainTheme", bundle: ..., traitCollection: ...)`
    @available(watchOSApplicationExtension 4.0, *)
    static func mainTheme(_: Void = ()) -> UIKit.UIColor? {
      return UIKit.UIColor(named: R.color.mainTheme.name)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.file` struct is generated, and contains static references to 29 files.
  struct file {
    /// Resource file `AMapLocation.json`.
    static let aMapLocationJson = Rswift.FileResource(bundle: R.hostingBundle, name: "AMapLocation", pathExtension: "json")
    /// Resource file `ArticleNormalList.json`.
    static let articleNormalListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "ArticleNormalList", pathExtension: "json")
    /// Resource file `ArticleTopList.json`.
    static let articleTopListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "ArticleTopList", pathExtension: "json")
    /// Resource file `Banner.json`.
    static let bannerJson = Rswift.FileResource(bundle: R.hostingBundle, name: "Banner", pathExtension: "json")
    /// Resource file `CollectArticleAction.json`.
    static let collectArticleActionJson = Rswift.FileResource(bundle: R.hostingBundle, name: "CollectArticleAction", pathExtension: "json")
    /// Resource file `Course.json`.
    static let courseJson = Rswift.FileResource(bundle: R.hostingBundle, name: "Course", pathExtension: "json")
    /// Resource file `CourseDetail.json`.
    static let courseDetailJson = Rswift.FileResource(bundle: R.hostingBundle, name: "CourseDetail", pathExtension: "json")
    /// Resource file `Friend.json`.
    static let friendJson = Rswift.FileResource(bundle: R.hostingBundle, name: "Friend", pathExtension: "json")
    /// Resource file `HotKey.json`.
    static let hotKeyJson = Rswift.FileResource(bundle: R.hostingBundle, name: "HotKey", pathExtension: "json")
    /// Resource file `LoginAndRegister.json`.
    static let loginAndRegisterJson = Rswift.FileResource(bundle: R.hostingBundle, name: "LoginAndRegister", pathExtension: "json")
    /// Resource file `Logout.json`.
    static let logoutJson = Rswift.FileResource(bundle: R.hostingBundle, name: "Logout", pathExtension: "json")
    /// Resource file `MessageCount.json`.
    static let messageCountJson = Rswift.FileResource(bundle: R.hostingBundle, name: "MessageCount", pathExtension: "json")
    /// Resource file `MyCoin.json`.
    static let myCoinJson = Rswift.FileResource(bundle: R.hostingBundle, name: "MyCoin", pathExtension: "json")
    /// Resource file `MyCoinList.json`.
    static let myCoinListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "MyCoinList", pathExtension: "json")
    /// Resource file `MyCollectList.json`.
    static let myCollectListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "MyCollectList", pathExtension: "json")
    /// Resource file `NavigationUrl.json`.
    static let navigationUrlJson = Rswift.FileResource(bundle: R.hostingBundle, name: "NavigationUrl", pathExtension: "json")
    /// Resource file `Pods-RxStudy-acknowledgements.plist`.
    static let podsRxStudyAcknowledgementsPlist = Rswift.FileResource(bundle: R.hostingBundle, name: "Pods-RxStudy-acknowledgements", pathExtension: "plist")
    /// Resource file `ProjectClassify.json`.
    static let projectClassifyJson = Rswift.FileResource(bundle: R.hostingBundle, name: "ProjectClassify", pathExtension: "json")
    /// Resource file `ProjectClassifyList.json`.
    static let projectClassifyListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "ProjectClassifyList", pathExtension: "json")
    /// Resource file `PublicNumber.json`.
    static let publicNumberJson = Rswift.FileResource(bundle: R.hostingBundle, name: "PublicNumber", pathExtension: "json")
    /// Resource file `PublicNumberList.json`.
    static let publicNumberListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "PublicNumberList", pathExtension: "json")
    /// Resource file `README.md`.
    static let readmeMd = Rswift.FileResource(bundle: R.hostingBundle, name: "README", pathExtension: "md")
    /// Resource file `RankList.json`.
    static let rankListJson = Rswift.FileResource(bundle: R.hostingBundle, name: "RankList", pathExtension: "json")
    /// Resource file `SearchResult.json`.
    static let searchResultJson = Rswift.FileResource(bundle: R.hostingBundle, name: "SearchResult", pathExtension: "json")
    /// Resource file `ToCodable.json`.
    static let toCodableJson = Rswift.FileResource(bundle: R.hostingBundle, name: "ToCodable", pathExtension: "json")
    /// Resource file `Tools.json`.
    static let toolsJson = Rswift.FileResource(bundle: R.hostingBundle, name: "Tools", pathExtension: "json")
    /// Resource file `Tree.json`.
    static let treeJson = Rswift.FileResource(bundle: R.hostingBundle, name: "Tree", pathExtension: "json")
    /// Resource file `appStore.js`.
    static let appStoreJs = Rswift.FileResource(bundle: R.hostingBundle, name: "appStore", pathExtension: "js")
    /// Resource file `open.js`.
    static let openJs = Rswift.FileResource(bundle: R.hostingBundle, name: "open", pathExtension: "js")

    /// `bundle.url(forResource: "AMapLocation", withExtension: "json")`
    static func aMapLocationJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.aMapLocationJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "ArticleNormalList", withExtension: "json")`
    static func articleNormalListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.articleNormalListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "ArticleTopList", withExtension: "json")`
    static func articleTopListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.articleTopListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Banner", withExtension: "json")`
    static func bannerJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.bannerJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "CollectArticleAction", withExtension: "json")`
    static func collectArticleActionJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.collectArticleActionJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Course", withExtension: "json")`
    static func courseJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.courseJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "CourseDetail", withExtension: "json")`
    static func courseDetailJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.courseDetailJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Friend", withExtension: "json")`
    static func friendJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.friendJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "HotKey", withExtension: "json")`
    static func hotKeyJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.hotKeyJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "LoginAndRegister", withExtension: "json")`
    static func loginAndRegisterJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.loginAndRegisterJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Logout", withExtension: "json")`
    static func logoutJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.logoutJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "MessageCount", withExtension: "json")`
    static func messageCountJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.messageCountJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "MyCoin", withExtension: "json")`
    static func myCoinJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.myCoinJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "MyCoinList", withExtension: "json")`
    static func myCoinListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.myCoinListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "MyCollectList", withExtension: "json")`
    static func myCollectListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.myCollectListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "NavigationUrl", withExtension: "json")`
    static func navigationUrlJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.navigationUrlJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Pods-RxStudy-acknowledgements", withExtension: "plist")`
    static func podsRxStudyAcknowledgementsPlist(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.podsRxStudyAcknowledgementsPlist
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "ProjectClassify", withExtension: "json")`
    static func projectClassifyJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.projectClassifyJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "ProjectClassifyList", withExtension: "json")`
    static func projectClassifyListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.projectClassifyListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "PublicNumber", withExtension: "json")`
    static func publicNumberJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.publicNumberJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "PublicNumberList", withExtension: "json")`
    static func publicNumberListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.publicNumberListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "README", withExtension: "md")`
    static func readmeMd(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.readmeMd
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "RankList", withExtension: "json")`
    static func rankListJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.rankListJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "SearchResult", withExtension: "json")`
    static func searchResultJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.searchResultJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "ToCodable", withExtension: "json")`
    static func toCodableJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.toCodableJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Tools", withExtension: "json")`
    static func toolsJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.toolsJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "Tree", withExtension: "json")`
    static func treeJson(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.treeJson
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "appStore", withExtension: "js")`
    static func appStoreJs(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.appStoreJs
      return fileResource.bundle.url(forResource: fileResource)
    }

    /// `bundle.url(forResource: "open", withExtension: "js")`
    static func openJs(_: Void = ()) -> Foundation.URL? {
      let fileResource = R.file.openJs
      return fileResource.bundle.url(forResource: fileResource)
    }

    fileprivate init() {}
  }

  /// This `R.image` struct is generated, and contains static references to 19 images.
  struct image {
    /// Image `LaunchImagePlayAndroid`.
    static let launchImagePlayAndroid = Rswift.ImageResource(bundle: R.hostingBundle, name: "LaunchImagePlayAndroid")
    /// Image `android`.
    static let android = Rswift.ImageResource(bundle: R.hostingBundle, name: "android")
    /// Image `back`.
    static let back = Rswift.ImageResource(bundle: R.hostingBundle, name: "back")
    /// Image `collect_selected`.
    static let collect_selected = Rswift.ImageResource(bundle: R.hostingBundle, name: "collect_selected")
    /// Image `collect`.
    static let collect = Rswift.ImageResource(bundle: R.hostingBundle, name: "collect")
    /// Image `home_selected`.
    static let home_selected = Rswift.ImageResource(bundle: R.hostingBundle, name: "home_selected")
    /// Image `home`.
    static let home = Rswift.ImageResource(bundle: R.hostingBundle, name: "home")
    /// Image `my_selected`.
    static let my_selected = Rswift.ImageResource(bundle: R.hostingBundle, name: "my_selected")
    /// Image `my`.
    static let my = Rswift.ImageResource(bundle: R.hostingBundle, name: "my")
    /// Image `notFound`.
    static let notFound = Rswift.ImageResource(bundle: R.hostingBundle, name: "notFound")
    /// Image `project_selected`.
    static let project_selected = Rswift.ImageResource(bundle: R.hostingBundle, name: "project_selected")
    /// Image `project`.
    static let project = Rswift.ImageResource(bundle: R.hostingBundle, name: "project")
    /// Image `publicNumber_selected`.
    static let publicNumber_selected = Rswift.ImageResource(bundle: R.hostingBundle, name: "publicNumber_selected")
    /// Image `publicNumber`.
    static let publicNumber = Rswift.ImageResource(bundle: R.hostingBundle, name: "publicNumber")
    /// Image `saber`.
    static let saber = Rswift.ImageResource(bundle: R.hostingBundle, name: "saber")
    /// Image `tree_selected`.
    static let tree_selected = Rswift.ImageResource(bundle: R.hostingBundle, name: "tree_selected")
    /// Image `tree`.
    static let tree = Rswift.ImageResource(bundle: R.hostingBundle, name: "tree")
    /// Image `user`.
    static let user = Rswift.ImageResource(bundle: R.hostingBundle, name: "user")
    /// Image `wan_android_placeholder`.
    static let wan_android_placeholder = Rswift.ImageResource(bundle: R.hostingBundle, name: "wan_android_placeholder")

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "LaunchImagePlayAndroid", bundle: ..., traitCollection: ...)`
    static func launchImagePlayAndroid(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.launchImagePlayAndroid, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "android", bundle: ..., traitCollection: ...)`
    static func android(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.android, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "back", bundle: ..., traitCollection: ...)`
    static func back(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.back, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "collect", bundle: ..., traitCollection: ...)`
    static func collect(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.collect, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "collect_selected", bundle: ..., traitCollection: ...)`
    static func collect_selected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.collect_selected, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "home", bundle: ..., traitCollection: ...)`
    static func home(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.home, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "home_selected", bundle: ..., traitCollection: ...)`
    static func home_selected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.home_selected, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "my", bundle: ..., traitCollection: ...)`
    static func my(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.my, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "my_selected", bundle: ..., traitCollection: ...)`
    static func my_selected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.my_selected, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "notFound", bundle: ..., traitCollection: ...)`
    static func notFound(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.notFound, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "project", bundle: ..., traitCollection: ...)`
    static func project(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.project, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "project_selected", bundle: ..., traitCollection: ...)`
    static func project_selected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.project_selected, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "publicNumber", bundle: ..., traitCollection: ...)`
    static func publicNumber(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.publicNumber, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "publicNumber_selected", bundle: ..., traitCollection: ...)`
    static func publicNumber_selected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.publicNumber_selected, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "saber", bundle: ..., traitCollection: ...)`
    static func saber(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.saber, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "tree", bundle: ..., traitCollection: ...)`
    static func tree(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tree, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "tree_selected", bundle: ..., traitCollection: ...)`
    static func tree_selected(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.tree_selected, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "user", bundle: ..., traitCollection: ...)`
    static func user(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.user, compatibleWith: traitCollection)
    }
    #endif

    #if os(iOS) || os(tvOS)
    /// `UIImage(named: "wan_android_placeholder", bundle: ..., traitCollection: ...)`
    static func wan_android_placeholder(compatibleWith traitCollection: UIKit.UITraitCollection? = nil) -> UIKit.UIImage? {
      return UIKit.UIImage(resource: R.image.wan_android_placeholder, compatibleWith: traitCollection)
    }
    #endif

    fileprivate init() {}
  }

  /// This `R.string` struct is generated, and contains static references to 1 localization tables.
  struct string {
    /// This `R.string.infoPlist` struct is generated, and contains static references to 1 localization keys.
    struct infoPlist {
      /// en translation: Play Android
      ///
      /// Locales: en, zh-Hans
      static let wanandroid = Rswift.StringResource(key: "wanandroid", tableName: "InfoPlist", bundle: R.hostingBundle, locales: ["en", "zh-Hans"], comment: nil)

      /// en translation: Play Android
      ///
      /// Locales: en, zh-Hans
      static func wanandroid(preferredLanguages: [String]? = nil) -> String {
        guard let preferredLanguages = preferredLanguages else {
          return NSLocalizedString("wanandroid", tableName: "InfoPlist", bundle: hostingBundle, comment: "")
        }

        guard let (_, bundle) = localeBundle(tableName: "InfoPlist", preferredLanguages: preferredLanguages) else {
          return "wanandroid"
        }

        return NSLocalizedString("wanandroid", tableName: "InfoPlist", bundle: bundle, comment: "")
      }

      fileprivate init() {}
    }

    fileprivate init() {}
  }

  fileprivate struct intern: Rswift.Validatable {
    fileprivate static func validate() throws {
      try _R.validate()
    }

    fileprivate init() {}
  }

  fileprivate class Class {}

  fileprivate init() {}
}

struct _R: Rswift.Validatable {
  static func validate() throws {
    #if os(iOS) || os(tvOS)
    try storyboard.validate()
    #endif
  }

  #if os(iOS) || os(tvOS)
  struct storyboard: Rswift.Validatable {
    static func validate() throws {
      #if os(iOS) || os(tvOS)
      try launchScreen.validate()
      #endif
      #if os(iOS) || os(tvOS)
      try main.validate()
      #endif
    }

    #if os(iOS) || os(tvOS)
    struct launchScreen: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = UIKit.UIViewController

      let bundle = R.hostingBundle
      let name = "LaunchScreen"

      static func validate() throws {
        if UIKit.UIImage(named: "LaunchImagePlayAndroid", in: R.hostingBundle, compatibleWith: nil) == nil { throw Rswift.ValidationError(description: "[R.swift] Image named 'LaunchImagePlayAndroid' is used in storyboard 'LaunchScreen', but couldn't be loaded.") }
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    #if os(iOS) || os(tvOS)
    struct main: Rswift.StoryboardResourceWithInitialControllerType, Rswift.Validatable {
      typealias InitialController = BaseNavigationController

      let bundle = R.hostingBundle
      let name = "Main"

      static func validate() throws {
        if #available(iOS 11.0, tvOS 11.0, *) {
        }
      }

      fileprivate init() {}
    }
    #endif

    fileprivate init() {}
  }
  #endif

  fileprivate init() {}
}
