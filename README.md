# nitoClass
Open source free class for tvOS (in progress)

discord channel: https://discord.gg/G3EEpsS

developer environment setup application:
https://github.com/lechium/nitoClass/releases

developer environment setup video: https://lbry.tv/@nitoTV:4/class_s01:5

**NOTE**: the command line tool and shell script are unfinished, I will revist them later when I have more time. A full writeup of this environment install will also be available at a later date.

## Manual setup:

**Required:** 

1. Apple ID: https://appleid.apple.com/account#!&page=create <br/>
2. Developer Account: https://developer.apple.com/account (sign in using an apple id) <br/>
3. macOS high sierra+<br/>
4. Xcode & Command Line Tools<br/>

The versions of Xcode and command line tools vary depending on your macOS version:

| | 10.13 | 10.14 | 10.15
--- | --- | --- | --- 
Xcode | [10.1](https://download.developer.apple.com/Developer_Tools/Xcode_10.1/Xcode_10.1.xip) | [11.3.1](https://download.developer.apple.com/Developer_Tools/Xcode_11.3.1/Xcode_11.3.1.xip) | [11.4](https://download.developer.apple.com/Developer_Tools/Xcode_11.4/Xcode_11.4.xip)
CLI | [10.13](https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_macOS_10.13_for_Xcode_10/Command_Line_Tools_macOS_10.13_for_Xcode_10.dmg) | [11.3.1](https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.3.1/Command_Line_Tools_for_Xcode_11.3.1.dmg) | [11.4](https://download.developer.apple.com/Developer_Tools/Command_Line_Tools_for_Xcode_11.4/Command_Line_Tools_for_Xcode_11.4.dmg)

5. [brew](https://brew.sh)<br/>
```/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"```

6. [Theos](https://github.com/theos/theos/wiki/Installation-macOS)<br/>

7. [tvOS Theos AppleTV SDK's](https://github.com/lechium/sdks)<br/>
These need to be placed in $THEOS/sdks/

8. [tvOS Templates](https://github.com/lechium/tvOS-templates)
These need to be placed in $THEOS/templates/

9. dpkg (requires brew)<br/>
```brew install dpkg```

10. ldid (requires brew)<br/>
```brew install ldid```
