
![alt tag](https://raw.githubusercontent.com/andresbrun/ABMSoundCloudAPI/master/Example/screenshots/ABMSoundCloudAPI_logo.png)

[![Build Status](https://travis-ci.org/andresbrun/ABMSoundCloudAPI.svg?style=flat)](https://travis-ci.org/andresbrun/ABMSoundCloudAPI)
[![Version](https://img.shields.io/cocoapods/v/ABMSoundCloudAPI.svg?style=flat)](http://cocoadocs.org/docsets/ABMSoundCloudAPI)
[![License](https://img.shields.io/cocoapods/l/ABMSoundCloudAPI.svg?style=flat)](http://cocoadocs.org/docsets/ABMSoundCloudAPI)
[![Platform](https://img.shields.io/cocoapods/p/ABMSoundCloudAPI.svg?style=flat)](http://cocoadocs.org/docsets/ABMSoundCloudAPI)

## Motivation

Since SoundCloud decided not to maintain anymore its API iOS library I decided to create my own one. Right now just support some of the API's endpoints such as:
* Authentication usign internal webview.
* Searching for songs given a query string.
* Download a song given the stream URL.
* Get User Playlists.
* Get Playlists given playlist ID.
* Get song info given song ID.
* Follow user given user ID.

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.


## Dependencies

* `AFNetworking`, '~> 2.5'
* `AFOAuth2Manager`, '~> 2.2'

## Requirements

This library needs to connect succesfully with SoundCloud API an account from where get:
* `Client_id`
* `Secret_key`
* `Redirect_url`

## Installation

ABMSoundCloudAPI is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "ABMSoundCloudAPI"

## Author

Andres Brun Moreno, andresbrunmoreno@gmail.com

## License

ABMSoundCloudAPI is available under the MIT license. See the LICENSE file for more info.

## Contributing

1. Fork it (https://github.com/andresbrun/ABMSoundCloudAPI/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

And I will review it as soon as I can :)
