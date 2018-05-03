//
//  KW_AttributeTextData.swift
//  KW_AttributeTextView_Swift
//
//  Created by LKW on 2018/5/3.
//  Copyright © 2018年 Udo. All rights reserved.
//

import UIKit
import CoreText

struct KWHyperLinkTextKey: Hashable {
    static var text     = "HyperLinkText";
    static var range    = "HyperLinkTextRange";
    static var index    = "HyperLinkTextIndex";
}

class KW_AttributeTextData: NSObject {

    var text: String?;
    var width: CGFloat?
    var textRealSize: CGSize?
    var font: UIFont? = UIFont.systemFont(ofSize: 16);
    var textColor: UIColor? = UIColor.black;
    var lineSpacing: CGFloat? = 3.0;
    var wordSpacing: CGFloat? = 0;
    var ctFrame: CTFrame?;
    var model: CTLineBreakMode? = CTLineBreakMode.byWordWrapping;
    var textAligment: CTTextAlignment? = CTTextAlignment.left;
    
    var hyperLinks: Dictionary<KWHyperLinkTextKey, Dictionary<String, Any>>?
    private (set) var allLinkTextRanges: Dictionary<KWHyperLinkTextKey, Array<Any>>?;
    
    
    
    func kw_completedDataSetting() -> Void {
        self.ctFrame = self.textCTFrame();
    }
    
    func kw_textIndexFromTouchedPoint(point: CGPoint) -> CFIndex {
        
        return -1;
    }
    
    
    private func textCTFrame() -> CTFrame? {
        
        
        
        return ctFrame;
    }
}
