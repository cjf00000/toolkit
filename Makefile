PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

BIN = $(PROJECT)/bin
SRC = $(PROJECT)/src
TEST = $(PROJECT)/test
THIRD_PARTY = $(PROJECT)/third_party
THIRD_PARTY_SRC = $(THIRD_PARTY)/src
THIRD_PARTY_LIB = $(THIRD_PARTY)/lib
THIRD_PARTY_INCLUDE = $(THIRD_PARTY)/include
THIRD_PARTY_HOST = https://github.com/xunzheng/third_party/raw/master
BOOST_HOST = http://downloads.sourceforge.net/project/boost/boost/1.54.0
# boost is too heavy for git to host...

NEED_MKDIR = $(BIN) $(THIRD_PARTY_SRC)

CXX = g++
CXXFLAGS = -g -O2 -std=c++11 -fno-omit-frame-pointer
INCFLAGS = -I$(SRC) -I$(THIRD_PARTY_INCLUDE) 
LDFLAGS = -L$(THIRD_PARTY_LIB) -pthread -lgflags -lglog

# ===================== rules =====================

all: $(NEED_MKDIR) libraries

libraries: gflags glog gtest
#libraries: gflags \
           glog \
           gtest \
           zeromq \
           boost \
           gperftools \
           tbb \
           oprofile \
           sparsehash \
           libconfig \
           yaml-cpp \
           leveldb

$(NEED_MKDIR):
	mkdir -p $@

