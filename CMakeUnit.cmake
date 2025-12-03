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
function(add_cmake_test name path)
    set(options SKIP WILL_FAIL)
    set(oneValueArgs "")
    set(multiValueArgs OPTIONS)
    cmake_parse_arguments(test "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    get_filename_component(testPath "${path}" ABSOLUTE)
    if (IS_DIRECTORY "${testPath}")
        cmake_path(APPEND path "CMakeLists.txt")
    endif ()
    get_filename_component(testPath "${path}" ABSOLUTE)
    if (NOT EXISTS "${testPath}")
        message(FATAL_ERROR "${path} not found")
    elseif (IS_DIRECTORY "${testPath}")
        message(FATAL_ERROR "${path} is not a file")
    endif ()

    if (${test_SKIP})
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
        ${test_OPTIONS}
        "-DCMAKE_MODULE_PATH=${CMAKE_MODULE_PATH}"
        -P "${CMAKE_CURRENT_BINARY_DIR}/${path}"
    )
    if (${test_WILL_FAIL})
        set_property(TEST "${name}" PROPERTY WILL_FAIL true)
    endif ()
endfunction()

macro(add_cmakeunit_target name)
    add_custom_target(
        "${name}"
        COMMAND ${CMAKE_CTEST_COMMAND} --output-on-failure
        ${ARGN}
    )
endmacro()
# }}} Core functions


# {{{ CMakeUnit internal helpers
function(CMakeUnit_check_relation relation)
    set(validRelation EQ NE LT LE GT GE)
    if (NOT relation IN_LIST validRelation)
        FATAL("Invalid relation '${relation}'")
    endif ()
endfunction()
# }}} CMakeUnit internal helpers


# {{{ Assertions
macro(FATAL)
    message(FATAL_ERROR "${ARGN}")
endmacro()

