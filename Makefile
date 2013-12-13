PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

BIN = $(PROJECT)/bin
SRC = $(PROJECT)/src
TEST = $(PROJECT)/test
THIRD_PARTY = $(PROJECT)/third_party
THIRD_PARTY_SRC = $(THIRD_PARTY)/src
THIRD_PARTY_LIB = $(THIRD_PARTY)/lib
THIRD_PARTY_INCLUDE = $(THIRD_PARTY)/include

TO_REMOVE = $(THIRD_PARTY)
TO_MKDIR = $(BIN) $(THIRD_PARTY) $(THIRD_PARTY_SRC)

CXX = g++
CXXFLAGS = -g -O2 -std=c++11
INCFLAGS = -I$(SRC) -I$(THIRD_PARTY_INCLUDE) 
LDFLAGS = -L$(THIRD_PARTY_LIB) -pthread -lgflags -lglog

# ===================== rules =====================

all: $(TO_MKDIR) libraries

$(TO_MKDIR):
	mkdir -p $@

libraries: gflags glog gtest

clean: 
	rm -rf $(BIN)/*

distclean:
	rm -rf $(TO_REMOVE)

# ===================== gflags ===================

GFLAGS_SRC = $(THIRD_PARTY_SRC)/gflags.tar.gz
GFLAGS_LIB = $(THIRD_PARTY_LIB)/libgflags.so

gflags: $(GFLAGS_LIB)

$(GFLAGS_LIB): $(GFLAGS_SRC)
	tar zxvf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/gflags-2.0; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make; \
        make install

$(GFLAGS_SRC):
	wget https://gflags.googlecode.com/files/gflags-2.0-no-svn-files.tar.gz -O $@

# ===================== glog =====================

GLOG_SRC = $(THIRD_PARTY_SRC)/glog.tar.gz
GLOG_LIB = $(THIRD_PARTY_LIB)/libglog.so

glog: $(GLOG_LIB)

$(GLOG_LIB): $(GLOG_SRC)
	tar zxvf $< -C $(THIRD_PARTY_SRC)
	cd $(THIRD_PARTY_SRC)/glog-0.3.3; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(THIRD_PARTY); \
	make; \
        make install

$(GLOG_SRC):
	wget https://google-glog.googlecode.com/files/glog-0.3.3.tar.gz -O $@

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
	cp gtest_main.a $@;

$(GTEST_SRC):
	wget https://googletest.googlecode.com/files/gtest-1.7.0.zip -O $@

# ================================================

include $(TEST)/test.mk
