# nixos-declarative-fish-plugin-mgr
NixOS module to manage fish plugins declaratively

## Usage and Examples

In your `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, ... }:
 
{
  imports =
    [
      # 1. Add archive of this repository to your imports.
      (fetchTarball
        "https://github.com/takagiy/nixos-declarative-fish-plugin-mgr/archive/0.0.1.tar.gz")
      
      #...  
    ];

  
  programs.fish = {
    # 2. Enable fish-shell.
    enable = true;
    
    # 3. Declare fish plugins to be installed.
    plugins = [
      "jethrokuan/fzf"
      "b4b4r07/enhancd"
    ];
  };

  #...    
}
```
