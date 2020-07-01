#!/bin/env sh

defaultTrue() {
    read -r judgement
    if [ "$judgement"x != "n"x ]; then
        judgement="y"
    fi
}
defaultFalse() {
    read -r judgement
    if [ "$judgement"x != "y"x ]; then
        judgement="n"
    fi
}

if [ "$1" = "usb" ]; then
    # Preparation{{{
    # update system time
    timedatectl set-ntp true
    #}}}
    # Partition{{{
    fdisk -l
    echo ""
    echo "Recommendation: "
    echo "create GPT partition table if it's a new disk"
    echo "+512M efi /boot"
    echo "+4G swap /swap"
    echo "+30G xfs /home"
    echo "+30G xfs /"
    echo ""
    echo "Tips in fdisk:"
    echo "m    help"
    echo "g    create GPT partition table"
    echo "p    print current partition info"
    echo "n    new partition"
    echo "d    delete partition"
    echo "t    change type"
    echo "l    list available types"
    echo "w    write"
    echo "q    quit"
    echo -n "Execute 'fdisk /dev/sdx' to start the partition operation. (enter to continue) "
    read -r wait
    bash
    #}}}
    # Filesystems{{{
    echo "mkswap /dev/sdxY"
    echo "swapon /dev/sdxY"
    echo "mkfs.ext4 /dev/sdxY"
    echo "mkfs.xfs /dev/sdxY"
    echo "mkfs.fat -F32 /dev/sdxY"
    echo -n "'fdisk -l' to get more info. (enter to continue) "
    read -r wait
    bash
    #}}}
    # Mount{{{
    echo -n "mount like this: 'mount /dev/sdxY /mnt'. (enter to continue) "
    read -r wait
    bash
    #}}}
    # Mirror{{{
    mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    echo "[1] tuna; [2] 163; [3] aliyun"
    echo -n "> "
    read -r mirror
    if [ "$mirror" = "1" ]; then
        echo 'Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
    elif [ "$mirror" = "2" ]; then
        echo 'Server = http://mirrors.163.com/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
    elif [ "$mirror" = "3" ]; then
        echo 'Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
    else
        echo 'Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
    fi
    #}}}
    pacman -Syy
    pacstrap /mnt base base-devel
    echo -n "Continue? [N/y] "
    defaultFalse
    while [ "$judgement" = "n" ]; do
        pacman -Syy
        pacstrap /mnt base base-devel
        echo -n "Continue? [N/y] "
        defaultFalse
    done
    genfstab -L /mnt >>/mnt/etc/fstab
    echo -n "Check fstab. (enter to continue) "
    read -r wait
    less /mnt/etc/fstab
    echo "execute 'arch-chroot /mnt'"
elif [ "$1" = "chroot" ]; then
    passwd
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    hwclock --systohc
    rm /etc/pacman.d/mirrorlist
    echo 'Server = http://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist
    sed -ri -e '$a # Server = http://mirrors.163.com/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    sed -ri -e '$a # Server = http://mirrors.aliyun.com/archlinux/$repo/os/$arch' /etc/pacman.d/mirrorlist
    sed -ri -e '$a # Server = https://archive.archlinux.org/repos/2019/03/15/$repo/os/$arch' /etc/pacman.d/mirrorlist
    sed -ri -e '$a # Server = https://archive.archlinux.org/repos/last/$repo/os/$arch' /etc/pacman.d/mirrorlist
    pacman -Syyuu
    pacman -S vim dialog wpa_supplicant ntfs-3g networkmanager intel-ucode v2ray sudo mesa xf86-video-intel xorg git w3m aria2 wget openssh netctl
    echo -n "Continue? [N/y] "
    defaultFalse
    while [ "$judgement" = "n" ]; do
        pacman -Syyuu
        pacman -S vim dialog wpa_supplicant ntfs-3g networkmanager intel-ucode v2ray sudo mesa xf86-video-intel xorg git w3m aria2 wget openssh netctl os-prober grub efibootmgr linux
        echo -n "Continue? [N/y] "
        defaultFalse
    done
    vim /etc/locale.gen
    locale-gen
    echo -n "add this to the first line: 'LANG=en_US.UTF-8' (enter to continue) "
    read -r wait
    vim /etc/locale.conf
    echo -n "set hostname (enter to continue) "
    read -r wait
    vim /etc/hostname
    rm /etc/hosts
    echo '127.0.0.1	localhost' >/etc/hosts
    sed -ri -e '$a ::1		localhost' /etc/hosts
    sed -ri -e '$a 127.0.1.1	myhostname.localdomain	myhostname' /etc/hosts
    vim /etc/hosts
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=ArchLinux
    grub-mkconfig -o /boot/grub/grub.cfg
    sed -ri -e 's/use_lvmetad = 1/use_lvmetad = 0/' /etc/lvm/lvm.conf
    useradd -m -G wheel sainnhe
    passwd sainnhe
    visudo
    echo ""
    echo "finish"
