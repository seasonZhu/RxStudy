#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SqfliteImportPublic.h"
#import "SqflitePluginPublic.h"

FOUNDATION_EXPORT double sqflite_darwinVersionNumber;
FOUNDATION_EXPORT const unsigned char sqflite_darwinVersionString[];

