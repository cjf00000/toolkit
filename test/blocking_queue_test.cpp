#include "blocking_queue.h"

#include <gtest/gtest.h>

#include <atomic>
#include <vector>
#include <pthread.h>

namespace {
  const int QUEUE_SIZE = 128;
  const int ITEM_PER_PRODUCER = 1024*1024;
}

// Each producer produces integers from 0 to ITEM_PER_PRODUCER. -1 is sent after
// all producers are finished. Consumer takes one item from queue and push it to
// a vector. After all threads are finished, we compare the size of the vector
// with number of items pushed into the queue.
class BlockingQueueTest : public testing::Test {
protected:
  BlockingQueueTest() : queue_(QUEUE_SIZE) {
  }

  void Init(int num_producer, int num_consumer) {
    num_producer_ = num_producer;
    num_consumer_ = num_consumer;
    pthread_mutex_init(&mutex_, NULL);
    producer_ = new pthread_t[num_producer_];
    consumer_ = new pthread_t[num_consumer_];
    //LOG(INFO) << "Spawn producer threads";
    for (int i = 0; i < num_producer_; ++i) {
      pthread_create(producer_ + i, NULL, producer_func, (void*)this);
    }
    //LOG(INFO) << "Spawn consumer threads";
    for (int i = 0; i < num_consumer_; ++i) {
      pthread_create(consumer_ + i, NULL, consumer_func, (void*)this);
    }
  }

  void Finish() {
    for (int i = 0; i < num_producer_; ++i) {
      pthread_join(producer_[i], NULL);
    }
    //LOG(INFO) << "Producer threads joined";
    for (int i = 0; i < num_consumer_; ++i) {
      queue_.Push(-1);
    }
    //LOG(INFO) << "Sent ternimation signal";
    for (int i = 0; i < num_consumer_; ++i) {
      pthread_join(consumer_[i], NULL);
    }
    //LOG(INFO) << "Consumer threads joined";
    if (producer_ != NULL)
      delete[] producer_;
    if (consumer_ != NULL)
      delete[] consumer_;
    pthread_mutex_destroy(&mutex_);
  }

  static void* producer_func(void *args) {
    BlockingQueueTest *obj = (BlockingQueueTest*)args;
    obj->do_produce();
    return 0;
  }
  static void* consumer_func(void *args) {
    BlockingQueueTest *obj = (BlockingQueueTest*)args;
    obj->do_consume();
    return 0;
  }

  void do_produce() {
    for (int i = 0; i < ITEM_PER_PRODUCER; ++i)
      queue_.Push(i);
  }

  void do_consume() {
    while (true) {
      int item = queue_.Pop();
      if (item < 0)
        break;
      pthread_mutex_lock(&mutex_);
      consumer_result_.push_back(item);
      pthread_mutex_unlock(&mutex_);
    }
  }

  BlockingQueue<int> queue_;
  pthread_t *producer_, *consumer_;
  int num_producer_, num_consumer_;
  pthread_mutex_t mutex_;
  std::vector<int> consumer_result_;
};

TEST_F(BlockingQueueTest, Constructor) 
{
  EXPECT_EQ(0, consumer_result_.size());
}

TEST_F(BlockingQueueTest, SingleProducerMultiConsumer)
{
  Init(1, 5);
  Finish();
  EXPECT_EQ(ITEM_PER_PRODUCER, consumer_result_.size());
}

TEST_F(BlockingQueueTest, MultiProducerSingleConsumer)
{
  int num_prod = 5;
  Init(num_prod, 1);
  Finish();
  EXPECT_EQ(ITEM_PER_PRODUCER * num_prod, consumer_result_.size());
}

TEST_F(BlockingQueueTest, MultiProducerMultiConsumer)
{
  int num_prod = 5;
  Init(num_prod, 6);
  Finish();
  EXPECT_EQ(ITEM_PER_PRODUCER * num_prod, consumer_result_.size());
}
