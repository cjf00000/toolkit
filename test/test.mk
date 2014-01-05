
TEST_LDFLAGS = $(LDFLAGS) -lgtest_main

TEST_SRC = $(wildcard $(TEST)/*.cc)
TEST_BIN = $(TEST_SRC:$(TEST)/%.cc=$(BIN)/%)

test: $(TEST_BIN)

$(TEST_BIN): $(BIN)/%: $(TEST)/%.cc
	$(CXX) $(CXXFLAGS) $(INCFLAGS) $< $(TEST_LDFLAGS) -o $@
