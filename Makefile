#
# Copyright (C) 2014 Anestis Bechtsoudis
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
PREFIX  ?= /usr/local

CXX      ?= g++
LD       ?= g++
DEP_CXX  ?= g++
AR       ?= ar
RANLIB   ?= ranlib
STRIP    ?= strip
CPPFLAGS += -std=gnu++17 -O2 -W -Wall -Werror -Wextra \
    -D__STDC_FORMAT_MACROS -D__STDC_CONSTANT_MACROS

# libsparse
LIB_NAME = sparse
SLIB     = lib$(LIB_NAME).a
LIB_SRCS = \
    backed_block.cpp \
    output_file.cpp \
    sparse.cpp \
    sparse_crc32.cpp \
    sparse_err.cpp \
    sparse_read.cpp \
    android-base/stringprintf.cpp
LIB_OBJS = $(LIB_SRCS:%.cpp=%.o)
LIB_INCS = -Iinclude -Iandroid-base/include

LDFLAGS += -L. -l$(LIB_NAME) -lm -lz

BINS = simg2img simg2simg img2simg append2simg
HEADERS = include/sparse/sparse.h

# simg2img
SIMG2IMG_SRCS = simg2img.cpp
SIMG2IMG_OBJS = $(SIMG2IMG_SRCS:%.cpp=%.o)

# simg2simg
SIMG2SIMG_SRCS = simg2simg.cpp
SIMG2SIMG_OBJS = $(SIMG2SIMG_SRCS:%.cpp=%.o)

# img2simg
IMG2SIMG_SRCS = img2simg.cpp
IMG2SIMG_OBJS = $(IMG2SIMG_SRCS:%.cpp=%.o)

# append2simg
APPEND2SIMG_SRCS = append2simg.cpp
APPEND2SIMG_OBJS = $(APPEND2SIMG_SRCS:%.cpp=%.o)

SRCS = \
    $(SIMG2IMG_SRCS) \
    $(SIMG2SIMG_SRCS) \
    $(IMG2SIMG_SRCS) \
    $(APPEND2SIMG_SRCS) \
    $(LIB_SRCS)

.PHONY: default all clean install

default: all
all: $(LIB_NAME) simg2img simg2simg img2simg append2simg

install: all
	install -d $(PREFIX)/bin $(PREFIX)/lib $(PREFIX)/include/sparse
	install -m 0755 $(BINS) $(PREFIX)/bin
	install -m 0755 $(SLIB) $(PREFIX)/lib
	install -m 0644 $(HEADERS) $(PREFIX)/include/sparse

$(LIB_NAME): $(LIB_OBJS)
		$(AR) rc $(SLIB) $(LIB_OBJS)
		$(RANLIB) $(SLIB)

simg2img: $(SIMG2IMG_SRCS) $(LIB_NAME)
		$(CXX) $(CPPFLAGS) $(LIB_INCS) -o simg2img $< $(LDFLAGS)

simg2simg: $(SIMG2SIMG_SRCS) $(LIB_NAME)
		$(CXX) $(CPPFLAGS) $(LIB_INCS) -o simg2simg $< $(LDFLAGS)

img2simg: $(IMG2SIMG_SRCS) $(LIB_NAME)
		$(CXX) $(CPPFLAGS) $(LIB_INCS) -o img2simg $< $(LDFLAGS)

append2simg: $(APPEND2SIMG_SRCS) $(LIB_NAME)
		$(CXX) $(CPPFLAGS) $(LIB_INCS) -o append2simg $< $(LDFLAGS)

%.o: %.cpp .depend
		$(CXX) $(CPPFLAGS) $(LIB_INCS) -c $< -o $@

clean:
		$(RM) -f *.o *.a simg2img simg2simg img2simg append2simg .depend

ifneq ($(wildcard .depend),)
include .depend
endif

.depend:
		@$(RM) .depend
		@$(foreach SRC, $(SRCS), $(DEP_CXX) $(LIB_INCS) $(SRC) $(CFLAGS) -MT $(SRC:%.c=%.o) -MM >> .depend;)

format:
		find . -regex '.*\.\(cpp\|hpp\|cc\|cxx\)' -exec clang-format -style=file -i {} \;
