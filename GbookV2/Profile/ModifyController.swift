//
//  ModifyController.swift
//  GbookV2
//
//  Created by macOS12 on 26/04/2019.
//  Copyright © 2019 macOS12. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import FirebaseFirestore
import PUGifLoading



class ModifyController: UIViewController {
    // MARK : - Variables
    
    @IBOutlet weak var changeName: UITextField!
    @IBOutlet weak var changeSecondName: UITextField!
    @IBOutlet weak var changeEmail: UITextField!
    @IBOutlet weak var changeUsername: UITextField!
    
    let loading = PUGIFLoading.init()
    let imagePicker = UIImagePickerController()
    
    var email:String?
    var likeStatus:Bool?
    var arrayNombres: [String] = []
    var arrayNombresPost: [String] = []
    public var userDocumentId: String?
    public var postDocumentId: String?
    public var commentDocumentId : String?
    public var emailData: String?
    public var emailData2 : String?
    @IBOutlet weak var buttonAvatar: UIButton!
    @IBOutlet weak var buttonProfile: UIButton!
    private var userData : [String : Any] = [:]
    
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var imageAvatar: UIImageView!
    public var nameData: String?
    public var secondNameData: String?
    public var userNameData: String?
    public var photoCommentData : String?
    //public var photoData: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        assignbackground()
        borderColor()
        getUser()
        
    

        changeEmail.text = emailData
        
        imagePicker.delegate = self
        
        imageAvatar.layer.borderWidth = 3
        imageAvatar.layer.borderColor = UIColor.black.cgColor
        imageAvatar.layer.cornerRadius = imageAvatar.frame.size.width/2.05
        imageAvatar.clipsToBounds = true
        
