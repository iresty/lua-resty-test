# Name
lua-resty-test is Ngx_lua test frame based on Openresty


#Description
This Lua library is a test frame for test your ngx_lua source or other server(tcp or udp):

http://wiki.nginx.org/HttpLuaModule

Note that at least ngx_lua 0.5.14 or ngx_openresty 1.2.1.14 is required.

#Synopsis


```
 # you do not need the following line if you are using
    # the ngx_openresty bundle:
    lua_package_path "/path/to/lua-resty-redis/lib/?.lua;;";

    server {
        location /test {
            content_by_lua '
                	local tb    = require "resty.test_base"
					local test = tb.new({unit_name="bench_example"})

					function tb:init(  )
					    self:log("init complete")
					end

					function tb:test_00001(  )
					    error("invalid input")
					end

					function tb:atest_00002()
					    self:log("never be called")
					end

					function tb:test_00003(  )
					   self:log("ok")
					end

					-- units test
					test:run()
					
					-- bench units test
					test:bench_run()
            ';
        }
    }
```

The output result:

```
0.000  [bench_example] unit test start
0.000  [bench_example] init complete
0.000    \_[test_00001] fail ...de/nginx/main_server/test_case_lua/unit/test_example.lua:9: invalid input
0.000    \_[test_00003] ↓ ok
0.000    \_[test_00003] PASS
0.000  [bench_example] unit test complete
0.000  [bench_example] !!!BENCH TEST START!!
0.484  [bench_example] succ count:	 100001	QPS:	 206613.65
0.484  [bench_example] fail count:	 100001 	QPS:	 206613.65
0.484  [bench_example] loop count:	 100000 	QPS:	 206611.58
0.484  [bench_example] !!!BENCH TEST ALL DONE!!!
```

