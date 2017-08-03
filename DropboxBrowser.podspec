Pod::Spec.new do |s|

  s.name         = "DropboxBrowser"
  s.version      = "6.1.2"
  s.summary      = "A simple and effective way to browse, view, and download files using the iOS Dropbox SDK."

  s.description  = <<-DESC
Dropbox Browser provides a simple and effective way to browse, search, and download files using the iOS Dropbox SDK. In a few minutes, add Dropbox file download support to your app. Your users can quickly select a file to handoff or download into your own app. Plus, there’s no need to worry about networking, caching, or errors.
                   DESC
  s.homepage     = "https://github.com/danielbierwirth/DropboxBrowser"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  s.license      = "MIT"

  s.authors            = { "Daniel Bierwirth" => "", "Sam Spencer" => ""}
  s.social_media_url   = "http://danielbierwirth.com"
  
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/danielbierwirth/DropboxBrowser.git", :tag => "v6.1.2" }
  s.source_files  = "ODB Classes/*.{h,m}"
  s.resource  = "DropboxMedia.xcassets"

  s.requires_arc = true
  s.dependency "ObjectiveDropboxOfficial", "~> 3.2.0"

end
