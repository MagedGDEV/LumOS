import os
import sys
import json
import platform
import pyaudio
import socket as sock_lib
import audioop
from vosk import Model, KaldiRecognizer, SetLogLevel

# ─────────────────────────────────────────────────────────
# Config
# ─────────────────────────────────────────────────────────

HW_RATE      = 48000
SAMPLE_RATE  = 16000
CHUNK        = 8000
HW_CHUNKS    = int(CHUNK * HW_RATE / SAMPLE_RATE)
WAKE_WORD    = "lumina"
COMMAND_TIMEOUT = 20
IS_MAC       = platform.system() == "Darwin"

if IS_MAC:
    MODEL_PATH = os.path.dirname(__file__) + "/model"
else:
    MODEL_PATH = "/usr/share/vosk/model"

SOCKET_PATH = "/tmp/lumos.sock"

# ─────────────────────────────────────────────────────────
# Grammar
# ─────────────────────────────────────────────────────────

WAKE_GRAMMAR = json.dumps([WAKE_WORD, "[unk]"])

COMMAND_GRAMMAR = json.dumps([
    "turn on", "turn off",
    "living room", "kitchen", "bedroom", "bathroom", "all",
    "[unk]"
])


def connect_socket():
    while True:
        try:
            s = sock_lib.socket(sock_lib.AF_UNIX, sock_lib.SOCK_STREAM)
            s.connect(SOCKET_PATH)
            print("[Socket] Connected to Qt app")
            return s
        except (FileNotFoundError, ConnectionRefusedError):
            print("[Socket] Waiting for Qt app...")
            import time
            time.sleep(1)

def send_command(s, action: str, room: str):
    msg = json.dumps({"action": action, "room": room})
    s.sendall(msg.encode())
def wake_sleep(s, state: bool):
    msg = json.dumps({"state": state})
    s.sendall(msg.encode())

def find_usb_mic(p: pyaudio.PyAudio):
    for i in range(p.get_device_count()):
        info = p.get_device_info_by_index(i)
        name = info.get("name", "").lower()
        if info.get("maxInputChannels", 0) > 0:
            if "usb" in name or "headset" in name or "microphone" in name:
                print(f"[Mic] Found USB mic: {info['name']} (index {i})")
                return i
    print("[Mic] No USB mic found, using default")
    return None


# ─────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────

def main():

    SetLogLevel(-1)
    socket = connect_socket()

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
    mic_index = find_usb_mic(p)
    stream = p.open(
        format             = pyaudio.paInt16,
        channels           = 1,
        rate               = HW_RATE,
        input              = True,
        input_device_index = mic_index,
        frames_per_buffer  = HW_CHUNKS
    )

    print(f"[Voice] Say '{WAKE_WORD}' to activate\n")

    listening_for_command = False
    chunks_since_wake     = 0
    # Timeout in chunks = COMMAND_TIMEOUT / (CHUNK/SAMPLE_RATE)
    timeout_chunks        = int(COMMAND_TIMEOUT / (CHUNK / SAMPLE_RATE))

    try:
        while True:
            data = stream.read(CHUNK, exception_on_overflow=False)
            data, _ = audioop.ratecv(data, 2, 1, HW_RATE, SAMPLE_RATE, None)

            if not listening_for_command:
                if wake_rec.AcceptWaveform(data):
                    result = json.loads(wake_rec.Result())
                    text   = result.get("text", "").strip()
                    if WAKE_WORD in text:
                        print(f"[Voice] Wake word detected — listening for command...")
                        wake_sleep(socket, True)
                        listening_for_command = True
                        chunks_since_wake     = 0
                        command_rec.Reset()

            else:
                chunks_since_wake += 1

                if chunks_since_wake >= timeout_chunks:
                    print(f"[Voice] Timeout — no command heard, going back to sleep\n")
                    wake_sleep(socket, False)
                    listening_for_command = False
                    wake_rec.Reset()
                    continue

                if command_rec.AcceptWaveform(data):
                    result = json.loads(command_rec.Result())
                    text   = result.get("text", "").strip()
                    if text and not ("[unk]" in text):
                        # parse and send
                        if "turn on" in text:
                            action = "turn_on"
                        elif "turn off" in text:
                            action = "turn_off"
                        else:
                            action = None

                        if action:
                            room = text.replace("turn on", "").replace("turn off", "").strip()
                            send_command(socket, action, room)
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
