#include "context.h"

#include <gflags/gflags.h>
#include <glog/logging.h>

#include <vector>

Context& Context::get_instance()
{
  static Context instance;
  return instance;
}

Context::Context() {
  std::vector<google::CommandLineFlagInfo> flags;
  google::GetAllFlags(&flags);
  for (size_t i = 0; i < flags.size(); i++) {
    google::CommandLineFlagInfo& flag = flags[i];
    ctx_[flag.name] = flag.is_default ? flag.default_value : flag.current_value;
    // debug
    //LOG(INFO) << flag.name << ": " << ctx_[flag.name];
  }
}

// -------------------- Getters ----------------------

int Context::get_int(std::string key) {
  return atoi(get_string(key).c_str());
}

double Context::get_double(std::string key) {
  return atof(get_string(key).c_str());
}

bool Context::get_bool(std::string key) {
  if (get_string(key).compare("true") == 0)
    return true;
  else
    return false;
}

std::string Context::get_string(std::string key) {
  std::unordered_map<std::string, std::string>::iterator it = ctx_.find(key);
  LOG_IF(FATAL, it == ctx_.end()) << "Failed to lookup " << key << " in context.";
  return it->second;
}

// -------------------- Setters ---------------------

void Context::set(std::string key, int value) {
  ctx_[key] = std::to_string(value);
}

void Context::set(std::string key, double value) {
  ctx_[key] = std::to_string(value);
}

void Context::set(std::string key, bool value) {
  ctx_[key] = (value) ? "true" : "false";
}

void Context::set(std::string key, std::string value) {
  ctx_[key] = value;
}
