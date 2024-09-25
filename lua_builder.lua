-- Lua Builder is a library for programatically creating lua source code.
-- It provides a class called `LuaBuilder` with methods for creating lua program statements,
-- such as local variables, functions, for, while, and repeat until loops.
-- It makes use of the builder pattern to allow for easy chaining of methods.
-- You can also call the instance of `LuaBuilder` with a string to insert it into the generated lua source code.

local table = table
local concat, format, type = table.concat, string.format, type

---@class LuaBuilder
---@field buf string[] The buffer of generated lua source code. This will eventually concatenated to form the final lua source code.
---@field indent_level number The current indentation level. Starts at 0.
---@field indent_str string The string to use for indentation. Defaults to 4 spaces. Usually either "    " or "\t".
---@field newline string The newline character to use. Defaults to "\n". Usually either "\n" or "\r\n".
local LuaBuilder = {}

---@alias Self LuaBuilder

--- Creates a new LuaBuilder instance.
--- @return LuaBuilder builder The new LuaBuilder instance.
function LuaBuilder.new()
    local self = {
        buf = {},
        indent_level = 0,
        indent_str = "    ",
        newline = "\n"
    }
    return setmetatable(self, {
        __index = LuaBuilder,
        __tostring = LuaBuilder.build,
        __call = LuaBuilder.insert_verbatim
    })
end

function LuaBuilder:build()
    return concat(self.buf)
end

LuaBuilder.to_string = LuaBuilder.build
LuaBuilder.to_text = LuaBuilder.build
LuaBuilder.output = LuaBuilder.build

--- Resets the builder to its initial state, allowing it to be reused.
---@return Self
function LuaBuilder:reset()
    -- Reset the buffer, allowing it to be reused without invoking the garbage collector or allocating a new table.
    local buf = self.buf
    for i = #buf, 1, -1 do buf[i] = nil end
    self.indent_level = 0
    self.indent_str = "    "
    self.newline = "\n"
    return self
end

--- Sets the string used for indentation. By default this is four spaces.
---@param indent string The string to use for indentation.
---@return Self
function LuaBuilder:set_indent_string(indent)
    self.indent_str = indent
    return self
end

--- Increases the indentation level.
---@return Self
function LuaBuilder:indent()
    self.indent_level = self.indent_level + 1
    return self
end

LuaBuilder.tab = LuaBuilder.indent

--- Gets the indentation string for the current indentation level.
---@return string indent The indentation string.
---@nodiscard
function LuaBuilder:get_indent()
    return self.indent_str:rep(self.indent_level)
end

--- Decreases the indentation level.
---@return Self
function LuaBuilder:dedent()
    self.indent_level = self.indent_level - 1
    return self
end

LuaBuilder.unindent = LuaBuilder.dedent
LuaBuilder.untab = LuaBuilder.dedent
LuaBuilder.de = LuaBuilder.dedent

--- Sets the newline character. By default this is "\n".
---@param newline string The newline character to use.
---@return Self
function LuaBuilder:set_newline(newline)
    self.newline = newline
    return self
end

--- Sets the newline character to "\n".
--- This is mainly for unix systems that just use LF for newlines.
---@return Self
function LuaBuilder:set_lf()
    self.newline = "\n"
    return self
end

--- Sets the newline character to "\r\n".
--- This is mainly for windows systems that use CRLF for newlines.
function LuaBuilder:set_crlf()
    self.newline = "\r\n"
    return self
end

LuaBuilder.append = LuaBuilder.insert_verbatim

