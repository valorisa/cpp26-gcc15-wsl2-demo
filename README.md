# cpp26-gcc15-wsl2-demo

---

## Présentation

Ce projet a pour objectif de montrer comment compiler et utiliser GCC 15.1 sous Ubuntu 25.04 (via WSL2 sur Windows 11 Enterprise) afin de profiter des toutes dernières fonctionnalités du standard C++26.  
Vous trouverez ici un exemple de code moderne, un script de build robuste et toutes les commandes nécessaires pour reproduire l’installation et l’utilisation de GCC 15.1 sur votre environnement.

---

## Prérequis

- **Windows 11 Enterprise** avec [WSL2](https://learn.microsoft.com/fr-fr/windows/wsl/install)
- **Ubuntu 25.04** installé sous WSL2
- **Git** installé (`git --version` doit fonctionner)

---

## Installation de GCC 15.1 sous Ubuntu 25.04 (WSL2)

### 1. Cloner ce dépôt

```shell
git clone https://github.com/valorisa/cpp26-gcc15-wsl2-demo.git
cd cpp26-gcc15-wsl2-demo
```

### 2. Installer les dépendances de compilation

```shell
sudo apt update
sudo apt install -y build-essential git make gawk flex bison libgmp-dev libmpfr-dev libmpc-dev python3 binutils perl libisl-dev libzstd-dev tar gzip bzip2
```

### 3. Télécharger et préparer les sources de GCC 15.1

```shell
mkdir -p ~/Projets/gcc-15
cd ~/Projets/gcc-15
git clone https://gcc.gnu.org/git/gcc.git gcc-15-source
cd gcc-15-source
git checkout releases/gcc-15.1.0
./contrib/download_prerequisites
```

### 4. Créer un dossier de build séparé

```shell
cd ~/Projets/gcc-15
mkdir gcc-15-build
cd gcc-15-build
```

### 5. Configurer GCC 15.1

```shell
../gcc-15-source/configure --prefix=/opt/gcc-15 --disable-multilib --enable-languages=c,c++ --disable-default-pie
```

### 6. Compiler GCC 15.1 (cela peut prendre du temps)

```shell
make -j$(($(nproc) - 1))
```

### 7. Installer GCC 15.1

```shell
sudo make install
```

### 8. Configurer les alternatives pour utiliser GCC 15.1 par défaut

```shell
sudo update-alternatives --install /usr/bin/gcc gcc /opt/gcc-15/bin/gcc 100
sudo update-alternatives --install /usr/bin/g++ g++ /opt/gcc-15/bin/g++ 100
sudo update-alternatives --config gcc
sudo update-alternatives --config g++
```

Sélectionnez `/opt/gcc-15/bin/gcc` et `/opt/gcc-15/bin/g++` dans la liste.

### 9. Vérifier l’installation

```shell
gcc --version
g++ --version
```

Vous devez voir : `gcc (GCC) 15.1.0`

---

## Compilation et exécution d’un exemple C++26

### 1. Copier le fichier d’exemple

Le fichier `test26.cpp` est fourni dans ce dépôt.

### 2. Compiler avec GCC 15.1 et le standard C++26

```shell
g++ -std=c++26 -Wno-deprecated-declarations -Wno-deprecated-variadic-comma-omission test26.cpp -o test26
```

### 3. Exécuter le programme

```shell
./test26
```

---

## 🛠️ Problèmes rencontrés lors de la compilation de GCC 15.1 sous Ubuntu 25.04 (WSL2)

### Erreur typique rencontrée

Lors de la compilation de GCC 15.1, il est possible d’obtenir l’erreur suivante :

```shell
/usr/bin/ld: /lib/x86_64-linux-gnu/crt1.o: in function `_start':
(.text+0x1b): undefined reference to `main'
collect2: error: ld returned 1 exit status
make: *** [Makefile:1009: libgcc_s.so] Error 1
```

#### **Cause**

Cette erreur survient si les variables d’environnement `CFLAGS` ou `LDFLAGS` sont définies à `-no-pie` (par exemple dans `.bashrc`, `/etc/environment` ou un terminal précédent), ce qui perturbe la création des bibliothèques partagées lors du build de GCC.

#### **Solution**

1. **Vérifier et nettoyer l’environnement avant compilation :**

   ```shell
   unset CFLAGS
   unset LDFLAGS
   ```

2. **S’assurer que ces variables ne sont pas définies dans vos fichiers de configuration shell** (`.bashrc`, `.profile`, etc.).

3. **Utiliser uniquement l’option `--disable-default-pie` lors de la configuration de GCC** :

   ```shell
   ../gcc-15-source/configure --prefix=/opt/gcc-15 --disable-multilib --enable-languages=c,c++ --disable-default-pie
   ```

4. **Repartir d’un dossier de build propre** :

   ```shell
   rm -rf ~/Projets/gcc-15/gcc-15-build
   mkdir ~/Projets/gcc-15/gcc-15-build
   cd ~/Projets/gcc-15/gcc-15-build
   ```

---

### 🚀 Script de compilation robuste

Voici un script Bash robuste appelé *'build-gcc15-no-pie.sh'* pour compiler GCC 15.1 sans rencontrer ce problème :

```shell
#!/bin/bash
set -e

SRC_DIR="$HOME/Projets/gcc-15/gcc-15-source"
BUILD_DIR="$HOME/Projets/gcc-15/gcc-15-build"
PREFIX="/opt/gcc-15"
NPROC=$(nproc)
JOBS=$((NPROC > 1 ? NPROC - 1 : 1))

unset CFLAGS
unset LDFLAGS

echo "=== Nettoyage de l'ancien build ==="
rm -rf "$BUILD_DIR"

echo "=== Installation des dépendances ==="
sudo apt update && sudo apt install -y build-essential git make gawk flex bison libgmp-dev libmpfr-dev libmpc-dev python3 binutils perl libisl-dev libzstd-dev tar gzip bzip2

echo "=== Préparation des sources ==="
[ ! -d "$SRC_DIR" ] && git clone https://gcc.gnu.org/git/gcc.git "$SRC_DIR"
cd "$SRC_DIR"
git checkout releases/gcc-15.1.0
./contrib/download_prerequisites

echo "=== Configuration ==="
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"
../gcc-15-source/configure --prefix="$PREFIX" --disable-multilib --enable-languages=c,c++ --disable-default-pie

echo "=== Compilation ==="
make -j"$JOBS"

echo "=== Installation ==="
sudo make install

echo "=== Vérification ==="
/opt/gcc-15/bin/gcc --version
```

---

## Astuces

- Pour compiler d’autres projets avec GCC 15.1, utilisez simplement `g++` ou `/opt/gcc-15/bin/g++`.
- Pour revenir à la version précédente de GCC, relancez :

  ```shell
  sudo update-alternatives --config gcc
  sudo update-alternatives --config g++
  ```

---

## Pour aller plus loin

- [Documentation officielle GCC](https://gcc.gnu.org/)
- [Nouveautés C++26 (cppreference)](https://en.cppreference.com/w/cpp/compiler_support/26)
- [WSL2 Documentation](https://learn.microsoft.com/fr-fr/windows/wsl/)

---

## Licence

Ce projet est publié sous licence MIT.

---

## Contact

Pour toute question ou suggestion, ouvrez une issue sur le dépôt GitHub.  

**Auteur** : [valorisa](https://github.com/valorisa)

---

## Référence

Guide inspiré de : [how-to-build-and-set-up-gcc-15-1-on-ubuntu](https://medium.com/@xersendo/moving-to-c-26-how-to-build-and-set-up-gcc-15-1-on-ubuntu-f52cc9173fa0)
![1_HhSVcgCMDHa4odEKNSNvgQ](https://github.com/user-attachments/assets/5ad67296-74cd-4d1a-afae-289e093f26fc)

---
