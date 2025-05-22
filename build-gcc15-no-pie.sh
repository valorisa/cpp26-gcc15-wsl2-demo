#!/bin/bash

set -e

SRC_DIR="$HOME/Projets/gcc-15/gcc-15-source"
BUILD_DIR="$HOME/Projets/gcc-15/gcc-15-build"
PREFIX="/opt/gcc-15"
NPROC=$(nproc)
JOBS=$((NPROC > 1 ? NPROC - 1 : 1))

echo "=== Nettoyage de l'ancien dossier de build ==="
rm -rf "$BUILD_DIR"

echo "=== Installation des dépendances ==="
sudo apt update
sudo apt install -y build-essential git make gawk flex bison libgmp-dev libmpfr-dev libmpc-dev python3 binutils perl libisl-dev libzstd-dev tar gzip bzip2

echo "=== Préparation des sources GCC 15.1.0 ==="
if [ ! -d "$SRC_DIR" ]; then
    mkdir -p "$(dirname "$SRC_DIR")"
    git clone https://gcc.gnu.org/git/gcc.git "$SRC_DIR"
    cd "$SRC_DIR"
    git checkout releases/gcc-15.1.0
    ./contrib/download_prerequisites
else
    cd "$SRC_DIR"
    git fetch
    git checkout releases/gcc-15.1.0
    ./contrib/download_prerequisites
fi

echo "=== Création du dossier de build ==="
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "=== Configuration de la compilation ==="
"$SRC_DIR/configure" --prefix="$PREFIX" --disable-multilib --enable-languages=c,c++ --disable-default-pie

echo "=== Compilation (cela peut être long) ==="
make -j"$JOBS"

echo "=== Installation de GCC 15.1.0 ==="
sudo make install

echo "=== Configuration des alternatives (optionnel) ==="
sudo update-alternatives --install /usr/bin/gcc gcc "$PREFIX/bin/gcc" 100
sudo update-alternatives --install /usr/bin/g++ g++ "$PREFIX/bin/g++" 100

echo "=== Pour activer GCC 15.1 par défaut, exécute : ==="
echo "sudo update-alternatives --config gcc"
echo "sudo update-alternatives --config g++"

echo "=== Vérification de la version installée ==="
"$PREFIX/bin/gcc" --version
"$PREFIX/bin/g++" --version

echo "=== FIN : GCC 15.1.0 installé dans $PREFIX ==="
