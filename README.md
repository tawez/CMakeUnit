# CMakeUnit

CMakeUnit is a small set of functions and macros useful when testing CMake code.
There are two main scenarios how you can use CMakeUnit:

1. TDD the code, functions or macro
2. Run part of the code in isolation

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


## API

### add_cmake_test

```cmake
add_cmake_test(<name> <path>
        [SKIP]
        [WILL_FAIL]
        [OPTIONS args...])
```

Add a test to be run by [ctest][cmake::ctest].  Test will be run with
[CMAKE_MODULE_PATH][cmake::CMAKE_MODULE_PATH] set to its current value.

#### Options

- `name`  
  Test name

- `path`  
  Path to test source resolved from the
  [CMAKE_CURRENT_SOURCE_DIR][cmake::CMAKE_CURRENT_SOURCE_DIR].
  If `path` is a folder, `CMakeLists.txt` is expected to be inside.

- `SKIP`  
  Skip this test but keep it in test report

- `WILL_FAIL`  
  Denote this test as expected to fail.  Will set test property
  [WILL_FAIL][cmake::WILL_FAIL] to `true`.

- `OPTIONS`  
  Additional test options.  This is a convenient way to set up test ENV.


### add_cmakeunit_target

```cmake
add_cmakeunit_target(name [args...])
```

Add custom target that will run [ctest][cmake::ctest] to execute registered
tests.

#### Options

- `name`
  Target name (usually there is no need to pass anything more).

- `args...`
  Additional target options (all [add_custom_target][cmake::add_custom_target] 
  options are accepted).

  > **NOTE**
    `COMMAND` option is already defined and if you don't want to make a mess,
    there is no need to pass another one.


## Assertions

- `FATAL([text...])`  
  Generates a fatal failure, which stops the execution of current test.

- `FAIL([text...])`  
  Generates a failure, which allows the current test to continue running.

- `EXPECT_TRUE(value)`  
  Verifies that `value` is _true_.

- `EXPECT_FALSE(value)`  
  Verifies that `value` is _false_.

- `EXPECT_DEFINED(variable)`  
  Verifies that `variable` is defined.

- `EXPECT_UNDEFINED(variable)`  
  Verifies that `variable` is undefined.

- `EXPECT_STREQ(value expected)`  
  Verifies that the two strings `value` and `expected` have the same contents.

- `EXPECT_NOT_STREQ(value expected)`  
  Verifies that the two strings `value` and `expected` have different contents.

- `EXPECT_MATCH(value pattern)`  
  Verifies that the `value` matches the `pattern`.

- `EXPECT_NOT_MATCH(value pattern)`  
  Verifies that the `value` does not match the `pattern`.

- `EXPECT_EQ(value expected)`  
  Verifies that `value == expected`.

- `EXPECT_NE(value expected)`  
  Verifies that `value != expected`.

- `EXPECT_LT(value expected)`  
  Verifies that `value < expected`.

- `EXPECT_LE(value expected)`  
  Verifies that `value <= expected`.

- `EXPECT_GT(value expected)`  
  Verifies that `value > expected`.

- `EXPECT_GE(value expected)`  
  Verifies that `value >= expected`.

- `EXPECT_LIST_LENGTH(variable relation expected)`  
  Verifies that length of a list denoted by the `variable` is in `relation` to
  `expected` value.

  `relation` is one of: `EQ`, `NE`, `LT`, `LE`, `GT`, `GE`


## Mocks

- `MOCK_FUNCTION(name)`  
  Defines a mock function `name`.

### Mock assertions

- `EXPECT_CALL_TIMES(name relation expected)`  
  Verifies that the number of calls of the `name` mock function is in `relation` 
  to `expected` value.

  `relation` is one of: `EQ`, `NE`, `LT`, `LE`, `GT`, `GE`
 
- `EXPECT_CALL_WITH(name callNo [args...])`  
  Verifies that `callNo` call of `name` mock function has been performed with 
  given `args`.


[cmake::add_custom_target]: https://cmake.org/cmake/help/latest/command/add_custom_target.html
[cmake::CMAKE_CURRENT_SOURCE_DIR]: https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_SOURCE_DIR.html
[cmake::CMAKE_MODULE_PATH]: https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html
[cmake::CTest]: https://cmake.org/cmake/help/latest/module/CTest.html
[cmake::ctest]: https://cmake.org/cmake/help/latest/manual/ctest.1.html
[cmake::WILL_FAIL]: https://cmake.org/cmake/help/latest/prop_test/WILL_FAIL.html
