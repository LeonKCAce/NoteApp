//  NoteViewController.swift
//  NoteApp_1108
//  Created by student42 on 2018/11/22.
import UIKit

protocol NoteViewControllerDelegate : class {
    func didFinishUpdate(note: Note)
}

class NoteViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imageView: UIImageView!
    
    var currentNote : Note! //NoteVC 一定要傳給ListVC,所以用！
    weak var noteDelegate : NoteViewControllerDelegate? //只能放class的物件，不能放struct物件
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = self.currentNote.text
        self.imageView.image = self.currentNote.image()
    }

    
    
    @IBAction func camera(_ sender: Any) {
        let controller = UIImagePickerController()
        controller.sourceType = .savedPhotosAlbum
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
    }
    
    //MARK:UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.imageView.image = image
            self.isNewPhoto = true
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    var isNewPhoto = false
    @IBAction func done(_ sender: Any) {
        self.currentNote.text = self.textView.text
        if self.isNewPhoto{
            if let imageData =  self.imageView.image?.jpegData(compressionQuality: 1) {
                do{
                    let home = URL(fileURLWithPath: NSHomeDirectory())
                    let documents = home.appendingPathComponent("Documents")
                    let fileName = "\(self.currentNote.noteID).jpg"
                    let fileURL = documents.appendingPathComponent(fileName)
                    self.currentNote.imageName = fileName
                try imageData.write(to: fileURL, options: .atomicWrite)
                } catch{
                    print("寫入圖檔有錯\(error)")
                }
            }
        }
        
        self.noteDelegate?.didFinishUpdate(note: self.currentNote)
        
        self.navigationController?.popViewController(animated: true)
    }

}
