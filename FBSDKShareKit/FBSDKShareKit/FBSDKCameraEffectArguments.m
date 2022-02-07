/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 * All rights reserved.
 *
 * This source code is licensed under the license found in the
 * LICENSE file in the root directory of this source tree.
 */

#if !TARGET_OS_TV

#import "FBSDKCameraEffectArguments.h"

#import <FBSDKCoreKit_Basics/FBSDKCoreKit_Basics.h>
#import <FBSDKShareKit/_FBSDKShareUtility.h>

@interface FBSDKCameraEffectArguments ()
@property (nonatomic) NSMutableDictionary<NSString *, id> *arguments;
@end

@implementation FBSDKCameraEffectArguments

#pragma mark - Object Lifecycle

- (instancetype)init
{
  if ((self = [super init])) {
    _arguments = [NSMutableDictionary new];
  }
  return self;
}

- (void)setString:(nullable NSString *)string forKey:(NSString *)key
{
  [self _setValue:[string copy] forKey:key];
}

- (nullable NSString *)stringForKey:(NSString *)key
{
  return [self _valueOfClass:NSString.class forKey:key];
}

- (void)setArray:(nullable NSArray<NSString *> *)array forKey:(NSString *)key
{
  [self _setValue:[array copy] forKey:key];
}

- (nullable NSArray<NSString *> *)arrayForKey:(NSString *)key
{
  return [self _valueOfClass:NSArray.class forKey:key];
}

- (NSDictionary<NSString *, id> *)allArguments;
{
  return _arguments;
}

- (void)_setValue:(id)value forKey:(NSString *)key
{
  [FBSDKCameraEffectArguments assertKey:key];
  if (value) {
    [FBSDKCameraEffectArguments assertValue:value];
    [FBSDKTypeUtility dictionary:_arguments setObject:value forKey:key];
  } else {
    [_arguments removeObjectForKey:key];
  }
}

- (id)_valueForKey:(NSString *)key
{
  key = [FBSDKTypeUtility coercedToStringValue:key];
  return (key ? [FBSDKTypeUtility objectValue:_arguments[key]] : nil);
}

- (id)_valueOfClass:(__unsafe_unretained Class)cls forKey:(NSString *)key
{
  id value = [self _valueForKey:key];
  return ([value isKindOfClass:cls] ? value : nil);
}

+ (void)assertKey:(id)key
{
  if ([key isKindOfClass:NSString.class]) {
    return;
  }
  NSString *reason = [NSString stringWithFormat:@"Invalid key found in CameraEffectArguments: %@", key];
  @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
}

+ (void)assertValue:(id)value
{
  BOOL isInvalid = NO;
  if ([value isKindOfClass:NSString.class]) {
    // Strings are always valid.
  } else if ([value isKindOfClass:NSArray.class]) {
    // Allow only string arrays.
    for (id subValue in (NSArray *)value) {
      if (![subValue isKindOfClass:NSString.class]) {
        isInvalid = YES;
        break;
      }
    }
  } else {
    isInvalid = YES;
  }

  if (isInvalid) {
    NSString *reason = [NSString stringWithFormat:@"Invalid value found in CameraEffectArguments: %@", value];
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
  }
}

@end

#endif
