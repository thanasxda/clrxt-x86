# SPDX-License-Identifier: GPL-2.0
include ../scripts/Makefile.include
include ../scripts/Makefile.arch

ifeq ($(srctree),)
srctree := $(patsubst %/,%,$(dir $(CURDIR)))
srctree := $(patsubst %/,%,$(dir $(srctree)))
endif

MAKE = make -S
LIBSUBCMD_DIR = $(srctree)/tools/lib/subcmd/
ifneq ($(OUTPUT),)
  LIBSUBCMD_OUTPUT = $(abspath $(OUTPUT))/libsubcmd
else
  LIBSUBCMD_OUTPUT = $(CURDIR)/libsubcmd
endif
LIBSUBCMD_DESTDIR = $(LIBSUBCMD_OUTPUT)
LIBSUBCMD = $(LIBSUBCMD_OUTPUT)/libsubcmd.a
CFLAGS += -I$(LIBSUBCMD_OUTPUT)/include

OBJTOOL    := $(OUTPUT)objtool
OBJTOOL_IN := $(OBJTOOL)-in.o

LIBELF_FLAGS := $(shell $(HOSTPKG_CONFIG) libelf --cflags 2>/dev/null)
LIBELF_LIBS  := $(shell $(HOSTPKG_CONFIG) libelf --libs 2>/dev/null || echo -lelf)

all: $(OBJTOOL)

INCLUDES := -I$(srctree)/tools/include \
	    -I$(srctree)/tools/arch/$(HOSTARCH)/include/uapi \
	    -I$(srctree)/tools/arch/$(SRCARCH)/include	\
	    -I$(srctree)/tools/objtool/include \
	    -I$(srctree)/tools/objtool/arch/$(SRCARCH)/include \
	    -I$(LIBSUBCMD_OUTPUT)/include
WARNINGS := $(EXTRA_WARNINGS) -Wno-switch-default -Wno-switch-enum -Wno-packed -Wno-nested-externs
OBJTOOL_CFLAGS := -Werror $(WARNINGS) -g $(INCLUDES) $(LIBELF_FLAGS) $(HOSTCFLAGS)
OBJTOOL_LDFLAGS := $(LIBELF_LIBS) $(LIBSUBCMD)

# Allow old libelf to be used:
elfshdr := $(shell echo '$(pound)include <libelf.h>' | $(CC) $(CFLAGS) -x c -E - | grep elf_getshdr)
OBJTOOL_CFLAGS += $(if $(elfshdr),,-DLIBELF_USE_DEPRECATED)

# Always want host compilation.
HOST_OVERRIDES := CC="$(HOSTCC)" EXTRA_CFLAGS="$(OBJTOOL_CFLAGS)" \
		  LD="$(HOSTLD)" AR="$(HOSTAR)"
BUILD_HOST_OVERRIDES := CC="$(HOSTCC)" CFLAGS="$(OBJTOOL_CFLAGS)" \
			LD="$(HOSTLD)" LDFLAGS="$(OBJTOOL_LDFLAGS)" \
			AR="$(HOSTAR)"

AWK = awk
MKDIR = mkdir

ifeq ($(V),1)
  Q =
else
  Q = @
endif

BUILD_ORC := n

ifeq ($(SRCARCH),x86)
	BUILD_ORC := y
endif

export BUILD_ORC
export srctree OUTPUT CFLAGS SRCARCH AWK
include $(srctree)/tools/build/Makefile.include

$(OBJTOOL_IN): fixdep FORCE
	$(Q)$(CONFIG_SHELL) ./sync-check.sh
	$(Q)$(MAKE) $(build)=objtool $(BUILD_HOST_OVERRIDES)


$(OBJTOOL): $(LIBSUBCMD) $(OBJTOOL_IN)
	$(QUIET_LINK)$(HOSTCC) $(OBJTOOL_IN) $(KBUILD_HOSTLDFLAGS) $(OBJTOOL_LDFLAGS) -o $@


$(LIBSUBCMD_OUTPUT):
	$(Q)$(MKDIR) -p $@

$(LIBSUBCMD): fixdep FORCE $(LIBSUBCMD_OUTPUT)
	$(Q)$(MAKE) -C $(LIBSUBCMD_DIR) O=$(LIBSUBCMD_OUTPUT) \
		DESTDIR=$(LIBSUBCMD_DESTDIR) prefix= subdir= \
		$(HOST_OVERRIDES) \
		$@ install_headers

$(LIBSUBCMD)-clean:
	$(call QUIET_CLEAN, libsubcmd)
	$(Q)$(RM) -r -- $(LIBSUBCMD_OUTPUT)

clean: $(LIBSUBCMD)-clean
	$(call QUIET_CLEAN, objtool) $(RM) $(OBJTOOL)
	$(Q)find $(OUTPUT) -name '*.o' -delete -o -name '\.*.cmd' -delete -o -name '\.*.d' -delete
	$(Q)$(RM) $(OUTPUT)arch/x86/lib/inat-tables.c $(OUTPUT)fixdep

FORCE:

.PHONY: clean FORCE
