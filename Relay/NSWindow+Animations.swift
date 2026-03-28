import Cocoa

extension NSWindow {
  func fadeIn(
    duration: TimeInterval = 0.05, callback: (() -> Void)? = nil
  ) {
    alphaValue = 0

    NSAnimationContext.runAnimationGroup { context in
      context.duration = duration
      animator().alphaValue = 1
    } completionHandler: {
      callback?()
    }
  }

  func fadeOut(
    duration: TimeInterval = 0.05, callback: (() -> Void)? = nil
  ) {
    alphaValue = 1

    NSAnimationContext.runAnimationGroup { context in
      context.duration = duration
      animator().alphaValue = 0
    } completionHandler: {
      callback?()
    }
  }

  func fadeInAndUp(
    distance: CGFloat = 50, duration: TimeInterval = 0.125,
    callback: (() -> Void)? = nil
  ) {
    let toFrame = frame
    let fromFrame = NSRect(
      x: toFrame.minX, y: toFrame.minY - distance, width: toFrame.width,
      height: toFrame.height)

    setFrame(fromFrame, display: true)
    alphaValue = 0

    NSAnimationContext.runAnimationGroup { context in
      context.duration = duration
      animator().alphaValue = 1
      animator().setFrame(toFrame, display: true)
    } completionHandler: {
      callback?()
    }
  }

  func fadeOutAndDown(
    distance: CGFloat = 50, duration: TimeInterval = 0.125,
    callback: (() -> Void)? = nil
  ) {
    let fromFrame = frame
    let toFrame = NSRect(
      x: fromFrame.minX, y: fromFrame.minY - distance, width: fromFrame.width,
      height: fromFrame.height)

    setFrame(fromFrame, display: true)
    alphaValue = 1

    NSAnimationContext.runAnimationGroup { context in
      context.duration = duration
      animator().alphaValue = 0
      animator().setFrame(toFrame, display: true)
    } completionHandler: {
      callback?()
    }
  }

  func shake() {
    let numberOfShakes = 3
    let stepDuration = 0.4 / Double(numberOfShakes * 2 + 1)
    let vigourOfShake: CGFloat = 0.03
    let origin = self.frame.origin
    let offset = self.frame.width * vigourOfShake

    var offsets: [CGFloat] = []
    for _ in 0..<numberOfShakes {
      offsets.append(-offset)
      offsets.append(offset)
    }
    offsets.append(0)

    func animateStep(_ index: Int) {
      guard index < offsets.count else { return }
      NSAnimationContext.runAnimationGroup { context in
        context.duration = stepDuration
        context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        self.animator().setFrameOrigin(
          NSPoint(x: origin.x + offsets[index], y: origin.y))
      } completionHandler: {
        animateStep(index + 1)
      }
    }
    animateStep(0)
  }
}
