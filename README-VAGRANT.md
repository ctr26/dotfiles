# 🧪 Testing Dotfiles with Vagrant

This guide explains how to test the dotfiles deployment using Vagrant virtual machines.

## 🚀 Quick Start

### Prerequisites
- [Vagrant](https://www.vagrantup.com/) installed
- [VirtualBox](https://www.virtualbox.org/) installed
- At least 4GB RAM available for VMs

### Start Testing Environment

```bash
# Start NixOS testing VM
vagrant up nixos

# Start Ubuntu testing VM  
vagrant up ubuntu

# Start both VMs
vagrant up nixos ubuntu
```

## 🖥️ Available Test Environments

### NixOS (Primary Target)
- **Box**: `nixos/nixos-23.11`
- **IP**: `192.168.56.10`
- **RAM**: 2GB
- **Purpose**: Test Nix/Home Manager deployment

```bash
vagrant ssh nixos
cd ~/dotfiles
./test-deploy.sh
```

### Ubuntu (Compatibility)
- **Box**: `ubuntu/jammy64`
- **IP**: `192.168.56.11`
- **RAM**: 1GB
- **Purpose**: Test traditional chezmoi deployment

```bash
vagrant ssh ubuntu
cd ~/dotfiles
./install.sh
```

### macOS (Optional)
- **Box**: `ramsey/macos-catalina`
- **IP**: `192.168.56.12`
- **RAM**: 4GB
- **Purpose**: Test macOS compatibility
- **Note**: Requires macOS host and proper licensing

```bash
# Only start if you have macOS licensing
vagrant up macos
```

## 🧪 Test Scenarios

### Scenario 1: Fresh NixOS Installation
```bash
vagrant up nixos
vagrant ssh nixos

# Test chezmoi deployment
cd ~/dotfiles
./test-deploy.sh
# Choose option 1: chezmoi installation
```

### Scenario 2: Nix Home Manager
```bash
vagrant ssh nixos

# Test Nix deployment
cd ~/dotfiles
./test-deploy.sh
# Choose option 2: Nix Home Manager deployment
```

### Scenario 3: Complete Testing Suite
```bash
vagrant ssh nixos

# Run all tests
cd ~/dotfiles
./test-deploy.sh
# Choose option 4: Test all methods
```

### Scenario 4: Cross-Platform Testing
```bash
# Test on Ubuntu
vagrant ssh ubuntu
cd ~/dotfiles && ./install.sh

# Test on NixOS
vagrant ssh nixos
cd ~/dotfiles && ./test-deploy.sh
```

## 🔍 What Gets Tested

### Chezmoi Deployment
- ✅ Chezmoi installation
- ✅ Dotfiles initialization
- ✅ Template processing
- ✅ External dependencies
- ✅ Cross-platform compatibility

### Nix Home Manager Deployment
- ✅ Flakes configuration
- ✅ Home Manager installation
- ✅ Package management
- ✅ Service configuration
- ✅ NixOS integration

### Installation Scripts
- ✅ System detection
- ✅ Dependency installation
- ✅ Error handling
- ✅ User prompts
- ✅ Post-install verification

## 🛠️ Development Workflow

### Making Changes
```bash
# Edit dotfiles locally
vim dot_bashrc

# Sync changes to VM
vagrant rsync nixos

# Test changes in VM
vagrant ssh nixos
cd ~/dotfiles && ./test-deploy.sh
```

### Reset Testing Environment
```bash
# Destroy and recreate VM
vagrant destroy nixos
vagrant up nixos

# Or just re-provision
vagrant provision nixos
```

### Debug Issues
```bash
# SSH with verbose output
vagrant ssh nixos -- -v

# Check VM status
vagrant status

# View VM logs
vagrant ssh nixos
journalctl -f
```

## 📝 Test Checklist

After running tests, verify:

### Shell Environment
- [ ] ZSH is default shell
- [ ] oh-my-zsh is installed
- [ ] Pure prompt is working
- [ ] Aliases are available

### Development Tools
- [ ] Git is configured with user info
- [ ] Vim/Neovim is working
- [ ] tmux is configured
- [ ] Required packages are installed

### System Integration
- [ ] dotfiles are properly linked
- [ ] Templates are processed correctly
- [ ] External dependencies are cloned
- [ ] Scripts executed successfully

### NixOS Specific
- [ ] Home Manager is working
- [ ] Nix packages are installed
- [ ] Services are running
- [ ] Configurations are applied

## 🚨 Troubleshooting

### Common Issues

**Vagrant Box Download Issues**
```bash
# Manually add box
vagrant box add nixos/nixos-23.11
```

**VirtualBox Issues**
```bash
# Check VirtualBox is running
VBoxManage --version

# Fix permission issues (Linux)
sudo usermod -a -G vboxusers $USER
```

**Network Issues**
```bash
# Check VM network
vagrant ssh nixos
ip addr show
```

**Sync Issues**
```bash
# Force rsync
vagrant rsync nixos

# Check synced folder
vagrant ssh nixos
ls -la /vagrant
```

### Getting Help

1. **Check Vagrant logs**:
   ```bash
   vagrant up nixos --debug
   ```

2. **Verify VM specs**:
   ```bash
   vagrant ssh nixos
   free -h && nproc
   ```

3. **Test dotfiles manually**:
   ```bash
   vagrant ssh nixos
   cd ~/dotfiles
   ls -la
   ./test-deploy.sh
   ```

## 📚 Resources

- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [NixOS Vagrant Boxes](https://app.vagrantup.com/nixos)
- [VirtualBox Documentation](https://www.virtualbox.org/manual/)

## 🎯 Pro Tips

1. **Snapshot VMs** after initial setup for quick resets
2. **Use rsync** for faster file synchronization
3. **Test incrementally** - don't change everything at once
4. **Keep VMs lightweight** - minimal GUI, essential packages only
5. **Document failures** - helps improve the dotfiles

Happy testing! 🚀