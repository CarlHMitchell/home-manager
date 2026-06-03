# Carl's Nix Configuration

Following the Dendritic pattern, WIP.

[Structured a bit like Doc-Steve's comprehensive example](https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Comprehensive_Example#comprehensive-example).

The File Naming Conventions - Some directories have brackets. These brackets serve two purposes:

They indicate that a directory is the name of a feature, not just for organizational purposes. All feature .nix files are always located in a directory named after the feature.
In the brackets, the usage contexts of the feature are listed, categorized by letter: (N)ixOS and/or (S)ystem-manager. Small caps indicate usage in the Home-Manager context. Since not every Home-Manager Configuration works on both systems, "n" and "s" refer to usage for Home-Manager on the specific system. "D" and "d" could be used for systems with nix-darwin.

Currently two hosts: a personal NixOS desktop with home-manager as a module, and a company-owned Ubuntu laptop with system-manager & home-manager standalone.
