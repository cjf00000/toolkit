PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

BIN = $(PROJECT)/bin
SRC = $(PROJECT)/src
TEST = $(PROJECT)/test
THIRD_PARTY = $(PROJECT)/third_party
THIRD_PARTY_SRC = $(THIRD_PARTY)/src
THIRD_PARTY_LIB = $(THIRD_PARTY)/lib
THIRD_PARTY_INCLUDE = $(THIRD_PARTY)/include
THIRD_PARTY_HOST = https://github.com/xunzheng/third_party/raw/master

NEED_MKDIR = $(BIN) $(THIRD_PARTY_SRC)

CXX = g++
CXXFLAGS = -g -O2 -std=c++11 -fno-omit-frame-pointer
INCFLAGS = -I$(SRC) -I$(THIRD_PARTY_INCLUDE) 
LDFLAGS = -L$(THIRD_PARTY_LIB) -pthread -lgflags -lglog

# ===================== rules =====================

all: $(NEED_MKDIR) libraries

#libraries: gflags glog gtest zmq boost gperftools tbb oprofile sparsehash
libraries: gflags glog gtest

$(NEED_MKDIR):
	mkdir -p $@

clean: 
	rm -rf $(BIN)/*

distclean: clean
	rm -rf $(THIRD_PARTY)

.PHONY: libraries

include $(TEST)/test.mk

# ===================== gflags ===================

GFLAGS_SRC = $(THIRD_PARTY_SRC)/gflags.tar.gz
GFLAGS_LIB = $(THIRD_PARTY_LIB)/libgflags.a

gflags: $(GFLAGS_LIB)

$(GFLAGS_LIB): $(GFLAGS_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/gflags-2.0; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make install

$(GFLAGS_SRC):
	wget $(THIRD_PARTY_HOST)/gflags-2.0-no-svn-files.tar.gz -O $@

# ===================== glog =====================

GLOG_SRC = $(THIRD_PARTY_SRC)/glog.tar.gz
GLOG_LIB = $(THIRD_PARTY_LIB)/libglog.a

glog: $(GLOG_LIB)

$(GLOG_LIB): $(GLOG_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/glog-0.3.3; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make install

$(GLOG_SRC):
	wget $(THIRD_PARTY_HOST)/glog-0.3.3.tar.gz -O $@

# ===================== gtest ====================

GTEST_SRC = $(THIRD_PARTY_SRC)/gtest.zip
GTEST_LIB = $(THIRD_PARTY_LIB)/libgtest_main.a

gtest: $(GTEST_LIB)

$(GTEST_LIB): $(GTEST_SRC)
	unzip $< -d $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/gtest-1.7.0/make; \
	make; \
	./sample1_unittest; \
	cp -r ../include/* $(THIRD_PARTY_INCLUDE)/; \
	cp gtest_main.a $@

$(GTEST_SRC):
	wget $(THIRD_PARTY_HOST)/gtest-1.7.0.zip -O $@

# ===================== zmq =====================

ZMQ_SRC = $(THIRD_PARTY_SRC)/zmq.tar.gz
ZMQ_LIB = $(THIRD_PARTY_LIB)/libzmq.a

zmq: $(ZMQ_LIB)

$(ZMQ_LIB): $(ZMQ_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/zeromq-3.2.3; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make install

$(ZMQ_SRC):
	wget $(THIRD_PARTY_HOST)/zeromq-3.2.3.tar.gz -O $@
	wget $(THIRD_PARTY_HOST)/zmq.hpp -P $(THIRD_PARTY_INCLUDE)

# ==================== boost ====================

BOOST_SRC = $(THIRD_PARTY_SRC)/boost.tar.bz2
BOOST_INCLUDE = $(THIRD_PARTY_INCLUDE)/boost

boost: $(BOOST_INCLUDE)

$(BOOST_INCLUDE): $(BOOST_SRC)
	tar jxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/boost_1_54_0; \
	./bootstrap.sh --with-libraries=system,thread --prefix=$(THIRD_PARTY); \
	./b2 install

$(BOOST_SRC):
	wget $(THIRD_PARTY_HOST)/boost_1_54_0.tar.bz2 -O $@

# ================== gperftools =================

GPERFTOOLS_SRC = $(THIRD_PARTY_SRC)/gperftools.tar.gz
GPERFTOOLS_LIB = $(THIRD_PARTY_LIB)/libtcmalloc.a

gperftools: $(GPERFTOOLS_LIB)

$(GPERFTOOLS_LIB): $(GPERFTOOLS_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/gperftools-2.1; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY) --enable-frame-pointers; \
	make install

$(GPERFTOOLS_SRC):
	wget $(THIRD_PARTY_HOST)/gperftools-2.1.tar.gz -O $@

# ===================== tbb =====================

TBB_SRC = $(THIRD_PARTY_SRC)/tbb.tgz
TBB_LIB = $(THIRD_PARTY_LIB)/libtbb.so

tbb: $(TBB_LIB)

$(TBB_LIB): $(TBB_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/tbb42_20131118oss; \
	make; \
	cp build/*_release/lib* $(THIRD_PARTY_LIB)/; \
	cp -r include/tbb $(THIRD_PARTY_INCLUDE)/

$(TBB_SRC):
	wget $(THIRD_PARTY_HOST)/tbb42_20131118oss_src.tgz -O $@

# =================== oprofile ===================

OPROFILE_SRC = $(THIRD_PARTY_SRC)/oprofile.tar.gz
OPROFILE_LIB = $(THIRD_PARTY_LIB)/oprofile

oprofile: $(OPROFILE_LIB)

$(OPROFILE_LIB): $(OPROFILE_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/oprofile-0.9.9; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make install

$(OPROFILE_SRC):
	wget $(THIRD_PARTY_HOST)/oprofile-0.9.9.tar.gz -O $@

# ================== sparsehash ==================

SPARSEHASH_SRC = $(THIRD_PARTY_SRC)/sparsehash.tar.gz
SPARSEHASH_INCLUDE = $(THIRD_PARTY_INCLUDE)/sparsehash

sparsehash: $(SPARSEHASH_INCLUDE)

$(SPARSEHASH_INCLUDE): $(SPARSEHASH_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/sparsehash-2.0.2; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make install

$(SPARSEHASH_SRC):
	wget $(THIRD_PARTY_HOST)/sparsehash-2.0.2.tar.gz -O $@

