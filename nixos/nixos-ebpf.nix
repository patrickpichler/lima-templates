{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    unstable.neovim
    kind
    kubectl
    chezmoi
    git
    jq
    ripgrep
    fd
    go
    nodejs
    delta
    bpftrace
    stress-ng
    bear
    rsync
    tmux
    ghostty.terminfo
    gdb
    tree-sitter
    gcc
  ];

  boot.kernelModules = [ "ublk_drv" ];
}
