#pragma once

#include <pthread.h> 
#include <semaphore.h>
#include <deque>
//#include <stdio.h>
//#include <assert.h>

// A thread-safe producer-consumer queue. The items should be copy constructable.
template<typename T>
class BlockingQueue {
public:
  explicit BlockingQueue(int max_size);
  ~BlockingQueue();

  // Push an item to the end of the queue.
  // If the queue is not full, push immediately. 
  // If the queue reached max_size, then block until someone consumes an item.
  void Push(const T& item);

  // Pop out an item from the front of the queue. 
  // If the queue is not empty, pop out immediately.
  // Otherwise block until it's not empty.
  T Pop();

private:
  // the max number of items in the queue
  int max_size_;
  // The queue of elements. Deque is used to provide O(1) time
  // for head elements removal.
  std::deque<T> queue_;
  // Allow only one thread to enter critical region
  pthread_mutex_t mutex_;
  // Block when the queue is empty or full
  sem_t empty_, full_;
};

template<typename T>
BlockingQueue<T>::BlockingQueue(int max_size) : max_size_(max_size)
{
  pthread_mutex_init(&mutex_, NULL);
  sem_init(&empty_, 0, 0);
  sem_init(&full_, 0, max_size_);
  //printf("BlockingQueue initialized with max size %d\n", max_size);
}

template<typename T>
BlockingQueue<T>::~BlockingQueue()
{
  pthread_mutex_destroy(&mutex_);
  sem_destroy(&empty_);
  sem_destroy(&full_);
}

template<typename T>
void BlockingQueue<T>::Push(const T& item)
{
  sem_wait(&full_);
  pthread_mutex_lock(&mutex_);

  //assert(queue_.size() < max_size_);
  queue_.push_back(item);
  //printf("Push called. queue size: %d\n", queue_.size());

  pthread_mutex_unlock(&mutex_);
  sem_post(&empty_);
}

template<typename T>
T BlockingQueue<T>::Pop()
{
  sem_wait(&empty_);
  pthread_mutex_lock(&mutex_);

  //assert(queue_.empty() == false);
  T item = queue_.front();
  queue_.pop_front();
  //printf("-------------- Pop out %d . queue size: %d\n", item, queue_.size());
  
  pthread_mutex_unlock(&mutex_);
  sem_post(&full_);

  return item;
}
