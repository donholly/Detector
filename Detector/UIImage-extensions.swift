//
//  UIImage-extensions.swift
//  Detector
//
//  Created by Don Holly on 1/25/18.
//  Copyright © 2018 Don Holly. All rights reserved.
//

import Foundation

extension UIImage {
    
//    - (nullable UIImage *)eai_croppedToRect:(CGRect)rect {
//    UIImage *croppedImage = nil;
//    UIGraphicsBeginImageContextWithOptions(rect.size, YES, self.scale);
//    {
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
//    [self drawAtPoint:CGPointZero];
//    croppedImage = UIGraphicsGetImageFromCurrentImageContext();
//    }
//    UIGraphicsEndImageContext();
//    return croppedImage;
//    }
    
    func cropped(toRect rect: CGRect) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(rect.size, true, self.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        context.translateBy(x: -rect.origin.x, y: -rect.origin.y)
        draw(at: .zero)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
