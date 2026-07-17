//
//  SoundManager.swift
//  myapp-1
//

import AVFoundation
import UIKit
import Combine

@MainActor
class SoundManager: NSObject, ObservableObject {
    static let shared = SoundManager()
    
    @Published var isMuted: Bool = UserDefaults.standard.bool(forKey: "SoundManagerIsMuted") {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: "SoundManagerIsMuted")
        }
    }
    
    private var players: [SoundType: AVAudioPlayer] = [:]
    
    private let lightImpact = UIImpactFeedbackGenerator(style: .light)
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    private let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationFeedback = UINotificationFeedbackGenerator()
    
    enum SoundType: CaseIterable {
        case tap
        case comboTap
        case trap
        case bonus
        
        case cardCorrect
        case cardWrong
        case levelUp
        
        case quizCorrect
        case quizWrong
        case streakBonus
        case timeOut
        
        case gameOver
        case victory
    }
    
    private enum WaveType {
        case sine
        case square
        case triangle
        case sawtooth
    }
    
    override private init() {
        super.init()
        setupAudioSession()
        synthesizeAllSounds()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("SoundManager: Failed to set up audio session - \(error)")
        }
    }
    
    private func synthesizeAllSounds() {
        for type in SoundType.allCases {
            if let data = generateAudioData(for: type) {
                do {
                    let player = try AVAudioPlayer(data: data)
                    player.prepareToPlay()
                    players[type] = player
                } catch {
                    print("SoundManager: Failed to create AVAudioPlayer for \(type) - \(error)")
                }
            }
        }
    }
    
    private func play(_ type: SoundType) {
        guard !isMuted, let player = players[type] else { return }
        if player.isPlaying {
            player.currentTime = 0
        }
        player.play()
    }
    
    func playTap() {
        play(.tap)
        lightImpact.impactOccurred()
    }
    
    func playCombo(multiplier: Int) {
        play(.comboTap)
        let intensity = min(1.0, CGFloat(multiplier) * 0.25)
        mediumImpact.impactOccurred(intensity: intensity)
    }
    
    func playTrap() {
        play(.trap)
        notificationFeedback.notificationOccurred(.error)
    }
    
    func playBonus() {
        play(.bonus)
        notificationFeedback.notificationOccurred(.success)
    }
    
    func playCardCorrect() {
        play(.cardCorrect)
        lightImpact.impactOccurred()
    }
    
    func playCardWrong() {
        play(.cardWrong)
        notificationFeedback.notificationOccurred(.error)
    }
    
    func playLevelUp() {
        play(.levelUp)
        notificationFeedback.notificationOccurred(.success)
    }
    
    func playQuizCorrect() {
        play(.quizCorrect)
        notificationFeedback.notificationOccurred(.success)
    }
    
    func playQuizWrong() {
        play(.quizWrong)
        notificationFeedback.notificationOccurred(.error)
    }
    
    func playStreakBonus() {
        play(.streakBonus)
        heavyImpact.impactOccurred()
    }
    
    func playTimeOut() {
        play(.timeOut)
        notificationFeedback.notificationOccurred(.warning)
    }
    
    func playGameOver() {
        play(.gameOver)
        notificationFeedback.notificationOccurred(.error)
    }
    
    func playVictory() {
        play(.victory)
        notificationFeedback.notificationOccurred(.success)
    }
    
    private func generateAudioData(for type: SoundType) -> Data? {
        switch type {
        case .tap:
            return createWavData(frequencies: [600.0, 800.0], durations: [0.03, 0.04], waveType: .sine, volume: 0.35)
        case .comboTap:
            return createWavData(frequencies: [659.25, 880.0, 1046.50], durations: [0.04, 0.04, 0.06], waveType: .triangle, volume: 0.4)
        case .trap:
            return createWavData(frequencies: [150.0, 140.0], durations: [0.12, 0.15], waveType: .sawtooth, volume: 0.45)
        case .bonus:
            return createWavData(frequencies: [523.25, 659.25, 783.99, 1046.50], durations: [0.06, 0.06, 0.06, 0.15], waveType: .triangle, volume: 0.45)
            
        case .cardCorrect:
            return createWavData(frequencies: [783.99, 1046.50], durations: [0.04, 0.08], waveType: .sine, volume: 0.35)
        case .cardWrong:
            return createWavData(frequencies: [220.0, 164.81], durations: [0.1, 0.15], waveType: .sawtooth, volume: 0.45)
        case .levelUp:
            return createWavData(frequencies: [440.0, 554.37, 659.25, 880.0], durations: [0.07, 0.07, 0.07, 0.2], waveType: .triangle, volume: 0.45)
            
        case .quizCorrect:
            return createWavData(frequencies: [587.33, 880.0], durations: [0.07, 0.14], waveType: .sine, volume: 0.4)
        case .quizWrong:
            return createWavData(frequencies: [180.0, 140.0], durations: [0.15, 0.18], waveType: .square, volume: 0.4)
        case .streakBonus:
            return createWavData(frequencies: [523.25, 659.25, 783.99, 987.77, 1046.50], durations: [0.05, 0.05, 0.05, 0.05, 0.18], waveType: .triangle, volume: 0.45)
        case .timeOut:
            return createWavData(frequencies: [400.0, 0.0, 400.0], durations: [0.08, 0.04, 0.12], waveType: .square, volume: 0.4)
            
        case .gameOver:
            return createWavData(frequencies: [400.0, 350.0, 300.0, 250.0], durations: [0.08, 0.08, 0.08, 0.25], waveType: .triangle, volume: 0.45)
        case .victory:
            return createWavData(frequencies: [523.25, 659.25, 783.99, 1046.50, 1318.51], durations: [0.07, 0.07, 0.07, 0.07, 0.25], waveType: .sine, volume: 0.45)
        }
    }
    
    private func createWavData(frequencies: [Double], durations: [Double], waveType: WaveType, volume: Double) -> Data? {
        let sampleRate: Double = 44100.0
        var samples: [Int16] = []
        
        for (index, freq) in frequencies.enumerated() {
            let duration = index < durations.count ? durations[index] : (durations.last ?? 0.1)
            let totalSamples = Int(sampleRate * duration)
            
            for i in 0..<totalSamples {
                let t = Double(i) / sampleRate
                var val: Double = 0.0
                
                if freq > 0 {
                    let angle = 2.0 * Double.pi * freq * t
                    switch waveType {
                    case .sine:
                        val = sin(angle)
                    case .square:
                        val = sin(angle) >= 0 ? 1.0 : -1.0
                    case .triangle:
                        val = 2.0 * abs(2.0 * (t * freq - floor(t * freq + 0.5))) - 1.0
                    case .sawtooth:
                        val = 2.0 * (t * freq - floor(t * freq + 0.5))
                    }
                } else {
                    val = 0.0
                }
                
                var envelope = 1.0
                let attackSamples = min(Int(0.008 * sampleRate), max(1, totalSamples / 4))
                let decaySamples = min(Int(0.015 * sampleRate), max(1, totalSamples / 4))
                
                if i < attackSamples {
                    envelope = Double(i) / Double(attackSamples)
                } else if i > totalSamples - decaySamples {
                    envelope = Double(totalSamples - i) / Double(decaySamples)
                }
                
                let sampleVal = Int16(max(-32767.0, min(32767.0, val * volume * envelope * 32767.0)))
                samples.append(sampleVal)
            }
        }
        
        return buildWavHeaderAndAppend(samples: samples, sampleRate: Int32(sampleRate))
    }
    
    private func buildWavHeaderAndAppend(samples: [Int16], sampleRate: Int32) -> Data {
        let numChannels: Int16 = 1
        let bitsPerSample: Int16 = 16
        let byteRate = sampleRate * Int32(numChannels) * Int32(bitsPerSample / 8)
        let blockAlign = numChannels * (bitsPerSample / 8)
        let dataSize = Int32(samples.count * 2)
        let chunkSize = 36 + dataSize
        
        var data = Data()
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46])
        var chunkLE = chunkSize.littleEndian
        data.append(Data(bytes: &chunkLE, count: 4))
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45])
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20])
        var subchunk1SizeLE = Int32(16).littleEndian
        data.append(Data(bytes: &subchunk1SizeLE, count: 4))
        var audioFormatLE = Int16(1).littleEndian
        data.append(Data(bytes: &audioFormatLE, count: 2))
        var numChannelsLE = numChannels.littleEndian
        data.append(Data(bytes: &numChannelsLE, count: 2))
        var sampleRateLE = sampleRate.littleEndian
        data.append(Data(bytes: &sampleRateLE, count: 4))
        var byteRateLE = byteRate.littleEndian
        data.append(Data(bytes: &byteRateLE, count: 4))
        var blockAlignLE = blockAlign.littleEndian
        data.append(Data(bytes: &blockAlignLE, count: 2))
        var bitsPerSampleLE = bitsPerSample.littleEndian
        data.append(Data(bytes: &bitsPerSampleLE, count: 2))
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61])
        var dataSizeLE = dataSize.littleEndian
        data.append(Data(bytes: &dataSizeLE, count: 4))
        
        var sampleBytes = [UInt8](repeating: 0, count: samples.count * 2)
        sampleBytes.withUnsafeMutableBufferPointer { ptr in
            for (i, sample) in samples.enumerated() {
                let ule = UInt16(bitPattern: sample.littleEndian)
                ptr[i * 2] = UInt8(truncatingIfNeeded: ule)
                ptr[i * 2 + 1] = UInt8(truncatingIfNeeded: ule >> 8)
            }
        }
        data.append(contentsOf: sampleBytes)
        return data
    }
}
