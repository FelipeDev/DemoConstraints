//
//  KeyboardConstraint.swift
//  DemoConstraints
//
//  Created by Felipe Hernández on 03-05-17.
//  Copyright © 2017 www.mobdev.cl - All rights reserved.
//

import UIKit


extension UIViewController {
  
  func hideKeyboard() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(UIViewController.dismissKeyboard))
    
    view.addGestureRecognizer(tap)
  }
  
  func dismissKeyboard() {
    view.endEditing(true)
  }
  
}

public class KeyboardConstraint: NSLayoutConstraint {
  
  var offset : CGFloat = 0
  var keyboardHeight : CGFloat = 0
  var shouldExecuteAnimation = true
  
  override public func awakeFromNib() {
    offset = constant
    super.awakeFromNib()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(KeyboardConstraint.keyboardWillShow(_:)),
      name: NSNotification.Name.UIKeyboardWillShow, object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(KeyboardConstraint.keyboardWillHide(_:)),
      name: NSNotification.Name.UIKeyboardWillHide, object: nil
    )
  }
  
  func keyboardWillShow(_ notification: Notification) {
    if let userInfo = notification.userInfo {
      if let frameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
        let frame = frameValue.cgRectValue
        keyboardHeight = frame.size.height
      }
      self.updateConstant()
      let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
      let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      switch (animationDuration, animationCurve) {
      case let (.some(duration), .some(curve)):
        let options = UIViewAnimationOptions(rawValue: curve.uintValue)
        UIView.animate(
          withDuration: TimeInterval(duration.doubleValue),
          delay: 0,
          options: options,
          animations: {
            UIApplication.shared.keyWindow?.layoutIfNeeded()
            return
        }
        )
      default:
        break
      }
    }
  }
  
  func keyboardWillHide(_ notification: NSNotification) {
    keyboardHeight = 0
    self.updateConstant()
    if let userInfo = notification.userInfo {
      let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber
      let animationCurve = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
      switch (animationDuration, animationCurve) {
      case let (.some(duration), .some(curve)):
        let options = UIViewAnimationOptions(rawValue: curve.uintValue)
        if shouldExecuteAnimation {
          UIView.animate(
            withDuration: TimeInterval(duration.doubleValue),
            delay: 0,
            options: options,
            animations: {
              UIApplication.shared.keyWindow?.layoutIfNeeded()
              return
          })
        }
      default:
        break
      }
    }
  }
  
  func updateConstant() {
    self.constant = offset + keyboardHeight
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}
