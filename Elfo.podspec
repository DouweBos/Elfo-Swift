#
# Be sure to run `pod lib lint Elfo.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Elfo'
  s.version          = '0.1.0'
  s.summary          = 'Swift implementation for the Elfo server module'

  s.description      = <<-DESC
Elfo is a remote debugging tool for your mobile applications. 
It will run in the background of your mobile applications and automatically connect to the Elfo client running on a Mac/iPhone/iPad on the same network.
When connected all logs, errors, network requests, analytics events, etc can be remotely logged on the client application. 
Consider this an offline version of Mixpanel's "live view".
                       DESC

  s.homepage         = 'https://github.com/DouweBos/Elfo-Swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'douwebos' => 'douwe@douwebos.nl' }
  s.source           = { :git => 'https://github.com/DouweBos/Elfo-Swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/douwebos_nl'

  s.platform     = :ios, :tvos
  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'

  s.source_files = 'Elfo/Classes/**/*'
  
  s.default_subspecs = 'Core'
  
  s.subspec 'Core' do |ss|
    ss.dependency 'CocoaAsyncSocket'
    ss.dependency 'DJBExtensionKit/Core'
  end
end
