//
//  ViewController.swift
//  KW_AttributeTextView_Swift
//
//  Created by LKW on 2018/5/3.
//  Copyright © 2018年 Udo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let x: CGFloat = 20.0;
        let w: CGFloat = self.view.bounds.size.width - 40;
        
        let text = "就业形势趋好，首先归功于经济200保持中高速经济增长。一季度，我国GDP同比增长200万，延续了近年来平稳增长的态势，经济增速符合预期。经济增长拉动就业的能力势趋好。根据测算，目前我国经济势趋好增长每提高一个百分点，能够带动近200万人就业。势趋好";
        
        let data = KW_AttributeTextData.init();
        data.text = text;
        data.width = w;
        data.lineSpacing = 8;
        data.font = UIFont.systemFont(ofSize: 14);
        data.hyperLinks = ["势趋好": [NSAttributedStringKey.foregroundColor: UIColor.green,
                                         NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)],
                           "根据测算": [NSAttributedStringKey.foregroundColor: UIColor.red,
                                            NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)]];
        
        data.kw_completedDataSetting();
        
        let frame = CGRect.init(x: x, y: 100, width: w, height: (data.textRealSize?.height)!)
        let textView = KW_AttributeTextView.init(frame: frame,
                                                 data: data);
        self.view.addSubview(textView);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

