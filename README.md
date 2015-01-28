# TicText

![icon](https://cloud.githubusercontent.com/assets/5849363/5930844/f1c6a678-a65a-11e4-9a33-96a9a788e3e4.png)
![title](https://cloud.githubusercontent.com/assets/5849363/5930870/376d78be-a65b-11e4-9ca4-53c2b70c4864.png)

CS 428 Spring 2015 Course Project

## iOS Setup

TicText requires Xcode 6 and iOS 7. 

#### Setting up your Xcode project

1. Install all project dependencies from [CocoaPods](http://cocoapods.org/#install) by running this script:
```
cd TicText-iOS
pod install
```

2. Open the Xcode workspace at `TicText-iOS/Anypic.xcworkspace`.

3. Create your TicText App on [Parse](https://parse.com/apps).

4. Copy your new app's application id and client key into `AppDelegate.m`:

```objective-c
[Parse setApplicationId:@"APPLICATION_ID" clientKey:@"CLIENT_KEY];"
```

Finally, select the `TicText` target and go to `Build Phases`. Under `Upload Symbol Files`, update line 3 to point to your Cloud Code folder, if any. If you're not using Cloud Code, feel free to remove the `Upload Symbol Files` section.

#### Configuring Anypic's Facebook integration

1. Set up a Facebook app at http://developers.facebook.com/apps

2. Set up a URL scheme for fbFACEBOOK_APP_ID, where FACEBOOK_APP_ID is your Facebook app's id. 

3. Add your Facebook app id to `Info.plist` in the `FacebookAppID` key.

## Cloud Code

Add your Parse app id and master key to `TicText-iOS/CloudCode/config/global.json`, then type `parse deploy` from the command line at `TicText-cloud`. See the [Cloud Code Guide](https://parse.com/docs/cloud_code_guide#clt) for more information about the `parse` CLI.
