#!/bin/bash
### THANAS x86-64 KERNEL - MODDED TORVALDS DEVELOPMENT FORK
### built with llvm/clang by default
###########################################################
LC_ALL=C
LANG=C

###### SET BASH COLORS AND CONFIGURE COMPILATION TIME DISPLAY
DATE_START=$(date +"%s")
yellow="\033[1;93m"
magenta="\033[05;1;95m"
restore="\033[0m"

###### SET VARIABLES
### dirs
source="$(pwd)"
makefile=$source/Makefile
### config
defconfig=thanas_defconfig

###### UPGRADE COMPILERS PRIOR TO COMPILATION
#sudo ./upgrade.sh




        sudo /usr/sbin/update-ccache-symlinks
        sudo ln -sfT $(which dash) $(which sh)

himri=$(who | head -n1 | awk '{print $1}')

cclm=$(ls /usr/lib | grep 'llvm-' | tail -n 1 | rev | cut -c-3 | rev)




LLVM_ENABLE_RUNTIMES=”openmp”
LLVM_ENABLE_PROJECTS=ON
LLVM_ENABLE_ASSERTIONS=ON
LLVM_CCACHE_BUILD=ON

OMP_TARGET_OFFLOAD=MANDATORY
OMP_NUM_THREADS=$(nproc)
OMP_DYNAMIC=true
OMP_DEBUG=disabled
LIBOMPTARGET_OMPT_SUPPORT=1


###### SET UP CCACHE
export USE_CCACHE=1
export USE_PREBUILT_CACHE=1
export PREBUILT_CACHE_DIR=~/.ccache
export CCACHE_DIR=~/.ccache
ccache -M 30G
ccache --set-config=sloppiness=locale,time_macros


###### AUTO VERSIONING
VERSION=$(cat $makefile | head -2 | tail -1 | cut -d '=' -f2)
PATCHLEVEL=$(cat $makefile | head -3 | tail -1 | cut -d '=' -f2)
SUBLEVEL=$(cat $makefile | head -4 | tail -1 | cut -d '=' -f2)
EXTRAVERSION=$(cat $makefile | head -5 | tail -1 | cut -d '=' -f2)
VERSION=$(echo "$VERSION" | awk -v FPAT="[0-9]+" '{print $NF}')
PATCHLEVEL=$(echo "$PATCHLEVEL" | awk -v FPAT="[0-9]+" '{print $NF}')
SUBLEVEL=$(echo "$SUBLEVEL" | awk -v FPAT="[0-9]+" '{print $NF}')
EXTRAVERSION="$(echo "${EXTRAVERSION}" | sed -e 's/^[[:space:]]*//')"
LOCALVERSION=$(echo '-clrxt+')
KERNELVERSION="${VERSION}.${PATCHLEVEL}.${SUBLEVEL}${EXTRAVERSION}${LOCALVERSION}"

###### DISPLAY KERNEL VERSION
clear
echo -e "${magenta}"
echo - THANAS X86-64 KERNEL -
echo -e "${yellow}"
make kernelversion
echo -e "${restore}"

###### COMPILER CONFIGURATION - OPTIONALLY PREBUILT COMPILER CONFIG
### set up paths in case of prebuilt compiler usage
### hash out "#clang" underneath to switch compiler from clang to gcc optionally
### if "CC=clang-10" is being used, -mllvm -polly optimizations will be enabled
### not included in clang-11 for now, due to compiler errors
##export CROSS_COMPILE=/usr/bin/x86_64-linux-gnu-
path=/usr/bin
path2=/usr/lib/llvm$cclm/bin

### set to prebuilt compiler
xpath=/home/$himri/TOOLCHAIN/clang/bin
export LD_LIBRARY_PATH=""$path2"/../lib:"$path2"/../lib64:$LD_LIBRARY_PATH"
export PATH=""$path2":$PATH"
#CLANG="CC=$xpath/clang
#        HOSTCC=$xpath/clang
#        AR=$xpath/llvm-ar
#        NM=$xpath/llvm-nm
#        OBJCOPY=$xpath/llvm-objcopy
#        OBJDUMP=$xpath/llvm-objdump
#        READELF=$xpath/llvm-readelf
#        OBJSIZE=$xpath/llvm-size
#        STRIP=$xpath/llvm-strip
#        LD=$xpath/ld.lld"

### set to system compiler
#CLANG="CC=/usr/lib/ccache/bin/clang  
#make sure it points to ccache
#clang="CC=$(which clang)
#        HOSTCC=$(which clang)
#        AR=llvm-ar$cclm
#        NM=llvm-nm$cclm
#        OBJCOPY=llvm-objcopy$cclm
#        OBJDUMP=llvm-objdump$cclm
#        READELF=llvm-readelf$cclm
#        OBJSIZE=llvm-size$cclm
#        STRIP=llvm-strip$cclm"
### optionally set linker seperately
#LD="LD=ld.lld$cclm"
if [ -e /home/$himri/TOOLCHAIN/clang ] ; then
LD="LD=$xpath/ld.lld$cclm"
else
LD="LD=ld.lld$cclm"
fi
### enable verbose output for debugging
#VERBOSE="V=1"
### ensure all cpu threads are used for compilation
THREADS=-j$(nproc --all)


