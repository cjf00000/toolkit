
test_all: test_blocking_queue

$(BIN)/blocking_queue_test: $(TEST)/blocking_queue_test.cpp $(SRC)/blocking_queue.h
	$(CXX) $(CXXFLAGS) $(DIRFLAGS) $< $(LIBS) -o $@

test_blocking_queue: $(BIN)/blocking_queue_test
	LD_LIBRARY_PATH=$(LIB) $<
