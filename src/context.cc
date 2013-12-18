#include "context.h"

#include <gflags/gflags.h>
#include <glog/logging.h>

#include <vector>

Context& Context::get_instance()
{
  static Context instance;
  return instance;
}

Context::Context()
{
  std::vector<google::CommandLineFlagInfo> flags;
  google::GetAllFlags(&flags);
  for (size_t i = 0; i < flags.size(); i++) {
    google::CommandLineFlagInfo& flag = flags[i];
    ctx_[flag.name] = flag.is_default ? flag.default_value : flag.current_value;
  }
}

int32_t Context::get_int32(std::string key)
{
  return atoi(get_string(key).c_str());
}

double Context::get_double(std::string key)
{
  return atof(get_string(key).c_str());
}

std::string Context::get_string(std::string key) {
  LOG_IF(FATAL, ctx_.find(key) == ctx_.end()) << "Failed to lookup "
      << key << " in context.";
  return ctx_[key];
}

void Context::put_int32(std::string key, int32_t value)
{
  // c++11 feature. Try to avoid using stringstream...
  ctx_[key] = std::to_string(value);
}

void Context::put_double(std::string key, double value)
{
  // c++11 feature. Try to avoid using stringstream...
  ctx_[key] = std::to_string(value);
}

void Context::put_string(std::string key, std::string value)
{
  ctx_[key] = value;
}