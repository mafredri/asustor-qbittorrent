#!/usr/bin/env zsh

[[ -n ${commands[apkg-tools.py]} ]] || {
	print "Error: could not find apkg-tools.py in path"
	exit 1
}

print "Requesting sudo to establish session..."
sudo echo -n

sshc() {
    ssh ascross 'zsh -s' <<<$@ 2>/dev/null
}

typeset -A arch_list
arch_list=(
    x86-64 /cross/x86_64-asustor-linux-gnu
    i386 /cross/i686-asustor-linux-gnu
    arm /cross/armv7a
)

script_path=${(%):-%x}
script_dir_path=${script_path:A:h}
script_dir_name=${script_dir_path:t}

package=${script_dir_name%-apkg}

print "Building $package"
cd -q $script_dir_path

version=$(<version.txt)
firmware=$(<firmware.txt)

build_apk='build/apk'
build_files='build/files'

mkdir -p $build_files
mkdir -p dist

for arch prefix in ${(kv)arch_list}; do
	[[ -d $build_apk/$arch ]] && rm -r $build_apk
	mkdir -p $build_apk/$arch

	print "Copying APK skeleton"
	rsync -a source/ $build_apk/$arch

    files=(${(@n)$(<files.txt)})
    pfiles=($prefix$^files)

    remote_files=(${(@n)$(sshc ls $pfiles)})

    {
        sshc ROOT=$prefix equery b ${remote_files/$prefix/} | sort | uniq > pkgversions_$arch.txt &&
        print "Wrote pkgversions_$arch.txt" || print "Failed writing pkgversions_$arch.txt"
    } &!

    rsync -a --relative ascross:"$pfiles" $build_files 2>/dev/null &&
    print "Fetched files for $arch" || print "Failed fetching files for $arch"

    print "Copying $arch files to $build_apk/$arch..."
    rsync -a $build_files$prefix/ $build_apk/$arch

	print "Finalizing..."
	print "Setting version:$version and arch:$arch"
	sed -i '' \
		-e "s^ARCH^${arch}^" \
		-e "s^VERSION^${version}^" \
		-e "s^FIRMWARE^${firmware}^" \
		$build_apk/$arch/CONTROL/config.json

	echo "Building APK..."
	# APKs require root privileges, make sure priviliges are correct
	sudo chown -R 0:0 $build_apk/$arch
	sudo apkg-tools.py create $build_apk/$arch --destination dist/
	sudo chown -R "$(whoami)" dist

	# Reset permissions on working directory
	sudo chown -R "$(whoami)" $build_apk/$arch
done

print "Thank you, come again!"
