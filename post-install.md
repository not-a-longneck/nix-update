# 🖥️ NixOS Post-Install Setup Guide

A reference sheet for manual setup steps that fall outside the declarative NixOS configuration — including Flatpak apps, virtualization, and peripheral tooling.

---

## 📦 Flatpak & Applications

### 1. Initialize Flathub and Install All Apps

Run this single command to add the Flathub remote repository and automatically batch-install your required desktop applications:

```bash
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install flathub -y \
  com.bambulab.BambuStudio \
  com.brave.Browser \
  com.rustdesk.RustDesk \
  io.ente.auth \
  md.obsidian.Obsidian \
  org.kde.kate \
  org.kde.kcolorchooser \
  org.signal.Signal \
  com.valvesoftware.Steam \
  com.obsproject.Studio \
  com.github.tchx84.Flatseal
```

---

## 🖧 Virtual Machine Manager (VMM)

Follow these quick manual steps inside the `virt-manager` GUI to provision your images:

1. Navigate to **Edit > Connection Details > Storage** and add a storage pool pointing to your `qcow2` image directory.
2. Create a new virtual machine instance and opt for selecting an existing disk image.
3. Attach required hardware components (USB targets, PCI passthrough devices) inside the details window before triggering the initial boot.

---

## ✏️ Espanso

Espanso is installed via config file. Run:

```
espanso service register
espanso start
```

👉 https://espanso.org/docs/install/linux

---

## 🌡️ CoolerControl

Initialize or configure hardware controller monitoring properties:

👉 https://docs.coolercontrol.org/getting-started.html

### Direct Snapshot Backup

```bash
sudo tar -czvf /home/backups/coolercontrol/coolercontrol-backup.tgz /etc/coolercontrol /var/lib/coolercontrol
```

### Direct Snapshot Restore

```bash
sudo systemctl stop coolercontrold && sudo tar -xzvf /home/backups/coolercontrol/coolercontrol-backup.tgz -C / && sudo systemctl start coolercontrold
```

---

## 🛜 Bluetooth

Backup bluetooth settings:
```
sudo tar -czvf /home/backups/bluetooth_backup.tar.gz -C / var/lib/bluetooth/
```

Restore bluetooth:
```
sudo systemctl stop bluetooth && sudo tar -xzvf /home/backups/bluetooth_backup.tar.gz -C / && sudo systemctl start bluetooth
```
