local iresty_test    = require "resty.iresty_test"
local tb = iresty_test.new({unit_name="example_mock"})

local M = {}
function M.test()
    return "hello world"
end


function tb:test_00001()
    local function mock_test()
        return "mock test func error"
    end

    local mock_rules = {
        { M, "test", mock_test}
    }

    local function mock_test_run()
        self:log(M.test())
    end

    self:mock_run(mock_rules, mock_test_run)
end

-- units test
tb:run()
