//
//  ViewController.swift
//  DavidQuispeSoundBoard
//
//  Created by David Quispe Maqque on 7/10/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    

    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones:[Grabacion] = []
    var reproducirAudio:AVAudioPlayer?
    var reproduccionTimer: Timer?
    var tiempoReproduccion = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaGrabaciones.dataSource = self
        tablaGrabaciones.delegate = self
        tablaGrabaciones.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return grabaciones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let grabacion = grabaciones[indexPath.row]
        
        // Mostrar el nombre de la grabación
        cell.textLabel?.text = grabacion.nombre
        
        // Convertir la duración de segundos a formato MM:SS
        let duracionTexto = formatTime(seconds: Int(grabacion.duracion))
        
        // Mostrar la duración en formato MM:SS
        cell.detailTextLabel?.text = "Duración: \(duracionTexto)"
        
        return cell
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = String(format: "%02d", seconds / 60)
        let seconds = String(format: "%02d", seconds % 60)
        return "\(minutes):\(seconds)"
    }


    
    override func viewWillAppear(_ animated: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
            grabaciones = try context.fetch(Grabacion.fetchRequest())
            tablaGrabaciones.reloadData()
        } catch{}
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]
        
        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.play()
            
            // Reiniciar el tiempo de reproducción
            tiempoReproduccion = 0
            
            // Iniciar el temporizador que actualiza el tiempo de reproducción
            reproduccionTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempoReproduccion), userInfo: nil, repeats: true)
            
        } catch {
            tablaGrabaciones.deselectRow(at: indexPath, animated: true)
        }
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()

            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            } catch {
            }
        }
    }
    
    @objc func actualizarTiempoReproduccion() {
        if let audioPlayer = reproducirAudio {
            tiempoReproduccion = Int(audioPlayer.currentTime)
            
            // Aquí puedes actualizar el UILabel o alguna otra vista
            print("Tiempo de reproducción: \(formatTime(seconds: tiempoReproduccion))")
            
            // Detener el temporizador cuando la reproducción termine
            if !audioPlayer.isPlaying {
                reproduccionTimer?.invalidate()
                reproduccionTimer = nil
            }
        }
    }

}

