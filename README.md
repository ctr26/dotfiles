# 🏠 ctr26's Dotfiles

A modern dotfiles repository with dual management systems for maximum flexibility and reproducibility.

## 🚀 Quick Install

### NixOS Users
If you don't have git installed yet:
```bash
# Install git, chezmoi, and python3 temporarily
nix-shell -p git chezmoi python3
```

Then proceed with installation:
```bash
chezmoi init --apply ctr26/dotfiles
```

**Or use Home Manager directly (requires flakes):**
```bash
# Temporary flakes (no config files written)
NIX_CONFIG="experimental-features = nix-command flakes" nix run github:ctr26/dotfiles#deploy-home

# Or permanently enable flakes, then deploy
mkdir -p ~/.config/nix && echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf && nix run github:ctr26/dotfiles#deploy-home
```

### All Other Systems
**One command to rule them all:**
```bash
curl -sSL https://raw.githubusercontent.com/ctr26/dotfiles/main/install.sh | bash
```

This script automatically detects your system and chooses the best installation method.

## 📋 What You Get

- **Shell**: ZSH with oh-my-zsh, pure prompt, and intelligent completions
- **Terminal**: Kitty with catppuccin theme and transparency
- **Multiplexer**: tmux with sensible defaults and theme integration
- **Editor**: Vim/Neovim with carefully selected plugins
- **Window Manager**: i3 with polybar status bar (NixOS)
- **Development**: Git, Docker, and essential dev tools
- **Themes**: Consistent catppuccin theming across all applications

## 🎯 Deployment Options

### 🐧 NixOS (Recommended)
Full system configuration with declarative package management:
```bash
git clone https://github.com/ctr26/dotfiles.git ~/dotfiles
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos
```

### 🏠 Home Manager (Any Linux)
User environment only with Nix package manager:
```bash
# Install Nix if not present
sh <(curl -L https://nixos.org/nix/install) --daemon

# Deploy configuration
nix run github:ctr26/dotfiles#deploy-home
```

### 🔧 Traditional (Cross-platform)
Using chezmoi for maximum compatibility:
```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Deploy dotfiles
chezmoi init --apply ctr26/dotfiles
```

## 🛠️ Management Commands

### NixOS/Home Manager
```bash
cd ~/dotfiles

# Interactive deployment menu
nix run .

# Deploy specific configurations
nix run .#deploy-home     # Home Manager only
nix run .#deploy-system   # Full NixOS system

# Update dependencies
nix run .#update

# Development shell
nix develop
```

### Chezmoi
```bash
# Apply changes
chezmoi apply

# Preview changes
chezmoi diff

# Edit configuration
chezmoi edit ~/.zshrc

# Update from repository
chezmoi update
```

## 📁 Repository Structure

```
dotfiles/
├── 📁 nix/                    # NixOS configurations
│   ├── home.nix              # Home Manager config
│   └── configuration.nix     # NixOS system config
├── 📁 dot_config/            # XDG config files
│   ├── i3/                   # Window manager
│   ├── kitty/                # Terminal emulator
│   ├── polybar/              # Status bar
│   └── ranger/               # File manager
├── 🎯 flake.nix              # Nix flake definition
├── 🚀 install.sh             # One-command installer
├── 📋 CLAUDE.md              # Development guide
├── ⚙️ dot_zshrc.tmpl         # ZSH configuration
├── ⚙️ dot_vimrc              # Vim configuration
├── ⚙️ dot_tmux.conf          # tmux configuration
└── 📦 .chezmoiexternal.toml  # External dependencies
```

## 🎨 Customization

### Changing Themes
The dotfiles use consistent catppuccin theming. To switch variants:

**NixOS/Home Manager**: Edit `nix/home.nix`
```nix
programs.kitty.theme = "Catppuccin-Frappe";  # or Latte, Macchiato, Mocha
```

**Chezmoi**: Update theme files in `dot_config/kitty/`

### Adding Packages

**NixOS**: Edit `nix/configuration.nix` or `nix/home.nix`
```nix
home.packages = with pkgs; [
  your-package-here
];
```

**Chezmoi**: Install manually or add to installation scripts

## 🔧 Development

For detailed development information, see [CLAUDE.md](CLAUDE.md).

### Testing Changes

**NixOS**:
```bash
# Test without switching
sudo nixos-rebuild test --flake .#nixos

# Apply permanently
sudo nixos-rebuild switch --flake .#nixos
```

**Home Manager**:
```bash
home-manager switch --flake .#ctr26
```

### Adding New Configurations

1. Add files using chezmoi naming convention (`dot_filename`)
2. Update NixOS configurations in `~/.config/nix/` directory  
3. Test both deployment methods
4. Update documentation

## ⚙️ Initial Configuration

After installation, configure git with your details:

```bash
# Set your name and email (replace with your actual info)
git config --global user.name "John Doe"
git config --global user.email "john.doe@example.com"

# Optional: Set your preferred editor
git config --global core.editor "nvim"
```

For chezmoi template variables, edit the chezmoi config:
```bash
chezmoi edit-config
```

Then add your personal information:
```toml
[data]
    name = "John Doe"
    email = "john.doe@example.com"

# Optional: Add git configuration
[git]
    autoCommit = true
    autoPush = true

# Optional: Add your system preferences  
[data.system]
    hostname = "my-laptop"
    timezone = "America/New_York"
```

The name and email will be used in template files like `dot_gitconfig.tmpl` and `dot_zshrc.tmpl`.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test changes with both deployment methods
4. Submit a pull request

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/ctr26/dotfiles/issues)
- **Documentation**: Check `CLAUDE.md` for detailed information
- **NixOS Help**: [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- **Chezmoi Help**: [Chezmoi Documentation](https://www.chezmoi.io/)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

**Happy dotfiles! 🎉**