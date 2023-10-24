{ config, pkgs, ... }:

{
  # Power management
  powerManagement.enable = true;

  # tlp conflicts with auto-cpufreq ensure they are not enabled together
  services = {
    # Thermal control
    thermald.enable = true;
    tlp = {
      enable = true;
      settings = {
        # Operation mode when no power supply can be detected: AC, BAT.
        TLP_DEFAULT_MODE = "BAT";

        # Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
        TLP_PERSISTENT_DEFAULT = 1;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 20;
      };
    };

    upower.enable = true;

    # Conflicts with tlp
    power-profiles-daemon.enable = false;
  };
  boot.blacklistedKernelModules = [ "nouveau" ];
}
