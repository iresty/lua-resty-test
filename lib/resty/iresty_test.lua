-- Copyright (C) YuanSheng Wang (membphis)

local setmetatable = setmetatable
local ngx    = ngx
local table  = table
local str_fmt= string.format
local unpack = unpack
local type   = type
local pairs  = pairs
local pcall  = pcall


local _M = {
    _VERSION = '0.02',
}


local mt = { __index = _M }


function _M.new(opts)
    opts = opts or {}
    local unit_name = opts.unit_name
    local write_log = (nil == opts.write_log) and true or opts.write_log
    return setmetatable({start_time=ngx.now(), unit_name = unit_name,
                          write_log = write_log, _test_inits = opts.test_inits,
                          processing=nil, count = 0,
                          count_fail=0, count_succ=0}, mt)
end


function _M._log(self, color, ...)
    local logs = {...}
    local color_d = {black=30, green=32, red=31, yellow=33, blue=34, purple=35,
                     dark_green=36, white=37}

    if color_d[color] then
        local function format_color(cur_color)
            return "\x1b[" .. cur_color .. "m"
        end
        ngx.print(format_color(color_d[color])
                  .. table.concat(logs, " ") ..'\x1b[m')
    else
        ngx.print(...)
    end

    ngx.flush()
end


function _M._log_standard_head( self )
    if not self.write_log then
        return
    end

    local fun_format
    if nil == self.processing then
        fun_format = str_fmt("[%s] ", self.unit_name)
    else
        fun_format = str_fmt("  \\_[%s] ", self.processing)
    end

    self:_log("default", str_fmt("%0.3f", ngx.now() - self.start_time),
              " ")
    self:_log("green",  fun_format)
end


function _M.log( self, ... )
    if not self.write_log then
        return
    end

    local log = {...}
    table.insert(log, "\n")

    self:_log_standard_head()
    if self.processing then
        table.insert(log, 1, "↓")
    end
    self:_log("default", unpack(log))
end


function _M.log_finish_fail( self, ... )
    if not self.write_log then
        return
    end

    local log = {...}
    table.insert(log, "\n")

    self:_log_standard_head(self)
    self:_log("yellow", "fail", unpack(log))
end


function _M.log_finish_succ( self, ... )
    if not self.write_log then
        return
    end

    local log = {...}
    table.insert(log, "\n")

    self:_log_standard_head(self)
    self:_log("green", unpack(log))
end


function _M._init_test_units( self )
    if self._test_inits then
        return self._test_inits
    end

    local test_inits = {}
    for k,v in pairs(self) do
        if k:lower():sub(1, 4) == "test" and type(v) == "function" then
        table.insert(test_inits, k)
        end
    end

    table.sort( test_inits )
    self._test_inits = test_inits
    return self._test_inits
end


function _M.run(self, loop_count)
    if self.unit_name then
      self:log_finish_succ("unit test start")
    end

    self:_init_test_units()

    loop_count = loop_count or 1

    self.time_start = ngx.now()

    for _ = 1, loop_count do
        if self.init then
            self:init()
        end

        for _,k in pairs(self._test_inits) do
            self.processing = k
            local _, err = pcall(self[k], self)
            if err then
                self:log_finish_fail(err)
                self.count_fail = self.count_fail + 1
            else
                self:log_finish_succ("PASS")
                self.count_succ = self.count_succ + 1
            end
            self.processing = nil
            ngx.flush()
        end

        if self.destroy then
            self:destroy()
        end
    end

    self.time_ended = ngx.now()

    if self.unit_name then
        self:log_finish_succ("unit test complete")
    end
end


return _M
