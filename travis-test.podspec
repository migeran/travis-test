Pod::Spec.new do |spec|
  spec.name                 = 'travis-test'
  spec.version              = '1.0.3'
  spec.homepage             = "https://github.com/migeran/travis-test"
  spec.license              = { :type => 'EPL', :file => 'LICENSE.txt' }
  spec.author               = { "Migeran" => "support@migeran.com" }
  spec.summary              = 'Simple cocoapods test'
  spec.platform             = :ios, "8.4"
  spec.source               = { :git => 'https://github.com/migeran/travis-test.git', :tag => '1.0.3' }
  # spec.source_files         = 'TestSDK/**/*.{h,m}'
  spec.vendored_frameworks = 'Frameworks/TestSDK.framework'
  spec.public_header_files  = "TestSDK/TestSDK.h"
  spec.requires_arc         = true
end
