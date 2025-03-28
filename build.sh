#!/bin/bash
### THANAS x86-64 KERNEL 
###########################################################
#LC_ALL=C
#LANG=C

### OLD SCRIPT I DONT BOTHER REWRITING OR UPDATING COMMENTS MIGHT BE OFF
# ps. gcc-13 almost scores 10% lower hackbench scores over llvm-17 on defaults. preferably build gcc + lld
# changes hardcoded to makefile, adjust or choose optimize for size to build O3 native polly llvm (lto)
# my advise is use gcc. faster binary lately and keeping up. unless you want to sacrifice performance.
# the tests were done with same flags, whereas gcc used graphite clang used polly. no lto
# but as i remember from the past even with lto it couldnt keep up.
# older versions of gcc were inferior to clang but lately not so.
# at least as far as hackbench latency goes.
# tests were done outside of the variables of makefile, havent checked if optimize for size has more hardcoded features
# use this source with gcc or put your own flags in makefile instead of this hasty solution.
# also from my experience either custom settings or defaults building with ccache substantially increases
# compilation time even if i have many GB ccache. just some personal notes from my experience. you be the judge.

# IMPORTANT OPTIONS:
CANYOUBOOT=yes # yes/no # if you still cant boot check the commit that converted inbuilt stuff to modules. or change the config to your hardware. setup tries to debloat as much as possible so can happen. unfortunately localmodconfig sometimes strips out modules. alternatively try localyesconfig, but know it as some performance impact.
# use latest llvm 
latest=no
if [ $buildforperformance = no ] ; then echo " building for security..." ; CANYOUBOOT=no ; else buildforperformance=yes ; fi


DATE_START=$(date +"%s")
yellow="\033[1;93m"
magenta="\033[05;1;95m"
restore="\033[0m"

source="$(pwd)"
makefile=$source/Makefile
defconfig=config
if [ $buildforperformance = no ] ; then defconfig=config_medium ; fi

#sudo ./upgrade.sh
if grep -qi debian /etc/os-release && [ $latest = yes ] ; then
cclm=$(ls /usr/lib | grep 'llvm-' | tail -n 1 | rev | cut -c-3 | rev)
fi
PATH=/usr/lib/ccache/bin:/lib/x86_64-linux-gnu:/usr/lib/llvm$cclm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin:/usr/local/games:/usr/games:$PATH
LD_LIBRARY_PATH=$PATH/../lib:$PATH/../lib64:/usr/lib/llvm$cclm/lib:/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH

sudo /usr/sbin/update-ccache-symlinks
sudo ln -sfT $(which dash) $(which sh)
export PATH="/usr/lib/ccache/bin:${PATH}"
export CCACHE_DIR="~/.ccache"
himri=$(who | head -n1 | awk '{print $1}')
#sudo chown $himri /var/cache/ccache ; sudo chown $himri /var/cache/ccache/* ; sudo chmod 775 /var/cache/ccache
LLVM_ENABLE_RUNTIMES=openmp
LLVM_ENABLE_PROJECTS=ON
LLVM_ENABLE_ASSERTIONS=ON
LLVM_CCACHE_BUILD=ON
OMP_TARGET_OFFLOAD=MANDATORY
OMP_NUM_THREADS=$(nproc)
OMP_DYNAMIC=true
OMP_DEBUG=disabled
LIBOMPTARGET_OMPT_SUPPORT=1

sudo export USE_CCACHE=1
sudo export CCACHE_RECACHE=yes
sudo export USE_PREBUILT_CACHE=1
sudo export PREBUILT_CACHE_DIR=~/.ccache
sudo export CCACHE_DIR=~/.ccache
sudo ccache -M 30G
sudo ccache --set-config=locale,time_macros,file_stat_matches,include_file_ctime,include_file_mtime

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

clear
echo -e "${magenta}"
echo - THANAS X86-64 KERNEL -
echo -e "${yellow}"
make kernelversion
echo -e "${restore}"


path=/usr/bin
export PATH=""$path":$PATH" ; 
export LD_LIBRARY_PATH=""$path"/../lib:"$path"/../lib64:$LD_LIBRARY_PATH"

