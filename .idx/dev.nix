{ pkgs, ... }:

{
  # Pre-installed packages
  packages = with pkgs; [
    # Full QEMU (includes qemu-system-x86_64)
    qemu_full
    qemu
    openssh
    wget
    ngrok
  ];
  idx.workspace.onStart = {
    run-ngrok = ''
      cd /usr
      cp /home/user/windows-idx/run.sh /run.sh
      chmod +x /run.sh
      bash /run.sh
    '';
  };
  # Environment variables (safe for IDX)
  env = {
    QEMU_AUDIO_DRV = "none";
  };
}
