//
//  EditarContactoViewController.swift
//  Contactos9-10
//
//  Created by Mac16 
//  Copyright © 2020 oscar. All rights reserved.
//

import UIKit
import CoreData

class EditarContactoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var contacto : Contacto?
    
    var indice : Int?
    
    var contactos = [Contacto]()
    
    @IBOutlet weak var imgContacto: UIImageView!
    @IBOutlet weak var nombreContacto: UITextField!
    @IBOutlet weak var telefonoContacto: UITextField!
    @IBOutlet weak var direccionContacto: UITextView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //RECIVIENDO LOS DATOS
        
        //CARGAR DATOS DEL CONTACTO SELECCIONDO
        self.nombreContacto.text = contacto!.nombre
        self.telefonoContacto.text = String(contacto!.telefono)
        self.direccionContacto.text = contacto!.direccion
        
        if contacto!.img != nil {
            self.imgContacto.image = UIImage(data: contacto!.img!)
        }
    
        //CARGAR LA BASE DE DATOS A NUESTRO ARREGLO
        cargarInfoCoreData()
        
        
        
    }
    func mostrarAdvertencia (mensaje : String){
           let alert = UIAlertController(title: "Advertencia", message: mensaje, preferredStyle: .alert)
           let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
              //nil
           }
           alert.addAction(accionAceptar)
           present(alert, animated: true)
       }
    
    @IBAction func guardarContactoButton(_ sender: UIButton) {
        if nombreContacto.text == "" || telefonoContacto.text == "" || direccionContacto.text == "" {
            print("CACAAAAAAAAAAAAA")
            mostrarAdvertencia(mensaje: "No puedes dejar campos vacíos")
        } else{
            print("no es caca")
            contactos[self.indice!].setValue(nombreContacto.text, forKey: "nombre")
            contactos[self.indice!].setValue(Int64(telefonoContacto.text!), forKey: "telefono")
            contactos[self.indice!].setValue(direccionContacto.text, forKey: "direccion")
            contactos[self.indice!].setValue(imgContacto.image?.pngData(), forKey: "img")
            guardarContacto()
            navigationController?.popViewController(animated: true)
        }
            
        
       
    }
    
    @IBAction func cancelarButton(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func seleccionaImagen(_ sender: UIBarButtonItem) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    
    func guardarContacto(){
        do {
            try contexto.save()
            print("Se guardo correctamente")
            
        } catch let error as NSError {
            print("Error al guardar en la base de datos \(error.localizedDescription)")
        }
        
    }
    
    func cargarInfoCoreData(){
        let fetchRequest : NSFetchRequest <Contacto> = Contacto.fetchRequest()
        do {
            self.contactos = try contexto.fetch(fetchRequest)
            
        }catch let error as NSError{
            print("Error al cargar de la bd \(error.localizedDescription)")
            
        }
    }
    
    //CARGAR LA IMAGEN AL UIVIEW
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let imagenSeleccionada = info[.editedImage] as? UIImage else {return}
        imgContacto.image = imagenSeleccionada
        picker.dismiss(animated: true)
    }
    
    //OCULTA EL TECLADO AL HACER CLIC FUERA DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


