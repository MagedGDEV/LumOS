import os
import sys
import json
import platform
import pyaudio
import json
from vosk import Model, KaldiRecognizer, SetLogLevel

# ─────────────────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────────────────

SAMPLE_RATE = 16000
CHUNK       = 4000
IS_MAC      = platform.system() == "Darwin"

if IS_MAC:
    MODEL_PATH = os.path.dirname(__file__) + "/model"
else:
    MODEL_PATH = "/usr/share/vosk/model"

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

    GRAMMAR = json.dumps([
        "turn on", "turn off",
        "living room", "kitchen", "bedroom", "bathroom", "all",
        "[unk]"
    ])

    model = Model(MODEL_PATH)
    rec   = KaldiRecognizer(model, SAMPLE_RATE, GRAMMAR)
    print("[Voice] Model loaded successfully")

    p         = pyaudio.PyAudio()
    stream    = p.open(
        format             = pyaudio.paInt16,
        channels           = 1,
        rate               = SAMPLE_RATE,
        input              = True,
        frames_per_buffer  = CHUNK
    )

    print("[Voice] Listening... Press Ctrl+C to stop\n")

    try:
        while True:
            data = stream.read(CHUNK, exception_on_overflow=False)
            if rec.AcceptWaveform(data):
                result = json.loads(rec.Result())
                text   = result.get("text", "").strip()
                if text:
                    print(f"[Voice] {text}")

    except KeyboardInterrupt:
        print("\n[Voice] Stopped")
    finally:
        stream.stop_stream()
        stream.close()
        p.terminate()

if __name__ == "__main__":
    main()