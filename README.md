# Setup

> Editing dotfiles ad nauseam.

## Void packages

```
sudo xbps-install -Sy \
    acpi \
    alacritty \
    alsa-utils \
    autocutsel \
    base-system \
    bash-completion \
    bc \
    bind-utils \
    blueman \
    bluez \
    bluez-alsa \
    bspwm \
    cargo \
    ccache \
    cmake \
    clang \
    clang-tools-extra \
    cloak \
    cryptsetup \
    dina-font \
    dmenu \
    docker \
    docker-compose \
    duf \
    editorconfig \
    emacs-x11 \
    exiftool \
    fd \
    feh \
    ffmpeg \
    figlet \
    figlet-fonts \
    firefox \
    fzf \
    gcc \
    gettext-devel \
    gimp \
    go \
    google-fonts-ttf \
    grip \
    grub-x86_64-efi \
    htop \
    i3lock \
    inetutils-ftp \
    inetutils-telnet \
    inotify-tools \
    irssi-perl \
    jq \
    keepassxc \
    libreoffice \
    libxcb-devel \
    light \
    lolcat-c \
    luarocks \
    lvm2 \
    mpc \
    mpd \
    mpv \
    mu4e \
    ncmpcpp \
    neomutt \
    neovim \
    nerd-fonts \
    net-tools \
    network-manager-applet \
    ninja \
    nodejs \
    numlockx \
    nvimpager \
    openvpn \
    pam-gnupg \
    pamixer \
    patch \
    perl-Text-CharWidth \
    perl-Unicode-LineBreak \
    perl-YAML \
    picom \
    pinentry-emacs \
    pinentry-gnome \
    pinentry-tty \
    plocate \
    pnpm \
    polybar \
    pulseaudio \
    python3-pip \
    python3-pipenv \
    python3-pytest \
    ranger \
    ripgrep \
    rofi-emoji \
    rsync \
    ruby \
    scrot \
    setxkbmap \
    slock \
    socklog-void \
    sqlite-devel \
    strace \
    supercat \
    sxhkd \
    syncthing \
    tcpdump \
    termshark \
    tidy \
    tlp \
    tmux \
    tree-sitter-devel \
    void-repo-nonfree \
    vsv \
    w3m-0.5.3+git20230121_2 \
    wget \
    wired-notify \
    wireshark \
    wmname \
    xauth \
    xautolock \
    xbacklight \
    xbanish \
    xcape \
    xclip \
    xdg-utils \
    xdo \
    xdotool \
    xev \
    xf86-input-evdev \
    xfd \
    xfontsel \
    xinit \
    xinput \
    xkblayout-state \
    xmodmap \
    xorg-minimal \
    xorgproto \
    xprop \
    xrandr \
    xrdb \
    xsel \
    xset \
    xsetroot \
    xtools \
    xwininfo \
    ImageMagick \
    NetworkManager \
    NetworkManager-openvpn-1.12.0_1 \
    Thunar
```

## xbps-mini-builder

```
tmp="$(mktemp -d)"
pushd "$tmp"
git clone --depth=1 https://github.com/the-maldridge/xbps-mini-builder .
touch packages.list
echo XBPS_ALLOW_RESTRICTED=yes > xbps-src.conf
popd
sudo mv "$tmp" /opt/xbps-mini-builder
sudo chown -R jaagr:jaagr /opt/xbps-mini-builder
```

## Dots

```
git clone --recursive --separate-git-dir=$HOME/.dots.git https://github.com/jaagr/dots.git /tmp/dots
rsync -rvl --exclude ".git" /tmp/dots/ $HOME/
rm -r /tmp/dots
git --git-dir=$HOME/.dots.git/ --work-tree=$HOME submodule update --init --recursive $HOME/
```

## Neovim

Install language servers and formatting tools

