import SwiftUI
import Speech
import AVFoundation

@MainActor
class VoiceInputManager: ObservableObject {
    @Published var isRecording = false
    @Published var transcribedText = ""
    @Published var errorMessage: String?

    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer()

    func requestPermission() async -> Bool {
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }

        guard speechStatus == .authorized else {
            errorMessage = "Speech recognition not authorized"
            return false
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            return true
        } catch {
            errorMessage = "Audio session setup failed"
            return false
        }
    }

    func startRecording() {
        guard let recognizer = speechRecognizer, recognizer.isAvailable else {
            errorMessage = "Speech recognizer not available"
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()
        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            errorMessage = "Audio engine failed to start"
            return
        }

        recognitionTask = recognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                if let result {
                    self?.transcribedText = result.bestTranscription.formattedString
                }
                if error != nil || (result?.isFinal == true) {
                    self?.stopRecording()
                }
            }
        }
    }

    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionRequest = nil
        recognitionTask = nil
        isRecording = false
    }
}

struct VoiceInputView: View {
    @StateObject private var voiceManager = VoiceInputManager()
    @Environment(\.dismiss) private var dismiss
    let onComplete: (String) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.xl) {
                Spacer()

                // Mic Animation
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(voiceManager.isRecording ? 0.2 : 0.1))
                        .frame(width: 160, height: 160)
                        .scaleEffect(voiceManager.isRecording ? 1.2 : 1.0)
                        .animation(
                            voiceManager.isRecording
                                ? .easeInOut(duration: 0.8).repeatForever()
                                : .default,
                            value: voiceManager.isRecording
                        )
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.3))
                        .frame(width: 100, height: 100)
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }

                // Transcribed text
                if !voiceManager.transcribedText.isEmpty {
                    Text(voiceManager.transcribedText)
                        .font(.appBody)
                        .multilineTextAlignment(.center)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.backgroundGray)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
                }

                Spacer()

                // Controls
                HStack(spacing: AppSpacing.xl) {
                    Button {
                        if voiceManager.isRecording {
                            voiceManager.stopRecording()
                        } else {
                            Task {
                                let granted = await voiceManager.requestPermission()
                                if granted {
                                    voiceManager.startRecording()
                                }
                            }
                        }
                    } label: {
                        Text(voiceManager.isRecording ? "Stop" : "Start")
                            .font(.appButtonLabel)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 12)
                            .background(
                                voiceManager.isRecording
                                    ? Color.accentRed
                                    : Color.primaryPurple
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }

                    if !voiceManager.transcribedText.isEmpty {
                        Button {
                            onComplete(voiceManager.transcribedText)
                            dismiss()
                        } label: {
                            Text("Use Text")
                                .font(.appButtonLabel)
                                .padding(.horizontal, 32)
                                .padding(.vertical, 12)
                                .background(Color.accentGreen)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(AppSpacing.lg)
            .navigationTitle("Voice Input")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
