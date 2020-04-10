INSTALL_TARGET_PROCESSES = Twitter
THEOS_DEVICE_IP=iphone.local
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TwitterH4x

TwitterH4x_FILES = Tweak.x
TwitterH4x_FILES += $(wildcard *.*m KIF/*.*m Categories/*.*m) 
TwitterH4x_CFLAGS = -fobjc-arc -IKIF -ICategories
TwitterH4x_LDFLAGS = -ObjC
TwitterH4x_FRAMEWORKS += IOKit

include $(THEOS_MAKE_PATH)/tweak.mk
