# Keep the desktop responsive (esp. Chrome video calls) when memory runs short.
{...}: {
  flake.modules.systemManager.memory-pressure = {...}: {
    environment.etc = {
      # Global oomd tuning. Default duration on Ubuntu is 20s.
      "systemd/oomd.conf.d/50-memory-pressure.conf".text = ''
        [OOM]
        DefaultMemoryPressureDurationSec=8s
      '';

      # Ubuntu ships ManagedOOMMemoryPressureLimit=50% here
      "systemd/system/user@.service.d/50-oomd-pressure.conf".text = ''
        [Service]
        ManagedOOMMemoryPressure=kill
        ManagedOOMMemoryPressureLimit=40%
      '';

      # Chrome managed policy (Linux path). Memory Saver discards inactive tabs.
      # MemorySaverModeSavings: 0 = moderate, 1 = balanced, 2 = maximum.
      "opt/chrome/policies/managed/memory-saver.json".text = builtins.toJSON {
        HighEfficiencyModeEnabled = true;
        MemorySaverModeSavings = 2;
      };
    };
  };

  flake.modules.homeManager.memory-pressure = {...}: let
    chromeDropIn = ''
      [Scope]
      # oomd picks other cgroups first; Chrome is only killed as a last resort.
      ManagedOOMPreference=avoid
      # Reclaim prefers other cgroups while Chrome is below this.
      MemoryLow=6G
    '';
    sessionDropIn = ''
      [Service]
      ManagedOOMPreference=omit
      MemoryLow=256M
    '';
  in {
    xdg.configFile = {
      "systemd/user/app-google\\x2dchrome-.scope.d/50-memory.conf".text = chromeDropIn;
      "systemd/user/app-com.google.Chrome-.scope.d/50-memory.conf".text = chromeDropIn;

      "systemd/user/app-code-.scope.d/50-memory.conf".text = ''
        [Scope]
        # Throttle & push to swap beyond this
        MemoryHigh=6G
        # Backstop: kernel kills the biggest process inside the scope (a runaway
        # extension host / language server), not the whole machine.
        MemoryMax=10G
      '';

      "systemd/user/plasma-kwin_wayland.service.d/50-memory.conf".text = sessionDropIn;
      "systemd/user/pipewire.service.d/50-memory.conf".text = sessionDropIn;
      "systemd/user/wireplumber.service.d/50-memory.conf".text = sessionDropIn;
    };
  };
}
