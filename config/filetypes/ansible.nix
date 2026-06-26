{ pkgs, ... }:
{
  # Ansible support: filetype detection, language server, and linter.

  # Ansible has no unique extension, so detect it for any .yml/.yaml file that
  # either lives under an `ansible.cfg` project root or sits in the standard
  # role/playbook directory layout, and set the `yaml.ansible` filetype that
  # ansiblels expects. Returning nil falls through to plain `yaml` (yamlls).
  # The value is a function (path, bufnr) -> filetype | nil.
  filetype.pattern.".*%.ya?ml".__raw = ''
    function(path, _)
      if vim.fs.root(path, "ansible.cfg")
        or path:match("/playbooks/")
        or path:match("/tasks/")
        or path:match("/handlers/")
        or path:match("/roles/")
      then
        return "yaml.ansible"
      end
    end
  '';

  # nixvim lists ansiblels in its `unpackaged` set, so the package must be
  # supplied explicitly.
  # https://nix-community.github.io/nixvim/plugins/lsp/servers/ansiblels/index.html
  lsp.servers.ansiblels = {
    enable = true;
    package = pkgs.ansible-language-server;
  };

  # ansiblels shells out to `ansible-lint` for diagnostics/validation.
  # https://nix-community.github.io/nixvim/NeovimOptions/index.html#extrapackages
  extraPackages = [ pkgs.ansible-lint ];
}
