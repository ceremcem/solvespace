# Include python

if (${CMAKE_SYSTEM_NAME} STREQUAL Windows)
    find_package(PythonInterp ${PYTHON_VERSION_MAJOR} REQUIRED)
    find_package(PythonLibs ${PYTHON_VERSION_MAJOR} REQUIRED)
    message(STATUS "python version ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}")
    message(STATUS "python libraries ${PYTHON_LIBRARIES}")
else()
    find_package(PythonInterp ${PYTHON_VERSION_MAJOR} REQUIRED)
    set(Python_ADDITIONAL_VERSIONS ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR})
    message(STATUS "python version ${Python_ADDITIONAL_VERSIONS}")
    if (NOT DEFINED PYTHON_VERSION_STRING)
        find_package(PythonLibs REQUIRED)
    else (NOT DEFINED PYTHON_VERSION_STRING)
        find_package(PythonLibs ${PYTHON_VERSION_STRING} EXACT REQUIRED)
    endif(NOT DEFINED PYTHON_VERSION_STRING)
endif()

include_directories(${PYTHON_INCLUDE_PATH})

if (WIN32)
	set(PYLIB_SUFFIX .pyd)
else()
	set(PYLIB_SUFFIX .so)
endif()

add_definitions(-DSLVS_STATIC_LIB)

set_source_files_properties(../slvs.i PROPERTIES CPLUSPLUS ON)
include_directories(../ ../../../include/)

# Add swig module
if (${CMAKE_VERSION} VERSION_LESS "3.8.0")
    swig_add_module(slvs python ../slvs.i)
else()
    swig_add_library(slvs LANGUAGE python SOURCES ../slvs.i)
endif()

if (APPLE)
    swig_link_libraries(slvs "-Wl,-undefined,dynamic_lookup" slvs_static_excp)
elseif(WIN32)
    swig_link_libraries(slvs ${PYTHON_LIBRARIES} slvs_static_excp)
else ()
    swig_link_libraries(slvs slvs_static_excp)
endif ()

if (NOT ENABLE_GUI)
    message(STATUS "python package")
    install(TARGETS _slvs LIBRARY DESTINATION py_slvs)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/slvs.py DESTINATION py_slvs)
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/__init__.py DESTINATION py_slvs)
endif( NOT ENABLE_GUI)
