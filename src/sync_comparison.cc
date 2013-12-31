//
// Benchmark of various synchronization mechanisms.
// Author: Xun Zheng (xunzheng at cs.cmu.edu)
//
// To compile (boost required): 
//   g++ -O3 -std=c++11 -I${BOOST_INCLUDE} sync_comparison.cc -o sync_comparison -L${BOOST_LIB} -pthread -lrt -lboost_thread -lboost_system
//
// To run:
//   LD_LIBRARY_PATH+=${BOOST_LIB} ./sync_comparison
//
#include <string.h>
#include <assert.h>
#include <time.h>
#include <pthread.h>
#include <iostream>
#include <thread>
#include <mutex>
#include <atomic>
#include <string>

#include <boost/thread.hpp>
#include <boost/atomic.hpp>

int num_threads = 4;
int array_size  = 1e+4;
int big_num     = 1e+7;

class Task {
public:
  Task(int array_size)
      : size_(array_size),
        array_(new int[size_]),
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
      assert(array_[i] == array_[i-1]);
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
    for (int i = 0; i < big_num; ++i)
      array_[index] += i;
  }

private:
  // data
  int size_;
  int *array_;
  // concurrency control
  int it_;
  std::mutex mutex_;
  std::atomic<int> atomic_it_;
  pthread_mutex_t pmutex_;
  pthread_spinlock_t spinlock_;
  boost::mutex bmutex_;
  boost::atomic<int> batomic_it_;
};

double get_time() {
  struct timespec start;
  clock_gettime(CLOCK_MONOTONIC, &start);
  return (start.tv_sec + start.tv_nsec/1000000000.0);
}

void run_with(void (Task::*func)(), std::string&& name) {
  Task task(array_size);
  double tik = get_time();
  std::thread threads[num_threads];
  for (int t = 0; t < num_threads; ++t)
    threads[t] = std::thread(func, &task);
  for (int t = 0; t < num_threads; ++t)
    threads[t].join();
  std::cout << name << "\t" << get_time() - tik << " sec\n";
}

int main(int argc, char **argv)
{
  if (argv[1]) num_threads = atoi(argv[1]);
  if (argv[2]) array_size = atoi(argv[2]);
  if (argv[3]) big_num = atoi(argv[3]);

  std::cout << "big_num: " << big_num
            << "\tnum_threads: " << num_threads
            << "\tarray_size: " << array_size
            << std::endl;

  // serial
  Task task(array_size);
  double tik = get_time();
  task.serial();
  std::cout << "serial\t\t" << get_time() - tik << " sec\n";

  // parallel
  run_with(&Task::std_mutex, "std::mutex");
  run_with(&Task::std_atomic, "std::atomic");
  run_with(&Task::pthread_mutex, "pthread_mutex");
  run_with(&Task::pthread_spin, "pthread_spin");
  run_with(&Task::boost_mutex, "boost::mutex");
  run_with(&Task::boost_atomic, "boost::atomic");
  run_with(&Task::std_atomic_relaxed_memorder, "atomic_relax");

  return 0;
}
