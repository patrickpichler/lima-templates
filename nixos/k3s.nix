{
  pkgs,
  config,
  lib,
  ...
}:
let
  helpers = import ./helpers.nix { };
  user = helpers.env.LIMA_CIDATA_USER;
  cfg = config.custom.k3s;
in
{
  options = {
    custom.k3s = {
      kata-containers = {
        enable = lib.mkEnableOption (lib.mdDoc "(currently not working)");
      };
    };
  };

  config = lib.mkMerge [
    {
      networking.firewall.allowedTCPPorts = [
        6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
        # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
        # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
      ];
      networking.firewall.allowedUDPPorts = [
        # 8472 # k3s, flannel: required if using multi-node for inter-node networking
      ];
      services.k3s = {
        enable = true;

        role = "server";

        extraFlags = toString [
          # "--debug" # Optionally add additional args to k3s
          "--write-kubeconfig-mode=640"
          "--write-kubeconfig-group=kubernetes"
        ];
      };

      users.extraGroups.kubernetes.members = [ user ];

    }

    # TODO(patrick.pichler): none of this is working on an M2 MacBook, as nested virtualization appears to
    # be required. Maybe there is a way around this, but for now it will stay broken.
    (lib.mkIf cfg.kata-containers.enable {
      services.k3s = {
        manifests = {
          kata-runtime-class = {
            target = "kata-runtime-class.yaml";

            content = {
              apiVersion = "node.k8s.io/v1";
              kind = "RuntimeClass";
              handler = "kata";
              metadata = {
                name = "kata";
              };
            };
          };
        };
      };

      # sservices.k3s.containerdConfigTemplates writes v2 only
      systemd.tmpfiles.settings."09-k3s"."/var/lib/rancher/k3s/agent/etc/containerd/config-v3.toml.tmpl"."L+".argument =
        let
          template = ''
            {{ template "base" . }}

            [plugins.'io.containerd.cri.v1.runtime'.containerd.runtimes.'kata']
                runtime_type = "io.containerd.kata.v2"
                privileged_without_host_devices = true
                pod_annotations = ["io.katacontainers.*"]
                container_annotations = ["io.katacontainers.*"]
          '';
        in
        "${pkgs.writeText "config-v3.toml.tmpl" template}";

      systemd.services.k3s.serviceConfig.DeviceAllow = [
        "/dev/kvm rwm"
        "/dev/mshv rwm"
        "/dev/kmsg rwm"
        "/dev/vhost-vsock rwm"
        "/dev/vhost-net rwm"
        "/dev/net/tun rwm"
      ];
      systemd.services.k3s.serviceConfig.Delegate = "yes";
      systemd.services.k3s.path = [ pkgs.kata-runtime ];
    })
  ];
}
