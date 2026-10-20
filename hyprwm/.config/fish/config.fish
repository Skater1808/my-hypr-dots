# Wenn die Shell nicht interaktiv ist, breche hier ab (analog zu deiner .bashrc)
status is-interactive; or return

# Aliase
alias keyd='sudo keyd'
alias lazydocker='sudo lazydocker'
alias ls='ls --color=always'
alias docker='sudo docker'
alias grep='rg'
alias cat='bat'

# Fastfetch nur ausführen, wenn das Terminal breit genug ist
if test (tput cols) -ge 90
    fastfetch
end
export PATH="/home/emil/.local/bin:$PATH"

# Initialize Oh My Posh with Wallust colors (JSON format)
oh-my-posh init fish --config ~/.config/oh-my-posh/themes/standard.json | source

function fish_user_key_bindings
    # Überschreibt Ctrl+C, um die Zeile über wl-copy in die Wayland-Zwischenablage zu legen
    bind \cc "commandline -b | wl-copy; commandline -f repaint"
end

zoxide init fish | source
