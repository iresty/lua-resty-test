package = "lua-resty-test"
version = "0.1-0"
source = {
   url = "git://github.com/iresty/lua-resty-test",
   tag = "v0.1"
}
description = {
   summary = "Lua test frame for the ngx_lua based on Openresty",
   homepage = "https://github.com/iresty/lua-resty-test",
   license = "Apache License 2.0",
   maintainer = "Yuansheng Wang <membphis@gmail.com>"
}
dependencies = {
   "luaunit",
}
build = {
   type = "builtin",
   modules = {
      ["resty.iresty_test"] = "lib/resty/iresty_test.lua"
   }
}