if [ -e /home/$himri/TOOLCHAIN/clang/bin ] ; then xpath=/home/$himri/TOOLCHAIN/clang/bin 
elif [ -e /usr/lib/llvm$cclm/bin ] ; then
xpath=/usr/lib/llvm$cclm/bin
else xpath=/usr/bin
fi
sudo ln -sfT $xpath/clang $(which clang)
export PATH=""$xpath":$PATH"
export LD_LIBRARY_PATH=""$xpath"/../lib:"$xpath"/../lib64:$LD_LIBRARY_PATH"
export PATH=""$path2":$PATH"
export LD_LIBRARY_PATH=""$path2"/../lib:"$path2"/../lib64:$LD_LIBRARY_PATH"
if grep -q debian /etc/os-release ; then gcc="CC=gcc-13" ; fi
 CLANG="$gcc
        AR=$xpath/llvm-ar$cclm
        NM=$xpath/llvm-nm$cclm
        OBJCOPY=$xpath/llvm-objcopy$cclm
        OBJDUMP=$xpath/llvm-objdump$cclm
        READELF=$xpath/llvm-readelf$cclm
        OBJSIZE=$xpath/llvm-size$cclm
        STRIP=$xpath/llvm-strip$cclm"
if grep -q debian /etc/os-release ; then CLANG="CC=gcc-13" ; fi


if [ -z $xtc ] ; then xtc=no ; fi
if [ $xtc = clang ] ; then
CLANG="CC=$xpath/clang
        HOSTCC=$xpath/clang
        AR=$xpath/llvm-ar
        NM=$xpath/llvm-nm
        OBJCOPY=$xpath/llvm-objcopy
        OBJDUMP=$xpath/llvm-objdump
        READELF=$xpath/llvm-readelf
        OBJSIZE=$xpath/llvm-size
        STRIP=$xpath/llvm-strip"
        fi

tc=gcc
if [ $tc = clang ] ; then
clang="CC=$(which clang)
        HOSTCC=$(which clang)
        AR=llvm-ar$cclm
        NM=llvm-nm$cclm
        OBJCOPY=llvm-objcopy$cclm
        OBJDUMP=llvm-objdump$cclm
        READELF=llvm-readelf$cclm
        OBJSIZE=llvm-size$cclm
        STRIP=llvm-strip$cclm"
        fi

ld=lld
if [ $ld = lld ] ; then
if [ -e /home/$himri/TOOLCHAIN/clang ] ; then
xpath=/home/$himri/TOOLCHAIN/clang/bin
LD="LD=$xpath/ld.lld"
else
LD="LD=ld.lld$cclm"
fi
fi

THREADS=-j$(nproc --all)

xcpu=$(if lscpu | grep -qi intel ; then echo " ibpb=off kvm-intel.vmentry_l1d_flush=never mds=off noibrs nopti l1tf=off kvm-intel.nested=1 intel_iommu=on,igfx_off tsx=on intel_pstate=hwp_only" ; elif lscpu | grep -qi amd ; then echo " mds=off noibrs nopti l1tf=off ibpb=off amd_iommu=pgtbl_v2 kvm-amd.avic=1 amd_iommu_intr=vapic amd_pstate=passive" ; fi)

bls=no
if [ $bls = yes ] || grep -q thanas /etc/rc.local ; then
#if [ $bls = yes ] ; then
sudo sed -i 's/CONFIG_CMDLINE_BOOL=.*/# CONFIG_CMDLINE_BOOL is not set/g' $PWD/config
sudo sed -i 's/CONFIG_CMDLINE=.*/# CONFIG_CMDLINE is not set/g' $PWD/config
elif grep -q "# CONFIG_CMDLINE is not set" $PWD/config ; then sudo sed -i 's/# CONFIG_CMDLINE is not set/CONFIG_CMDLINE="rcu_nocbs=0'"$xcpu"' align_va_addr=on idle=nomwait clocksource=tsc tsc=reliable nohz=on skew_tick=1 audit=0 noreplace-smp nowatchdog cgroup_no_v1=all irqaffinity=0 iommu.strict=0 novmcoredd iommu=force,pt edd=on iommu.forcedac=1 hugetlb_free_vmemmap=on apm=on cec_disable cpu_init_udelay=1000 tp_printk_stop_on_boot nohpet clk_ignore_unused gbpages rootflags=noatime libata.force=ncq,dma,nodmalog,noiddevlog,nodirlog,lpm,setxfer enable_mtrr_cleanup pcie_aspm=force pcie_aspm.policy=performance pstore.backend=null cpufreq.default_governor=performance reboot=warm stack_depot_disable=true"/g' $PWD/$defconfig ; fi

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
 # debian/arch 
 if [ -e /lib/ld-linux-x86-64.so.2 ] ; then x86=/lib/ld-linux-x86-64.so.2 ; elif [ -e /usr/lib64/ld-linux-x86-64.so.2 ] ; then x86=/usr/lib64/ld-linux-x86-64.so.2 ; fi
