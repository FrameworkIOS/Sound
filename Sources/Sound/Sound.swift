//
//  Sound.swift
//
//
//  Created by Krisna Pranav on 04/03/23.
//

import Foundation
import AudioToolbox.AudioServices
import AudioToolbox
import AVFoundation

@available(iOS 10.0, *)
public typealias 🎹 = Sound

@available(iOS 10.0, *)
public class Sound {
    
    private static let `default` = Sound()
    
    private var feedbackGenerator: (notification: UINotificationFeedbackGenerator?,
        impact: (light: UIImpactFeedbackGenerator?,
        medium: UIImpactFeedbackGenerator?,
        heavy: UIImpactFeedbackGenerator?),
        selection: UISelectionFeedbackGenerator?) = (nil, (nil, nil, nil), nil)
    
    private var player: AVAudioPlayer?
    
    private var symphonyCounter = 0
    
    private var timers = [Timer]()
    
    private init() { }
    
    public static func wakeTapticEngine() {
        if Sound.default.feedbackGenerator.notification == nil {
            Sound.default.feedbackGenerator = (notification: UINotificationFeedbackGenerator(),
                                               impact: (light: UIImpactFeedbackGenerator(style: .light),
                                                        medium: UIImpactFeedbackGenerator(style: .medium),
                                                        heavy: UIImpactFeedbackGenerator(style: .heavy)),
                                               selection: UISelectionFeedbackGenerator())
        }
    }
    
    public static func prepareTapticEngine() {
        if Sound.default.feedbackGenerator.notification == nil {
            Sound.wakeTapticEngine()
        }
        Sound.default.feedbackGenerator.selection?.prepare()
        Sound.default.feedbackGenerator.notification?.prepare()
        Sound.default.feedbackGenerator.impact.light?.prepare()
        Sound.default.feedbackGenerator.impact.medium?.prepare()
        Sound.default.feedbackGenerator.impact.heavy?.prepare()
    }
    
    public static func putTapticEngineToSleep() {
        Sound.default.feedbackGenerator = (nil, (nil, nil, nil), nil)
    }
    
