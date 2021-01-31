//
//  ViewController.swift
//  AppCovid
//
//  Created by Mac16
//

import UIKit
import WebKit

class ViewController: UIViewController, UISearchBarDelegate {
    
    let urlAPICovid = "https://corona.lmao.ninja/v3/covid-19/countries/"
    
    @IBOutlet weak var labelPais: UILabel!
    @IBOutlet weak var labelActualizacion: UILabel!
    @IBOutlet weak var labelActivos: UILabel!
    @IBOutlet weak var labelRecuperados: UILabel!
    @IBOutlet weak var labelMortales: UILabel!
    @IBOutlet weak var labelConfirmados: UILabel!
    @IBOutlet weak var imgBandera: WKWebView!
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text != "" {
            buscarPorPais(pais: searchBar.text ?? "")
        } else {
            mostrarAlerta(titulo: "Advertencia", mensaje: "No puedes dejar el campo vacío")
        }
        
    }
    
    
    
    func mostrarAlerta(titulo: String, mensaje:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: titulo, message: mensaje, preferredStyle: UIAlertController.Style.alert)
            let aceptarAlert = UIAlertAction(title: "Aceptar", style: UIAlertAction.Style.default, handler:  nil)
            alert.addAction(aceptarAlert)
            self.present(alert, animated: true, completion: nil)
        }
       
    }
    
    func buscarPorPais(pais:String){
        let peticion = URLRequest(url: URL(string: "\(urlAPICovid)\(pais)")!)
        let tarea = URLSession.shared.dataTask(with: peticion){datos,respuesta,error in
            if error != nil {
                print(error!)
            } else {
                do {
                    let json = try JSONSerialization.jsonObject(with: datos!, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                    print(json)
                    if let message = json["message"] as? String{
                        switch message {
                        case "Country not found or doesn't have any cases":
                            self.mostrarAlerta(titulo: "Error", mensaje: "No se encontró el pais")
                        default:
                            self.mostrarAlerta(titulo: "Error", mensaje: "Ocurrió un error, intentalo más tarde")
                        }
                    }else{
                        self.actualizaDatosGUI(json: json)
                    }
                    
                } catch {
                    print(error)
                }
            }
        }
        tarea.resume()
    }
    
    func actualizaDatosGUI(json : AnyObject){
        let unixtimeInterval = json["updated"] as! Double
        let fechaActualizacion = self.unixTimeToDate(unixtimeInterval: unixtimeInterval)
        let pais = json["country"] as! String
        let banderaimg = (json["countryInfo"] as! [String:Any])["flag"] as! String
        
        let casosConfirmados = String(json["cases"] as! Int)
        let casosMuertos = String(json["deaths"] as! Int)
        let casosRecuperados = String(json["recovered"] as! Int)
        let casosActivos = String(json["active"] as! Int)
        
        DispatchQueue.main.async {
            self.imgBandera.load(URLRequest(url: URL(string: banderaimg)!))
            self.labelPais.text = pais
            self.labelConfirmados.text = "\(casosConfirmados) casos"
            self.labelRecuperados.text = "\(casosRecuperados) casos"
            self.labelMortales.text = "\(casosMuertos) casos"
            self.labelActivos.text = "\(casosActivos) casos"
            self.labelActualizacion.text = "\(fechaActualizacion)"
        }
        
        print(fechaActualizacion + "Ultima actualizacion")
        print(pais + "Pais")
        print(banderaimg + "URL Bandera")
        print(casosConfirmados + "Casos confirmados")
        print(casosRecuperados + "Casos recuperados")
        print(casosMuertos + "Casos mortales")
        print(casosActivos + "Casos activos")
        
        
    }
    
    func unixTimeToDate(unixtimeInterval:Double) -> String{
        let date = Date(timeIntervalSince1970:(unixtimeInterval/1000)) //De milisegundos a segundos
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        //dateFormatter.timeStyle = DateFormatter.Style.medium //Set time style
        //dateFormatter.dateStyle = DateFormatter.Style.medium //Set date style
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm" //Specify your format that you want
        let fechaActualizacion = dateFormatter.string(from: date)
        return fechaActualizacion
    }
    
    func formatoNumeros(){
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
    }
    
    //OCULTA EL TECLADO AL HACER CLIC FUERA DE LA PANTALLA
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