        let tapBackIconFlecha = UITapGestureRecognizer(target: self, action: #selector(backButtonTapped(tapBackIconFlecha:)))
        backButton.isUserInteractionEnabled = true
        backButton.addGestureRecognizer(tapBackIconFlecha)
        
        // Do any additional setup after loading the view.
    }
    func assignbackground(){
        let background = UIImage(named: "prueba")
        
        
        var imageView : UIImageView!
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode =  UIView.ContentMode.scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = background
        imageView.center = view.center
        view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }
    func borderColor(){
        
        
        //MARK: Estilo botones
        
        buttonAvatar.layer.shadowColor = UIColor.black.cgColor
        buttonAvatar.layer.shadowOffset = CGSize(width: 5, height: 5)
        buttonAvatar.layer.shadowRadius = 5
        buttonAvatar.layer.shadowOpacity = 1.0
        buttonProfile.layer.shadowColor = UIColor.black.cgColor
        buttonProfile.layer.shadowOffset = CGSize(width: 5, height: 5)
        buttonProfile.layer.shadowRadius = 5
        buttonProfile.layer.shadowOpacity = 1.0
        
        buttonAvatar.layer.cornerRadius = 12
        buttonProfile.layer.cornerRadius = 12
    }
    @objc func backButtonTapped(tapBackIconFlecha: UITapGestureRecognizer)
    {
        
        
        let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "TableViewCellViewController") as! TableViewCellViewController
        vc.email = self.email
        present(vc, animated: true, completion: nil)
    }
    func getUser() {
        let myGroup = DispatchGroup()
        myGroup.enter()
        
        let db = Firestore.firestore()
        print("Email:")
        print(email!)
        db.collection("Usuarios").whereField("Email", isEqualTo: email!)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        self.userDocumentId = document.documentID
                        self.userData = document.data()
                        print(self.userDocumentId!)
                        self.emailData = self.userData["Email"] as? String
                        self.nameData = self.userData["Nombre"] as? String
                        self.secondNameData = self.userData["Apellidos"] as? String
                        self.userNameData = self.userData["Nombre de usuario"] as? String
                        //self.photoData = self.userData["profileURL"] as? UIImageView
                        
                        print(self.emailData!)
                        
                        
                        self.changeEmail.text = self.emailData
                        self.changeName.text = self.nameData
                        self.changeSecondName.text = self.secondNameData
                        self.changeUsername.text = self.userNameData
                        print("***FOTOO")
                        
                        
                        let url = URL(string : ((self.userData["profileURL"])! as! String))
                        if let url = url as? URL{
                            KingfisherManager.shared.retrieveImage(with: url as! Resource , options: nil, progressBlock: nil){ (image, error , cache , imageURL) in
                                
                                self.imageAvatar.image = image
                                self.imageAvatar.kf.indicatorType = .activity
                                
                            }
 
                        }
                    }
                    myGroup.leave()
                }
                
                
                
        }
        myGroup.notify(queue: DispatchQueue.main, execute: {
            
            print("***DATOS DE USUARIO COGIDO CON EXITO")
            self.getAllFIRData()
        })
    }
 
    func getAllFIRData(){
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        
        let db = Firestore.firestore()
        print("Email:")
        print(email!)
        
        db.collection("Post").whereField("Email", isEqualTo: email!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    self.postDocumentId = document.documentID
                    self.arrayNombres.append(document.documentID)
                    self.userData = document.data()
                    self.emailData2 = self.userData["Email"] as? String
                    self.userNameData = self.userData["NombredeUsuario"] as? String ?? ""
                    self.nameData = self.userData["Nombre"] as? String ?? ""

                    print(self.nameData!)
                }
                myGroup.leave()
            }
            
            
            myGroup.notify(queue: DispatchQueue.main, execute: {
                print("***TODOS LOS POST QUE TIENEN QUE VER CON EL EMAIL COGIDOS CON EXITO")
                self.getAllCommentsData()
            })
        }
    }
    func getAllCommentsData(){
        
        let myGroup = DispatchGroup()
        myGroup.enter()
        
        let db = Firestore.firestore()
        print("Email:")
        print(email!)
        
        db.collection("Comentario").whereField("Email", isEqualTo: email!).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    self.commentDocumentId = document.documentID
                    self.arrayNombresPost.append(document.documentID)
                    self.userData = document.data()
                    self.emailData2 = self.userData["Email"] as? String
                    self.userNameData = self.userData["NombreUsuario"] as? String ?? ""
                    self.photoCommentData = self.userData["ImagenAvatar"] as? String ?? ""
                }
                myGroup.leave()
            }
            myGroup.notify(queue: DispatchQueue.main, execute: {
                print("***TODOS LOS COMENTARIOS RELACIONADOS CON EL EMAIL COGIDOS CON EXITO")
                
            })
        }
        
        
        
    }
    
    
    
    
    
    @IBAction func editButton(_ sender: UIButton) {
        loading.show("Actualizando", gifimagename: "mario")
        updateUser()
    }
    
    @IBAction func changeAvatar(_ sender: UIButton) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true , completion: nil)
        
    }
    func updateUser(){
        let myGroup = DispatchGroup()
        myGroup.enter()
        let db = Firestore.firestore()
        
        db.collection("Usuarios").document(userDocumentId!).updateData([
            "Nombre": changeName.text!,
            "Apellidos": changeSecondName.text!,
            "Nombre de usuario": changeUsername.text!
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            } else {
                print("Document successfully updated")
                
            }
            
        }
        myGroup.leave()
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("***UPDATEA TODOS LOS DATOS DEL USUARIO MODIFICADO")
            self.saveFIRData()
        })
    }
    
    func saveFIRData(){
        let myGroup = DispatchGroup()
        myGroup.enter()
        self.uploadImage(self.imageAvatar.image!){url in
            
            self.saveImage(profileURL: url!){ sucess in
                if sucess != nil {
                    print("***SAVEFIRDATA")
                    
                }
            }
            myGroup.leave()
            
        }
        
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("***GUARDA LA FOTO MODIFICADA POR EL USUARIO")
            self.updateUserPost()
        })
    }
    
    func updateUserPost(){
        let myGroup = DispatchGroup()
        myGroup.enter()
        let db = Firestore.firestore()
        for nombres in arrayNombres {
            
            db.collection("Post").document(
                nombres).updateData([
                    "NombredeUsuario" : changeUsername.text!
                    
                    ])
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
            }
        }
        myGroup.leave()
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("***UPDATE EL NOMBRE MODIFICADO EN TODOS SUS POSTS SUBIDOS")
            self.saveFIRData2()
        })
        
    }
    
    func saveFIRData2(){
        let myGroup = DispatchGroup()
        myGroup.enter()
        self.uploadImage(self.imageAvatar.image!){url in
            
            self.updateImage(profileURL: url!){ sucess in
                if sucess != nil {
                    print("***SAVEFIRDATA2")
                }
            }
            myGroup.leave()
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("***GUARDA LA FOTO MODIFICADA POR EL USUARIO EN LOS POST SUBIDOS")
            self.updateUserComments()
        })
    }
    
    
    
    func updateUserComments(){
        let myGroup = DispatchGroup()
        myGroup.enter()
        
        let db = Firestore.firestore()
        for nombres in arrayNombresPost {
            db.collection("Comentario").document(
                nombres).updateData([
                    "NombreUsuario" : changeUsername.text!
                    ])
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("Document successfully updated")
                    }
            }
        }
        myGroup.leave()
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            print("***UPDATEA EL NOMBRE EN TODOS LOS COMENTARIOS DEJADOS POR EL USUARIO")
            self.saveFIRData3()
        })
        
    }

    func saveFIRData3(){
        let myGroup = DispatchGroup()
        myGroup.enter()
        self.uploadImage(self.imageAvatar.image!){url in
            
            self.updateImageComentario(profileURL: url!){ sucess in
                if sucess != nil {
                    print("*****SAVEFIRDATA3")
                }
            }
            myGroup.leave()
        }
        
        myGroup.notify(queue: DispatchQueue.main, execute: {
            
            print("***GUARDA LA FOTO MODIFICADA POR EL USUARIO EN TODOS LOS COMENTARIOS")
            
            self.loading.hide()
            let storyboard = UIStoryboard(name: "Storyboard", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "TableViewCellViewController") as! TableViewCellViewController
            vc.email = self.emailData
            
            self.present(vc, animated: true, completion: nil)
        })
    }
}




