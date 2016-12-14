Pod::Spec.new do |s|
  s.name         = "DJComponentHotfix"
  s.version      = "0.2.0"
  s.summary      = "A short description of DJHotfixManager."

  s.description  = <<-DESC
                   only for private use
                   DESC

  s.homepage     = "http://douzhongxu.com"
  s.license      = "MIT (Dokay)"
  s.author             = { "Doaky" => "dokay_dou@163.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://github.com/Dokay/DJHotfixManager.git", :tag => s.version.to_s }
  
  s.subspec 'RSA' do |rsa|
    rsa.source_files = 'DJComponentHotfix/DJHotfixManager/RSA/*.{h,m}'
	#rsa.public_header_files = 'DJComponentHotfix/DJHotfixManager/RSA/*.{h}'
    rsa.requires_arc = true
    rsa.frameworks = 'Security'
  end
  s.subspec 'AES' do |aes|
    aes.source_files = 'DJComponentHotfix/DJHotfixManager/AESCrypt/*.{h,m}'
    aes.requires_arc = true
	#aes.frameworks = 'CommonCrypto'
	aes.osx.frameworks = "CommonCrypto"
  end
  s.subspec 'Core' do |core|
    core.source_files = 'DJComponentHotfix/DJHotfixManager/Core/*.{h,m}'
	core.exclude_files = 'DJComponentHotfix/DJHotfixManager/Core/AppDelegate+DJLaunchProtect.h','DJComponentHotfix/DJHotfixManager/Core/AppDelegate+DJLaunchProtect.m'
	core.requires_arc = true
	core.dependency 'JSPatch'
    core.dependency 'DJComponentHotfix/RSA'
	core.dependency 'DJComponentHotfix/AES'
	core.dependency 'SSZipArchive'
  end
end
