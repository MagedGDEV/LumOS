import os
import sys
import json
import platform
import pyaudio
from vosk import Model, KaldiRecognizer, SetLogLevel

# ─────────────────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────────────────

SAMPLE_RATE  = 16000
CHUNK        = 2000
WAKE_WORD    = "lumina"
COMMAND_TIMEOUT = 10  # seconds to wait for command after wake word
IS_MAC       = platform.system() == "Darwin"

if IS_MAC:
    MODEL_PATH = os.path.dirname(__file__) + "/model"
else:
    MODEL_PATH = "/usr/share/vosk/model"

# ─────────────────────────────────────────────────────────
# Grammar
# ─────────────────────────────────────────────────────────

WAKE_GRAMMAR = json.dumps([WAKE_WORD, "[unk]"])

COMMAND_GRAMMAR = json.dumps([
    "turn on", "turn off",
    "living room", "kitchen", "bedroom", "bathroom", "all",
    "[unk]"
])

# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

def main():

    SetLogLevel(-1)

    print(f"[Voice] Platform : {platform.system()}")
    print(f"[Voice] Model    : {MODEL_PATH}")

    if not os.path.exists(MODEL_PATH):
        print(f"\n[Voice] ERROR: Model not found at '{MODEL_PATH}'")
        print("[Voice] Download from https://alphacephei.com/vosk/models")
        print(f"[Voice] Extract and place at: {MODEL_PATH}\n")
        sys.exit(1)

    model = Model(MODEL_PATH)

    wake_rec    = KaldiRecognizer(model, SAMPLE_RATE, WAKE_GRAMMAR)
    command_rec = KaldiRecognizer(model, SAMPLE_RATE, COMMAND_GRAMMAR)

    print("[Voice] Model loaded successfully")

    p      = pyaudio.PyAudio()
    stream = p.open(
        format            = pyaudio.paInt16,
        channels          = 1,
        rate              = SAMPLE_RATE,
        input             = True,
        frames_per_buffer = CHUNK
    )

    print(f"[Voice] Say '{WAKE_WORD}' to activate\n")

    listening_for_command = False
    chunks_since_wake     = 0
    # Timeout in chunks = COMMAND_TIMEOUT / (CHUNK/SAMPLE_RATE)
    timeout_chunks        = int(COMMAND_TIMEOUT / (CHUNK / SAMPLE_RATE))

    try:
        while True:
            data = stream.read(CHUNK, exception_on_overflow=False)

            if not listening_for_command:
                if wake_rec.AcceptWaveform(data):
                    result = json.loads(wake_rec.Result())
                    text   = result.get("text", "").strip()
                    if WAKE_WORD in text:
                        print(f"[Voice] Wake word detected — listening for command...")
                        listening_for_command = True
                        chunks_since_wake     = 0
                        command_rec.Reset()

            else:
                chunks_since_wake += 1

                if chunks_since_wake >= timeout_chunks:
                    print(f"[Voice] Timeout — no command heard, going back to sleep\n")
                    listening_for_command = False
                    wake_rec.Reset()
                    continue

                if command_rec.AcceptWaveform(data):
                    result = json.loads(command_rec.Result())
                    text   = result.get("text", "").strip()
                    if text and not ("[unk]" in text):
                        print(f"[Voice] Command  : '{text}'\n")
                        chunks_since_wake = 0 
                        command_rec.Reset()
                    else:
                        print(f"[Voice] Not recognized, try again...\n")

    except KeyboardInterrupt:
        print("\n[Voice] Stopped")
    finally:
        stream.stop_stream()
        stream.close()
        p.terminate()

if __name__ == "__main__":
    main()
