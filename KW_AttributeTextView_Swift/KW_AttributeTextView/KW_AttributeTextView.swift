//
//  KW_AttributeTextView.swift
//  KW_AttributeTextView_Swift
//
//  Created by LKW on 2018/5/3.
//  Copyright © 2018年 Udo. All rights reserved.
//

import UIKit

class KW_AttributeTextView: UIView {

    private var text: KW_AttributeTextData?;
    
    init(frame: CGRect, data: KW_AttributeTextData) {
        super.init(frame: frame);
        self.text = data;
        self.backgroundColor = UIColor.white;
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(frame);
        let context = UIGraphicsGetCurrentContext();
        context?.textMatrix = CGAffineTransform.identity;
        context?.translateBy(x: 0, y: self.bounds.size.height);
        context?.scaleBy(x: 1.0, y: -1.0);
        CTFrameDraw((self.text?.ctFrame)!, context!);
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = ((touches as NSSet).anyObject())! as! UITouch;
        let point = touch.location(in: self);
        let idx: CFIndex = (self.text?.kw_textIndexFromTouchedPoint(point: point))!;
        if (idx < (self.text?.text?.count)! && idx > -1) {
            let string: NSString = NSString.init(string: (self.text?.text)!);
            var c = string.character(at: idx);
            print("current touched text == \(NSString.init(characters: &c, length: 1))");
            for key in (self.text?.allLinkTextRanges.keys)! {
                let ranges = self.text?.allLinkTextRanges[key];
                for value in ranges! {
                    let range = value as! NSRange;
                    if (NSLocationInRange(idx, range)) {
                        let hyperLinkInfo: [String: Any] = [KWHyperLinkTextKey.text: key,
                                                            KWHyperLinkTextKey.range: range];
                        
                        print("hyperLink Text == \(hyperLinkInfo)")
                        break;
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
