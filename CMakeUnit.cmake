# CMakeUnit v1.0.0
# https://github.com/tawez/CMakeUnit
#
# MIT License
#
# Copyright (c) 2025 Maciej Stankiewicz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.


cmake_policy(SET CMP0057 NEW)


# {{{ Core functions

# Add a test to be run by ctest.
# Test will be run with CMAKE_MODULE_PATH set to its current value.
# Usage:
#   add_cmake_test(<name> <path>
#                  [SKIP]
#                  [WILL_FAIL]
#                  [OPTIONS args...])
# Params:
#   name       Test name
#   path       Path to test source resolved from the CMAKE_CURRENT_SOURCE_DIR.
#              If path is a folder, CMakeLists.txt is expected to be inside.
#   SKIP       Skip this test but keep it in test report
#   WILL_FAIL  Denote this test as expected to fail.  Will set test property
#              WILL_FAIL to true.
#   OPTIONS    Additional test options.  This is a convenient way to set up test ENV.
function(add_cmake_test name path)
    set(options SKIP WILL_FAIL)
    set(oneValueArgs "")
    set(multiValueArgs OPTIONS)
    cmake_parse_arguments(arg "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(test_path_ "${path}" ABSOLUTE)
    if (IS_DIRECTORY "${test_path_}")
        cmake_path(APPEND path "CMakeLists.txt")
    endif ()
    get_filename_component(test_path_ "${path}" ABSOLUTE)
    if (NOT EXISTS "${test_path_}")
        message(FATAL_ERROR "${path} not found")
    elseif (IS_DIRECTORY "${test_path_}")
        message(FATAL_ERROR "${path} is not a file")
    endif ()

    if (${arg_SKIP})
        add_test(
            NAME "${name}"
            COMMAND ${CMAKE_COMMAND} -E echo "Skip '${name}' test"
        )
        set_property(TEST "${name}" PROPERTY SKIP_REGULAR_EXPRESSION "Skip '${name}' test")
        return()
    endif ()

    configure_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/${path}"
        "${CMAKE_CURRENT_BINARY_DIR}/${path}"
        @ONLY
    )

    add_test(
        NAME "${name}"
        COMMAND ${CMAKE_COMMAND}
        ${arg_OPTIONS}
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        -P "${CMAKE_CURRENT_BINARY_DIR}/${path}"
    )
    if (${arg_WILL_FAIL})
        set_property(TEST "${name}" PROPERTY WILL_FAIL true)
    endif ()
endfunction()


# Add a custom target that will run ctest to execute registered tests.
# Usage:
#   add_cmakeunit_target(<name> [args...])
# Params:
#   name  Target name (usually there is no need to pass anything more).
#   args  Additional target options (all add_custom_target options are accepted).
macro(add_cmakeunit_target name)
    add_custom_target(
        "${name}"
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        ${ARGN}
    )
endmacro()

# }}} Core functions


# {{{ Reporters

# Generate a fatal error and abort the current test/code.
# Usage:
#   FATAL([text...])
# Params:
#   text  Text to display when reporting error.
macro(FATAL)
    message(FATAL_ERROR "${ARGN}")
endmacro()


# Generate a non-fatal error and allow the current test/code to continue.
# Usage:
#   FAIL([text...])
# Params:
#   text  Text to display when reporting error.
macro(FAIL)
    message(SEND_ERROR "${ARGN}")
endmacro()

# }}} Reporters


# {{{ Assertions

