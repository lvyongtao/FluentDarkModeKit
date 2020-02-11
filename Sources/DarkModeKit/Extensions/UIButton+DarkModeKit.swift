//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

#if SWIFT_PACKAGE
import DarkModeCore
#endif

extension UIButton {
  open override func dm_updateDynamicColors() {
    super.dm_updateDynamicColors()

    [UIControl.State.normal, .highlighted, .disabled, .selected, .focused].forEach { state in
      if let color = titleColor(for: state)?.copy() as? DynamicColor {
        setTitleColor(color, for: state)
      }
    }
  }
}
