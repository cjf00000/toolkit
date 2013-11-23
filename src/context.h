#pragma once

#include <boost/unordered_map.hpp>

#include <string>

// An extension of google flags. It is a singleton that stores 1) google flags
// and 2) other lightweight global flags. Underlying data structure is map of
// string and string, similar to google::CommandLineFlagInfo.
class Context {
public:
  static Context& get_instance();

  int32_t get_int32(std::string key);
  double get_double(std::string key);
  std::string get_string(std::string key);

  void put_int32(std::string key, int32_t value);
  void put_double(std::string key, double value);
  void put_string(std::string key, std::string value);

private:
  // Private constructor. Store all the gflags values.
  Context();

  // Underlying data structure
  boost::unordered_map<std::string, std::string> ctx_;
};
