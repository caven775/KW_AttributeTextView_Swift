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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
