# CMakeUnit

CMakeUnit is a small set of functions and additional rules to make CMake code testing easy.  It can
be used to write unit tests for CMake functions and macros as well as to evaluate ad hoc written
code without running all the project.

- [API](#api)
- [Project setup](#project-setup)
- [How to write tests?](#how-to-write-tests)


## API

Api is simple and minimal.  There is no ASERT and CHECK like functions.  Just write some IFs in your
test.

- [add_cmake_test](#add_cmake_test)
- [add_cmakeunit_target](#add_cmakeunit_target)
- [xadd_cmake_test](#xadd_cmake_test)


### add_cmake_test

Add a test to be run by [ctest][cmake::ctest].

```cmake
add_cmake_test(<test> [<arg>...]
               [WILL_FAIL])
```

Test is added in two steps:

1. cmake source file is copied from [CMAKE_CURRENT_SOURCE_DIR][cmake::CMAKE_CURRENT_SOURCE_DIR] to
   [CMAKE_CURRENT_BINARY_DIR][cmake::CMAKE_CURRENT_BINARY_DIR]
2. new test is added using [add_test][cmake::add_test]

Test will be run with [CMAKE_MODULE_PATH][cmake::CMAKE_MODULE_PATH] set to its current value.

#### Options

- `test` file name that contains test code (without `.cmake` extension).  File location is resolved
  from the [CMAKE_CURRENT_SOURCE_DIR][cmake::CMAKE_CURRENT_SOURCE_DIR].

- `[<arg>...]` additional arguments for [add_test][cmake::add_test].  This is a convenient way to
  set up test ENV.

- `WILL_FAIL` will set test property [WILL_FAIL][cmake::WILL_FAIL] to `true`.


### add_cmakeunit_target

Add custom target that will run [ctest](https://cmake.org/cmake/help/latest/manual/ctest.1.html)
to execute tests.

```cmake
add_cmakeunit_target(<name> [<arg>...])
```

#### Options

- `name` target name (usually there is no need to pass anything more).
- `[<arg>...]` additional target options (all [add_custom_target][cmake::add_custom_target] options
  are accepted).

> **NOTE**
> 
> `COMMAND` option is already defined and there is no need to pass another one if you don't want to
> make a mess.


### xadd_cmake_test

Add a test that will be skipped but still present in test log.

```cmake
xadd_cmake_test(<test>)
```

#### Options

- `test` file name that contains test code (without `.cmake` extension).  File location is resolved
  from the [CMAKE_CURRENT_SOURCE_DIR][cmake::CMAKE_CURRENT_SOURCE_DIR].

> **TIP**
> 
> If you want to skip the test, just prepend `add_cmake_test` with `x`.


## Project setup

Follow this four simple steps:

1. include [CTest][cmake::CTest]
2. add to [CMAKE_MODULE_PATH][cmake::CMAKE_MODULE_PATH] location of CMakeUnit module and location of
   every module you want to test
3. add all the tests that you need using [add_cmake_test](#add_cmake_test)
4. add test target using [add_cmakeunit_target](#add_cmakeunit_target)

When done, follow the usual steps to run the test target:

```bash
mkdir build
cd build
cmake ..
make <cmakeunit target name>
```


## How to write tests?

The test will fail if it returns a value other than `0`.

TBD

  **Example**

  ```cmake
  add_cmake_test(foo
      "-DVAR1=someValue"
  )
  ```
  `VAR1` will be defined in the test. It's value will be set to `someValue`.



> **TIP**
> 
> Prepend `add_cmake_test` with `x` if you want to skip the test.
> 
> ```cmake
> add_cmake_test(test1)
> xadd_cmake_test(test2)
> ```
> Test `test2` will be skipped and the report like this will be logged:
> 
> ```log
>     Start 1: test1
> 1/2 Test #1: test1 ............................   Passed    0.00 sec
>     Start 2: test2
> 2/2 Test #2: test2 ............................***Skipped   0.00 sec
>
> 100% tests passed, 0 tests failed out of 2
> 
> Total Test time (real) =   0.00 sec
> 
> The following tests did not run:
>       2 - test2 (Skipped)
> ```



---

### Example project structure

This is example project structure (only essential folders and files are presented):

```
<PROJECT_ROOT_DIR>
├── CMakeLists.txt
├── cmake
│   └── CMakeUnit.cmake
├── src
│   └── module.cmake
└── tests
    ├── CMakeLists.txt
    └── module
        ├── CMakeLists.txt
        ├── test1.cmake
        └── test2.cmake
```

- `CMakeLists.txt` project cmake entrypoint
- `cmake` folder with CMake modules
- `src` folder with CMake code to test
- `tests` folder withs tests


### Setup

1.  In CMakeLists.txt

    - include CTest
    - add to CMAKE_MODULE_PATH location of CMakeUnit module
    - add to CMAKE_MODULE_PATH locations of source code to test

    ```cmake
    cmake_minimum_required(VERSION 3.30)
    
    project(my-project)
    
    if (PROJECT_IS_TOP_LEVEL)
       include(CTest)
       list(PREPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/src;${CMAKE_CURRENT_LIST_DIR}/cmake")
       add_subdirectory(tests)
    endif ()
    ```

2.  In tests/CMakeLists.txt

    - add all test suites you need
    - add test target

    ```cmake
    include(CMakeUnit)
    add_subdirectory(module)
    add_cmakeunit_target(tests)
    ```

3.  In tests/module/CMakeLists.txt

    - add every test in test suite that you need

    ```cmake
    include(UTestHelpers)
    add_cmake_test(test1)
    add_cmake_test(test2)
    ```

### Run

Assuming the setup as described above, there are required usual steps as to run any CMake target.

```bash
mkdir build
cd build
cmake ..
make tests
```

---

[cmake::add_custom_target]: https://cmake.org/cmake/help/latest/command/add_custom_target.html
[cmake::add_test]: https://cmake.org/cmake/help/latest/command/add_test.html
[cmake::CMAKE_CURRENT_BINARY_DIR]: https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_BINARY_DIR.html
[cmake::CMAKE_CURRENT_SOURCE_DIR]: https://cmake.org/cmake/help/latest/variable/CMAKE_CURRENT_SOURCE_DIR.html
[cmake::CMAKE_MODULE_PATH]: https://cmake.org/cmake/help/latest/variable/CMAKE_MODULE_PATH.html
[cmake::CTest]: https://cmake.org/cmake/help/latest/module/CTest.html
[cmake::ctest]: https://cmake.org/cmake/help/latest/manual/ctest.1.html
[cmake::WILL_FAIL]: https://cmake.org/cmake/help/latest/prop_test/WILL_FAIL.html
