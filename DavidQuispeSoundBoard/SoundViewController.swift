//
//  SoundViewController.swift
//  DavidQuispeSoundBoard
//
//  Created by David Quispe Maqque on 7/10/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {

    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var volumenSlider: UISlider!
    
    var grabarAudio:AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer: Timer?
    var recordingTime = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false

        // Do any additional setup after loading the view.
    }
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording{
            //detener la grabacion
            grabarAudio?.stop()
            //Cambiar texto del boton grabar
            grabarButton.setTitle("GRABAR", for: .normal)
            reproducirButton.isEnabled = true
            agregarButton.isEnabled = true
            
            timer?.invalidate()
            timer = nil
        }else{
            //Empezar a grabar
            grabarAudio?.record()
            //Cambiar el texto del boton grabar a detener
            grabarButton.setTitle("DETENER", for: .normal)
            reproducirButton.isEnabled = false
            
            recordingTime = 0
            recordingTimeLabel.text = "0 segundos"
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRecordingTime), userInfo: nil, repeats: true)
        }
    }
    @IBAction func reproducirTapped(_ sender: Any) {
        do{
            try reproducirAudio = AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio!.play()
            print("Reproduciendo")
        } catch {}
    }
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let grabacion = Grabacion(context: context)
            grabacion.nombre = nombreTextField.text
            grabacion.audio = NSData(contentsOf: audioURL!)! as Data
            grabacion.duracion = Int32(recordingTime) // Guardar la duración
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            navigationController!.popViewController(animated: true)
    }
    
    @IBAction func cambiarVolumen(_ sender: UISlider) {
        reproducirAudio?.volume = sender.value
    }
    
    
    func configurarGrabacion(){
        do{
            //creando sesion de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            //creando direccion para el archivo de audio
            let basePath:String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath,"audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            //impresion de ruta donde se guardan los archivos
            print("********************")
            print(audioURL!)
            print("********************")
            
            //crear opciones para el grabador de audio
            var settings:[String:AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            //crear el objeto de grabacion de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        }catch let error as NSError{
            print(error)
        }
    }
    
    func formatTime(seconds: Int) -> String {
        let minutes = String(format: "%02d", seconds / 60)
        let seconds = String(format: "%02d", seconds % 60)
        return "\(minutes):\(seconds)"
    }

    @objc func updateRecordingTime() {
        recordingTime += 1
        recordingTimeLabel.text = formatTime(seconds: recordingTime)
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