```
cat >~/.local/bin/mason-install <<'EOF'
#!/bin/bash

for pkg in "$@"; do
  echo "** installing: $pkg"
  nvim --headless \
    -c "lua require('mason')" \
    -c "MasonInstall $pkg" \
    -c "quit"
done
EOF

chmod +x ~/.local/bin/mason-install

mason-install \
    bash-language-server \
    black \
    clang-format \
    clangd \
    cmake-language-server \
    cmakelint \
    emmet-ls \
    gitlint \
    golines \
    gomodifytags \
    gopls \
    gotests \
    isort \
    json-lsp \
    jsonlint \
    ktfmt \
    ktlint \
    kotlin-language-server \
    lua-language-server \
    prettierd \
    pyflakes \
    rust-analyzer \
    shellcheck \
    shellharden \
    shfmt \
    stylelint \
    stylua \
    svelte-language-server \
    typescript-language-server \
    unocss-language-server \
    vue-language-server \
    yaml-language-server \
    yamlfmt \
    yamllint

# nvim --headless \
#     -c "lua require('nvim-treesitter')" \
#     -c "TSInstallSync all" \
#     -c "quit"

npm install -g \
    js-beautify \
    prettier \
    turbo
```

## Emacs

```
git clone --depth=1 https://github.com/doomemacs/doomemacs ~/.emacs.d
git clone git@gitlab.com:jaagr/doom.d.git ~/.doom.d
doom sync
doom doctor
```

## Emacs mail

Create an IMAP app password to be used by `mbsync`:

https://app.fastmail.com/settings/security/general

```
sudo xbps-install -Sy isync mu4e

mkdir -p "$HOME/.mail"
read -p 'Enter username: ' -r username && echo
read -p 'Enter IMAP app password: ' -s -r password && echo
echo "$username" > ~/.mail/credentials-fastmail.txt
echo "$password" >> ~/.mail/credentials-fastmail.txt
gpg -e -r c@rlberg.se ~/.mail/credentials-fastmail.txt
shred -uvz ~/.mail/credentials-fastmail.txt
unset username password

cat >"$HOME/.mbsyncrc" <<-EOF
# First section: remote IMAP account
IMAPAccount fastmail
Host imap.fastmail.com
Port 993
UserCmd +"gpg -q -d -r c@rlberg.se ~/.mail/credentials-fastmail.txt.gpg | head -1"
PassCmd +"gpg -q -d -r c@rlberg.se ~/.mail/credentials-fastmail.txt.gpg | tail -1"
TSLType IMAPS
TSLVersions +1.2

IMAPStore fastmail-remote
Account fastmail

# This section describes the local storage
MaildirStore fastmail-local
Path ~/.mail/
Inbox ~/.mail/INBOX
# The SubFolders option allows to represent all
# IMAP subfolders as local subfolders
SubFolders Verbatim

# This section a "channel", a connection between remote and local
Channel fastmail
Far :fastmail-remote:
Near :fastmail-local:
Patterns *
Expunge None
CopyArrivalDate yes
Sync All
Create Near
SyncState *
EOF

mbsync -a
mu init -m "$HOME/.mail" --my-address=c@rlberg.se
mu index
```

## ProtonVPN

Get OpenVPN credentials and server configuration files from the Proton account page:

https://account.proton.me/u/0/vpn/OpenVpnIKEv2

```
# Configure the firewall after the tunnel interface has been created
sudo dnf remove -y firewalld
sudo dnf install -y ufw
~/scripts/killswitch.sh ~/downloads/se.protonvpn.net.udp.ovpn
```

## VeraCrypt

```
cd /opt/xbps-mini-builder
./xbps-mini-builder VeraCrypt
cd void-packages
sudo xbps-install -y VeraCrypt
```

## Google Chrome

```
cd /opt/xbps-mini-builder
./xbps-mini-builder google-chrome
cd void-packages
sudo xbps-install -y google-chrome
```

## Neomutt

```
mkdir -p ~/.mutt/cache/bodies
cat >~/.mutt/signature <<EOF

Best regards,
Michael
EOF
```

## Fonts

### Siji

```
tmp="$(mktemp -d)"
pushd "$tmp"
git clone --depth=1 https://github.com/stark/siji .
./install.sh
popd
rm -rf "$tmp"
```

### Powerline

```
tmp="$(mktemp -d)"
pushd "$tmp"
git clone --depth=1 https://github.com/powerline/fonts .
./install.sh
popd
rm -rf "$tmp"
```

### Figlet

```
tmp="$(mktemp -d)"
pushd "$tmp"
git clone --depth=1 https://github.com/xero/figlet-fonts .
mkdir -p ~/.local/share/figlet
cp *.fl* ~/.local/share/figlet/
popd
rm -rf "$tmp"
```
