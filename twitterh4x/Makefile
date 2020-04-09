INSTALL_TARGET_PROCESSES = Twitter
THEOS_INSTALL_DEVICE=kbphones.local
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = TwitterH4x

TwitterH4x_FILES = Tweak.xm
TwitterH4x_FILES += KIF/UIEvent+KIFAdditions.m KIF/UIView-KIFAdditions.m KIF/CGGeometry-KIFAdditions.m KIF/UIScreen+KIFAdditions.m KIF/UIWindow-KIFAdditions.m KIF/IOHIDEvent+KIF.m KIF/UITouch-KIFAdditions.m KIF/NSError-KIFAdditions.m KIF/UIApplication-KIFAdditions.m KIF/UIView-Debugging.m
TwitterH4x_FILES += Categories/UIView+RecursiveFind.m Categories/UIColor+Additions.m
TwitterH4x_CFLAGS = -fobjc-arc -IKIF -ICategories
TwitterH4x_LDFLAGS = -ObjC
TwitterH4x_FRAMEWORKS += IOKit

include $(THEOS_MAKE_PATH)/tweak.mk
