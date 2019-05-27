# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'Photosophia6' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  pod 'FlickrKit'
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'Alamofire-SwiftyJSON', '~> 3.0.0'
  pod 'SwiftyJSON'
  pod 'AlamofireImage', '~> 3.5.0'
  pod 'RxKingfisher', '~> 0.5.0'
  pod 'Whisper'
  pod 'RealmSwift'
  #pod 'SKPhotoBrowser'
  pod 'NYTPhotoViewer', '~> 2.0.0'
  pod 'Firebase', '~> 6.1.0'
  pod 'Firebase/Analytics'
  
  
  # Pods for Photosophia6

  target 'Photosophia6Tests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Photosophia6UITests' do
    inherit! :search_paths
    # Pods for testing
  end

  
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          if ['Whisper'].include? target.name
              target.build_configurations.each do |config|
                  config.build_settings['SWIFT_VERSION'] = '4.0'
              end
          end
      end
  end
end
