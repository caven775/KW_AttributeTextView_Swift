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
    var text     = "HyperLinkText";
    var range    = "HyperLinkTextRange";
    var index    = "HyperLinkTextIndex";
}

class KW_AttributeTextData: NSObject {

    var text: String? = "";
    var width: CGFloat? = UIScreen.main.bounds.size.width;
    var font: UIFont? = UIFont.systemFont(ofSize: 16);
    var textColor: UIColor? = UIColor.black;
    var lineSpacing: CGFloat? = 3.0;
    var wordSpacing: CGFloat? = 0;
    var model: CTLineBreakMode? = CTLineBreakMode.byWordWrapping;
    var textAligment: CTTextAlignment? = CTTextAlignment.left;
    var hyperLinks: [String: [String: Any]]?
    private var tempText: String = "";
    private (set) var textRealSize: CGSize?
    private (set) var ctFrame: CTFrame?;
    private (set) lazy var allLinkTextRanges: [String: Array<Any>] = {
        return [:];
    }();
    
    func kw_completedDataSetting() -> Void {
        self.ctFrame = self.textCTFrame();
    }
    
    func kw_textIndexFromTouchedPoint(point: CGPoint) -> CFIndex {
        
        return -1;
    }
    
    
    private func textCTFrame() -> CTFrame? {
        
        let size = CGSize.init(width: self.width!, height: CGFloat.greatestFiniteMagnitude);
        let content: NSAttributedString = self.attributedContentText();
        let frameSetter = CTFramesetterCreateWithAttributedString(content as CFAttributedString);
        let textRealSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRange.init(location: 0, length: 0), nil, size, nil);
        self.textRealSize = textRealSize;
        let path = CGMutablePath.init();
        path.addRect(CGRect.init(x: 0, y: 0, width: self.width!, height: textRealSize.height));
        let ctFrame = CTFramesetterCreateFrame(frameSetter, CFRange.init(location: 0, length: 0), path, nil);
        self.ctFrame = ctFrame;
        return ctFrame;
    }
    
    private func attributedContentText() -> NSAttributedString {
        
        var attributedContent: NSMutableAttributedString?
        var lineSpacing: CGFloat = self.lineSpacing!;
        let ctFont = CTFontCreateWithName((self.font?.fontName)! as CFString, (self.font?.pointSize)!, nil);
        var minLineHeight: CGFloat = (self.font?.pointSize)!;
        var maxLineHeight: CGFloat = (self.font?.pointSize)! + (self.font?.pointSize)!/2.0;
        var textMode: CTLineBreakMode = self.model!;
        var textAligment: CTTextAlignment = self.textAligment!;
        
        let kNumberOfSettings = 7;
        let settings = [CTParagraphStyleSetting(spec: .alignment,
                                               valueSize: size_t(Float(textAligment.rawValue)),
                                               value: &textAligment),
                        CTParagraphStyleSetting(spec: .minimumLineHeight,
                                               valueSize: size_t(minLineHeight),
                                               value: &minLineHeight),
                        CTParagraphStyleSetting(spec: .maximumLineHeight,
                                               valueSize: size_t(maxLineHeight),
                                               value: &maxLineHeight),
                        CTParagraphStyleSetting(spec: .lineSpacingAdjustment,
                                               valueSize: size_t(lineSpacing),
                                               value: &lineSpacing),
                        CTParagraphStyleSetting(spec: .minimumLineSpacing,
                                               valueSize: size_t(lineSpacing),
                                               value: &lineSpacing),
                        CTParagraphStyleSetting(spec: .maximumLineSpacing,
                                               valueSize: size_t(lineSpacing),
                                               value: &lineSpacing),
                        CTParagraphStyleSetting(spec: .lineBreakMode,
                                               valueSize: size_t(Float(textMode.rawValue)),
                                               value: &textMode)
        ]
        
        let style = CTParagraphStyleCreate(settings, kNumberOfSettings);
        
        let attributed: [NSAttributedStringKey : Any] = [NSAttributedStringKey.foregroundColor     : self.textColor!,
                                                         NSAttributedStringKey.paragraphStyle      : style,
                                                         NSAttributedStringKey.font                : ctFont,
                                                         NSAttributedStringKey.kern                : self.wordSpacing!];
        attributedContent = NSMutableAttributedString.init(string: self.text!,
                                                           attributes: attributed);
        
        self.saveHyperLinkTextRane(linkText: "势趋好", origin: self.text!);
        return attributedContent!;
    }
    
    
    func saveHyperLinkTextRane(linkText: String, origin: String) -> Void {
        
        let NSOrigin = NSString.init(string: origin);
        let range = NSOrigin.range(of: linkText);
        if (range.location != NSNotFound) {
            var values = self.allLinkTextRanges[linkText];
            if (values == nil) {
                values = [];
            }
            let preString = NSOrigin.substring(to: (range.location + range.length));
            let suffString = NSOrigin.substring(from: (range.location + range.length));
            tempText = tempText + preString;
            let linkRange = NSRange.init(location: tempText.count - linkText.count, length: linkText.count);
            values!.append(linkRange);
            self.allLinkTextRanges[linkText] = values;
            if (suffString.count >= linkText.count) {
                self.saveHyperLinkTextRane(linkText: linkText, origin: suffString);
            } else {
                tempText = "";
            }
        } else {
            tempText = "";
        }
    }
}
