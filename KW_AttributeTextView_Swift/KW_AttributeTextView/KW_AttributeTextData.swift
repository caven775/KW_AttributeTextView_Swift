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

    var text: String? = "";
    var width: CGFloat? = UIScreen.main.bounds.size.width;
    var font: UIFont? = UIFont.systemFont(ofSize: 16);
    var textColor: UIColor? = UIColor.black;
    var lineSpacing: CGFloat? = 3.0;
    var wordSpacing: CGFloat? = 0;
    var model: CTLineBreakMode? = CTLineBreakMode.byWordWrapping;
    var textAligment: CTTextAlignment? = CTTextAlignment.left;
    var hyperLinks: [String: [NSAttributedStringKey: Any]]?
    private var tempText: String = "";
    private (set) var textRealSize: CGSize? = CGSize.zero;
    private (set) var ctFrame: CTFrame?;
    private (set) lazy var allLinkTextRanges: [String: Array<Any>] = {
        return [:];
    }();
    
    func kw_completedDataSetting() -> Void {
        self.ctFrame = self.textCTFrame();
    }
    
    func kw_textIndexFromTouchedPoint(point: CGPoint) -> CFIndex {
        
        let frame = CGRect.init(x: 0, y: 0, width: self.textRealSize!.width, height: self.textRealSize!.height);
        let lines = CTFrameGetLines(self.ctFrame!);
        let count = CFArrayGetCount(lines);
        if count == 0 {
            return -1;
        }
        var origins = [CGPoint](repeating: CGPoint.zero, count: count);
        CTFrameGetLineOrigins(self.ctFrame!, CFRange.init(location: 0, length: 0), &origins);
        var transform = CGAffineTransform.init(translationX: 0, y: frame.size.height);
        transform = transform.scaledBy(x: 1.0, y: -1.0);
        
        var idx: CFIndex = -1;
        for index in 0..<count {
            let linePoint = origins[index];
            let ctLine = unsafeBitCast(CFArrayGetValueAtIndex(lines, index), to: CTLine.self)
            let flippedRect = self.getLineBounds(line: ctLine, point: linePoint);
            let rect = flippedRect.applying(transform);
            if (rect.contains(point)) {
                let relativePoint = CGPoint.init(x: point.x - rect.minX - self.font!.pointSize/2.0,
                                                 y: point.y - rect.minY);
                
                idx = CTLineGetStringIndexForPosition(ctLine, relativePoint);
            }
        }
        return idx;
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
    
        self.saveHyperLinkRanges();
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
        
        self.addHyperLinkTextAttribute(attributedContent: attributedContent!);
        return attributedContent!;
    }
    
    private func saveHyperLinkRanges() -> Void {
        if self.hyperLinks != nil {
            for key in self.hyperLinks!.keys {
                self.saveHyperLinkTextRane(linkText: key, origin: self.text!);
            }
        }
    }
    
    
    private func addHyperLinkTextAttribute(attributedContent: NSMutableAttributedString) -> Void {
        if self.allLinkTextRanges.values.count > 0 {
            for key in (self.hyperLinks?.keys)! {
                let values = self.allLinkTextRanges[key];
                for value in values! {
                    let range = value as! NSRange;
                    let attributed = self.hyperLinks![key];
                    if(attributedContent.string.count >= range.location + range.length && attributed != nil) {
                        attributedContent.setAttributes(self.hyperLinks![key], range: range);
                    }
                }
            }
        }
    }
    
    
    private func saveHyperLinkTextRane(linkText: String, origin: String) -> Void {
        
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
    
    func getLineBounds(line: CTLine, point: CGPoint) -> CGRect {
        var ascent: CGFloat = 0.0;
        var descent: CGFloat = 0.0;
        var leading: CGFloat = 0.0;
        let width: Double = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        let height: CGFloat = ascent + descent;
        return CGRect.init(x: point.x, y: point.y - descent, width: CGFloat(width), height: height);
    }
}
