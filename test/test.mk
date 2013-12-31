
TEST_LDFLAGS = $(LDFLAGS) -lgtest_main

TEST_SRC = $(wildcard $(TEST)/*.cc)
TEST = $(TEST_SRC:$(TEST)/%.cc=$(BIN)/%)

test: $(TEST)

$(TEST): $(BIN)/%: $(TEST)/%.cc
	$(CXX) $(CXXFLAGS) $(INCFLAGS) $< $(TEST_LDFLAGS) -o $@

test_blocking_queue: $(BIN)/blocking_queue_test
	LD_LIBRARY_PATH=$(LIB) $<
