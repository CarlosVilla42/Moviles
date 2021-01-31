//
//  ViewController.swift
//  Contactos9-10
//
//  Created by Mac16
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var contactos = [Contacto]()
    
    var contactoSeleccionado : Contacto?
    
    var indice : Int?

    @IBOutlet weak var TablaContactos: UITableView!
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //registrar la nueva celda personalizada
        TablaContactos.register(UINib(nibName: "ContactoTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        cargarInfoCoreData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        TablaContactos.reloadData()
    }


    func mostrarAdvertencia (mensaje : String){
        let alert = UIAlertController(title: "Advertencia", message: mensaje, preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
            self.alertaAgregarContacto()
        }
        alert.addAction(accionAceptar)
        present(alert, animated: true)
    }
    
    func alertaAgregarContacto(){
        //AGREGAR CONTACTO CON UNA ALERTA
        let alert = UIAlertController(title: "Agregar contacto", message: "Nuevo contacto", preferredStyle: .alert)
        
        alert.addTextField { (nombreAlert) in
            nombreAlert.placeholder = "Nombre"
        }
        alert.addTextField { (telefonoAlert) in
            telefonoAlert.placeholder = "Telefono"
        }
        alert.addTextField { (direccionAlert) in
            direccionAlert.placeholder = "Direccion"
        }
        
        
        
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
            
            //variables para guardar la info del nuevo contacto
            guard let nombreAlert = alert.textFields?.first?.text else {
                return
            }
            guard let telefonoAlert = alert.textFields?[1].text else {
                return
            }
            guard let direccionAlert = alert.textFields?[2].text else {
                return
            }
            
            //ANTES DE GUARDAR VERIFICAMOS SI TODOS LOS CAMPOS TIENEN UN DATO
            if nombreAlert == "" || telefonoAlert == "" || direccionAlert == "" {
                self.mostrarAdvertencia(mensaje: "No se puede registrar con campos vacios")
                
            } else {
                
                let entidadContacto = Contacto(context: self.contexto)
                
                entidadContacto.nombre = nombreAlert
                entidadContacto.telefono = Int64(telefonoAlert) ?? 0
                entidadContacto.direccion = direccionAlert
                
                self.guardarContacto()
                self.cargarInfoCoreData()
                
                
                self.TablaContactos.reloadData()
            }
            
        }
        
        let accionCancelar = UIAlertAction(title: "Cancelar", style: .default, handler: nil)
        
        alert.addAction(accionAceptar)
        alert.addAction(accionCancelar)
        
        present(alert, animated: true)
    }
    
    @IBAction func AgregarContacto(_ sender: UIBarButtonItem) {
        alertaAgregarContacto()
    }
    
    func cargarInfoCoreData(){
        let fetchRequest : NSFetchRequest <Contacto> = Contacto.fetchRequest()
        do {
            self.contactos = try contexto.fetch(fetchRequest)
           
        }catch let error as NSError{
            print("Error al cargar de la bd \(error.localizedDescription)")
            
        }
    }
    
    func guardarContacto(){
        do {
            try contexto.save()
            print("Se guardo correctamente")
            
        } catch let error as NSError {
            print("Error al guardar en la base de datos \(error.localizedDescription)")
        }
        
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return contactos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let celda = TablaContactos.dequeueReusableCell(withIdentifier: "cell") as! ContactoTableViewCell
        
        //metodo para celdas personalizadas

        celda.nombreLabel.text = contactos[indexPath.row].nombre
        celda.telefonoLabel.text = String(contactos[indexPath.row].telefono)
        celda.dirLabel.text = contactos[indexPath.row].direccion
        if contactos[indexPath.row].img != nil {
            celda.imgContacto.image = UIImage(data: contactos[indexPath.row].img!)
        }
        
        
        return celda
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            contexto.delete(contactos[indexPath.row])
            contactos.remove(at: indexPath.row)
            guardarContacto()
            TablaContactos.reloadData()
        }
    }
    //MÉTODO CUANDO SELECCIONAS UN ELEMENTO DE LA TABLA
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) //QUITAR LA SELECCIÓN PERMANENTE
        self.contactoSeleccionado = contactos[indexPath.row] //GUARDO EL OBJETO CONTACTO COMPLETO
        self.indice = indexPath.row //GUARDO EL ÍNDICE SELECCIONADO
        performSegue(withIdentifier: "editarContacto", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editarContacto"{
            let ObjContacto = segue.destination as! EditarContactoViewController
            ObjContacto.contacto = contactoSeleccionado //ENVÍO EL CONTACTO SELECCIONADO
            ObjContacto.indice = self.indice //ENVIO EL ÍNDICE SELECCIONADO
        }
    }
    
}

