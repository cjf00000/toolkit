//
// Useful bit operations
//

#include <stdint.h>

// AND instead of mod
bool is_even(int x) {
  if (x & 1 == 0)
    return true;
  return false;
}

// Computing (x+y)/2 without overflow
int average(int x, int y) {
  return (x & y) + ((x ^ y) >> 1);
}

// Swap without temp variable
void swap(int &x, int &y) {
  x ^= y;
  y ^= x;
  x ^= y;
}

// Absolute value. (x >> 31) is sign bit of int.
int32_t abs(int32_t x) {
  return (x ^ (x >> 31)) - (x >> 31);
}

// 1011 => 1101
int32_t binary_reverse(int32_t x) {
  x = ((x & 0x55555555) << 1) | ((x & 0xAAAAAAAA) >> 1);
  x = ((x & 0x33333333) << 2) | ((x & 0xCCCCCCCC) >> 2);
  x = ((x & 0x0F0F0F0F) << 4) | ((x & 0xF0F0F0F0) >> 4);
  x = ((x & 0x00FF00FF) << 8) | ((x & 0xFF00FF00) >> 8);
  x = ((x & 0x0000FFFF) << 16) | ((x & 0xFFFF0000) >> 16);
  return x;
}