if grep -q "CONFIG_NFT_FLOW_OFFLOAD is not set" $PWD/config ; then sed -i 's/# CONFIG_NFT_FLOW_OFFLOAD.*/CONFIG_NFT_FLOW_OFFLOAD=y/g' $PWD/config ; fi
#if lscpu | grep -qi intel ; then sudo sed -i 's/# CONFIG_MNATIVE_INTEL.*/CONFIG_MNATIVE_INTEL=y/g' $PWD/config ; fi
#if lscpu | grep -qi amd ; then sudo sed -i 's/# CONFIG_MNATIVE_AMD.*/CONFIG_MNATIVE_AMD=y/g' $PWD/config ; fi
  if grep -q "CONFIG_GENERIC_CPU=y" $PWD/.config ; then sudo sed -i 's/CONFIG_GENERIC_CPU=y/# CONFIG_GENERIC_CPU is not set/g' $PWD/.config ; fi
  
  if $x86 --help | grep -q "v4 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU4.*/CONFIG_GENERIC_CPU4=y/g' $PWD/config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/$defconfig
elif $x86 --help | grep -q "v3 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU3.*/CONFIG_GENERIC_CPU3=y/g' $PWD/config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/$defconfig  
elif $x86 --help | grep -q "v2 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU2.*/CONFIG_GENERIC_CPU2=y/g' $PWD/config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/$defconfig  
else sudo sed -i 's/# CONFIG_MCORE2.*/CONFIG_MCORE2=y/g' $PWD/config    
  fi
grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;

sudo cp $PWD/$defconfig $PWD/.config

Keys.ENTER | sudo make $CLANG $LD localmodconfig

#make xconfig

