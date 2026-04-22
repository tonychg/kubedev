{
  inputs = {
    utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    utils,
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [
          kind
          kustomize
          kustomize-sops
          kubernetes-helm
          kubectl
          kube-capacity
          argocd
          k9s
          gnumake
          cilium-cli
          traceroute
          go-task
          argocd
        ];
      };
    });
}
