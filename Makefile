PROJECT := $(shell readlink $(dir $(lastword $(MAKEFILE_LIST))) -f)

BIN = $(PROJECT)/bin
SRC = $(PROJECT)/src
INCLUDE = $(PROJECT)/include
LIB = $(PROJECT)/lib
BUILD = $(PROJECT)/build
DEPENDENCIES = $(PROJECT)/dependencies
TEST = $(PROJECT)/test
DIRECTORIES = $(BIN) $(BUILD) $(DEPENDENCIES)

# directories except .git, src, and test
TO_DELETE = $(filter-out $(SRC) $(TEST), $(shell find ${PROJECT} -maxdepth 1 -mindepth 1 -type d ! -name *git))

CXX = g++
CXXFLAGS = -g -O2 -std=c++11
DIRFLAGS = -I$(SRC) -I$(INCLUDE) -L$(LIB)
#LIBS = -lgflags -lgtest_main

# ===================== rules =====================

all: $(DIRECTORIES) libraries

$(DIRECTORIES):
	mkdir -p $(BIN) $(BUILD) $(DEPENDENCIES)

libraries: gflags gtest

clean: 
	rm -rf $(BIN)/*

distclean:
	rm -rf $(TO_DELETE)

# ===================== gflags ===================

GFLAGS_TAR = $(DEPENDENCIES)/gflags.tar.gz
GFLAGS_LIB = $(LIB)/libgflags.so

gflags: $(GFLAGS_LIB)

$(GFLAGS_LIB): $(GFLAGS_TAR)
	tar zxvf $< -C $(BUILD)
	cd $(BUILD)/gflags-2.0; \
	mkdir build; \
	cd build; \
	../configure --prefix=$(PROJECT); \
	make check install clean distclean

$(GFLAGS_TAR):
	wget https://gflags.googlecode.com/files/gflags-2.0-no-svn-files.tar.gz -O $@

# ===================== gtest ====================

GTEST_ZIP = $(DEPENDENCIES)/gtest.zip
GTEST_LIB = $(LIB)/libgtest_main.a

gtest: $(GTEST_LIB)

$(GTEST_LIB): $(GTEST_ZIP)
	unzip $< -d $(BUILD)
	cd $(BUILD)/gtest-1.7.0/make; \
	make; \
	./sample1_unittest; \
	cp gtest_main.a $@

$(GTEST_ZIP):
	wget https://googletest.googlecode.com/files/gtest-1.7.0.zip -O $@

