//
//  GumView.swift
//  GumView
//
//  Created by beryu on 2015/10/12.
//  Copyright © 2015年 blk. All rights reserved.
//

import UIKit

public class GumView: UIView, UIGestureRecognizerDelegate {
  
  private var amountX: CGFloat = 0
  private var amountY: CGFloat = 0
  private var amountMax: CGFloat = 0
  private var angle: CGFloat = 0
  
  private var targetView: UIView? {
    didSet {
      self.setPanGesture()
    }
  }
  
  override public func awakeFromNib() {
    self.targetView = self.superview
  }
  
  override public func drawRect(rect: CGRect) {
    self.drawRectWithBezierPath(amountX: self.amountX, amountY: self.amountY)
  }
  
  public func handleSlide(panGestureRecognizer:UIPanGestureRecognizer) {
    self.amountX = panGestureRecognizer.translationInView(self).x
    self.amountY = panGestureRecognizer.translationInView(self).y
    self.setNeedsDisplay()

    if abs(self.amountY) > 200 || panGestureRecognizer.state == UIGestureRecognizerState.Ended {
      self.amountMax = self.amountY
      self.animateBounce()
      self.targetView?.removeGestureRecognizer(panGestureRecognizer)
    }
  }
  
  private func setPanGesture() {
    let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "handleSlide:")
    panGestureRecognizer.delegate = self
    self.targetView?.addGestureRecognizer(panGestureRecognizer)
  }
  
  private func drawRectWithBezierPath(amountX amountX: CGFloat, amountY: CGFloat) {
    let width = self.bounds.width
    let height = self.bounds.height
    let originX: CGFloat = 0
    let originY: CGFloat = 0
    
    let context = UIGraphicsGetCurrentContext()
    
    CGContextSetFillColor(context, CGColorGetComponents(UIColor.redColor().CGColor))
    CGContextMoveToPoint(context, originX, originY)
    CGContextAddPath(context, self.getBezierPath(amountX: amountX, amountY: amountY))
    CGContextAddLineToPoint(context, originX + width, originY + height)
    CGContextAddLineToPoint(context, originX, originY + height)
    CGContextFillPath(context)
  }
  
  private func getBezierPath(amountX amountX: CGFloat, amountY: CGFloat) -> CGPathRef {
    let width = self.bounds.width
    let height = self.bounds.height
    let centerY = height / 2
    
    let bezierPath = UIBezierPath()
    
    let leftPoint = CGPointMake(0, centerY)
    let middlePoint = CGPointMake(width / 2 + amountX, centerY + amountY)
    let rightPoint = CGPointMake(width, centerY)
    
    bezierPath.moveToPoint(leftPoint)
    bezierPath.addQuadCurveToPoint(rightPoint, controlPoint: middlePoint)
    
    return bezierPath.CGPath
  }

  private func animateBounce() {
    if self.amountMax == 0 {
      return
    }
    self.angle = (self.angle + 1) % 360
    let sinNum = sin(angle)
    self.amountMax *= 0.8
    self.amountY = sinNum * self.amountMax
    if abs(self.amountMax) < 0.1 {
      self.amountY = 0
      self.angle = 0
      self.amountMax = 0
      setPanGesture()
    }
    self.setNeedsDisplay()
    
    let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.016 * Double(NSEC_PER_SEC))) // 60fps
    dispatch_after(delayTime, dispatch_get_main_queue()) {
      self.animateBounce()
    }
  }
}
