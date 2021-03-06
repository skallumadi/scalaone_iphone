//
//  UIImage+SOAvatar.h
//  ScalaOne
//
//  Created by Jean-Pierre Simard on 9/5/12.
//  Copyright (c) 2012 Magnetic Bear Studios. All rights reserved.
//  http://www.magneticbear.com

#import <QuartzCore/QuartzCore.h>

typedef enum {
    SOAvatarTypeSmall,
    SOAvatarTypeLarge,
    SOAvatarTypeUser,
    SOAvatarTypeFavoriteOff,
    SOAvatarTypeFavoriteOn,
} SOAvatarType;

@interface UIImage (SOAvatar)

+ (UIImage *)avatarWithSource:(UIImage *)source type:(SOAvatarType)avatarType;

+ (UIImage *)roundedImage:(UIImage *)image withRadius:(CGFloat)radius scale:(CGFloat)scale;

+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