macro(ASSERT_TRUE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (NOT ${value})
            FATAL("'${value}' is expected to be 'true'")
        endif ()
    endblock()
endmacro()

macro(ASSERT_FALSE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (${value})
            FATAL("'${value}' is expected to be 'false'")
        endif ()
    endblock()
endmacro()

macro(ASSERT_DEFINED variable)
    if (NOT DEFINED ${variable})
        FATAL("'${variable}' is expected to be defined")
    endif ()
endmacro()

macro(ASSERT_UNDEFINED variable)
    if (DEFINED ${variable})
        FATAL("'${variable}' is expected not to be defined")
    endif ()
endmacro()

macro(ASSERT_STREQ value expected)
    if (NOT "${value}" STREQUAL "${expected}")
        FATAL("'${value}' is expected to equal to '${expected}'")
    endif ()
endmacro()

macro(ASSERT_NOT_STREQ value expected)
    if ("${value}" STREQUAL "${expected}")
        FATAL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endmacro()

macro(ASSERT_MATCH value pattern)
    if (NOT "${value}" MATCHES "${pattern}")
        FATAL("'${value}' is expected to match '${pattern}'")
    endif ()
endmacro()

macro(ASSERT_NOT_MATCH value pattern)
    if ("${value}" MATCHES "${pattern}")
        FATAL("'${value}' is expected not to match '${pattern}'")
    endif ()
endmacro()

function(ASSERT_EQ value expected)
    if (NOT value EQUAL expected)
        FATAL("'${value}' is expected to equal to '${expected}'")
    endif ()
endfunction()

function(ASSERT_NE value expected)
    if (value EQUAL expected)
        FATAL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endfunction()

function(ASSERT_LT value expected)
    if (NOT value LESS expected)
        FATAL("'${value}' is expected to be lower than '${expected}'")
    endif ()
endfunction()

function(ASSERT_LE value expected)
    if (NOT value LESS_EQUAL expected)
        FATAL("'${value}' is expected to be lower than or equal to '${expected}'")
    endif ()
endfunction()

function(ASSERT_GT value expected)
    if (NOT value GREATER expected)
        FATAL("'${value}' is expected to be greater than '${expected}'")
    endif ()
endfunction()

function(ASSERT_GE value expected)
    if (NOT value GREATER_EQUAL expected)
        FATAL("'${value}' is expected to be greater than or equal to '${expected}'")
    endif ()
endfunction()

function(ASSERT_LIST_LENGTH variable relation expected)
    CMakeUnit_check_comparison(${relation})
    list(LENGTH ${variable} actualLength)
    cmake_language(CALL "ASSERT_${relation}" ${actualLength} ${expected})
endfunction()

function(ASSERT_LIST_EQ variable)
    if (NOT "${variable}" STREQUAL "${ARGN}")
        FATAL("'${variable}' is expected to equal to '${ARGN}'")
    endif ()
endfunction()

macro(FAIL)
    message(SEND_ERROR "${ARGN}")
endmacro()

macro(EXPECT_TRUE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (NOT ${value})
            FAIL("'${value}' is expected to be 'true'")
        endif ()
    endblock()
endmacro()

macro(EXPECT_FALSE value)
    block(SCOPE_FOR POLICIES)
        cmake_policy(SET CMP0012 NEW)
        if (${value})
            FAIL("'${value}' is expected to be 'false'")
        endif ()
    endblock()
endmacro()

macro(EXPECT_DEFINED variable)
    if (NOT DEFINED ${variable})
        FAIL("'${variable}' is expected to be defined")
    endif ()
endmacro()

macro(EXPECT_UNDEFINED variable)
    if (DEFINED ${variable})
        FAIL("'${variable}' is expected not to be defined")
    endif ()
endmacro()

macro(EXPECT_STREQ value expected)
    if (NOT "${value}" STREQUAL "${expected}")
        FAIL("'${value}' is expected to equal to '${expected}'")
    endif ()
endmacro()

macro(EXPECT_NOT_STREQ value expected)
    if ("${value}" STREQUAL "${expected}")
        FAIL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endmacro()

macro(EXPECT_MATCH value pattern)
    if (NOT "${value}" MATCHES "${pattern}")
        FAIL("'${value}' is expected to match '${pattern}'")
    endif ()
endmacro()

macro(EXPECT_NOT_MATCH value pattern)
    if ("${value}" MATCHES "${pattern}")
        FAIL("'${value}' is expected not to match '${pattern}'")
    endif ()
endmacro()

function(EXPECT_EQ value expected)
    if (NOT value EQUAL expected)
        FAIL("'${value}' is expected to equal to '${expected}'")
    endif ()
endfunction()

function(EXPECT_NE value expected)
    if (value EQUAL expected)
        FAIL("'${value}' is expected not to equal to '${expected}'")
    endif ()
endfunction()

function(EXPECT_LT value expected)
    if (NOT value LESS expected)
        FAIL("'${value}' is expected to be lower than '${expected}'")
    endif ()
endfunction()

function(EXPECT_LE value expected)
    if (NOT value LESS_EQUAL expected)
        FAIL("'${value}' is expected to be lower than or equal to '${expected}'")
    endif ()
endfunction()

function(EXPECT_GT value expected)
    if (NOT value GREATER expected)
        FAIL("'${value}' is expected to be greater than '${expected}'")
    endif ()
endfunction()

function(EXPECT_GE value expected)
    if (NOT value GREATER_EQUAL expected)
        FAIL("'${value}' is expected to be greater than or equal to '${expected}'")
    endif ()
endfunction()

function(EXPECT_LIST_LENGTH variable relation expected)
    CMakeUnit_check_relation(${relation})
    list(LENGTH ${variable} actualLength)
    cmake_language(CALL "EXPECT_${relation}" ${actualLength} ${expected})
endfunction()

function(EXPECT_LIST_EQ value)
    if (NOT "${value}" STREQUAL "${ARGN}")
        FAIL("'${value}' is expected to equal to '${ARGN}'")
    endif ()
endfunction()
# }}} Assertions
