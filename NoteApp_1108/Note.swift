//
//  Note.swift
//  NoteApp_1108
//
//  Created by student42 on 2018/11/8.
//  Copyright © 2018年 student42. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Note : NSManagedObject {
    static func == (lhs:Note, rhs: Note) -> Bool {
        return lhs.noteID == rhs.noteID
    }

    @NSManaged var noteID: String //像mysql, primary key
    @NSManaged var text: String?
    @NSManaged var imageName : String?
//    var image: UIImage? //直接放在記憶體裡
    
    override func awakeFromInsert() {
        noteID = UUID().uuidString
    }
   /* override init(){
        noteID = UUID().uuidString //自動產生32字亂碼
    }*/
    func image() -> UIImage? {
        if let name = imageName{
            let home = URL(fileURLWithPath: NSHomeDirectory())
            let documents = home.appendingPathComponent("Documents")
            let fileName = name
            let fileURL = documents.appendingPathComponent(fileName)
            if let image = UIImage(contentsOfFile: fileURL.path) {
                return image
            }
        
        }
        return nil
    }
    
    
    func thumbnailImage() -> UIImage? {
        if let image =  self.image() {
            
            let thumbnailSize = CGSize(width:50, height: 50);
            let scale = UIScreen.main.scale
            UIGraphicsBeginImageContextWithOptions(thumbnailSize,false,scale)
            let widthRatio = thumbnailSize.width / image.size.width;
            let heightRadio = thumbnailSize.height / image.size.height;
            let ratio = max(widthRatio,heightRadio);
            let imageSize = CGSize(width:image.size.width*ratio,height: image.size.height*ratio);
            image.draw(in:CGRect(x: -(imageSize.width-thumbnailSize.width)/2.0,y: -(imageSize.height-thumbnailSize.height)/2.0,
                                 width: imageSize.width,height: imageSize.height))

            let smallImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            return smallImage
        }else{
            return nil;
        }
        
    }
}
