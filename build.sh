#!/usr/bin/env bash

# Keep track of the devstack directory
TOP_DIR=$(cd $(dirname "$0") && pwd)

# Build directory
BUILD_DIR=${BUILD_DIR:-${TOP_DIR}/build}

# Import common functions
source $TOP_DIR/functions

if [[ ! -r $TOP_DIR/crosstoolrc ]]; then
    die $LINENO "missing $TOP_DIR/crosstoolrc"
fi
source $TOP_DIR/crosstoolrc

if [[ ! -r $TOP_DIR/userlandrc ]]; then
    die $LINENO "missing $TOP_DIR/userlandrc"
fi
source $TOP_DIR/userlandrc

#
# Build Toolchain
#
toolchain_build() {
    make_dir $BUILD_DIR
    make_dir $BUILD_DIR/dl

    echo "Downloading toolchain-ng"
    chdir $BUILD_DIR/dl
    do_job wget -q -c $CROSSTOOL_REPO
    chdir $BUILD_DIR
    untar_bundle jxvf $BUILD_DIR/dl/crosstool-ng-${CROSSTOOL_VER}.tar.bz2
    chdir crosstool-ng-${CROSSTOOL_VER}
    echo "Preparing toolchain-ng"
    do_job ./configure --prefix=$BUILD_DIR/ct
    do_job make
    do_job make install
    echo "Building Toolchain"
    make_dir $BUILD_DIR/work.ct
    chdir $BUILD_DIR/work.ct
    do_job $BUILD_DIR/ct/bin/ct-ng $TARGET_ARCH
    echo CT_PREFIX_DIR="$BUILD_DIR/x-tools/\${CT_TARGET}" >> $BUILD_DIR/work.ct/.config
    echo CT_CC_LANG_JAVA=n >> $BUILD_DIR/work.ct/.config
    echo CT_CC_LANG_ADA=n >> $BUILD_DIR/work.ct/.config
    echo CT_CC_LANG_FORTRAN=n >> $BUILD_DIR/work.ct/.config
    #echo "CT_CC_GCC_SYSTEM_ZLIB=\"y\"" >> $BUILD_DIR/work.ct/.config
    do_job_verbose $BUILD_DIR/ct/bin/ct-ng build -j$NJOBS
}

#
# Build Userland
#

