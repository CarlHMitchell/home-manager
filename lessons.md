# Lessons & Things I've Learned

Each flake-parts module can create an input in the main flake.nix. E.g. the IosevkaCarl one. Update the main flake.nix contents with `nix run .#write-flake`. Update the flake.lock with `nix flake update .`. Update the system with `sudo nixos-rebuild switch --flake .#carl-nixos`

Each flake-parts module creates an output. 

Vibe-coded this. It sort of works, but I don't feel I have a good understanding of how it all actually fits together & how to properly extend it. Fine as a starting point, but learning Nix more deeply is also a goal. Treating this repo as a living example to compare to other examples, to see where my config might be improved.
