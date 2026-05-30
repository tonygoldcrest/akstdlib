ENTRY    = testEntry
DIST     = dist
LIB_SRCS = $(wildcard lib/*.s)
LIB_OBJS = $(patsubst lib/%.s, $(DIST)/%.o, $(LIB_SRCS))
SDK      = $(shell xcrun -sdk macosx --show-sdk-path)

all: $(DIST)/$(ENTRY)

$(DIST):
	mkdir -p $(DIST)

$(DIST)/libakstd.a: $(LIB_OBJS) | $(DIST)
	ar rcs $@ $(LIB_OBJS)

$(DIST)/$(ENTRY): $(DIST)/$(ENTRY).o $(DIST)/libakstd.a
	ld -o $@ $(DIST)/$(ENTRY).o -L$(DIST) -lakstd \
		-lSystem \
		-syslibroot $(SDK) \
		-e _main \
		-arch arm64

$(DIST)/%.o: lib/%.s | $(DIST)
	as -g -o $@ $<

$(DIST)/%.o: %.s | $(DIST)
	as -g -o $@ $<

clean:
	rm -rf $(DIST)

.PHONY: all clean
