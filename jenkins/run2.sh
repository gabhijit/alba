#!/bin/bash -xue

env | sort

export WORKSPACE=$PWD
export ALBA_HOME=$PWD
echo ${WORKSPACE}
export DRIVER=./setup/setup.native

export ARAKOON_BIN=$(which arakoon)

if [ -t 1 ];
then TTY="-t";
     make ;
else
    # this path is taken on jenkins, clean previous builds first
    TTY="";
    make clean || true;
    make || true;
fi

if (${ALBA_USE_ETCD:-false} -eq true)
then
    export ALBA_ETCD=127.0.0.1:5000/albas/xxxx/
fi

id
ulimit -n 1024
ulimit -c unlimited
cat /proc/sys/kernel/core_pattern

function package_debian {
    DEB_BUILD_OPTIONS=nostrip fakeroot debian/rules clean build binary
    created_package=`ls -t alba_*_amd64.deb | head -n1`
    new_package=alba_`git describe --tags --dirty | xargs`_amd64.deb
    if [ $created_package == $new_package ]
    then echo "point release"
    else mv ${created_package} ${new_package}
    fi
}

case "${1-bash}" in
    asd_start)
        ${DRIVER} asd_start || true
        ;;
    cpp)
        ./jenkins/cpp/010-build_client.sh
        ${DRIVER} cpp  || true
        ;;
    ocaml)
        ${DRIVER} ocaml || true
        ;;
    stress)
        ${DRIVER} stress || true
        ;;
    voldrv_backend)
        ${DRIVER} voldrv_backend || true
        ;;
    voldrv_tests)
        ${DRIVER} voldrv_tests || true
        ;;
    disk_failures)
        ${DRIVER} disk_failures || true
        ;;
    compat)
        ${DRIVER} compat || true
        ;;
    recovery)
        ${DRIVER} recovery || true
        ;;
    everything_else)
        ${DRIVER} everything_else  || true
        ;;
    test_integrate_deb)
        ./jenkins/run.sh test_integrate_deb
        ;;
    test_integrate_rpm)
        ./jenkins/run.sh test_integrate_rpm
        ;;
    bash)
        bash
        ;;
    clean)
        make clean
        ;;
    build)
        make
        ;;
    package_deb)
        package_debian
        ;;
    package_rpm)
        ./jenkins/package_rpm/030-package.sh
        ;;
    *)
        echo "invalid test suite specified..."
        exit1
esac