# Verify if the value is true.
# Usage:
#   ASSERT_TRUE(<value>)
# Params:
#   value  Value to test
# Report:
#   fatal error  if the value is not true
macro(ASSERT_TRUE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (NOT ${value})
            FATAL("'${value}' is expected to be 'true'")
        endif ()
    endblock()
endmacro()

# Verify if the value is true.
# Usage:
#   EXPECT_TRUE(<value>)
# Params:
#   value  Value to test
# Report:
#   non-fatal error  if the value is not true
macro(EXPECT_TRUE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (NOT ${value})
            FAIL("'${value}' is expected to be 'true'")
        endif ()
    endblock()
endmacro()


# Verify if the value is false.
# Usage:
#   ASSERT_FALSE(<value>)
# Params:
#   value  Value to test
# Report:
#   fatal error  if the value is not false
macro(ASSERT_FALSE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (${value})
            FATAL("'${value}' is expected to be 'false'")
        endif ()
    endblock()
endmacro()

# Verify if the value is false.
# Usage:
#   EXPECT_FALSE(<value>)
# Params:
#   value  Value to test
# Report:
#   non-fatal error  if the value is not false
macro(EXPECT_FALSE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (${value})
            FAIL("'${value}' is expected to be 'false'")
        endif ()
    endblock()
endmacro()


# Verify if the variable is defined.
# Usage:
#   ASSERT_DEFINED(<variable>)
# Params:
#   variable  Variable to test
# Report:
#   fatal error  if the variable is not defined
macro(ASSERT_DEFINED variable)
    if (NOT DEFINED ${variable})
        FATAL("'${variable}' is expected to be defined")
    endif ()
endmacro()

# Verify if the variable is defined.
# Usage:
#   EXPECT_DEFINED(<variable>)
# Params:
#   variable  Variable to test
# Report:
#   non-fatal error  if the variable is not defined
macro(EXPECT_DEFINED variable)
    if (NOT DEFINED ${variable})
        FAIL("'${variable}' is expected to be defined")
    endif ()
endmacro()


# Verify if the variable is undefined.
# Usage:
#   ASSERT_UNDEFINED(<variable>)
# Params:
#   variable  Variable to test
# Report:
#   fatal error  if the variable is defined
macro(ASSERT_UNDEFINED variable)
    if (DEFINED ${variable})
        FATAL("'${variable}' is expected not to be defined")
    endif ()
endmacro()

# Verify if the variable is undefined.
# Usage:
#   EXPECT_UNDEFINED(<variable>)
# Params:
#   variable  Variable to test
# Report:
#   non-fatal error  if the variable is defined
macro(EXPECT_UNDEFINED variable)
    if (DEFINED ${variable})
        FAIL("'${variable}' is expected not to be defined")
    endif ()
endmacro()


# Verify if two strings, value and expected, have the same content.
# Usage:
#   ASSERT_STREQ(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if values differ
macro(ASSERT_STREQ value expected)
    if (NOT "${value}" STREQUAL "${expected}")
        FATAL("'${value}' is expected to equal to '${expected}'")
    endif ()
endmacro()

# Verify if two strings, value and expected, have the same content.
# Usage:
#   EXPECT_STREQ(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if values differ
macro(EXPECT_STREQ value expected)
    if (NOT "${value}" STREQUAL "${expected}")
        FAIL("'${value}' is expected to equal to '${expected}'")
    endif ()
endmacro()


# Verify if two strings, value and expected, have different content.
# Usage:
#   ASSERT_NOT_STREQ(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if values are equal
macro(ASSERT_NOT_STREQ value expected)
    if ("${value}" STREQUAL "${expected}")
        FATAL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endmacro()

# Verify if two strings, value and expected, have different content.
# Usage:
#   EXPECT_NOT_STREQ(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if values are equal
macro(EXPECT_NOT_STREQ value expected)
    if ("${value}" STREQUAL "${expected}")
        FAIL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endmacro()


# Verify if the value matches the pattern.
# Usage:
#   ASSERT_MATCH(<value> <pattern>)
# Params:
#   value    Value to test
#   pattern  Pattern to test value against
# Report:
#   fatal error  if the value does not match the pattern
macro(ASSERT_MATCH value pattern)
    if (NOT "${value}" MATCHES "${pattern}")
        FATAL("'${value}' is expected to match '${pattern}'")
    endif ()
endmacro()

# Verify if the value matches the pattern.
# Usage:
#   EXPECT_MATCH(<value> <pattern>)
# Params:
#   value    Value to test
#   pattern  Pattern to test value against
# Report:
#   non-fatal error  if the value does not match the pattern
macro(EXPECT_MATCH value pattern)
    if (NOT "${value}" MATCHES "${pattern}")
        FAIL("'${value}' is expected to match '${pattern}'")
    endif ()
endmacro()


# Verify if the value does not match the pattern.
# Usage:
#   ASSERT_NOT_MATCH(<value> <pattern>)
# Params:
#   value    Value to test
#   pattern  Pattern to test value against
# Report:
#   fatal error  if the value matches the pattern
macro(ASSERT_NOT_MATCH value pattern)
    if ("${value}" MATCHES "${pattern}")
        FATAL("'${value}' is expected not to match '${pattern}'")
    endif ()
endmacro()

# Verify if the value does not match the pattern.
# Usage:
#   EXPECT_NOT_MATCH(<value> <pattern>)
# Params:
#   value    Value to test
#   pattern  Pattern to test value against
# Report:
#   non-fatal error  if the value matches the pattern
macro(EXPECT_NOT_MATCH value pattern)
    if ("${value}" MATCHES "${pattern}")
        FAIL("'${value}' is expected not to match '${pattern}'")
    endif ()
endmacro()


# Verify if the value equals to the expected.
# Usage:
#   ASSERT_EQ(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if values differ
function(ASSERT_EQ value expected)
    if (NOT value EQUAL expected)
        FATAL("'${value}' is expected to equal to '${expected}'")
    endif ()
endfunction()

# Verify if the value equals to the expected.
# Usage:
#   EXPECT_EQ(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if values differ
function(EXPECT_EQ value expected)
    if (NOT value EQUAL expected)
        FAIL("'${value}' is expected to equal to '${expected}'")
    endif ()
endfunction()


# Verify if the value does not equal to the expected.
# Usage:
#   ASSERT_NE(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if values are equal
function(ASSERT_NE value expected)
    if (value EQUAL expected)
        FATAL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endfunction()

# Verify if the value does not equal to the expected.
# Usage:
#   EXPECT_NE(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if values are equal
function(EXPECT_NE value expected)
    if (value EQUAL expected)
        FAIL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endfunction()


# Verify if the value is less than the expected.
# Usage:
#   ASSERT_LT(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if the value is not less than expected
function(ASSERT_LT value expected)
    if (NOT value LESS expected)
        FATAL("'${value}' is expected to be lower than '${expected}'")
    endif ()
endfunction()

# Verify if the value is less than the expected.
# Usage:
#   EXPECT_LT(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if the value is not less than expected
function(EXPECT_LT value expected)
    if (NOT value LESS expected)
        FAIL("'${value}' is expected to be lower than '${expected}'")
    endif ()
endfunction()


# Verify if the value is less than or equal to the expected.
# Usage:
#   ASSERT_LE(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if the value is greater than expected
function(ASSERT_LE value expected)
    if (NOT value LESS_EQUAL expected)
        FATAL("'${value}' is expected to be lower than or equal to '${expected}'")
    endif ()
endfunction()

# Verify if the value is less than or equal to the expected.
# Usage:
#   EXPECT_LE(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if the value is greater than expected
function(EXPECT_LE value expected)
    if (NOT value LESS_EQUAL expected)
        FAIL("'${value}' is expected to be lower than or equal to '${expected}'")
    endif ()
endfunction()


# Verify if the value is greater than the expected.
# Usage:
#   ASSERT_GT(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if the value is not greater than expected
function(ASSERT_GT value expected)
    if (NOT value GREATER expected)
        FATAL("'${value}' is expected to be greater than '${expected}'")
    endif ()
endfunction()

# Verify if the value is greater than the expected.
# Usage:
#   EXPECT_GT(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if the value is not greater than expected
function(EXPECT_GT value expected)
    if (NOT value GREATER expected)
        FAIL("'${value}' is expected to be greater than '${expected}'")
    endif ()
endfunction()


# Verify if the value is greater than or equal to the expected.
# Usage:
#   ASSERT_GE(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   fatal error  if the value is less than expected
function(ASSERT_GE value expected)
    if (NOT value GREATER_EQUAL expected)
        FATAL("'${value}' is expected to be greater than or equal to '${expected}'")
    endif ()
endfunction()

# Verify if the value is greater than or equal to the expected.
# Usage:
#   EXPECT_GE(<value> <expected>)
# Params:
#   value     Value to test
#   expected  Expected value
# Report:
#   non-fatal error  if the value is less than expected
function(EXPECT_GE value expected)
    if (NOT value GREATER_EQUAL expected)
        FAIL("'${value}' is expected to be greater than or equal to '${expected}'")
    endif ()
endfunction()


# Verify if the length of the list is in relation to the given expected value.
# Usage:
#   ASSERT_LIST_LENGTH(<variable> <relation> <expected>)
# Params:
#   variable  List variable to test
#   relation  One of: EQ, NE, LT, LE, GT, GE
#   expected  Expected list length
# Report:
#   fatal error  if the list length is not in relation to expected value
function(ASSERT_LIST_LENGTH variable relation expected)
    set(valid_relation_ EQ NE LT LE GT GE)
    if (NOT relation IN_LIST valid_relation_)
        FATAL("Invalid relation '${relation}'")
    endif ()

    list(LENGTH ${variable} actual_length_)
    cmake_language(CALL "ASSERT_${relation}" ${actual_length_} ${expected})
endfunction()

# Verify if the length of the list is in relation to the given expected value.
# Usage:
#   EXPECT_LIST_LENGTH(<variable> <relation> <expected>)
# Params:
#   variable  List variable to test
#   relation  One of: EQ, NE, LT, LE, GT, GE
#   expected  Expected list length
# Report:
#   non-fatal error  if the list length is not in relation to expected value
function(EXPECT_LIST_LENGTH variable relation expected)
    set(valid_relation_ EQ NE LT LE GT GE)
    if (NOT relation IN_LIST valid_relation_)
        FATAL("Invalid relation '${relation}'")
    endif ()

    list(LENGTH ${variable} actual_length_)
    cmake_language(CALL "EXPECT_${relation}" ${actual_length_} ${expected})
endfunction()


# Verify if the value equals to the list made of the given item(s).
# Usage:
#   ASSERT_LIST_EQ(<value> [<item>...])
# Params:
#   value    Value to test
#   item...  Expected content of the list
# Report:
#   fatal error  if the value differs from the given list of items
function(ASSERT_LIST_EQ value)
    if (NOT "${value}" STREQUAL "${ARGN}")
        FATAL("'${value}' is expected to equal to '${ARGN}'")
    endif ()
endfunction()

# Verify if the value equals to the list made of the given item(s).
# Usage:
#   EXPECT_LIST_EQ(<value> [<item>...])
# Params:
#   value    Value to test
#   item...  Expected content of the list
# Report:
#   non-fatal error  if the value differs from the given list of items
function(EXPECT_LIST_EQ value)
    if (NOT "${value}" STREQUAL "${ARGN}")
        FAIL("'${value}' is expected to equal to '${ARGN}'")
    endif ()
endfunction()


# Verify if the value contains all the given item(s) without any particular order.
# Usage:
#   ASSERT_LIST_CONTAINS(<value> [<item>...])
# Params:
#   value    Value to test
#   item...  Expected content of the list
# Report:
#   fatal error  if the value does not contain at least one item
function(ASSERT_LIST_CONTAINS value)
    set(not_found_ "")
    foreach(item_ IN LISTS ARGN)
        if (NOT item_ IN_LIST value)
            list(APPEND not_found_ ${item_})
        endif ()
    endforeach ()
    if (NOT "${not_found_}" STREQUAL "")
        FATAL("'${value}' is expected to contain '${not_found_}'")
    endif ()
endfunction()

# Verify if the value contains all the given item(s) without any particular order.
# Usage:
#   EXPECT_LIST_CONTAINS(<value> [<item>...])
# Params:
#   value    Value to test
#   item...  Expected content of the list
# Report:
#   non-fatal error  if the value does not contain at least one item
function(EXPECT_LIST_CONTAINS value)
    set(not_found_ "")
    foreach(item_ IN LISTS ARGN)
        if (NOT item_ IN_LIST value)
            list(APPEND not_found_ ${item_})
        endif ()
    endforeach ()
    if (NOT "${not_found_}" STREQUAL "")
        FAIL("'${value}' is expected to contain '${not_found_}'")
    endif ()
endfunction()

# }}} Assertions


# {{{ Mocks

# Define a mock function with the given name.
# Usage:
#   MOCK_FUNCTION(<name>)
# Params:
#   name  Name of the mock to be created
# Report:
#   fatal error  if mock function for the same name is defined again
function(MOCK_FUNCTION name)
    get_property(is_mock_defined_ GLOBAL PROPERTY "MOCK_FUNCTION_${name}" SET)
    if (is_mock_defined_)
        FATAL("Mock function '${name}' is already defined")
    endif ()
    set_property(GLOBAL PROPERTY "MOCK_FUNCTION_${name}" "")

    function(${name})
        get_property(call_log_ GLOBAL PROPERTY "MOCK_FUNCTION_${CMAKE_CURRENT_FUNCTION}")
        list(JOIN ARGN " " call_args_)
        set_property(GLOBAL APPEND PROPERTY "MOCK_FUNCTION_${CMAKE_CURRENT_FUNCTION}" "(${call_args_})")
    endfunction()
endfunction()


# Verify if the mock has been called the expected number of times.
# Usage:
#   EXPECT_CALL_TIMES(<name> <expected>)
# Params:
#   name      Mock function name
#   expected  Expected number of mock function calls (no less than 0)
# Report:
#   fatal error      if mock function is not defined
#                    or if expected is less than 0
#   non-fatal error  if mock function was not called expected number of times
function(EXPECT_CALL_TIMES name expected)
    get_property(is_mock_defined_ GLOBAL PROPERTY "MOCK_FUNCTION_${name}" SET)
    if (NOT is_mock_defined_)
        FATAL("Mock function '${name}' is not defined")
    endif ()

    if (expected LESS 0)
        FATAL("'expected' is ${expected} but should be greater or equal 0")
    endif ()

    get_property(call_log_ GLOBAL PROPERTY "MOCK_FUNCTION_${name}")
    list(LENGTH call_log_ call_count_)
    if (NOT call_count_ EQUAL expected)
        if (NOT call_count_ EQUAL 1)
            set(pl_ "s")
        endif ()
        FAIL("'${name}' has been called ${call_count_} time${pl_} but ${expected} is expected")
    endif ()
endfunction()


# Verify if the nth call of the mock function has been done with the given arguments.
# Usage:
#   EXPECT_CALL_WITH(<name> <nth> [<arg>...])
# Params:
#   name    Mock function name
#   nth     Number of the call of the mock function to verify
#   arg...  List of expected arguments
# Report:
#   fatal error      if mock function is not defined
#                    or if nth is less than 1
#   non-fatal error  if mock function has not been called
#                    or if has been called less than nth times
#                    or if expected arguments differ to actual
function(EXPECT_CALL_WITH name nth)
    get_property(is_mock_defined_ GLOBAL PROPERTY "MOCK_FUNCTION_${name}" SET)
    if (NOT is_mock_defined_)
        FATAL("Mock function '${name}' is not defined")
    endif ()

    if (nth LESS 1)
        FATAL("'nth' is ${nth} but should be greater than 0")
    endif ()

    get_property(call_log_ GLOBAL PROPERTY "MOCK_FUNCTION_${name}")
    list(LENGTH call_log_ call_count_)
    if (call_count_ EQUAL 0)
        FAIL("'${name}' has not been called yet")
        return()
    endif ()

    if (nth GREATER call_count_)
        if (NOT call_count_ EQUAL 1)
            set(pl_ "s")
        endif ()
        FAIL("'${name}' has been called ${call_count_} time${pl_} but at least ${nth} is expected")
        return()
    endif ()

    list(JOIN ARGN " " expected_args_)
    set(expected_args_ "(${expected_args_})")
    math(EXPR nth_call_ "${nth} - 1")
    list(GET call_log_ ${nth_call_} actual_args_)
    if (NOT expected_args_ STREQUAL actual_args_)
        FAIL("'${name}' was called with ${actual_args_} but ${expected_args_} is expected")
    endif ()
endfunction()
# }}} Mocks
