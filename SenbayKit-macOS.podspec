#
# Be sure to run `pod lib lint SenbayKit-macOS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SenbayKit-macOS'
  s.version          = '0.1.0'
  s.summary          = 'Senbay: A Platform for Instantly Capturing, Integrating, and Restreaming of Synchronized Multiple Sensor-data Streams'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The spread of smartphones allows us to freely capture video and diverse hardware sensors' data (e.g., accel erometer, gyroscope). While recording such data is relatively simple, it is often challenging to share and restream this data to other people and applications. Such capability is very valuable for a range of applications such as a context-aware prototyping/developing platform, an integrated data recording and analysis tool, and a sensor-data based video editing system. To enable such complex operations, we propose Senbay, a platform for instant sensing, integrating, and restreaming multiple-sensor data streams. The platform embeds collected sensor data into a video frame using an animated two-dimensional barcode via real-time video processing. The video-embedded sensor data, dubbed Senbay Video, can be easily restreamed to other people and reused by data rich, context-aware applications.
                       DESC

  s.homepage         = 'https://github.com/tetujin/SenbayKit-macOS'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'Apache2', :file => 'LICENSE' }
  s.author           = { 'tetujin' => 'tetujin@ht.sfc.keio.ac.jp' }
  s.source           = { :git => 'https://github.com/tetujin/SenbayKit-macOS.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform = :osx
  s.osx.deployment_target = "10.10"

  s.source_files = 'SenbayKit-macOS/Classes/**/*'

  # s.resource_bundles = {
  #   'SenbayKit-macOS' => ['SenbayKit-macOS/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Cocoa','Foundation'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'ZXingObjC'
end
