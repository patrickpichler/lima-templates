# lima-templates

This repo contains a collection of various lima related templates I find useful.

## Usage

Run `limactl start --name=whatever ./template.yaml` with the wanted template to start a VM from it. It is
also possible to directly use them from URLs.

## NixOS usage

Create the VM with `limactl start --name=whatever ./nixos-ebpf.yaml`.

Copy the NixOS config under the `nixos` folder to the VM either with `limactl copy` or `git clone`.
Be sure to put it under `/etc/nixos` (technically not a hard requirement, but standard in NixOS).

Install whatever variant of the nixos system you want with the following command:

```sh
sudo nixos-rebuild boot --flake /etc/nixos#nixos-ebpf-aarch64 --impure
```

To work around GitHub API limits, create a fine-grained PAT (without access to anythingn!) and
set it with
```sh
 NIX_CONFIG="access-tokens = github.com=github_pat_xxx"
```

Here the `nixos-ebpf-aarch64` configuration from the `nixos/flake.nix` configurations is installed.

Reboot the VM with `limactl reboot whatever`. It should no longer being stuck on boot-up and you
should be greeted by a message explaining how to setup the docker daemon.

## K3s server

There also exists a configuration that spawns a local k3s serverr. To configure it, copy the config
over to the lima vm and run the followin command:

```sh
sudo nixos-rebuild boot --flake /etc/nixos#nixos-ebpf-k3s-aarch64 --impure
```
