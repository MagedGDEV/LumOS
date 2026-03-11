
https://github.com/user-attachments/assets/048bbdc5-5953-4e5d-bf76-419a99aca4c9
# LumOS 💡

> Qt6 Smart Home Light Controller · Yocto Kirkstone · Raspberry Pi · GPIO

A fullscreen Qt6 QML application cross-compiled with Yocto for Raspberry Pi 2, running on a Wayland/Weston compositor. Built and deployed inside a Docker container using `kas` for reproducible layer management.

## Current Progress

https://github.com/user-attachments/assets/0b45c789-ff18-4017-b90f-ce7cb2a55165

| Milestone | Status |
| --- | --- |
| Hello World Application | ✅ Done |
| GPIO LED control button | ✅ Done |
| App boots on Pi directly | 🔜 Coming |
<!-- | Next | 🔄 In Progress | -->

## Stack

| Layer | Technology |
| --- | --- |
| UI Framework | Qt6 QML |
| Display Server | Wayland / Weston |
| Build System | Yocto Project (Kirkstone) |
| Layer Management | kas |
| Build Environment | Docker (Ubuntu 22.04) |
| Target Hardware | Raspberry Pi 2 |

## Build Instructions

### Prerequisites

- Docker Desktop installed
- At least 8GB RAM allocated to Docker
- At least 300GB disk space

---

### Step 1 — Build the Docker image

```bash
docker build -t yocto-builder ./docker
```

### Step 2 — Create a persistent Linux volume (Optional)

```bash
docker volume create yocto-build
```

### Step 3 — Start the container

**On macOS:**

```bash
docker run -it \
  -v yocto-build:/yocto \
  -v $(pwd):/source \
  yocto-builder
```

### Step 4 — Copy project into the volume

```bash
cp -r /source/app /yocto/
cp -r /source/meta-app /yocto/
cp -r /source/kas.yml /yocto/
```

### Step 5 — Build with kas

```bash
cd /yocto
kas build kas.yml
```

> First build takes **2-4 hours**. Subsequent builds use sstate cache and are much faster.

### Step 6 — Copy the image to your machine

Open a new terminal on your host machine and run:

```bash
docker cp <container_id>:/yocto/build/tmp/deploy/images/raspberrypi2/core-image-weston-raspberrypi2-XXXXXX.rootfs.wic.bz2 ./
```

Find your container ID with:

```bash
docker ps
```

Replace `XXXXXX` with your timestamp generated

### Step 7 — Flash to SD card

**Decompress the image:**

```bash
bzip2 -d core-image-weston-raspberrypi2.rootfs.wic.bz2
```

**Find your SD card device:**

```bash
# On macOS
diskutil list
```

**Flash the image:**

```bash
# On macOS (replace /dev/diskN with your SD card)
sudo dd if=core-image-weston-raspberrypi2-XXXXXX.rootfs.wic of=/dev/rdiskN bs=4m status=progress
```

### Step 8 — Boot the Raspberry Pi

Insert the SD card into your Raspberry Pi 2, connect a display, and power on. The application launches automatically on boot via systemd.

## Attach a Second Terminal to the Running Container

```bash
docker ps  # get container ID
docker exec -it <container_id> bash
```
