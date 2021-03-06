SV = verilator

TARGET ?= refcpu/VTop

SV_PREFIX = VModel
SV_BUILD = $(BUILD_ROOT)/$(TARGET)/verilated# # build/gcc/refcpu/VTop/verilated
SV_ROOT := $(shell dirname $(TARGET))#        # refcpu. NOTE: builtin $(dir ...) will leave the final "/".
SV_NAME := $(notdir $(TARGET))#               # VTop
SV_MKFILE = $(SV_BUILD)/$(SV_PREFIX).mk#      # build/gcc/refcpu/VTop/verilated/VTop.mk
SV_VTOP = source/$(TARGET).sv#                # source/refcpu/VTop.sv

SV_FILES := \
	$(wildcard source/util/*) \
	$(wildcard source/ram/*) \
	$(wildcard source/include/*.svh) \
	$(shell find 'source/include/$(SV_ROOT)' -type f -name '*.svh') \
	$(shell find 'source/$(SV_ROOT)' -type f -name '*.sv')

SV_INCLUDES = \
	-y source/util/ \
	-y source/ram/ \
	-y source/include/ \
	-y source/$(SV_ROOT)/ \
	-y source/$(SV_ROOT)/*/

SV_WARNINGS = \
	-Wall -Wpedantic \
	-Wno-IMPORTSTAR
	# add warnings that you wanna ignore.

SV_FLAGS = \
	--cc -sv --relative-includes \
	--output-split 6000 \
	--trace-fst --trace-structs \
	--no-trace-params \
	--Mdir $(SV_BUILD) \
	--top-module $(SV_NAME) \
	--prefix $(SV_PREFIX) \
	$(SV_INCLUDES) \
	$(SV_WARNINGS)

ifeq ($(USE_CLANG), 1)
SV_FLAGS += -CFLAGS -stdlib=libc++
endif

$(SV_MKFILE): $(SV_FILES)
	@mkdir -p $(SV_BUILD)
	$(SV) $(SV_FLAGS) $(SV_VTOP)
	@touch $@

.PHONY: verilate

verilate: $(SV_MKFILE)
