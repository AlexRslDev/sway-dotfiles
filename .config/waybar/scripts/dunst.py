import subprocess
import json

def main():
    paused = subprocess.run(['dunstctl', 'is-paused'], capture_output=True, text=True).stdout.strip() == 'true'
    waiting = int(subprocess.run(['dunstctl', 'count', 'waiting'], capture_output=True, text=True).stdout.strip())
    
    icon_type = "dnd" if paused else "none"
    if waiting > 0:
        icon_type = f"{icon_type}-notification"
    else:
        icon_type = f"{icon_type}-none"
        
    print(json.dumps({"alt": icon_type}))

if __name__ == "__main__":
    main()