elif [ "$1" = "user" ]; then
    # timedatectl set-local-rtc 1 --adjust-system-clock
    sudo timedatectl set-local-rtc 1
    sudo hwclock --systohc --localtime
    # Basic{{{
    ssh-keygen -t rsa -b 4096 -C "sainnhe@gmail.com"
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_rsa
    mkdir ~/repo
    cd ~/repo
    git config --global http.proxy socks5://127.0.0.1:1080
    git clone https://github.com/sainnhe/dotfiles.git
    git clone https://github.com/sainnhe/scripts.git
    git clone https://github.com/sainnhe/notes.git
    cd dotfiles
    git remote set-url origin git@github.com:sainnhe/dotfiles.git
    cd ../scripts
    git remote set-url origin git@github.com:sainnhe/scripts.git
    cd ../notes
    git remote set-url origin git@github.com:sainnhe/notes.git
    cd ../
    git clone https://aur.archlinux.org/pikaur.git
    cd ~/repo/pikaur
    makepkg -si
    sudo pacman -S python-pysocks asp
    echo "setup dotfiles manually"
    #}}}
    # Network{{{
    sudo systemctl disable netctl
    sudo systemctl enable NetworkManager
    sudo cp ~/repo/scripts/func/v2ray/v2ray-tcp.json /etc/v2ray/config.json
    sudo systemctl enable v2ray
    sudo systemctl start v2ray
    sudo pacman -S proxychains net-tools
    sudo cp ~/repo/dotfiles/.root/etc/proxychains.conf /etc/proxychains.conf
    #}}}
    # LightDM{{{
    sudo pacman -S lightdm i3-gaps
    sudo pacman -S lightdm-webkit2-greeter
    pikaur -S lightdm-webkit2-theme-material2
    sudo systemctl enable lightdm
    sudo cp ~/repo/dotfiles/.root/etc/lightdm/lightdm.conf /etc/lightdm/lightdm.conf
    sudo cp ~/repo/dotfiles/.root/etc/lightdm/lightdm-webkit2-greeter.conf /etc/lightdm/lightdm-webkit2-greeter.conf
    #}}}
    # LightDM{{{
    sudo pacman -S sddm
    pikaur -S sddm-greeter sddm-config-editor sddm-sugar-light
    sudo cp ~/repo/dotfiles/.root/etc/sddm.conf /etc/sddm.conf
    #}}}
    # Surface{{{
    mkdir -p ~/playground
    cd ~/playground || exit
    # DKMS modules
    sudo pacman -S dkms acpi acpi_call-dkms
    # Add arch linux repository
    wget https://raw.githubusercontent.com/linux-surface/linux-surface/master/pkg/keys/surface.asc
    sudo pacman-key --add surface.asc
    sudo pacman-key --finger 56C464BAAC421453
    sudo pacman-key --lsign-key 56C464BAAC421453
    sudo cp ~/repo/dotfiles/.root/etc/pacman.conf /etc/pacman.conf
    sudo pacman -Sy
    # Install the kernel and firmwares
    sudo pacman -S linux-surface-headers linux-surface surface-ipts-firmware
    # Post-Installation
    pikaur -S update-grub aic94xx-firmware wd719x-firmware libwacom-surface surface-control surface-dtx-daemon libva-vdpau-driver-vp9
    sudo update-grub
    sudo systemctl enable surface-dtx-daemon.service
    # Nvidia
    # pikaur -S nvidia-beta-dkms nvidia-settings-beta nvidia-utils-beta opencl-nvidia-beta lib32-nvidia-utils-beta lib32-opencl-nvidia-beta bumblebee
    sudo pacman -S nvidia-dkms nvidia-settings nvidia-utils opencl-nvidia lib32-nvidia-utils lib32-opencl-nvidia bumblebee
    sudo pacman -S virtualgl lib32-virtualgl lib32-primus lib32-primus_vk primus primus_vk
    sudo mkdir -p /etc/modprobe.d
    sudo mkdir -p /etc/X11/xorg.conf.d
    sudo mkdir -p /etc/modules-load.d
    sudo cp ~/repo/dotfiles/.root/etc/modprobe.d/dgpu.conf /etc/modprobe.d/
    sudo cp ~/repo/dotfiles/.root/etc/modprobe.d/blacklist-nouveau.conf /etc/modprobe.d/
    sudo cp ~/repo/dotfiles/.root/etc/X11/xorg.conf.d/20-intel.conf /etc/X11/xorg.conf.d/
    sudo cp ~/repo/dotfiles/.root/etc/X11/xorg.conf.d/20-nvidia.conf /etc/X11/xorg.conf.d/
    sudo cp ~/repo/dotfiles/.root/etc/modules-load.d/nvidia.conf /etc/modules-load.d/
    sudo sed -i 's/^Driver=.*/Driver=nvidia/' /etc/bumblebee/bumblebee.conf
    sudo usermod -a -G bumblebee sainnhe
    sudo systemctl enable bumblebeed.service
    #}}}
    pikaur -S gvim firefox-developer-edition telegram-desktop alacritty lsd svn evince nautilus chromium
    pikaur -S nerd-fonts-complete wqy-microhei ttf-monaco ttf-droid noto-fonts noto-fonts-extra noto-fonts-cjk noto-fonts-emoji ttf-symbola
    proxychains -q wget https://github.com/fphoenix88888/ttf-mswin10-arch/raw/master/ttf-ms-win10-zh_cn-10.0.18362.116-1-any.pkg.tar.xz
    pikaur -S fcitx fcitx-configtool fcitx-libpinyin fcitx-cloudpinyin fcitx-table-extra fcitx-table-other kcm-fcitx fcitx-skins fcitx-skin-material
    sudo pacman -Syy
    sudo pacman -S archlinuxcn-keyring
    echo "setup i3, zsh, tmux, vim manually"
fi
