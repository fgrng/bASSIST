# JSON representation of Time objects
# ===================================
# http://guides.rubyonrails.org/upgrading_ruby_on_rails.html#upgrading-from-rails-4-0-to-rails-4-1
# 
# as_json for objects with time component (Time, DateTime,
# ActiveSupport::TimeWithZone) now returns millisecond precision by
# default. If you need to keep old behavior with no millisecond precision,
# set the following in an initializer:
ActiveSupport::JSON::Encoding.time_precision = 0