if grep -q "CONFIG_SND_HDA is not set" $PWD/.config  ; then sudo sed -i 's/# CONFIG_SND_HDA is not set/CONFIG_SND_HDA=y/g' $PWD/.config ; fi
if grep -q "CONFIG_SND_USB is not set" $PWD/.config  ; then sudo sed -i 's/# CONFIG_SND_USB is not set/CONFIG_SND_USB=y/g' $PWD/.config ; fi
if grep -q "CONFIG_SND_USB_AUDIO is not set" $PWD/.config  ; then sudo sed -i 's/# CONFIG_SND_USB_AUDIO is not set/CONFIG_SND_USB_AUDIO=y/g' $PWD/.config ; fi
if grep -q CONFIG_INIT_ENV_ARG_LIMIT $PWD/.config ; then sudo sed -i 's/CONFIG_INIT_ENV_ARG_LIMIT=.*/CONFIG_INIT_ENV_ARG_LIMIT=128/g' $PWD/.config ; fi
if grep -q CONFIG_HAVE_KERNEL_GZIP $PWD/.config ; then sudo sed -i 's/CONFIG_HAVE_KERNEL_GZIP=.*/CONFIG_HAVE_KERNEL_GZIP=n/g' $PWD/.config ; fi
if grep -q CONFIG_HAVE_KERNEL_BZIP2 $PWD/.config ; then sudo sed -i 's/CONFIG_HAVE_KERNEL_BZIP2=.*/CONFIG_HAVE_KERNEL_BZIP2=n/g' $PWD/.config ; fi
if grep -q CONFIG_HAVE_KERNEL_LZMA $PWD/.config ; then sudo sed -i 's/CONFIG_HAVE_KERNEL_LZMA=.*/CONFIG_HAVE_KERNEL_LZMA=n/g' $PWD/.config ; fi
if grep -q CONFIG_HAVE_KERNEL_LZO $PWD/.config ; then sudo sed -i 's/CONFIG_HAVE_KERNEL_LZO=.*/CONFIG_HAVE_KERNEL_LZO=n/g' $PWD/.config ; fi
if grep -q CONFIG_HAVE_KERNEL_XZ $PWD/.config ; then sudo sed -i 's/CONFIG_HAVE_KERNEL_XZ=.*/CONFIG_HAVE_KERNEL_XZ=n/g' $PWD/.config ; fi
if grep -q CONFIG_CONTEXT_TRACKING $PWD/.config ; then sudo sed -i 's/CONFIG_CONTEXT_TRACKING=.*/CONFIG_CONTEXT_TRACKING=n/g' $PWD/.config ; fi
if grep -q CONFIG_CONTEXT_TRACKING_IDLE $PWD/.config ; then sudo sed -i 's/CONFIG_CONTEXT_TRACKING_IDLE=.*/CONFIG_CONTEXT_TRACKING_IDLE=n/g' $PWD/.config ; fi
if grep -q CONFIG_CONTEXT_TRACKING_USER $PWD/.config ; then sudo sed -i 's/CONFIG_CONTEXT_TRACKING_USER=.*/CONFIG_CONTEXT_TRACKING_USER=n/g' $PWD/.config ; fi
if ! grep -q CONFIG_BPF_JIT_ALWAYS_ON=y  $PWD/.config ; then echo "CONFIG_BPF_JIT_ALWAYS_ON=y" | sudo tee -a $PWD/.config ; fi
if ! grep -q CONFIG_BPF_LSM=y $PWD/.config ; then echo "CONFIG_BPF_LSM=y" | sudo tee -a $PWD/.config ; fi
sudo sed -i 's/CONFIG_VIRT_CPU_ACCOUNTING=.*/CONFIG_VIRT_CPU_ACCOUNTING=n/g' $PWD/.config
sudo sed -i 's/CONFIG_VIRT_CPU_ACCOUNTING_GEN=.*/CONFIG_VIRT_CPU_ACCOUNTING_GEN=n/g' $PWD/.config
echo CONFIG_BPF_JIT_ALWAYS_ON=y | sudo tee -a $PWD/.config
sudo sed -i 's/CONFIG_HPET_TIMER=.*/CONFIG_HPET_TIMER=n/g' $PWD/.config
sudo sed -i 's/CONFIG_HAVE_LIVEPATCH=.*/CONFIG_HAVE_LIVEPATCH=n/g' $PWD/.config
echo CONFIG_HAVE_EBPF_JIT=y | sudo tee -a $PWD/.config
sudo sed -i 's/CONFIG_HAVE_PERF_EVENTS=.*/CONFIG_HAVE_PERF_EVENTS=n/g' $PWD/.config
sudo sed -i 's/CONFIG_GUEST_PERF_EVENTS=.*/CONFIG_GUEST_PERF_EVENTS=n/g' $PWD/.config
sudo sed -i 's/CONFIG_PERF_EVENTS=.*/CONFIG_PERF_EVENTS=n/g' $PWD/.config
sudo sed -i 's/CONFIG_SCHED_INFO=.*/CONFIG_SCHED_INFO=n/g' $PWD/.config
if ! grep -q CONFIG_NFT_FLOW_OFFLOAD=y $PWD/.config ; then echo CONFIG_NFT_FLOW_OFFLOAD=y | sudo tee -a $PWD/.config ; fi

#sudo sed -i 's/.*//g' $PWD/.config
#sudo sed -i 's/.*//g' $PWD/.config
#sudo sed -i 's/.*//g' $PWD/.config
#sudo sed -i 's/.*//g' $PWD/.config
#sudo sed -i 's/.*//g' $PWD/.config





#if [ -e /boot/EFI ] || [ -e /efi ] || [ -e /boot/efi/EFI ] ; then echo " " ; else 
#if grep -q " is not set" $PWD/.config ; then sudo sed -i 's/#  is not =y/g' $PWD/.config ; else
#echo "=y" | sudo tee -a $PWD/.config ; fi ; fi


