# Lua Builder

Lua Builder is a library for programmatically creating lua source code in Lua, using a comfortable method-chaining syntax. 

All Lua keywords and control structures are supported, along with extra convenance functions for quality-of-life.

This library is intended to be used for creating languages that transpile into Lua, or building scripts that contain large amounts of repetitive code.

# Getting Started

`require("lua_builder")` into your script, and create a new instance using `LuaBuilder.new()`. Lua keywords all start with a capital letter to not clash with the syntax. To finally build the Lua code, use the `build` method.

Text can also be appended directly by calling the instance of `LuaBuilder` with a string.

Example: FizzBuzz
```lua
local LuaBuilder = require("lua_builder")
local builder = LuaBuilder.new()

-- Generates a function that solves FizzBuzz
-- return is added as a string to prevent a newline from being added
builder"return ":Function(nil, "i")
for i = 1, 100 do
    builder:If()"i ":eq(i):Then()
    if i % 15 == 0 then
        builder:call_function("print", '"fizzbuzz"')
    elseif i % 3 == 0 then
        builder:call_function("print", '"fizz"')
    elseif i % 5 == 0 then
        builder:call_function("print", '"buzz"')
    else
        builder:call_function("print", i)
    end
    builder:End()
end
builder:End()

local code = builder:build()
local fizz_buzz = assert(load(code))()

for i = 1, 100 do
    fizz_buzz(i)
end

builder:empty() -- Allow this builder to be reused
```
