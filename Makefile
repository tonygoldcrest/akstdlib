ENTRY           = testEntry
DIST            = dist

# macOS
MACOS_DIST      = $(DIST)/macos
MACOS_SDK       = $(shell xcrun -sdk macosx --show-sdk-path)
MACOS_LIB_SRCS  = $(wildcard lib/*.macos.s)
MACOS_LIB_OBJS  = $(patsubst lib/%.macos.s, $(MACOS_DIST)/%.o, $(MACOS_LIB_SRCS))

# Linux (ARM64 — Raspberry Pi 4)
LINUX_DIST            = $(DIST)/linux
LINUX_LIB_SRCS        = $(wildcard lib/*.linux.s)
LINUX_LIB_OBJS        = $(patsubst lib/%.linux.s, $(LINUX_DIST)/%.o, $(LINUX_LIB_SRCS))

# Linux debug
LINUX_DEBUG_DIST      = $(DIST)/linux-debug
LINUX_DEBUG_LIB_OBJS  = $(patsubst lib/%.linux.s, $(LINUX_DEBUG_DIST)/%.o, $(LINUX_LIB_SRCS))

.PHONY: all macos linux linux-debug clean

all: macos

macos: $(MACOS_DIST)/$(ENTRY)

linux: $(LINUX_DIST)/$(ENTRY)

linux-debug: $(LINUX_DEBUG_DIST)/$(ENTRY)

$(MACOS_DIST) $(LINUX_DIST) $(LINUX_DEBUG_DIST):
	mkdir -p $@

# macOS: assemble lib + entry
$(MACOS_DIST)/%.o: lib/%.macos.s | $(MACOS_DIST)
	as -g -o $@ $<

$(MACOS_DIST)/$(ENTRY).o: $(ENTRY).macos.s | $(MACOS_DIST)
	as -g -o $@ $<

# macOS: archive + link
$(MACOS_DIST)/libakstd.a: $(MACOS_LIB_OBJS) | $(MACOS_DIST)
	ar rcs $@ $^

$(MACOS_DIST)/$(ENTRY): $(MACOS_DIST)/$(ENTRY).o $(MACOS_DIST)/libakstd.a
	ld -o $@ $< -L$(MACOS_DIST) -lakstd \
		-lSystem \
		-syslibroot $(MACOS_SDK) \
		-e _main \
		-arch arm64

# Linux: assemble lib + entry (no debug info)
$(LINUX_DIST)/%.o: lib/%.linux.s | $(LINUX_DIST)
	as -o $@ $<

$(LINUX_DIST)/$(ENTRY).o: $(ENTRY).linux.s | $(LINUX_DIST)
	as -o $@ $<

# Linux: archive + link (no stdlib, strip all symbols)
$(LINUX_DIST)/libakstd.a: $(LINUX_LIB_OBJS) | $(LINUX_DIST)
	ar rcs $@ $^

$(LINUX_DIST)/$(ENTRY): $(LINUX_DIST)/$(ENTRY).o $(LINUX_DIST)/libakstd.a
	ld -o $@ $< -L$(LINUX_DIST) -lakstd \
		-e _start \
		-s

# Linux debug: assemble lib + entry (DWARF debug info for DAP)
$(LINUX_DEBUG_DIST)/%.o: lib/%.linux.s | $(LINUX_DEBUG_DIST)
	as -g -o $@ $<

$(LINUX_DEBUG_DIST)/$(ENTRY).o: $(ENTRY).linux.s | $(LINUX_DEBUG_DIST)
	as -g -o $@ $<

# Linux debug: archive + link (no stdlib, keep symbols + DWARF)
$(LINUX_DEBUG_DIST)/libakstd.a: $(LINUX_DEBUG_LIB_OBJS) | $(LINUX_DEBUG_DIST)
	ar rcs $@ $^

$(LINUX_DEBUG_DIST)/$(ENTRY): $(LINUX_DEBUG_DIST)/$(ENTRY).o $(LINUX_DEBUG_DIST)/libakstd.a
	ld -o $@ $< -L$(LINUX_DEBUG_DIST) -lakstd \
		-e _start

clean:
	rm -rf $(DIST)
