{
  wsl = {
    enable = true;
    nativeSystemd = true;
    defaultUser = "luigi";
    startMenuLaunchers = true;
    wslConf.automount.root = "/mnt";
  };

  services.dbus.apparmor = "enabled";
  security.apparmor.enable = true;
}
