Pod::Spec.new do |spec|
  spec.name                  = 'libxml'
  spec.version               = '2.7.8'
  spec.authors               = 'libxml'
  spec.homepage              = 'https://github.com/gumob/libxml'
  spec.summary               = 'Thread safe libxml for iOS 6'
  spec.license               = 'MIT'
  spec.platform              = :ios
  spec.ios.deployment_target = '6.0'
  spec.source                = { :git => 'https://github.com/gumob/libxml.git', :tag => '2.7.8' }
  spec.source_files          = 'libxml/*.h'
  spec.preserve_paths        = 'libxml2.a'
  spec.library               = 'xml2'
  spec.xcconfig              = { 'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/libxml"' }
  spec.requires_arc          = false
end
