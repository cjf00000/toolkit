#include "sync_comparison.h"

#include <gtest/gtest.h>
#include <glog/logging.h>
#include <gflags/gflags.h>

#include <thread>
#include <time.h>

DEFINE_int32(big_num, 1e+6, "");
DEFINE_int32(array_size, 1e+4, "");
DEFINE_int32(num_threads, 4, "");

double get_time() {
  struct timespec start;
  clock_gettime(CLOCK_MONOTONIC, &start);
  return (start.tv_sec + start.tv_nsec/1000000000.0);
}

void run_with(void (Task::*func)(), std::string&& name) {
  Task task(FLAGS_array_size, FLAGS_big_num);
  double tik = get_time();
  std::thread threads[FLAGS_num_threads];
  for (int t = 0; t < FLAGS_num_threads; ++t)
    threads[t] = std::thread(func, &task);
  for (int t = 0; t < FLAGS_num_threads; ++t)
    threads[t].join();
  LOG(INFO) << name << "\t" << get_time() - tik << " sec\n";
}

TEST(sync_comp_test, sync_comp) {
  LOG(INFO) << "num_threads: " << FLAGS_num_threads;
  LOG(INFO) << "array_size: " << FLAGS_array_size;
  LOG(INFO) << "big_num: " << FLAGS_big_num;

  // serial
  Task task(FLAGS_array_size, FLAGS_big_num);
  double tik = get_time();
  task.serial();
  double tok = get_time();
  LOG(INFO) << "serial\t\t" << tok - tik << " sec\n";

  // parallel
  run_with(&Task::std_mutex, "std::mutex");
  run_with(&Task::std_atomic, "std::atomic");
  run_with(&Task::pthread_mutex, "pthread_mutex");
  run_with(&Task::pthread_spin, "pthread_spin");
  run_with(&Task::boost_mutex, "boost::mutex");
  run_with(&Task::boost_atomic, "boost::atomic");
  run_with(&Task::std_atomic_relaxed_memorder, "atomic_relax");
}
