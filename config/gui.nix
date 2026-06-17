# Options for GUI frontends (e.g. Veil, Neovide). In a terminal these are
# ignored; in a GUI, nvim's `guifont` drives the font — Veil reads it on local
# connections (its veil.toml [font] is only a fallback). Matched to
# ~/.config/kitty/kitty.conf (Menlo 11) so the GUI matches the terminal.
#
# https://nix-community.github.io/nixvim/NeovimOptions/index.html#opts
# https://neovim.io/doc/user/options.html#'guifont'
{ ... }:
{
  opts = {
    # <font>:h<size>
    guifont = "Menlo:h11";
  };
}
