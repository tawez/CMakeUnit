# CMakeUnit

CMakeUnit is a small set of functions and macros useful when testing CMake code.
There are three main scenarios how you can use CMakeUnit:

1. TDD the code, functions and macros
2. Run a part of the code in isolation
3. Use assertions in production code


## Project setup

1. Include [CTest][cmake::CTest]
2. Add location of CMakeUnit module and location of every module you want to
   test to the [CMAKE_MODULE_PATH][cmake::CMAKE_MODULE_PATH]
3. Add all the tests that you need with [add_cmake_test](#add_cmake_test)
4. Add test target with [add_cmakeunit_target](#add_cmakeunit_target)

When done, follow the usual steps to run the test target:

```bash
mkdir build
cd build
cmake ..
make <cmakeunit target name>
```

For complete project setup and test examples, see 
[CMakeUnit-example](https://github.com/tawez/CMakeUnit-example).

To use CMakeUnit in production code, just include CMakeUnit and use assertions wherever needed. 


## API

- [Core functions](#core-functions)
- [Reporters](#reporters)
- [Assertions](#assertions)
- [Mocks](#mocks)

### Core functions

- [add_cmake_test](#add_cmake_test)
- [add_cmakeunit_target](#add_cmakeunit_target)


#### add_cmake_test

Add a test to be run by ctest.
Test will be run with CMAKE_MODULE_PATH set to its current value.

##### Usage

```cmake
add_cmake_test(<name> <path>
               [SKIP]
               [WILL_FAIL]
               [OPTIONS args...])
```

##### Params

- `name`       Test name
- `path`       Path to test source resolved from the CMAKE_CURRENT_SOURCE_DIR.
               If path is a folder, CMakeLists.txt is expected to be inside.
- `SKIP`       Skip this test but keep it in test report
- `WILL_FAIL`  Denote this test as expected to fail.
               Will set test property WILL_FAIL to true.
- `OPTIONS`    Additional test options.  This is a convenient way to set up test ENV.


#### add_cmakeunit_target

Add a custom target that will run ctest to execute registered tests.

##### Usage

```cmake
add_cmakeunit_target(<name> [args...])
```

##### Params

- `name`  Target name (usually there is no need to pass anything more).
- `args`  Additional target options (all add_custom_target options are accepted).


### Reporters

- [FATAL](#fatal)
- [FAIL](#fail)


#### FATAL

Generate a fatal error and abort the current test/code.

##### Usage

```cmake
FATAL([text...])
```

##### Params

- `text`  Text to display when reporting error.


#### FAIL

Generate a non-fatal error and allow the current test/code to continue.

##### Usage

```cmake
FAIL([text...])
```

##### Params

- `text`  Text to display when reporting error.


### Assertions

The following assertions come as a pair of variants `ASSERT` and `EXPECT`.
Upon failure, `ASSERT` generates fatal error and aborts the execution of
the current test/code, while `EXPECT` generates non-fatal error and allows
the current test/code to continue.

> **NOTE:**
> If not specified, _error_ means _fatal error_ for `ASSERT` and
> _non-fatal error_ for `EXPECT` assertions.

- [ASSERT_TRUE / EXPECT_TRUE](#assert_true--expect_true)
- [ASSERT_FALSE / EXPECT_FALSE](#assert_false--expect_false)
- [ASSERT_DEFINED / EXPECT_DEFINED](#assert_defined--expect_defined)
- [ASSERT_UNDEFINED / EXPECT_UNDEFINED](#assert_undefined--expect_undefined)
- [ASSERT_STREQ / EXPECT_STREQ](#assert_streq--expect_streq)
- [ASSERT_NOT_STREQ / EXPECT_NOT_STREQ](#assert_not_streq--expect_not_streq)
- [ASSERT_MATCH / EXPECT_MATCH](#assert_match--expect_match)
- [ASSERT_NOT_MATCH / EXPECT_NOT_MATCH](#assert_not_match--expect_not_match)
- [ASSERT_EQ / EXPECT_EQ](#assert_eq--expect_eq)
- [ASSERT_NE / EXPECT_NE](#assert_ne--expect_ne)
- [ASSERT_LT / EXPECT_LT](#assert_lt--expect_lt)
- [ASSERT_LE / EXPECT_LE](#assert_le--expect_le)
- [ASSERT_GT / EXPECT_GT](#assert_gt--expect_gt)
- [ASSERT_GE / EXPECT_GE](#assert_ge--expect_ge)
- [ASSERT_LIST_LENGTH / EXPECT_LIST_LENGTH](#assert_list_length--expect_list_length)
- [ASSERT_LIST_EQ / EXPECT_LIST_EQ](#assert_list_eq--expect_list_eq)
- [ASSERT_LIST_CONTAINS / EXPECT_LIST_CONTAINS](#assert_list_contains--expect_list_contains)


#### ASSERT_TRUE / EXPECT_TRUE

Verify if the value is true.

##### Usage

```cmake
ASSERT_TRUE(<value>)
EXPECT_TRUE(<value>)
```

##### Params

- `value`  Value to test

##### Reports

- `error`  if the value is not true


#### ASSERT_FALSE / EXPECT_FALSE

Verify if the value is false.

##### Usage

```cmake
ASSERT_FALSE(<value>)
EXPECT_FALSE(<value>)
```

##### Params

- `value`  Value to test

##### Reports

- `error`  if the value is not false


#### ASSERT_DEFINED / EXPECT_DEFINED

Verify if the variable is defined.

##### Usage

```cmake
ASSERT_DEFINED(<variable>)
EXPECT_DEFINED(<variable>)
```

##### Params

- `variable`  Variable to test

##### Reports

- `error`  if the variable is not defined


#### ASSERT_UNDEFINED / EXPECT_UNDEFINED

Verify if the variable is undefined.

##### Usage

```cmake
ASSERT_UNDEFINED(<variable>)
EXPECT_UNDEFINED(<variable>)
```

##### Params

- `variable`  Variable to test

##### Reports

- `error`  if the variable is defined


#### ASSERT_STREQ / EXPECT_STREQ

Verify if two strings, value and expected, have the same content.

##### Usage

```cmake
ASSERT_STREQ(<value> <expected>)
EXPECT_STREQ(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if values differ


#### ASSERT_NOT_STREQ / EXPECT_NOT_STREQ

Verify if two strings, value and expected, have different content.

##### Usage

```cmake
ASSERT_NOT_STREQ(<value> <expected>)
EXPECT_NOT_STREQ(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if values are equal


#### ASSERT_MATCH / EXPECT_MATCH
        
Verify if the value matches the pattern.

##### Usage

```cmake
ASSERT_MATCH(<value> <pattern>)
EXPECT_MATCH(<value> <pattern>)
```

##### Params

- `value`  Value to test
- `pattern`  Pattern to test value against

##### Reports

- `error`  if the value does not match the pattern


#### ASSERT_NOT_MATCH / EXPECT_NOT_MATCH

Verify if the value does not match the pattern.

##### Usage

```cmake
ASSERT_NOT_MATCH(<value> <pattern>)
EXPECT_NOT_MATCH(<value> <pattern>)
```

##### Params

- `value`  Value to test
- `pattern`  Pattern to test value against

##### Reports

- `error`  if the value matches the pattern


#### ASSERT_EQ / EXPECT_EQ

Verify if the value equals to the expected.

##### Usage

```cmake
ASSERT_EQ(<value> <expected>)
EXPECT_EQ(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if values differ


#### ASSERT_NE / EXPECT_NE

Verify if the value does not equal to the expected.

##### Usage

```cmake
ASSERT_NE(<value> <expected>)
EXPECT_NE(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if values are equal


#### ASSERT_LT / EXPECT_LT

Verify if the value is less than the expected.

##### Usage

```cmake
ASSERT_LT(<value> <expected>)
EXPECT_LT(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if the value is not less than expected


#### ASSERT_LE / EXPECT_LE

Verify if the value is less than or equal to the expected.

##### Usage

```cmake
ASSERT_LE(<value> <expected>)
EXPECT_LE(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if the value is greater than expected


#### ASSERT_GT / EXPECT_GT

Verify if the value is greater than the expected.

##### Usage

```cmake
ASSERT_GT(<value> <expected>)
EXPECT_GT(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if the value is not greater than expected


#### ASSERT_GE / EXPECT_GE

Verify if the value is greater than or equal to the expected.

##### Usage

```cmake
ASSERT_GE(<value> <expected>)
EXPECT_GE(<value> <expected>)
```

##### Params

- `value`  Value to test
- `expected`  Expected value

##### Reports

- `error`  if the value is less than expected


#### ASSERT_LIST_LENGTH / EXPECT_LIST_LENGTH

Verify if the length of the list is in relation to the given expected value.

##### Usage

```cmake
ASSERT_LIST_LENGTH(<variable> <relation> <expected>)
EXPECT_LIST_LENGTH(<variable> <relation> <expected>)
```

##### Params

- `variable`  List variable to test
- `relation`  One of: `EQ`, `NE`, `LT`, `LE`, `GT`, `GE`
- `expected`  Expected list length

##### Reports

- `error`  if the list length is not in relation to expected value


#### ASSERT_LIST_EQ / EXPECT_LIST_EQ

Verify if the value equals to the list made of the given item(s).

##### Usage

```cmake
ASSERT_LIST_EQ(<value> [<item>...])
EXPECT_LIST_EQ(<value> [<item>...])
```

##### Params

- `value`    Value to test
- `item...`  Expected content of the list

##### Reports

- `error`  if the value differs from the given list of items


#### ASSERT_LIST_CONTAINS / EXPECT_LIST_CONTAINS

Verify if the value contains all the given item(s) without any particular order.

##### Usage

```cmake
ASSERT_LIST_CONTAINS(<value> [<item>...])
EXPECT_LIST_CONTAINS(<value> [<item>...])
```

##### Params

- `value`    Value to test
- `item...`  Expected content of the list

##### Reports

- `error`  if the value does not contain at least one item


### Mocks

- [MOCK_FUNCTION](#mock_function)
- [EXPECT_CALL_TIMES](#expect_call_times)
- [EXPECT_CALL_WITH](#expect_call_with)


#### MOCK_FUNCTION

Define a mock function with the given name.

##### Usage

```cmake
MOCK_FUNCTION(<name>)
```

##### Params

- `name`  Name of the mock to be created

##### Reports

- `fatal error`  if mock function for the same `name` is defined again


#### EXPECT_CALL_TIMES

Verify if the mock has been called the expected number of times.

##### Usage

```cmake
EXPECT_CALL_TIMES(<name> <expected>)
```

##### Params

- `name`      Mock function name
- `expected`  Expected number of mock function calls (no less than 0)

##### Reports

- `fatal error`      if mock function is not defined
                     or if `expected` is less than 0
- `non-fatal error`  if mock function was not called `expected` number of times


#### EXPECT_CALL_WITH

Verify if the nth call of the mock function has been done with the given arguments.

##### Usage

```cmake
EXPECT_CALL_WITH(<name> <nth> [<arg>...])
```

##### Params

- `name`    Mock function name
- `nth`     Number of the call of the mock function to verify
- `arg...`  List of expected arguments

##### Reports

- `fatal error`      if mock function is not defined
                     or if `nth` is less than 1
- `non-fatal error`  if mock function has not been called
                     or if has been called less than `nth` times
                     or if expected arguments differ to actual



---


[cmake::add_custom_target]: https://cmake.org/cmake/help/latest/command/add_custom_target.html
[cmake::CMAKE_CURRENT_SOURCE_DIR]: https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_SOURCE_DIR.html
[cmake::CMAKE_MODULE_PATH]: https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html
[cmake::CTest]: https://cmake.org/cmake/help/latest/module/CTest.html
[cmake::ctest]: https://cmake.org/cmake/help/latest/manual/ctest.1.html
[cmake::WILL_FAIL]: https://cmake.org/cmake/help/latest/prop_test/WILL_FAIL.html