--- Appends a space to the generated lua source code.
---@return Self
function LuaBuilder:sp()
    self.buf[#self.buf + 1] = " "
    return self
end

LuaBuilder.space = LuaBuilder.sp

--- Appends a left parenthesis to the generated lua source code.
---@return Self
function LuaBuilder:lp()
    self.buf[#self.buf + 1] = "("
    return self
end

LuaBuilder.lparen = LuaBuilder.lp

--- Appends a right parenthesis to the generated lua source code.
---@return Self
function LuaBuilder:rp()
    self.buf[#self.buf + 1] = ")"
    return self
end

LuaBuilder.rparen = LuaBuilder.rp

--- Appends a left brace to the generated lua source code.
---@return Self
function LuaBuilder:lb()
    self.buf[#self.buf + 1] = "{"
    return self
end

LuaBuilder.lbrace = LuaBuilder.lb

--- Appends a right brace to the generated lua source code.
---@return Self
function LuaBuilder:rb()
    self.buf[#self.buf + 1] = "}"
    return self
end

LuaBuilder.rbrace = LuaBuilder.rb

function LuaBuilder:semicolon()
    self.buf[#self.buf + 1] = ";"
    return self
end

LuaBuilder.semi = LuaBuilder.semicolon

--- Appends a newline to the generated lua source code, along with the current indentation.
---@return Self
function LuaBuilder:nl()
    self.buf[#self.buf + 1] = self.newline .. self:get_indent()
    return self
end

--- Appends a newline to the generated lua source code, and increases the indentation level.
---@return Self
function LuaBuilder:nlin()
    self.indent_level = self.indent_level + 1
    self.buf[#self.buf + 1] = self.newline .. self:get_indent()
    return self
end

--- Appends a newline to the generated lua source code, and decreases the indentation level.
---@return Self
function LuaBuilder:nlde()
    self.indent_level = self.indent_level - 1
    self.buf[#self.buf + 1] = self.newline .. self:get_indent()
    return self
end

--- Appends a newline to the generated lua source code, without indentation. Useful for blank lines.
---@return Self
function LuaBuilder:nlnoindent()
    self.buf[#self.buf + 1] = self.newline
    return self
end

LuaBuilder.nln = LuaBuilder.nlnoindent

--- Inserts the text verbatim into the generated lua source code.
--- This can also be invoked by calling the instance of `LuaBuilder` with a string.
---@param text string The text to insert.
---@return Self
function LuaBuilder:insert_verbatim(text)
    self.buf[#self.buf + 1] = text
    return self
end

--- The user is responsible for adding any space between the `--` and the comment itself.
---@param comment string The comment to add.
---@param is_doc? boolean Whether the comment should use the `---` documentation comment prefix.
---@return Self
function LuaBuilder:comment(comment, is_doc)
    local prefix = is_doc and "---" or "--"
    self.buf[#self.buf + 1] = prefix .. comment
    return self
end

--- Generates the start of a multi-line comment.
---@return Self
function LuaBuilder:start_multiline_comment()
    self.buf[#self.buf + 1] = "--[["
    return self
end

--- Generates the start of a multi-line string.
---@return Self
function LuaBuilder:start_multiline_string()
    self.buf[#self.buf + 1] = "[["
    return self
end

--- Generates the end of a multi-line comment (or string).
---@return Self
function LuaBuilder:end_multiline_comment()
    self.buf[#self.buf + 1] = "]]"
    return self
end

LuaBuilder.end_multiline_string = LuaBuilder.end_multiline_comment

--- Generates the `local` keyword.
---@return Self
function LuaBuilder:Local()
    self.buf[#self.buf + 1] = "local "
    return self
end

--- Generates a local variable declaration.
---@param name string The name of the variable.
---@return Self
function LuaBuilder:local_var(name)
    self.buf[#self.buf + 1] = "local " .. name
    self:nl()
    return self
end

--- Generates a local variable declaration for multiple variables.
---@param names string[] The names of the variables.
---@return Self
function LuaBuilder:local_vars(names)
    self.buf[#self.buf + 1] = "local " .. concat(names, ", ")
    self:nl()
    return self
end

--- Generates a variable(s) assignment(s).
---@param name string|string[] The name(s) of the variable(s).
---@param value? string|string[] The value(s) to assign, if any.
---@return Self
function LuaBuilder:assign(name, value)
    if type(name) == "table" then name = concat(name, ", ") end
    if type(value) == "table" then value = concat(value, ", ") end
    self.buf[#self.buf + 1] = "local " .. name .. " = " .. value
    self:nl()
    return self
end


--- Generates a local variable(s) declaration and assignment(s).
---@param name string|string[] The name(s) of the variable(s).
---@param value? string|string[] The value(s) to assign, if any.
---@return Self
function LuaBuilder:local_assign(name, value)
    if type(name) == "table" then name = concat(name, ", ") end
    if type(value) == "table" then value = concat(value, ", ") end
    self.buf[#self.buf + 1] = "local " .. name .. " = " .. value
    self:nl()
    return self
end

--- Convience function for localizing global variables.
---@param names string[] The names of the variables.
---@param table? string The name of the table where the variable are localized from, if any.
---@return Self
function LuaBuilder:localize(names, table)
    if table then
        self.buf[#self.buf + 1] = "local " .. table .. " = " .. table
        self:nl()
        end
    self.buf[#self.buf + 1] = "local " .. concat(names, ", ") .. " = "
    if table then
        local values = {}
        for i = 1, #names do
            values[i] = table .. "." .. names[i]
        end
        self.buf[#self.buf + 1] = concat(values, ", ")
    else
        self.buf[#self.buf + 1] = concat(names, ", ")
    end
    self:nl()
    return self
end

--- Generates the `=` operator, followed by an optional value.
---@param value? string The value to assign, if any.
---@return Self
function LuaBuilder:equals(value)
    self.buf[#self.buf + 1] = " = " .. (value or "")
    return self
end

--- Generates a single value.
---@param value string The value to generate.
---@return Self
function LuaBuilder:value(value)
    self.buf[#self.buf + 1] = value
    return self
end

--- Generates a list of values.
---@param values string[] The values to generate.
---@return Self
function LuaBuilder:values(values)
    self.buf[#self.buf + 1] = concat(values, ", ")
    return self
end

--- Helper function for formatting strings as lua string literals.
---@param string string The string to format.
---@return string formatted The formatted string.
---@nodiscard
local function str(string)
    return (format("%q", string):gsub("\\\n", "\\n"))
end

LuaBuilder.format_string = str
LuaBuilder.str = str

--- Appends `string` as a string literal.
---@param string string The string to format and append.
---@return Self
function LuaBuilder:string(string)
    self.buf[#self.buf + 1] = format("%q", string):gsub("\\\n", "\\n")
    return self
end

--TODO: Add support for serializing tables into lua source code.

--- Generates the `if` keyword.
---@return Self
function LuaBuilder:If()
    self.buf[#self.buf + 1] = "if "
    return self
end

--- Generates the `then` keyword.
---@return Self
function LuaBuilder:Then()
    self.buf[#self.buf + 1] = "then"
    self:nlin()
    return self
end

--- Generates an `if` statement, followed by a condition, and finally followed by the `then` keyword.
---@param condition string The condition to check.
---@return Self
function LuaBuilder:IfThen(condition)
    self.buf[#self.buf + 1] = "if " .. condition .. " then"
    self:nlin()
    return self
end

--- Generates the `elseif` keyword.
---@return Self
function LuaBuilder:ElseIf()
    self:nlde()
    self.buf[#self.buf + 1] = "elseif "
    return self
end

--- Generates an `elseif` statement, followed by a condition, and finally followed by the `then` keyword.
---@param condition string The condition to check.
---@return Self
function LuaBuilder:ElseIfThen(condition)
    self:nlde()
    self.buf[#self.buf + 1] = "elseif " .. condition .. " then"
    self:nlin()
    return self
end

--- Generates the `else` keyword.
---@return Self
function LuaBuilder:Else()
    self:nlde()
    self.buf[#self.buf + 1] = "else"
    self:nlin()
    return self
end

--- Generates the `end` keyword.
---@return Self
function LuaBuilder:End()
    self:nlde()
    self.buf[#self.buf + 1] = "end"
    return self
end

LuaBuilder.EndIf = LuaBuilder.End

--- Generates the `while` keyword.
---@return Self
function LuaBuilder:While()
    self.buf[#self.buf + 1] = "while "
    return self
end

--- Generates the `do` keyword. Used in while, repeat, and for loops.
---@return Self
function LuaBuilder:Do()
    self.buf[#self.buf + 1] = "do"
    self:nlin()
    return self
end

LuaBuilder.EndWhile = LuaBuilder.End

--- Generates the `repeat` keyword.
---@return Self
function LuaBuilder:Repeat()
    self.buf[#self.buf + 1] = "repeat"
    self:nlin()
    return self
end

--- Generates the `until` keyword, optionally followed by a condition.
---@param condition? string The condition to check, if any.
---@return Self
function LuaBuilder:Until(condition)
    self.buf[#self.buf + 1] = "until " .. (condition or "")
    return self
end

--- Generates the `break` keyword.
---@return Self
function LuaBuilder:Break()
    self.buf[#self.buf + 1] = "break"
    return self
end

LuaBuilder.EndRepeat = LuaBuilder.End

--- Generates the `for` keyword.
---@return Self
function LuaBuilder:For()
    self.buf[#self.buf + 1] = "for "
    return self
end

--- Generates the `in` keyword.
---@return Self
function LuaBuilder:In()
    self.buf[#self.buf + 1] = " in "
    return self
end

--- Generates a numeric for loop.
--- Example: `for i = 1, 10, 2 do`
---@param var string
---@param start number
---@param finish number
---@param step? number
---@return Self
function LuaBuilder:for_numeric_do(var, start, finish, step)
    self.buf[#self.buf + 1] = "for " .. var .. " = " .. start .. ", " .. finish .. (step and (", " .. step) or "") .. " do"
    self:nlin()
    return self
end

--- Generates a for loop with an iterator.
---@param vars string|string[] The variables to iterate over.
---@param iterator string The iterator to use.
---@return Self
function LuaBuilder:for_in_do(vars, iterator)
    if type(vars) == "table" then vars = concat(vars, ", ") end
    self.buf[#self.buf + 1] = "for " .. vars .. " in " .. iterator .. " do"
    self:nlin()
    return self
end

LuaBuilder.EndFor = LuaBuilder.End

--- Generates a function declaration.
---@param name? string The name of the function, if nil the function is anonymous.
---@param args? string|string[] The arguments of the function, if nil the function has no arguments.
---@return Self
function LuaBuilder:Function(name, args)
    if args == nil then args = ""
    elseif type(args) == "table" then args = concat(args, ", ")
    end
    self.buf[#self.buf + 1] = "function" .. (name and (" " .. name) or "") .. "(" .. args .. ")"
    self:nlin()
    return self
end

--- Generates the `...` variable.
---@return Self
function LuaBuilder:vararg()
    self.buf[#self.buf + 1] = "..."
    return self
end

LuaBuilder.va = LuaBuilder.vararg

--- Convience function for selecting a value from a vararg.
---@param index number The index of the value to select.
---@return Self
function LuaBuilder:select(index)
    self.buf[#self.buf + 1] = "select(" .. index .. ", ...)"
    return self
end

--- Convience function for getting the length of a vararg.
function LuaBuilder:va_len()
    self.buf[#self.buf + 1] = "select('#', ...)"
    return self
end

--- Generates a return statement, optionally followed by a list of values.
--- Note that `Return` on its own does not add a space after the `return` keyword.
--- To get around this, call `Return` with an empty string.
---@param values? string|string[] The values to return, if any.
---@return Self
function LuaBuilder:Return(values)
    if values == nil then values = ""
    elseif type(values) == "table" then values = concat(values, ", ")
    else values = " " .. values
    end
    self.buf[#self.buf + 1] = "return" .. values
    return self
end

LuaBuilder.EndFunction = LuaBuilder.End

--- Generates a call statement.
---@param args? string|string[] The arguments to pass to the function, if nil the function has no arguments.
---@return Self
function LuaBuilder:call(args)
    if args == nil then args = ""
    elseif type(args) == "table" then args = concat(args, ", ")
    end
    self.buf[#self.buf + 1] = "(" .. args .. ")"
    return self
end

--- Generates a call to a function.
---@param name string The name of the function to call.
---@param args? string|string[] The arguments to pass to the function, if nil the function has no arguments.
---@return Self
function LuaBuilder:call_function(name, args)
    if args == nil then args = ""
    elseif type(args) == "table" then args = concat(args, ", ")
    end
    self.buf[#self.buf + 1] = name .. "(" .. args .. ")"
    return self
end

--- Generates a call to a function with a string argument.
--- Lua allows the parentheses to be omitted when calling a function with a single string argument.
--- Example: `print"Hello World!"`
---@param name string The name of the function to call.
---@param string string The string argument to pass to the function.
---@return Self
function LuaBuilder:call_function_string(name, string)
    self.buf[#self.buf + 1] = name .. format("%q", string):gsub("\\\n", "\\n")
    return self
end

LuaBuilder.call_string = LuaBuilder.call_function_string

--- Generates a call to a method.
---@param name string The name of the method to call.
---@param args? string|string[] The arguments to pass to the method, if nil the method has no arguments.
---@return Self
function LuaBuilder:CallMethod(name, args)
    if args == nil then args = ""
    elseif type(args) == "table" then args = concat(args, ", ")
    end
    self.buf[#self.buf + 1] = ":" .. name .. "(" .. args .. ")"
    return self
end

--- Generates a `.`.
---@return Self
function LuaBuilder:dot()
    self.buf[#self.buf + 1] = "."
    return self
end

--- Generates a `,`.
---@return Self
function LuaBuilder:comma()
    self.buf[#self.buf + 1] = ","
    return self
end

--- Generates the start of a multi-line table literal `{`.
--- This method also raises the indentation level.
---@return Self
function LuaBuilder:table_start()
    self.buf[#self.buf + 1] = "{"
    self:nlin()
    return self
end

--- Generates the end of a multi-line table literal `}`.
--- This method also lowers the indentation level.
---@return Self
function LuaBuilder:table_end()
    self:nlde()
    self.buf[#self.buf + 1] = "}"
    return self
end

--- Generates the `nil` keyword.
---@return Self
function LuaBuilder:Nil()
    self.buf[#self.buf + 1] = "nil"
    return self
end

--- Generates the `true` keyword.
---@return Self
function LuaBuilder:True()
    self.buf[#self.buf + 1] = "true"
    return self
end

--- Generates the `false` keyword.
---@return Self
function LuaBuilder:False()
    self.buf[#self.buf + 1] = "false"
    return self
end

--- Generates the `self` keyword.
--- This is used to refer to the current instance of a class in a method.
---@return Self
function LuaBuilder:Self()
    self.buf[#self.buf + 1] = "self"
    return self
end

--- Generates the `==` operator, followed by a value to compare.
---@param value number|string The value to compare.
---@return Self
function LuaBuilder:eq(value)
    self.buf[#self.buf + 1] = "== " .. value .. " "
    return self
end

LuaBuilder.is_equal_to = LuaBuilder.eq

--- Generates the `~=` operator, followed by a value to compare.
---@param value number|string The value to compare.
---@return Self
function LuaBuilder:ne(value)
    self.buf[#self.buf + 1] = "~= " .. value .. " "
    return self
end

LuaBuilder.is_not_equal_to = LuaBuilder.ne

--- Generates the `>` operator, followed by a value to compare.
---@param value number|string The value to compare.
---@return Self
function LuaBuilder:gt(value)
    self.buf[#self.buf + 1] = "> " .. value .. " "
    return self
end

LuaBuilder.is_greater_than = LuaBuilder.gt

--- Generates the `>=` operator, followed by a value to compare.
---@param value number|string The value to compare.
---@return Self
function LuaBuilder:ge(value)
    self.buf[#self.buf + 1] = ">= " .. value .. " "
    return self
end

LuaBuilder.is_greater_than_or_equal_to = LuaBuilder.ge

--- Generates the `<` operator, followed by a value to compare.
---@param value number|string The value to compare.
---@return Self
function LuaBuilder:lt(value)
    self.buf[#self.buf + 1] = "< " .. value .. " "
    return self
end

LuaBuilder.is_less_than = LuaBuilder.lt

--- Generates the `<=` operator, followed by a value to compare.
---@param value number|string The value to compare.
---@return Self
function LuaBuilder:le(value)
    self.buf[#self.buf + 1] = "<= " .. value .. " "
    return self
end

LuaBuilder.is_less_than_or_equal_to = LuaBuilder.le

--- Generates the `and` keyword.
---@return Self
function LuaBuilder:And()
    self.buf[#self.buf + 1] = "and "
    return self
end

--- Generates the `or` keyword.
---@return Self
function LuaBuilder:Or()
    self.buf[#self.buf + 1] = "or "
    return self
end

--- Generates the `not` keyword.
---@return Self
function LuaBuilder:Not()
    self.buf[#self.buf + 1] = "not "
    return self
end

--- Convience function for generating a ternary expression.
---@param condition string The condition to check.
---@param true_value string The value if the condition is true.
---@param false_value string The value if the condition is false.
---@return Self
function LuaBuilder:ternary(condition, true_value, false_value)
    self.buf[#self.buf + 1] = condition .. " and " .. true_value .. " or " .. false_value
end

--- Generates the `#` operator, followed by an optional value.
---@param value? string The value to get the length of, if any.
---@return Self
function LuaBuilder:len(value)
    self.buf[#self.buf + 1] = "#" .. (value and (value .. " ") or "")
    return self
end

--- Generates the start of an index expression, with an optional value.
---@param index number|string The index to use.
---@param value? string The value to index into, if any.
---@return Self
function LuaBuilder:index(index, value)
    self.buf[#self.buf + 1] = (value or "") .. "[" .. index .. "]"
    return self
end

--- Generates a field access.
---@param field string The field to access.
---@return Self
function LuaBuilder:field(field)
    self.buf[#self.buf + 1] = "." .. field
    return self
end

--- Generates the `+` operator, followed by a value.
---@param value number|string The value to add.
---@return Self
function LuaBuilder:add(value)
    self.buf[#self.buf + 1] = " + " .. value
    return self
end

--- Generates the statement `name = name + value`.
--- Example: `i = i + 1`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to add.
---@return Self
function LuaBuilder:add_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " + " .. value
    self:nl()
    return self
end

--- Generates the `-` operator, followed by a value.
--- @param value number|string The value to subtract.
---@return Self
function LuaBuilder:sub(value)
    self.buf[#self.buf + 1] = " - " .. value
    return self
end

--- Generates the statement `name = name - value`.
--- Example: `i = i - 1`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to subtract.
---@return Self
function LuaBuilder:sub_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " - " .. value
    self:nl()
    return self
end

--- Generates the `*` operator, followed by a value.
---@param value number|string The value to multiply.
---@return Self
function LuaBuilder:mult(value)
    self.buf[#self.buf + 1] = " * " .. value
    return self
end

--- Generates the statement `name = name * value`.
--- Example: `a = a * 10`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to multiply.
---@return Self
function LuaBuilder:mult_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " * " .. value
    self:nl()
    return self
end

--- Generates the `/` operator, followed by a value.
---@param value number|string The value to divide.
---@return Self
function LuaBuilder:div(value)
    self.buf[#self.buf + 1] = " / " .. value
    return self
end

--- Generates the statement `name = name / value`.
--- Example: `a = a / 10`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to divide.
---@return Self
function LuaBuilder:div_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " / " .. value
    self:nl()
    return self
end

--- Generates the `%` operator, followed by a value.
---@param value number|string The value to modulo.
---@return Self
function LuaBuilder:mod(value)
    self.buf[#self.buf + 1] = " % " .. value
    return self
end

--- Generates the statement `name = name % value`.
--- Example: `a = a % 10`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to modulo.
---@return Self
function LuaBuilder:mod_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " % " .. value
    self:nl()
    return self
end

--- Generates the `^` operator, followed by a value.
---@param value number|string The value to raise to the power of.
---@return Self
function LuaBuilder:pow(value)
    self.buf[#self.buf + 1] = " ^ " .. value
    return self
end

--- Generates the statement `name = name ^ value`.
--- Example: `a = a ^ 2`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to raise to the power of.
---@return Self
function LuaBuilder:pow_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " ^ " .. value
    self:nl()
    return self
end

--- Generates the `..` operator, followed by a value.
---@param value number|string The value to concatenate.
---@return Self
function LuaBuilder:concat(value)
    self.buf[#self.buf + 1] = " .. " .. value
    return self
end

--- Generates the statement `name = name .. value`.
--- Example: `s = s .. " World!"`
---@param name string The name of the variable to assign the result to.
---@param value number|string The value to concatenate.
---@return Self
function LuaBuilder:concat_assign(name, value)
    self.buf[#self.buf + 1] = name .. " =" .. name .. " .. " .. value
    self:nl()
    return self
end

--- Convience function for pushing a value onto a table.
---@param name string The name of the table to push the value onto.
---@param value number|string The value to push onto the table.
---@return Self
function LuaBuilder:push(name, value)
    self.buf[#self.buf + 1] = name .. "[#" .. name .. " + 1] = " .. value
    return self
end

--- Convience function for getting the top value of a table.
---@param name string The name of the table to get the top value of.
---@return Self
function LuaBuilder:get_top(name)
    self.buf[#self.buf + 1] = name .. "[#" .. name .. "]"
end



--- Convience function for requiring a module.
---@param module string The name of the module to require.
---@param path? string The path to the module. Default to the module name.
---@return Self
function LuaBuilder:require(module, path)
    self.buf[#self.buf + 1] = "require" .. "(\"" .. (path or module) .. "\")"
    return self
end

return LuaBuilder