userland_build() {
    echo "Downloading Userland"
    chdir $BUILD_DIR/dl
    do_job wget -q -c $RUBY_REPO
    do_job wget -q -c $OPENSSL_REPO
    do_job wget -q -c $LIBYAML_REPO
    git_clone https://github.com/opscode/chef.git $BUILD_DIR/chef 11.4.0
    git_clone $ZLIB_URL $BUILD_DIR/zlib v$ZLIB_VER
    chdir $BUILD_DIR
    untar_bundle zxvf $BUILD_DIR/dl/yaml-${LIBYAML_VER}.tar.gz
    untar_bundle jxvf $BUILD_DIR/dl/ruby-${RUBY_VER}.tar.bz2
    if [ -f $TOP_DIR/$RUBY_PATCH ]; then
        patch -d $BUILD_DIR/ruby-${RUBY_VER} -p1 < $TOP_DIR/${RUBY_PATCH}
    fi
    untar_bundle zxvf $BUILD_DIR/dl/openssl-${OPENSSL_VER}.tar.gz
    TOOLS_BIN=$BUILD_DIR/x-tools/$TARGET_ARCH/bin
    export CC=$TOOLS_BIN/$TARGET_ARCH-gcc
    export LD=$TOOLS_BIN/$TARGET_ARCH-gcc
    export AR=$TOOLS_BIN/$TARGET_ARCH-ar
    export RANLIB=$TOOLS_BIN/$TARGET_ARCH-ranlib
    #export INSTALL='/usr/bin/install -c -s'
    export STRIP=$TOOLS_BIN/$TARGET_ARCH-strip

    echo "Building libyaml"
    chdir $BUILD_DIR/yaml-${LIBYAML_VER}
    do_job_verbose ./configure --host=$TARGET_ARCH --prefix=/
    do_job_verbose make -j$NJOBS
    do_job_verbose make install DESTDIR=$BUILD_DIR/x-tools/$TARGET_ARCH/$TARGET_ARCH

    echo "Building zlib"
    chdir $BUILD_DIR/zlib
    AR_RC="$AR rc"
    CC=$CC AR=$AR_RC LD=$LD ./configure --prefix=$BUILD_DIR/x-tools/$TARGET_ARCH/$TARGET_ARCH
    do_job_verbose make -j$NJOBS
    do_job_verbose make install

    echo "Building openssl"
    chdir $BUILD_DIR/openssl-$OPENSSL_VER
    TARGET_ARCH_S=`$CC -dumpmachine | awk -F"-" '{ print $1 }'`
    OPENSSL_TARGET_ARCH="linux-elf"
    OPENSSL_CFLAGS="-O1"
    if [ $TARGET_ARCH_S = "powerpc" ]; then
        OPENSSL_TARGET_ARCH="ppc"
    fi
    ./Configure linux-$OPENSSL_TARGET_ARCH threads zlib shared no-asm no-hw no-ec
    sed -i -e "s:-O[0-9]:$OPENSSL_CFLAGS:" Makefile
    do_job_verbose make CC=$CC LD=$LD SHLIB_MINOR=$OPENSSL_VER_MINOR
    do_job_verbose make CC=$CC LD=$LD SHLIB_MINOR=$OPENSSL_VER_MINOR INSTALLTOP=/ INSTALL_PREFIX=$BUILD_DIR/x-tools/$TARGET_ARCH/$TARGET_ARCH install_sw

    echo "Building ruby"
    chdir $BUILD_DIR/ruby-${RUBY_VER}
    do_job_verbose ./configure --host=$TARGET_ARCH --target=$TARGET_ARCH --prefix=$DEPLOY_PREFIX/ruby --disable-install-doc
    do_job_verbose make -j$NJOBS
    make install DESTDIR=$BUILD_DIR/output

    echo "Building gems"
    chdir $BUILD_DIR/chef
    do_job gem build chef.gemspec
    gem_opts="--no-rdoc --no-ri -i $BUILD_DIR/output/$DEPLOY_PREFIX/ruby/lib/ruby/gems/1.9.1"
    do_job_verbose gem install mixlib-config -v 1.1.2 $gem_opts
    do_job_verbose gem install mime-types -v 1.22 $gem_opts
    do_job_verbose gem install net-ssh-multi -v 1.1 $gem_opts
    do_job_verbose gem install mixlib-cli -v 1.3.0 $gem_opts
    do_job_verbose gem install net-ssh-gateway -v 1.2.0 $gem_opts
    do_job_verbose gem install mixlib-log -v 1.6.0 $gem_opts
    do_job_verbose gem install mixlib-authentication -v 1.3.0 $gem_opts
    do_job_verbose gem install mixlib-shellout -v 1.1.0 $gem_opts
    do_job_verbose gem install systemu -v 2.5.2 $gem_opts
    do_job_verbose gem install yajl-ruby -v 1.1.0 $gem_opts
    do_job_verbose gem install ipaddress -v 0.8.0 $gem_opts
    do_job_verbose gem install ohai -v 6.16.0 $gem_opts
    do_job_verbose gem install rest-client -v 1.6.7 $gem_opts
    do_job_verbose gem install net-ssh -v 2.6.7 $gem_opts
    do_job_verbose gem install highline -v 1.6.17 $gem_opts
    do_job_verbose gem install erubis -v 2.7.0 $gem_opts
    do_job_verbose gem install chef-11.4.0.gem $gem_opts

    # XXX need cross-compiling
    chdir $BUILD_DIR/output/$DEPLOY_PREFIX/ruby/lib/ruby/gems/1.9.1/gems/yajl-ruby-1.1.0/ext/yajl
    do_job_verbose ruby -I $BUILD_DIR/output/$DEPLOY_PREFIX/ruby/lib/ruby/1.9.1/${TARGET_ARCH_S}-linux extconf.rb
    do_job_verbose make clean
    do_job_verbose make
    do_job_verbose cp *.so ../../lib/yajl/

    # XXX fix shebang
    chdir $BUILD_DIR/output/$DEPLOY_PREFIX/ruby/lib/ruby/gems/1.9.1/bin
    for f in * ; do
        sed -i -e "s:#![0-9a-z\/.]*:#!$DEPLOY_PREFIX/ruby/bin/ruby:" $f
    done
}

if [[ ! -r $BUILD_DIR/x-tools ]]; then
    toolchain_build
fi
echo "Toolchain: deployed. Proceed to next stop."
userland_build
chdir $BUILD_DIR/output
tar cjvf $BUILD_DIR/chef-embedded-11.4.0.tar.bz2 opt
echo "Build: done"
