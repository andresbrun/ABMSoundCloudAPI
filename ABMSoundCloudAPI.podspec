
Pod::Spec.new do |s|
  s.name             = "ABMSoundCloudAPI"
  s.version          = "0.1.0"
  s.summary          = "Own library to handle oauth2 authentication and basic operations for SoundCloud API."
  s.description      = <<-DESC
Since SoundCloud decided not to maintain any longer its library for iOS I diceded to create my own one. Right now it is supported:
* Authentication usign internal webview
* Searching for songs
* Download a song
* Get Playlists given playlist ID
* Get song info given song ID
                       DESC
  s.homepage         = "https://github.com/andresbrun/ABMSoundCloudAPI"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Andres Brun Moreno" => "andresbrunmoreno@gmail.com" }
  s.source           = { :git => "https://github.com/andresbrun/ABMSoundCloudAPI.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/andrewsBrun'

  s.platform     = :ios, '7.0'
  s.requires_arc = true 

  s.source_files = 'Pod/Classes/**/*.{h,m}'
  s.resources = 'Pod/Classes/Views/*.storyboard'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.dependency 'AFNetworking', '~> 2.5'
  s.dependency 'AFOAuth2Manager', '~> 2.2'
end