clean: 
	rm -rf $(BIN)/*

distclean: clean
	rm -rf $(THIRD_PARTY)

.PHONY: libraries

include $(TEST)/test.mk

# ===================== gflags ===================

GFLAGS_SRC = $(THIRD_PARTY_SRC)/gflags-2.0.tar.gz
GFLAGS_LIB = $(THIRD_PARTY_LIB)/libgflags.so

gflags: $(GFLAGS_LIB)

$(GFLAGS_LIB): $(GFLAGS_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY); \
	make install

$(GFLAGS_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ===================== glog =====================

GLOG_SRC = $(THIRD_PARTY_SRC)/glog-0.3.3.tar.gz
GLOG_LIB = $(THIRD_PARTY_LIB)/libglog.so

glog: $(GLOG_LIB)

$(GLOG_LIB): $(GLOG_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY); \
	make install

$(GLOG_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ===================== gtest ====================

GTEST_SRC = $(THIRD_PARTY_SRC)/gtest-1.7.0.zip
GTEST_LIB = $(THIRD_PARTY_LIB)/libgtest_main.a

gtest: $(GTEST_LIB)

$(GTEST_LIB): $(GTEST_SRC)
	unzip $< -d $(THIRD_PARTY_SRC)
	cd $(basename $<)/make; \
	make; \
	./sample1_unittest; \
	cp -r ../include/* $(THIRD_PARTY_INCLUDE)/; \
	cp gtest_main.a $@

$(GTEST_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ==================== zeromq ====================

ZMQ_SRC = $(THIRD_PARTY_SRC)/zeromq-3.2.3.tar.gz
ZMQ_LIB = $(THIRD_PARTY_LIB)/libzmq.so

zeromq: $(ZMQ_LIB)

$(ZMQ_LIB): $(ZMQ_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY); \
	make install

$(ZMQ_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@
	wget $(THIRD_PARTY_HOST)/zmq.hpp -P $(THIRD_PARTY_INCLUDE)

# ==================== boost ====================

BOOST_SRC = $(THIRD_PARTY_SRC)/boost_1_54_0.tar.bz2
BOOST_INCLUDE = $(THIRD_PARTY_INCLUDE)/boost

boost: $(BOOST_INCLUDE)

$(BOOST_INCLUDE): $(BOOST_SRC)
	tar jxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./bootstrap.sh --with-libraries=system,thread --prefix=$(THIRD_PARTY); \
	./b2 install

$(BOOST_SRC):
	wget $(BOOST_HOST)/$(notdir $@) -O $@

# ================== gperftools =================

GPERFTOOLS_SRC = $(THIRD_PARTY_SRC)/gperftools-2.1.tar.gz
GPERFTOOLS_LIB = $(THIRD_PARTY_LIB)/libtcmalloc.so

gperftools: $(GPERFTOOLS_LIB)

$(GPERFTOOLS_LIB): $(GPERFTOOLS_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY) --enable-frame-pointers; \
	make install

$(GPERFTOOLS_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ===================== tbb =====================

TBB_SRC = $(THIRD_PARTY_SRC)/tbb42_20131118oss.tgz
TBB_LIB = $(THIRD_PARTY_LIB)/libtbb.so

tbb: $(TBB_LIB)

$(TBB_LIB): $(TBB_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $<); \
	make; \
	cp build/*_release/lib* $(THIRD_PARTY_LIB)/; \
	cp -r include/tbb $(THIRD_PARTY_INCLUDE)/

$(TBB_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# =================== oprofile ===================
# NOTE: need libpopt-dev binutils-dev

OPROFILE_SRC = $(THIRD_PARTY_SRC)/oprofile-0.9.9.tar.gz
OPROFILE_LIB = $(THIRD_PARTY_LIB)/oprofile

oprofile: $(OPROFILE_LIB)

$(OPROFILE_LIB): $(OPROFILE_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY); \
	make install

$(OPROFILE_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ================== sparsehash ==================

SPARSEHASH_SRC = $(THIRD_PARTY_SRC)/sparsehash-2.0.2.tar.gz
SPARSEHASH_INCLUDE = $(THIRD_PARTY_INCLUDE)/sparsehash

sparsehash: $(SPARSEHASH_INCLUDE)

$(SPARSEHASH_INCLUDE): $(SPARSEHASH_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY); \
	make install

$(SPARSEHASH_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ==================== libconfig ===================

LIBCONFIG_SRC = $(THIRD_PARTY_SRC)/libconfig-1.4.9.tar.gz
LIBCONFIG_LIB = $(THIRD_PARTY_LIB)/libconfig++.so

libconfig: $(LIBCONFIG_LIB)

$(LIBCONFIG_LIB): $(LIBCONFIG_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	./configure --prefix=$(THIRD_PARTY); \
	make install

$(LIBCONFIG_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

# ==================== yaml-cpp ===================

YAMLCPP_SRC = $(THIRD_PARTY_SRC)/yaml-cpp-0.5.1.tar.gz
YAMLCPP_MK = $(THIRD_PARTY_SRC)/yaml-cpp.mk
YAMLCPP_LIB = $(THIRD_PARTY_LIB)/libyaml-cpp.a

yaml-cpp: boost $(YAMLCPP_LIB)

$(YAMLCPP_LIB): $(YAMLCPP_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	make -f $(YAMLCPP_MK) BOOST_PREFIX=$(THIRD_PARTY) TARGET=$@; \
	cp -r include/* $(THIRD_PARTY_INCLUDE)/

$(YAMLCPP_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@
	wget $(THIRD_PARTY_HOST)/$(notdir $(YAMLCPP_MK)) -P $(THIRD_PARTY_SRC)

# ==================== leveldb ===================

LEVELDB_SRC = $(THIRD_PARTY_SRC)/leveldb-1.15.0.tar.gz
LEVELDB_LIB = $(THIRD_PARTY_LIB)/libleveldb.so

leveldb: $(LEVELDB_LIB)

$(LEVELDB_LIB): $(LEVELDB_SRC)
	tar zxf $< -C $(THIRD_PARTY_SRC)
	cd $(basename $(basename $<)); \
	make; \
	cp ./libleveldb.* $(THIRD_PARTY_LIB)/; \
	cp -r include/* $(THIRD_PARTY_INCLUDE)/

$(LEVELDB_SRC):
	wget $(THIRD_PARTY_HOST)/$(notdir $@) -O $@

