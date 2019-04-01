//
//  BaseTest.swift
//  Base
//
//  Created by jintao on 2019/3/31.
//  Copyright © 2019 jintao. All rights reserved.
//

import Foundation
import MachO
import antiFishhook

// protect
public func protectNSLog() {
    resetSymbol("NSLog")
}

// protect BaseTest Framework's dladdr
public func protectDladdr() {
    for i in 0..<_dyld_image_count() {
        if let name = _dyld_get_image_name(i) {
            let imageName = String(cString: name)
            if imageName.contains("FishHookProtect"),
                let symbol = "dladdr".data(using: String.Encoding.utf8)?.map({$0}),
                let image = _dyld_get_image_header(i)
            {
                resetSymbol(symbol, image: image, imageSlide: _dyld_get_image_vmaddr_slide(i))
                break
            }
        }
    }
}


public func verificationDyld() {
    if let testImp = class_getMethodImplementation(BaseTest.self, #selector(BaseTest.baseTest)) {
        var info = Dl_info()
        if dladdr(UnsafeRawPointer(testImp), &info) == -999 {
            print("dladdr --------- fishhook")
        } else if dladdr(UnsafeRawPointer(testImp), &info) == 1 {
            print("dladdr fname---------",  String(cString: info.dli_fname))
        }
    }
}

class BaseTest {
    @objc func baseTest() {
        print("baseTest")
    }
}
