require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name           = "react-native-dynamic-bundle"
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = "https://github.com/Azunya/react-native-dynamic-bundle/#readme"
  s.source         = { :git => 'https://github.com/Azunya/react-native-dynamic-bundle.git' }

  s.requires_arc   = true

  s.preserve_paths = 'README.md', 'package.json', 'index.js'
  s.source_files   = 'ios/**/*.{h,m}'
  s.dependency 'React'
end