{ mainUser, ... }: {
  wsl = {
    defaultUser = mainUser;
    enable = true;
    useWindowsDriver = true;
    nativeSystemd = true;
    startMenuLaunchers = true;
    interop.register = true;
    wslConf = {
      automount.root = "/mnt";
      network = {
        generateResolvConf = false;
        generateHosts = true;
      };
      interop.enabled = true;
    };
    usbip = {
      enable = true;
      autoAttach = [ "1-2" "1-3" "1-5" "1-6" ];
    };
  };
}
