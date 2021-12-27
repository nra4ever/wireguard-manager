#!/bin/bash
# Secure WireGuard For CentOS, Debian, Ubuntu, Arch, Fedora, Redhat, Raspbian

# Checking For Virtualization
function virt-check() {
  # Deny OpenVZ
  if [[ $(command -v "systemd-detect-virt") ]]; then
    if [ "$(systemd-detect-virt)" == "openvz" ]; then
      echo "OpenVZ virtualization is not supported (yet)."
      exit
    fi
    # Deny LXC
    if [ "$(systemd-detect-virt)" == "lxc" ]; then
      echo "LXC virtualization is not supported (yet)."
    fi
  else
    echo "Warning: this script might not work correctly in your system."
  fi
}

# Virtualization Check
virt-check

# Detect Operating System
function dist-check() {
  DIST_CHECK="/etc/os-release"
  # shellcheck disable=SC1090
  if [ -e $DIST_CHECK ]; then
    # shellcheck disable=SC1091
    source $DIST_CHECK
    DISTRO=$ID
    # shellcheck disable=SC2034
    VERSION=$VERSION_ID
  else
    echo "Your distribution is not supported (yet)."
    exit
  fi
}

# Check Operating System
dist-check

# Install WireGuard Client
function install-wireguard-client() {
  # Installation begins here.
  if [ "$DISTRO" == "ubuntu" ] && [ "$VERSION" == "19.10" ]; then
    apt-get update
    apt-get install linux-headers-"$(uname -r)" -y
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  # shellcheck disable=SC2235
  if [ "$DISTRO" == "ubuntu" ] && ([ "$VERSION" == "16.04" ] || [ "$VERSION" == "18.04" ]); then
    apt-get update
    apt-get install software-properties-common -y
    add-apt-repository ppa:wireguard/wireguard -y
    apt-get update
    apt-get install linux-headers-"$(uname -r)" -y
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "debian" ]; then
    apt-get update
    echo "deb http://deb.debian.org/debian/ unstable main" >/etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >/etc/apt/preferences.d/limit-unstable
    apt-get update
    apt-get install linux-headers-"$(uname -r)" -y
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "raspbian" ]; then
    apt-get update
    apt-get install dirmngr -y
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 04EE7237B7D453EC
    echo "deb http://deb.debian.org/debian/ unstable main" >/etc/apt/sources.list.d/unstable.list
    printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' >/etc/apt/preferences.d/limit-unstable
    apt-get update
    apt-get install raspberrypi-kernel-headers -y
    apt-get install wireguard qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "arch" ]; then
    pacman -Syu
    pacman -Syu --noconfirm linux-headers
    pacman -Syu --noconfirm haveged qrencode iptables
    pacman -Syu --noconfirm wireguard-tools wireguard-arch resolvconf
  fi
  if [ "$DISTRO" = 'fedora' ] && [ "$VERSION" == "32" ]; then
    dnf update -y
    dnf install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
    dnf install qrencode wireguard-tools haveged resolvconf -y
  fi
  # shellcheck disable=SC2235
  if [ "$DISTRO" = 'fedora' ] && ([ "$VERSION" == "30" ] || [ "$VERSION" == "31" ]); then
    dnf update -y
    dnf copr enable jdoss/wireguard -y
    dnf install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
    dnf install qrencode wireguard-dkms wireguard-tools haveged resolvconf -y
  fi
  if [ "$DISTRO" == "centos" ] && [ "$VERSION" == "8" ]; then
    yum update -y
    yum install epel-release -y
    yum update -y
    yum install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" resolvconf -y
    yum config-manager --set-enabled PowerTools
    yum copr enable jdoss/wireguard -y
    yum install wireguard-dkms wireguard-tools qrencode haveged -y
  fi
  if [ "$DISTRO" == "centos" ] && [ "$VERSION" == "7" ]; then
    yum update -y
    curl https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo --create-dirs -o /etc/yum.repos.d/wireguard.repo
    yum update -y
    yum install epel-release -y
    yum update -y
    yum install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
    yum install wireguard-dkms wireguard-tools qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "redhat" ] && [ "$VERSION" == "8" ]; then
    yum update -y
    yum install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    yum update -y
    # shellcheck disable=SC2046
    subscription-manager repos --enable codeready-builder-for-rhel-8-$(arch)-rpms
    yum copr enable jdoss/wireguard
    yum install wireguard-dkms wireguard-tools qrencode haveged resolvconf -y
  fi
  if [ "$DISTRO" == "redhat" ] && [ "$VERSION" == "7" ]; then
    yum update -y
    curl https://copr.fedorainfracloud.org/coprs/jdoss/wireguard/repo/epel-7/jdoss-wireguard-epel-7.repo --create-dirs -o /etc/yum.repos.d/wireguard.repo
    yum update -y
    yum install epel-release -y
    yum install kernel-headers-"$(uname -r)" kernel-devel-"$(uname -r)" -y
    yum install wireguard-dkms wireguard-tools qrencode haveged resolvconf -y
  fi
}

# WireGuard Client
install-wireguard-client
