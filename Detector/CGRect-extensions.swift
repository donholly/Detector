//
//  CGRect.swift
//  Top
//
//  Created by Don Holly on 12/5/17.
//

import Foundation

extension CGRect {
    var area: CGFloat {
        return size.width * size.height
    }
    
    func rounded(toNearest: Double) -> CGRect {
        return
            CGRect(x: round(Double(self.origin.x) / toNearest) * toNearest,
                   y: round(Double(self.origin.y) / toNearest) * toNearest,
                   width: round(Double(self.size.width) / toNearest) * toNearest,
                   height: round(Double(self.size.height) / toNearest) * toNearest)
    }
    
    func enlargedBy(_ percentX: CGFloat, percentY: CGFloat, withinSize: CGSize? = nil, truncateVsShift: Bool = false) -> CGRect {
        let enlargeX = (percentX * size.width) / 2
        let enlargeY = (percentY * size.height) / 2
        var enlarged = self.insetBy(dx: -enlargeX, dy: -enlargeY)
        
        if let withinSize = withinSize {
            // Check left
            if enlarged.origin.x < 0 {
                if enlarged.width - enlarged.origin.x > withinSize.width && !truncateVsShift {
                    enlarged.size.width = withinSize.width
                } else {
                    enlarged.size.width -= abs(enlarged.origin.x)
                }
                enlarged.origin.x = 0
            }
            
            // Check right
            if enlarged.maxX > withinSize.width {
                let diff = enlarged.maxX - withinSize.width
                if truncateVsShift {
                    enlarged.size.width -= diff
                } else {
                    if enlarged.origin.x - diff < 0 {
                        enlarged.origin.x = 0
                    } else {
                        enlarged.origin.x -= diff
                    }
                }
            }
            
            // Check top
            if enlarged.origin.y < 0 {
                if enlarged.height - enlarged.origin.y > withinSize.height && !truncateVsShift {
                    enlarged.size.height = withinSize.height
                } else {
                    enlarged.size.height -= abs(enlarged.origin.y)
                }
                enlarged.origin.y = 0
            }
            
            // Check bottom
            if enlarged.maxY > withinSize.height {
                let diff = enlarged.maxY - withinSize.height
                if truncateVsShift {
                    enlarged.size.height -= diff
                } else {
                    if enlarged.origin.y - diff < 0 {
                        enlarged.origin.y = 0
                    } else {
                        enlarged.origin.y -= diff
                    }
                }
            }
        }
        
        return enlarged
    }
}