    private func playAudio(from assetName: String, completion: (() -> Void)?) {
        guard let asset = NSDataAsset(name: assetName) else {
            handle(error: SoundError.notFound(assetName))
            completion?()
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(data: asset.data, fileTypeHint: nil)
            if let player = player {
                player.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + player.duration, execute: {
                    completion?()
                })
            } else {
                handle(error: SoundError.couldNotPlay(assetName))
                completion?()
            }
        } catch {
            handle(error: error)
            completion?()
        }
    }

    private func playAudio(from file: (name: String, extension: String), completion: (() -> Void)?) {
        guard let url = Bundle.main.url(forResource: file.name, withExtension: file.extension) else {
            handle(error: SoundError.notFound("\(file.name + "." + file.extension)"))
            completion?()
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            if let player = player {
                player.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + player.duration, execute: {
                    completion?()
                })
            } else {
                handle(error: SoundError.couldNotPlay("\(file.name + "." + file.extension)"))
                completion?()
            }
        } catch {
            handle(error: error)
            completion?()
        }
    }
    
    private func playAudio(from url: URL, completion: (() -> Void)?) {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            player = try AVAudioPlayer(contentsOf: url)
            if let player = player {
                player.play()
                DispatchQueue.main.asyncAfter(deadline: .now() + player.duration, execute: {
                    completion?()
                })
            } else {
                handle(error: SoundError.couldNotPlay(url.absoluteString))
                completion?()
            }
        } catch {
            handle(error: error)
            completion?()
        }
    }
    
    private func playSystemSound(with soundId: Int, completion: (() -> Void)?) {
        AudioServicesPlaySystemSoundWithCompletion(SystemSoundID(soundId)) {
            DispatchQueue.main.async {
                completion?()
            }
        }
    }
    
    private func playHapticFeedback(_ feedback: HapticFeedback, completion: (() -> Void)?) {
        let duration: TimeInterval  https://developer.apple.com/ios/human-interface-guidelines/interaction/feedback/
        switch feedback {
        case .notification(let notification):
            switch notification {
            case .success:
                Sound.default.feedbackGenerator.notification?.notificationOccurred(.success)
                duration = 0.2
            case .warning:
                Sound.default.feedbackGenerator.notification?.notificationOccurred(.warning)
                duration = 0.25
            case .failure:
                Sound.default.feedbackGenerator.notification?.notificationOccurred(.error)
                duration = 0.5
            }
        case .impact(let impact):
            switch impact {
            case .light:
                Sound.default.feedbackGenerator.impact.light?.impactOccurred()
            case .medium:
                Sound.default.feedbackGenerator.impact.medium?.impactOccurred()
            case .heavy:
                Sound.default.feedbackGenerator.impact.heavy?.impactOccurred()
            }
            duration = 0.1
        case .selection:
            Sound.default.feedbackGenerator.selection?.selectionChanged()
            duration = 0.05
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
            completion?()
        })
    }
    
    public static func cancel() {
        for timer in Sound.default.timers {
            timer.invalidate()
        }
        Sound.default.timers.removeAll()
    }
        
    public static func play(_ notes: [Note], completion: (() -> Void)? = nil) {
        cancel()
        Sound.default.symphonyCounter += 1
        var pauseDurationBeforeNextNote: TimeInterval = 0
        let notes = Sound.default.removeUnnecessaryNotes(from: notes)
        var completion = completion
        if notes.contains(where: { (note) -> Bool in
            switch note {
            case .hapticFeedback: return true
            default: return false
            }
        }) {
            prepareTapticEngine()
            if let definedCompletion = completion {
                let newCompletion: (() -> Void) = {
                    definedCompletion()
                    putTapticEngineToSleep()
                }
                completion = newCompletion
            } else {
                completion = {
                    putTapticEngineToSleep()
                }
            }
        }
        notesLoop: for i in 0..<notes.count {
            let note = notes[i]
            var music: (() -> Void)? = nil
            var iterationCompletion: (() -> Void)? = nil
            if (i < notes.count - 2) {
                let nextNote = notes[i + 1]
                switch nextNote {
                case .waitUntilFinished:
                    let afterNextNoteIndex = i + 2
                    let finalNoteIndex = notes.count - 1
                    let restOfNotes = Array(notes[afterNextNoteIndex...finalNoteIndex])
                    let capturedCounter = Sound.default.symphonyCounter
                    iterationCompletion = {
                        if Sound.default.symphonyCounter == capturedCounter {
                            play(restOfNotes, completion: completion)
                        }
                    }
                default: break
                }
            } else if (i < notes.count - 1) {
                let nextNote = notes[i + 1]
                switch nextNote {
                case .waitUntilFinished:
                    iterationCompletion = completion
                default: break
                }
            } else if i == notes.count - 1 {
                iterationCompletion = completion
            }
            switch note {
            case .sound(let audio):
                switch audio {
                case .asset(let name):
                    music = { Sound.default.playAudio(from: name, completion: iterationCompletion) }
                case .file(let name, let type):
                    music = { Sound.default.playAudio(from: (name, type), completion: iterationCompletion) }
                case .url(let url):
                    music = { Sound.default.playAudio(from: url, completion: iterationCompletion) }
                case .system(let sound):
                    music = { Sound.default.playSystemSound(with: sound.rawValue, completion: iterationCompletion) }
                }
            case .vibration(let vibration):
                music = { Sound.default.playSystemSound(with: vibration.rawValue, completion: iterationCompletion) }
            case .tapticEngine(let engine):
                music = { Sound.default.playSystemSound(with: engine.rawValue, completion: iterationCompletion) }
            case .hapticFeedback(let feedback):
                music = { Sound.default.playHapticFeedback(feedback, completion: iterationCompletion) }
            case .waitUntilFinished:
                if i != 0 {
                    break notesLoop
                }
            case .wait(let interval):
                pauseDurationBeforeNextNote += interval
                if i == notes.count - 1 {
                    music = { iterationCompletion?() }
                }
            }
            if let music = music {
                let timer = Timer(timeInterval: pauseDurationBeforeNextNote, repeats: false) { (_) in
                    music()
                }
                RunLoop.main.add(timer, forMode: .common)
                Sound.default.timers.append(timer)
            }
        }
        if notes.count == 0 {
            completion?()
        }
    }
    
    private func removeUnnecessaryNotes(from notes: [Note]) -> [Note] {
        var results = [Note]()
        for note in notes {
            if results.count == 0 {
                results.append(note)
            } else if let last = results.last {
                switch note {
                case .waitUntilFinished:
                    switch last {
                    case .waitUntilFinished: break
                    default: results.append(note)
                    }
                default: results.append(note)
                }
            }
        }
        if results.count == 1 {
            let onlyNote = results[0]
            switch onlyNote {
            case .waitUntilFinished: return []
            default: break
            }
        } else {
            var removedFirstWaits = false
            var removedLastWaits = false
            while !removedFirstWaits || !removedLastWaits {
                switch results.first! {
                case .waitUntilFinished: results.removeFirst()
                default: removedFirstWaits = true
                }
                switch results.last! {
                case .waitUntilFinished: results.removeLast()
                default: removedLastWaits = true
                }
            }
        }
        return results
    }
}