if grep -q "CONFIG_NFT_FLOW_OFFLOAD is not set" $PWD/.config ; then sed -i 's/# CONFIG_NFT_FLOW_OFFLOAD.*/CONFIG_NFT_FLOW_OFFLOAD=y/g' $PWD/.config 
elif ! grep -q CONFIG_NFT_OFFLOAD $PWD/.config ; then echo 'CONFIG_NFT_FLOW_OFFLOAD=y' | sudo tee -a $PWD/.config ; fi

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
  if grep -q "CONFIG_GENERIC_CPU=y" $PWD/.config ; then sudo sed -i 's/CONFIG_GENERIC_CPU=y/# CONFIG_GENERIC_CPU is not set/g' $PWD/.config ; fi

#if lscpu | grep -qi intel ; then sudo sed -i 's/# CONFIG_MNATIVE_INTEL.*/CONFIG_MNATIVE_INTEL=y/g' $PWD/config ; fi
#if lscpu | grep -qi amd ; then sudo sed -i 's/# CONFIG_MNATIVE_AMD.*/CONFIG_MNATIVE_AMD=y/g' $PWD/config ; fi
  # these are now overriden by march=native since kernel meant to be compiled locally anyway
  if $x86 --help | grep -q "v4 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU4.*/CONFIG_GENERIC_CPU4=y/g' $PWD/.config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/.config 
elif $x86 --help | grep -q "v3 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU3.*/CONFIG_GENERIC_CPU3=y/g' $PWD/.config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/.config  
elif $x86 --help | grep -q "v2 (supported" ; then sudo sed -i 's/# CONFIG_GENERIC_CPU2.*/CONFIG_GENERIC_CPU2=y/g' $PWD/.config ; sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/.config  
else sudo sed -i 's/# CONFIG_MCORE2.*/CONFIG_MCORE2=y/g' $PWD/.config    
  fi
  
if [ $buildforperformance = no ] ; then sudo sed -i 's/ibpb=off kvm-intel.vmentry_l1d_flush=never mds=off noibrs nopti l1tf=off//g' $PWD/.config
  
if [ $CANYOUBOOT = no ] ; then if ! grep -q CONFIG_RETPOLINE $PWD/.config ; then echo CONFIG_RETPOLINE=y | sudo tee -a $PWD/.config ; else sudo sed -i 's/# CONFIG_RETPOLINE.*/CONFIG_RETPOLINE=y/g' $PWD/.config ; fi ; fi

if ! grep -q CONFIG_STACKDEPOT $PWD/.config ; then echo CONFIG_STACKDEPOT=n | sudo tee -a $PWD/.config ; else sudo sed -i 's/CONFIG_STACKDEPOT=y/CONFIG_STACKDEPOT=n/g' $PWD/.config ; fi 

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config 


Keys.ENTER | sudo make $THREADS $VERBOSE $CLANG $LD
Keys.ENTER | sudo make $THREADS $VERBOSE $CLANG $LD modules

