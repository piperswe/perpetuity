#!/usr/bin/env bash

set -euxo pipefail

md5file() {
        echo "$(md5sum "$1" | awk '{ print $1 }') $(du -b "$1" | awk '{ print $1 }') $1"
}
sha256file() {
        echo "$(sha256sum "$1" | awk '{ print $1 }') $(du -b "$1" | awk '{ print $1 }') $1"
}

cd ~

incoming_dir="${1:-incoming}"

lockfile ~/process.lock
trap "rm -f ~/process.lock" EXIT

for march in $(cat ~/marches.txt)
do
        mkdir -p $incoming_dir/$march perpetuity/$march/{pool,dists/trixie/core/binary-i386}
        pushd perpetuity/$march
        find ~/$incoming_dir/$march -name '*.deb' -exec cp '{}' pool/ \;
        find ~/$incoming_dir/$march -name '*.udeb' -exec cp '{}' pool/ \;
        find ~/$incoming_dir/$march -type f -delete
        dpkg-scanpackages pool/ > dists/trixie/core/binary-i386/Packages
        gzip -kf dists/trixie/core/binary-i386/Packages
        xz -kf dists/trixie/core/binary-i386/Packages
        bzip2 -kf dists/trixie/core/binary-i386/Packages
        pushd dists/trixie
        cat > Release <<EOF
Origin: Perpetuity
Label: Perpetuity
Suite: trixie
Version: 13
Codename: trixie
Architectures: all i386
Components: core
MD5Sum:
 $(md5file core/binary-i386/Packages)
 $(md5file core/binary-i386/Packages.gz)
 $(md5file core/binary-i386/Packages.xz)
 $(md5file core/binary-i386/Packages.bz2)
SHA256:
 $(sha256file core/binary-i386/Packages)
 $(sha256file core/binary-i386/Packages.gz)
 $(sha256file core/binary-i386/Packages.xz)
 $(sha256file core/binary-i386/Packages.bz2)
EOF
        popd
        gpg -a -s --clearsign < dists/trixie/Release > dists/trixie/InRelease
        gpg -a -b -s < dists/trixie/Release > dists/trixie/Release.gpg
        popd
done
