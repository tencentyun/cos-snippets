#
# NOTE: This podspec is NOT to be published. It is only used as a local source!
#

Pod::Spec.new do |s|
  s.name             = 'CSSGTestCase'
  s.version          = '1.0.0'
  s.summary          = 'High-performance, high-fidelity mobile apps.'
  s.description      = <<-DESC
Flutter provides an easy and productive way to build and deploy high-performance mobile apps for Android and iOS.
                       DESC
  s.homepage         = 'https://cloud.tencent.com/product/cos'
  s.license          = { :type => 'MIT' }
  s.author           = { 'COS CSSG Dev Team' => 'wjielai@tencent.com' }
  s.ios.deployment_target = '8.0'
  s.source           = { :path => '.' }
  s.static_framework = true
  s.frameworks = 'XCTest'
  s.dependency 'QCloudCOSXML'
  s.source_files  = [
      'cases/*.{swift}',
      'secret/*.{swift}'
      ]
end