cd $source
#./extras.sh

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config ;
if grep -q "CONFIG_GENERIC_CPU=y" $PWD/.config ; then sudo sed -i 's/CONFIG_GENERIC_CPU=y/# CONFIG_GENERIC_CPU is not set/g' $PWD/.config ; fi
if grep -q "CONFIG_MNATIVE_INTEL=y" $PWD/config ; then sudo sed -i 's/CONFIG_MNATIVE_INTEL=y/# CONFIG_MNATIVE_INTEL is not set/g' $PWD/config ; fi
if grep -q "CONFIG_MNATIVE_AMD=y" $PWD/config ; then sudo sed -i 's/CONFIG_MNATIVE_AMD=y/# CONFIG_MNATIVE_AMD is not set/g' $PWD/config ; fi
if grep -q "CONFIG_GENERIC_CPU4=y" $PWD/config ; then sudo sed -i 's/CONFIG_GENERIC_CPU4=y/# CONFIG_GENERIC_CPU4 is not set/g' $PWD/config ; fi
if grep -q "CONFIG_GENERIC_CPU3=y" $PWD/config ; then sudo sed -i 's/CONFIG_GENERIC_CPU3=y/# CONFIG_GENERIC_CPU3 is not set/g' $PWD/config ; fi
if grep -q "CONFIG_GENERIC_CPU2=y" $PWD/config ; then sudo sed -i 's/CONFIG_GENERIC_CPU2=y/# CONFIG_GENERIC_CPU2 is not set/g' $PWD/config ; fi
if grep -q "/CONFIG_MCORE2=y" $PWD/config ; then sudo sed -i 's/CONFIG_MCORE2=y/# CONFIG_MCORE2 is not set/g' $PWD/config ; fi
if grep -q "# CONFIG_CMDLINE_BOOL is not set" $PWD/config ; then sudo sed -i 's/# CONFIG_CMDLINE_BOOL is not set/CONFIG_CMDLINE_BOOL=y/g' $PWD/config ; fi
if grep -q "# CONFIG_CMDLINE is not set" $PWD/config ; then sudo sed -i 's/# CONFIG_CMDLINE is not set/CONFIG_CMDLINE="rcu_nocbs=0'"$(if [ $buildforperformance = yes ] ; then echo " ibpb=off kvm-intel.vmentry_l1d_flush=never mds=off noibrs nopti l1tf=off" ; fi)"' kvm-intel.nested=1 intel_iommu=on,igfx_off tsx=on intel_pstate=hwp_only amd_iommu=pgtbl_v2 kvm-amd.avic=1 amd_iommu_intr=vapic amd_pstate=passive align_va_addr=on idle=nomwait clocksource=tsc tsc=reliable nohz=on skew_tick=1 audit=0 noreplace-smp nowatchdog cgroup_no_v1=all irqaffinity=0 iommu.strict=0 novmcoredd iommu=force,pt edd=on iommu.forcedac=1 hugetlb_free_vmemmap=on apm=on cec_disable cpu_init_udelay=1000 tp_printk_stop_on_boot nohpet clk_ignore_unused gbpages rootflags=noatime libata.force=ncq,dma,nodmalog,noiddevlog,nodirlog,lpm,setxfer enable_mtrr_cleanup pcie_aspm=force pcie_aspm.policy=performance pstore.backend=null cpufreq.default_governor=performance reboot=warm stack_depot_disable=true"/g' $PWD/config ; fi

grep CONFIG_GENERIC_CPU $PWD/.config $PWD/config 

systemd-machine-id-setup >/dev/null ; if [ $? = 0 ] ; then 
if [ ! -e /usr/sbin/bls-schedlatency.bash ] ; then
echo '[Unit]
Description=Set sched_latency_ns in accordance with basic-linux-setup
After=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target

[Service]
User=root
ExecStart=/usr/sbin/bls-schedlatency.bash
Type=simple
Restart=always
Environment="DISPLAY=:0"
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target suspend.target hibernate.target hybrid-sleep.target suspend-then-hibernate.target' | sudo tee /usr/lib/systemd/system/bls-schedlatency.service

echo '#!/bin/bash
if [ -e /sys/kernel/debug/sched/latency_ns ] 
then
echo 40000 > /sys/kernel/debug/sched/latency_ns 
elif [ -e /proc/sys/kernel/sched_latency_ns ] 
then 
echo 40000 > /proc/sys/kernel/sched_latency_ns
fi' | sudo tee /usr/sbin/bls-schedlatency.bash
sudo chmod +x /usr/sbin/bls-schedlatency.bash
sudo systemctl enable bls-schedlatency
sudo systemctl start bls-schedlatency
fi
fi

if [ -e $source/arch/x86/boot/vmlinux.bin ] ; then
sudo make $THREADS modules_install
sudo make $THREADS install
#DRACUT_KMODDIR_OVERRIDE=1
sudo cp $PWD/arch/x86/boot/bzImage /boot/vmlinuz-"${KERNELVERSION}"
sudo dracut -f -v /boot/initramfs-"${KERNELVERSION}".img "${KERNELVERSION}"
#sudo kernel-install add /boot/initramfs-"${KERNELVERSION}".img /boot/vmlinuz-"${KERNELVERSION}"
#dracut --version ; if [ $? = 0 ] ; then 
sudo dracut --regenerate-all -f --lz4$(if [ -e /boot/efi ] || [ -e /efi ] || [ -e /boot/EFI ] ; then echo " --uefi" ; fi) 
#else
cd /boot
sudo mkinitramfs -ko initrd.img-"${KERNELVERSION}" "${KERNELVERSION}"
cd $PWD
#fi
#sudo refind-install ; sudo refind-mkdefault
sudo sed -i 's/timeout .*/timeout 1/g' /boot/EFI/refind/refind.conf
#sudo bootctl install
#sudo bootctl update
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

### reopen menu
#./0*





###### END
