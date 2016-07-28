Pod::Spec.new do |s|
  s.name         = "DJHotfixManager"
  s.version      = "0.0.1"
  s.summary      = "A short description of DJHotfixManager."

  s.description  = <<-DESC
                   only for private use
                   DESC

  s.homepage     = "http://douzhongxu.com"
  s.license      = "MIT (Dokay)"
  s.author             = { "Doaky" => "dokay_dou@163.com" }
  s.platform     = :ios, "7.0"
  s.ios.deployment_target = "7.0"
  s.source       = { :git => "https://bitbucket.org/movestep/ios_hot_update.git", :tag => s.version.to_s }
  
  s.subspec 'RSA' do |rsa|
    rsa.source_files = 'DJComponentHotfix/DJHotfixManager/RSA/*.{h,m}'
	#rsa.public_header_files = 'DJComponentHotfix/DJHotfixManager/RSA/*.{h}'
    rsa.requires_arc = true
    rsa.frameworks = 'Security'
  end
  s.subspec 'Core' do |core|
    core.source_files = 'DJComponentHotfix/DJHotfixManager/Core/*.{h,m}'
	core.requires_arc = true
	core.dependency 'JSPatch'
    core.dependency 'DJHotfixManager/RSA'
  end
end