extension ModifyController: UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    func setupImagePicker(){
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.delegate = self
            imagePicker.isEditing = true
            
            self.present(imagePicker , animated: true , completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        imageAvatar?.image = image
        
        self.dismiss(animated: true, completion: nil)
        
    }
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    

    func uploadImage(_ image:UIImage , completion: @escaping (_ url: URL?) -> ()){
        let storageRef = Storage.storage().reference().child("Imagenes/\(randomString(length: Int.random(in: 10 ... 35)))/myimage.jpg")
        let imgData = imageAvatar.image?.jpegData(compressionQuality: 0.2)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        storageRef.putData(imgData!, metadata: metaData)
        { (metadata,error) in
            if error == nil{
                print("success")
                storageRef.downloadURL(completion: { (url, error) in
                    completion(url!)
                })
                
            }else{
                print("error in save image")
                completion(nil)
            }
        }
    }
    
    func saveImage(profileURL:URL, completion: @escaping ((_ url: URL?) -> ())){
        let db = Firestore.firestore()
        
         db.collection("Usuarios").document(userDocumentId!).updateData([
            
         "profileURL": profileURL.absoluteString] as [String:Any])
        
    }
    
    func updateImage(profileURL:URL, completion: @escaping ((_ url: URL?) -> ())){
        let db = Firestore.firestore()
        
        
        for nombres in arrayNombres {
            
            db.collection("Post").document(
                nombres).updateData([
                    
                    "ImagenAvatar" : profileURL.absoluteString] as [String:Any])
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("****Imagenes de avatar")
                    }
            }
        }
        
    }
    
    func updateImageComentario(profileURL:URL, completion: @escaping ((_ url: URL?) -> ())){
        let myGroup = DispatchGroup()
        myGroup.enter()
        let db = Firestore.firestore()
        
        for nombres in arrayNombresPost {
            
            db.collection("Comentario").document(
                nombres).updateData([
                    
                    "ImagenAvatar" : profileURL.absoluteString] as [String:Any])
                { err in
                    if let err = err {
                        print("Error updating document: \(err)")
                    } else {
                        print("****Hecho")
                    }
            }
        }
    }
    
    
    
}
