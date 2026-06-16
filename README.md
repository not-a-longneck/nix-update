# ❄️ NixOS GitHub-Driven Sync Layout

A simplified pipeline to run a declarative NixOS node directly from GitHub updates, omitting localized git management overhead or local editing friction. Changes are made on GitHub and pulled down onto the local machine via a single executable command.

## 🏗️ Repository Hierarchy

Your GitHub repository (`NixOS-VCVM`) must structure files relative to the target root mapping:

```text
.
├── configuration.nix
├── hardware-configuration.nix
└── scripts
    └── nix-update.nix
```

## 🚀 First-Time Bootstrap Setup

Because the automated `nix-update` command is built directly into your NixOS configuration, you must manually place the files onto your system the very first time to generate the command environment.

### 1. Create Necessary Structural Trees

Open a terminal on your target NixOS machine and establish the script runtime subdirectory:

```bash
sudo mkdir -p /etc/nixos/scripts
```

### 2. Populate Configuration Engine Files

Copy-paste your configurations from your repository directly into the matching target locations:

```bash
# Paste your updated configuration.nix content here
sudo nano /etc/nixos/configuration.nix
```

```bash
# Paste your scripts/nix-update.nix file content here
sudo mkdir /etc/nixos/scripts/
sudo nano /etc/nixos/scripts/nix-update.nix
```

### 3. Compile and Switch Generations

Run your initial system build. This registers the new shell aliases into your user environment profile:

```bash
sudo nixos-rebuild switch
```

### 4. Initialize the Environment

Reload your current shell session to mount and activate the `nix-update` terminal tool:

```bash
exec zsh
```

## 🔄 Daily Workflow

Once the bootstrap initialization is successful, do not edit your configuration files locally within `/etc/nixos`.

1. Edit your configurations exclusively on GitHub via the web interface, an IDE, or an external workstation.
2. Commit and push the updates directly to your `main` branch.
3. On the local NixOS system, run your specialized execution command:

```bash
nix-update
```

## 🛠️ Automation Failure Recovery

If an update fails—either due to network issues while executing curls or because of syntax errors during compilation—the sync utility rolls back configuration file trees immediately to their previous working states.

To manually evaluate local system baseline adjustments or check operational file structures, use standard system diff blocks:

```bash
sudo diff /etc/nixos/configuration.nix /etc/nixos/configuration.nix.bak
```
