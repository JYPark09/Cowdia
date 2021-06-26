# Set warnings as error
option(COWDIA_WARNINGS_AS_ERRORS "Treat all warnings as error" ON)
if(COWDIA_WARNINGS_AS_ERRORS)
    if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
        set(WARN_AS_ERROR_FLAGS "/WX")
    else()
        set(WARN_AS_ERROR_FLAGS "-Werror")
    endif()
endif()

# Determine architecture
set(X64 OFF)
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(X64 ON)
endif()

# Platform definitions
if(UNIX)
    set(BUILD_PLATFORM "UNIX")
elseif(WIN32)
    set(BUILD_PLATFORM "WIN32")
elseif(APPLE)
    set(BUILD_PLATFORM "APPLE")
endif()

# Project options
set(DEFAULT_PROJECT_OPTIONS
    CXX_STANDARD 17
    LINKER_LANGUAGE "CXX"
    POSITION_INDEPENDENT_CODE ON
)

# Compile definitions
set(TOUPPER ${CMAKE_SYSTEM_NAME} SYSTEM_NAME_UPPER)
set(DEFAULT_COMPILE_DEFINITIONS SYSTEM_${SYSTEM_NAME_UPPER} COWDIA_PLATFORM_${BUILD_PLATFORM})

# Compile options
set(DEFAULT_COMPILE_OPTIONS)

# MSVC compiler options
if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(DEFAULT_COMPILE_DEFINITIONS ${DEFAULT_COMPILE_DEFINITIONS}
        _SCL_SECURE_NO_WARNINGS
        _CRT_SECURE_NO_WARNINGS
    )

    string(REGEX REPLACE "/W[0-4]" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")

    set(DEFAULT_COMPILE_OPTIONS ${DEFAULT_COMPILE_OPTIONS}
        /MP
        /W4
        ${WARN_AS_ERROR_FLAGS}

        $<$<CONFIG:Release>:
        /Gw
        /Gs-
        /GL
        /GF
        >
    )
endif()

# GCC and Clang compiler options
if(CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(DEFAULT_COMPILE_OPTIONS ${DEFAULT_COMPILE_OPTIONS}
        -Wall
        -Wno-missing-braces
        -Wno-register
        -Wno-error=register

        ${WARN_AS_ERROR_FLAGS}
        -std=c++1z
    )
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(DEFAULT_COMPILE_OPTIONS ${DEFAULT_COMPILE_OPTIONS}
        -Wno-int-in-bool-context
    )
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(DEFAULT_COMPILE_OPTIONS ${DEFAULT_COMPILE_OPTIONS}
        -fsized-deallocation
    )
endif()

# Linker options
set(DEFAULT_LINKER_OPTIONS)

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_SYSTEM_NAME MATCHES "Linux")
    set(DEFAULT_LINKER_OPTIONS -pthread -lstdc++fs)
endif()

# Code coverage
if(CMAKE_BUILD_TYPE MATCHES Debug AND (CMAKE_CXX_COMPILER_ID MATCHES "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang"))
    set(DEFAULT_COMPILE_OPTIONS ${DEFAULT_COMPILE_OPTIONS}
        -g
        -O0
        -fprofile-arcs
        -ftest-coverage
    )

    set(DEFAULT_LINKER_OPTIONS ${DEFAULT_LINKER_OPTIONS}
        -fprofile-arcs
        -ftest-coverage
    )
endif()