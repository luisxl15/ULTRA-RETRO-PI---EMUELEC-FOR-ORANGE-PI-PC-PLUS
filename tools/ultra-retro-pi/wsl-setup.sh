#!/bin/bash
# prepara o Ubuntu 20.04 do WSL (URP-Build) para o build do Neo-EmuELEC-H3; rodar como root
set -e
export DEBIAN_FRONTEND=noninteractive
echo "== fase 1/4: apt update"
apt-get update -q
echo "== fase 2/4: base"
apt-get install -y -q ca-certificates sudo locales tzdata git nano less file rsync cpio
ln -sf /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime
sed -i 's/^# *en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen && locale-gen
update-locale LANG=en_US.UTF-8
echo "== fase 3/4: dependencias do build"
apt-get install -y -q gcc g++ make build-essential unzip zip wget curl xz-utils bzip2 lzop zstd \
  bc sed patch patchutils perl gawk gperf diffutils golang patchelf \
  libc6-dev libncurses5-dev libtinfo-dev texinfo device-tree-compiler gcc-multilib g++-multilib \
  xfonts-utils xsltproc default-jre-headless python2 python-is-python2 python3 python3-pip \
  libjson-perl libxml-parser-perl xmlstarlet cmake bison flex libssl-dev u-boot-tools \
  libxml2-utils dosfstools mtools parted \
  libgirepository-1.0-1 gir1.2-glib-2.0 \
  bsdmainutils \
  libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev
  # pgi carrega a libgirepository do host via ctypes; o sameboy usa hexdump;
  # o ecwolf:host acha o SDL do host (o README do fork manda instalar libsdl2-dev)
# o Ubuntu Base nao traz /etc/mtab; sem ele o mke2fs da etapa final (mkimage) aborta
ln -sf /proc/self/mounts /etc/mtab
echo "== fase 4/4: usuario de build (sem senha, so para nao compilar como root)"
id builder >/dev/null 2>&1 || useradd -m -s /bin/bash builder
echo "builder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/builder
chmod 440 /etc/sudoers.d/builder
printf '[user]\ndefault=builder\n[automount]\noptions="metadata"\n[interop]\nappendWindowsPath=false\n' > /etc/wsl.conf
apt-get clean
echo "== PRONTO"
