Pod::Spec.new do |s|
  s.name = 'MotionMachine'
  s.version = '1.3.2'
  s.swift_version = '4.0'
  s.license = { :type => 'MIT' }
  s.summary = 'An elegant, powerful, and modular animation library for Swift.'
  s.description = <<-DESC
                       MotionMachine provides a modular, generic platform for manipulating values. Its animation engine was built from the ground up to support not just UIKit values, but property values of any class you want to manipulate. It offers sensible default functionality that abstracts most of the hard work away, allowing you to focus on your work.
                     DESC
  s.homepage = 'https://github.com/poetmountain/MotionMachine'
  s.social_media_url = 'https://twitter.com/petsound'
  s.authors = { 'Brett Walker' => 'brett@brettwalker.net' }
  s.source = { :git => 'https://github.com/poetmountain/MotionMachine.git', :tag => "#{s.version}" }
  s.source_files = 'Sources/**/*.{m,h,swift}'
  s.frameworks = 'CoreGraphics', 'QuartzCore'
  s.ios.deployment_target = '8.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc = true
end
