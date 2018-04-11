//
//  ViewController.swift
//  speechPrac
//
//  Created by 정기웅 on 2018. 4. 11..
//  Copyright © 2018년 정기웅. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, SFSpeechRecognizerDelegate {


    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    
    //음성인식
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-kr"))
    //
    private var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    private let audioEngine = AVAudioEngine()
    private var recognitionTask: SFSpeechRecognitionTask?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        microphoneButton.isEnabled = false
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized :
                isButtonEnabled = true
            case .denied, .restricted, .notDetermined : isButtonEnabled = false
            }
            
            OperationQueue.main.addOperation {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
    }

    func startRecording() {
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
        }
        catch {
            print("audio engine error")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest,
                                                            resultHandler: { (result, error) in
                                                                if let _result = result {
                                                                    self.textView.text = _result.bestTranscription.formattedString
                                                                }
        })
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    @IBAction func microphoneTapped(_ sender: UIButton) {
        if audioEngine.isRunning {
            stopRecording()
            microphoneButton.setTitle(("start"), for: .normal)
        }
        else {
            startRecording()
            microphoneButton.setTitle("stop", for: .normal)
        }
    }
    
}