###   USE GCC EXPERIMENTAL WHEN COMPILING, NOT ALWAYS BUT PROBABLY FASTER THAN CLANG SETUP
## update: actually tested. clang polly lld 15 gives 10 % slower binary over gcc 13
# tested llvm-17.0.0 as well, gcc-13 substancially faster binary

himri=$(who | head -n1 | awk '{print $1}')

#sudo modprobed-db & sleep 3 ; sudo modprobed-db store

#f ! grep -q 'f2fs
#xfs
#vfat
#loop
#isofs
#efivars
#usb_storage
#usbhid
#lz4
#i915
#fb
#drm
#vfb
#drm_dma_helper
#' /home/$himri/.config/modprobed.db ; then
#echo 'f2fs
#xfs
#vfat
#loop
#isofs
#efivars
#usb_storage
#usbhid
#lz4
#i915
#fb
#drm
#vfb
#drm_dma_helper' | sudo tee -a /home/$himri/.config/modprobed.db ; fi

#sudo modprobed-db store

# quick fix to extend cmdline if so. sudo bls=yes ./build.sh
#are_you_already_using_basic_linux_setup?
bls=no
if [ $bls = yes ] || grep -q thanas /etc/rc.local ; then
sudo sed -i 's/CONFIG_CMDLINE_BOOL=.*/# CONFIG_CMDLINE_BOOL is not set/g' $PWD/config
sudo sed -i 's/CONFIG_CMDLINE=.*/# CONFIG_CMDLINE is not set/g' $PWD/config
fi


#sudo cp -f /home/$himri/.config $PWD/.config
###### SETUP KERNEL CONFIG
#sudo rm -rf .config
#sudo rm -rf .config.old
#cp $defconfig .config

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
 x86="/lib/ld-linux-x86-64.so.2" 

#if lscpu | grep -qi intel ; then sudo sed -i 's/# CONFIG_MNATIVE_INTEL.*/CONFIG_MNATIVE_INTEL=y/g' $PWD/config ; fi
#if lscpu | grep -qi amd ; then sudo sed -i 's/# CONFIG_MNATIVE_AMD.*/CONFIG_MNATIVE_AMD=y/g' $PWD/config ; fi
  if grep -q "CONFIG_GENERIC_CPU=y" $PWD/.config ; then sudo sed -i 's/CONFIG_GENERIC_CPU=y/# CONFIG_GENERIC_CPU is not set/g' $PWD/.config ; fi
  
  if $x86 --help | grep -q "v4 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU4.*/CONFIG_GENERIC_CPU4=y/g' $PWD/config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/config 
elif $x86 --help | grep -q "v3 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU3.*/CONFIG_GENERIC_CPU3=y/g' $PWD/config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/config  
elif $x86 --help | grep -q "v2 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU2.*/CONFIG_GENERIC_CPU2=y/g' $PWD/config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/config  
else sudo sed -i 's/# CONFIG_MCORE2.*/CONFIG_MCORE2=y/g' $PWD/config    
  fi
grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;

sudo cp $PWD/config $PWD/.config


Keys.ENTER | sudo make $CLANG $LD localmodconfig
### optionally modify defconfig prior to compilation
### unhash "#make menuconfig" underneath for customization
### note this is temporary since the default config gets replaced prior to each compilation
### for permanence use "./defconfig-regen.sh" and back it up because this also will be replaced but by every git pull instead
### optionally use the included "stock_defconfig" for a stock kernel configuration built on this source
### for this to function with the "build.sh" rename "stock_defconfig" and replace "thanas_defconfig" with it
#make menuconfig
### or apply "make xconfig" instead of menuconfig to configure it graphically
#make xconfig
grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
  if grep -q "CONFIG_GENERIC_CPU=y" $PWD/.config ; then sudo sed -i 's/CONFIG_GENERIC_CPU=y/# CONFIG_GENERIC_CPU is not set/g' $PWD/.config ; fi

#if lscpu | grep -qi intel ; then sudo sed -i 's/# CONFIG_MNATIVE_INTEL.*/CONFIG_MNATIVE_INTEL=y/g' $PWD/config ; fi
#if lscpu | grep -qi amd ; then sudo sed -i 's/# CONFIG_MNATIVE_AMD.*/CONFIG_MNATIVE_AMD=y/g' $PWD/config ; fi
  
  if $x86 --help | grep -q "v4 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU4.*/CONFIG_GENERIC_CPU4=y/g' $PWD/.config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/.config 
elif $x86 --help | grep -q "v3 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU3.*/CONFIG_GENERIC_CPU3=y/g' $PWD/.config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/.config  
elif $x86 --help | grep -q "v2 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU2.*/CONFIG_GENERIC_CPU2=y/g' $PWD/.config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/.config  
else sudo sed -i 's/# CONFIG_MCORE2.*/CONFIG_MCORE2=y/g' $PWD/.config    
  fi
grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
###### START COMPILATION
Keys.ENTER | sudo make $THREADS $VERBOSE $CLANG $LD
Keys.ENTER | sudo make $THREADS $VERBOSE $CLANG $LD modules

###### START AUTO INSTALLATION
### check to see if all went successfull
if [ -e $source/arch/x86/boot/vmlinux.bin ]; then
### install
sudo make $THREADS modules_install
sudo make $THREADS install
#DRACUT_KMODDIR_OVERRIDE=1
sudo cp $PWD/arch/x86/boot/bzImage /boot/vmlinuz-"${KERNELVERSION}"
sudo dracut -f -v /boot/initramfs-"${KERNELVERSION}".img "${KERNELVERSION}"
#sudo kernel-install add /boot/initramfs-"${KERNELVERSION}".img /boot/vmlinuz-"${KERNELVERSION}"
sudo dracut --regenerate-all --lz4 --uefi --early-microcode -f 
#sudo refind-install ; sudo refind-mkdefault
sudo sed -i 's/timeout .*/timeout 1/g' /boot/EFI/refind/refind.conf
#sudo bootctl install
#sudo bootctl update
###### SETTING UP SYSTEM CONFIGURATION
### set up init.sh for kernel configuration
cd $source
#./extras.sh

###### COMPLETION
echo ...
echo ...
echo ...
echo YOU CAN REBOOT RN...
echo -e "${yellow}"
cat $source/include/generated/compile.h
echo "-------------------"
echo "Build Completed in:"
echo "-------------------"
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo -e "${magenta}"
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo -e "${restore}"


### failed build scenario
else
echo -e "${yellow}"
echo "-------------------"
echo "Build failed..."
echo "-------------------"
DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo -e "${magenta}"
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo -e "${restore}"
fi
grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
if grep -q "CONFIG_GENERIC_CPU=y" $PWD/.config ; then sudo sed -i 's/CONFIG_GENERIC_CPU=y/# CONFIG_GENERIC_CPU is not set/g' $PWD/.config ; fi
if grep -q "CONFIG_MNATIVE_INTEL=y" $PWD/config ; then sed -i 's/CONFIG_MNATIVE_INTEL=y/# CONFIG_MNATIVE_INTEL is not set/g' $PWD/config ; fi
if grep -q "CONFIG_MNATIVE_AMD=y" $PWD/config ; then sed -i 's/CONFIG_MNATIVE_AMD=y/# CONFIG_MNATIVE_AMD is not set/g' $PWD/config ; fi
if grep -q "CONFIG_GENERIC_CPU4=y" $PWD/config ; then sudo sed -i 's/CONFIG_GENERIC_CPU4=y/# CONFIG_GENERIC_CPU4 is not set/g' $PWD/config ; fi
if grep -q "CONFIG_GENERIC_CPU3=y" $PWD/config ; then sudo sed -i 's/CONFIG_GENERIC_CPU3=y/# CONFIG_GENERIC_CPU3 is not set/g' $PWD/config ; fi
if grep -q "CONFIG_GENERIC_CPU2=y" $PWD/config ; then sudo sed -i 's/CONFIG_GENERIC_CPU2=y/# CONFIG_GENERIC_CPU2 is not set/g' $PWD/config ; fi
if grep -q "/CONFIG_MCORE2=y" $PWD/config ; then sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/config ; fi
if grep -q "# CONFIG_CMDLINE_BOOL is not set" $PWD/config ; then sudo sed -i 's/# CONFIG_CMDLINE_BOOL is not set/CONFIG_CMDLINE_BOOL=y/g' $PWD/config ; fi
if grep -q "# CONFIG_CMDLINE is not set" $PWD/config ; then sudo sed -i 's/# CONFIG_CMDLINE is not set/CONFIG_CMDLINE="cgroup_disable=io,perf_event,rdma,cpu,cpuacct,cpuset,net_prio,hugetlb,blkio,memory,devices,freezer,net_cls,pids,misc noautogroup numa=off rcu_nocbs=0 slub_merge align_va_addr=on idle=nomwait clocksource=tsc tsc=reliable nohz=on skew_tick=1 audit=0 noreplace-smp nowatchdog cgroup_no_v1=all cryptomgr.notests irqaffinity=0 forcepae iommu.strict=0 novmcoredd iommu=force,pt edd=on iommu.forcedac=1 highres=on hugetlb_free_vmemmap=on apm=on cec_disable cpu_init_udelay=1000 tp_printk_stop_on_boot nohpet clk_ignore_unused gbpages rootflags=noatime libata.force=ncq,dma,nodmalog,noiddevlog,nodirlog,lpm,setxfer enable_mtrr_cleanup pcie_aspm=force pcie_aspm.policy=performance pstore.backend=null"/g' $PWD/config ; fi

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
### reopen menu
#./0*

###### END
