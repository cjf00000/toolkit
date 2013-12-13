
TEST_LIBS = -lgtest_main

# ===================== rules =====================

test_all: test_blocking_queue

$(BIN)/blocking_queue_test: $(TEST)/blocking_queue_test.cc \
                            $(SRC)/blocking_queue.h
	$(CXX) $(CXXFLAGS) $(INCFLAGS) $< $(LDFLAGS) $(TEST_LIBS) -o $@

test_blocking_queue: $(BIN)/blocking_queue_test
	LD_LIBRARY_PATH=$(LIB) $<
