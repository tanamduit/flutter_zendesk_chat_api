#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flutter_zendesk_chat'
  s.version          = '1.0.0'
  s.summary          = 'Flutter zendesk chat api.'
  s.description      = <<-DESC
A flutter plugin use to porting cendesk chat API.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'tanamduit' => 'ricky.pratama@tanamduit.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'ZDCChat/API'
  s.static_framework = true
  s.ios.deployment_target = '8.0'
end