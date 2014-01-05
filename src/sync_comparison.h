// Benchmark of various synchronization mechanisms.
// Author: Xun Zheng (xunzheng at cs.cmu.edu)
//
#include <string.h>
#include <pthread.h>
#include <mutex>
#include <atomic>
#include <string>

#include <glog/logging.h>
#include <boost/thread.hpp>
#include <boost/atomic.hpp>

class Task {
public:
  Task(int array_size, int big_num)
      : size_(array_size),
        array_(new int[size_]),
        big_num_(big_num),
        it_(0),
        atomic_it_(0),
        batomic_it_(0) {
    memset(array_, 0, sizeof(int) * size_);
    pthread_mutex_init(&pmutex_, NULL);
    pthread_spin_init(&spinlock_, 0);
  }

  ~Task() {
    pthread_mutex_destroy(&pmutex_);
    pthread_spin_destroy(&spinlock_);
    for (int i = 1; i < size_; ++i) {
      CHECK_EQ(array_[i], array_[i-1]);
    }
    delete[] array_;
  }

  void serial() {
    for (int i = 0; i < size_; ++i)
      spend_time(i);
  }

  void std_mutex() {
    while (true) {
      int index = -1;
      {
        std::lock_guard<std::mutex> guard(mutex_);
        index = it_++;
      }
      if (index >= size_) break;
      spend_time(index);
    }
  }

  void std_atomic() {
    while (true) {
      int index = -1;
      index = atomic_it_++;
      if (index >= size_) break;
      spend_time(index);
    }
  }

  void std_atomic_relaxed_memorder() {
    while (true) {
      int index = -1;
      index = atomic_it_.fetch_add(1, std::memory_order_relaxed);
      if (index >= size_) break;
      spend_time(index);
    }
  }

  void pthread_mutex() {
    while (true) {
      int index = -1;
      pthread_mutex_lock(&pmutex_);
      index = it_++;
      pthread_mutex_unlock(&pmutex_);
      if (index >= size_) break;
      spend_time(index);
    }
  }

  void pthread_spin() {
    while (true) {
      int index = -1;
      pthread_spin_lock(&spinlock_);
      index = it_++;
      pthread_spin_unlock(&spinlock_);
      if (index >= size_) break;
      spend_time(index);
    }
  }

  void boost_mutex() {
    while (true) {
      int index = -1;
      {
        boost::lock_guard<boost::mutex> guard(bmutex_);
        index = it_++;
      }
      if (index >= size_) break;
      spend_time(index);
    }
  }

  void boost_atomic() {
    while (true) {
      int index = -1;
      index = batomic_it_++;
      if (index >= size_) break;
      spend_time(index);
    }
  }

private:
  void spend_time(int index) {
    for (int i = 0; i < big_num_; ++i)
      array_[index] += i;
  }

private:
  // data
  int size_;
  int *array_;
  int big_num_;
  // concurrency control
  int it_;
  std::mutex mutex_;
  std::atomic<int> atomic_it_;
  pthread_mutex_t pmutex_;
  pthread_spinlock_t spinlock_;
  boost::mutex bmutex_;
  boost::atomic<int> batomic_it_;
};

