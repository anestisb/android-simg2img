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

CC      ?= gcc
LD      ?= gcc
DEP_CC  ?= gcc
AR      ?= ar
RANLIB  ?= ranlib
STRIP   ?= strip
CFLAGS  += -O2 -Wall -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE=1

# libsparse
LIB_NAME = sparse
SLIB     = lib$(LIB_NAME).a
LIB_SRCS = \
    backed_block.c \
    output_file.c \
    sparse.c \
    sparse_crc32.c \
    sparse_err.c \
    sparse_read.c
LIB_OBJS = $(LIB_SRCS:%.c=%.o)
LIB_INCS = -Iinclude

LDFLAGS += -L. -l$(LIB_NAME) -lm -lz

# simg2img
SIMG2IMG_SRCS = simg2img.c
SIMG2IMG_OBJS = $(SIMG2IMG_SRCS:%.c=%.o)

# simg2simg
SIMG2SIMG_SRCS = simg2simg.c
SIMG2SIMG_OBJS = $(SIMG2SIMG_SRCS:%.c=%.o)

# img2simg
IMG2SIMG_SRCS = $(LIBSPARSE_SRCS) img2simg.c
IMG2SIMG_OBJS = $(IMG2SIMG_SRCS:%.c=%.o)

# append2simg
APPEND2SIMG_SRCS = $(LIBSPARSE_SRCS) append2simg.c
APPEND2SIMG_OBJS = $(APPEND2SIMG_SRCS:%.c=%.o)

SRCS = \
    $(SIMG2IMG_SRCS) \
    $(SIMG2SIMG_SRCS) \
    $(IMG2SIMG_SRCS) \
    $(APPEND2SIMG_SRCS) \
    $(LIB_SRCS)

.PHONY: default all clean

default: all
all: $(LIB_NAME) simg2img simg2simg img2simg append2simg

$(LIB_NAME): $(LIB_OBJS)
		$(AR) rc $(SLIB) $(LIB_OBJS)
		$(RANLIB) $(SLIB)

simg2img: $(SIMG2IMG_SRCS)
		$(CC) $(CFLAGS) $(LIB_INCS) -o simg2img $< $(LDFLAGS)

simg2simg: $(SIMG2SIMG_SRCS)
		$(CC) $(CFLAGS) $(LIB_INCS) -o simg2simg $< $(LDFLAGS)

img2simg: $(IMG2SIMG_SRCS)
		$(CC) $(CFLAGS) $(LIB_INCS) -o img2simg $< $(LDFLAGS)

append2simg: $(APPEND2SIMG_SRCS)
		$(CC) $(CFLAGS) $(LIB_INCS) -o append2simg $< $(LDFLAGS)

%.o: %.c .depend
		$(CC) -c $(CFLAGS) $(LIB_INCS) $< -o $@

clean:
		$(RM) -f *.o *.a simg2img simg2simg img2simg append2simg .depend

ifneq ($(wildcard .depend),)
include .depend
endif

.depend:
		@$(RM) .depend
		@$(foreach SRC, $(SRCS), $(DEP_CC) $(LIB_INCS) $(SRC) $(CFLAGS) -MT $(SRC:%.c=%.o) -MM >> .depend;)

indent:
		indent -linux -l100 -lc100 -nut -i4 *.c *.h; rm -f *~
