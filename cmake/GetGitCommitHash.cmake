function(get_git_commit_hash)
    get_filename_component(GIT_DESCRIBE_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} PATH)
    get_filename_component(GIT_ROOT ${GIT_DESCRIBE_CMAKE_DIR} PATH)
    set(GIT_DIR "${GIT_ROOT}/.git")
    if(NOT EXISTS ${GIT_DIR})
        message(WARNING "Not a git repository")
        return()
    elseif(NOT IS_DIRECTORY ${GIT_DIR})
        # In case we are included as a git submodule.
        file(READ ${GIT_DIR} GIT_SUB_DIR)
        string(REPLACE "gitdir: " "" GIT_SUB_DIR ${GIT_SUB_DIR})
        string(STRIP ${GIT_SUB_DIR} GIT_SUB_DIR)
        set(GIT_DIR "${GIT_ROOT}/${GIT_SUB_DIR}")
    endif()

    # Add a CMake configure dependency to the currently checked out revision.
    set(GIT_DEPENDS ${GIT_DIR}/HEAD)
    file(READ ${GIT_DIR}/HEAD HEAD_REF)
    if(HEAD_REF MATCHES "ref: (.+)\n")
        set(HEAD_REF ${CMAKE_MATCH_1})
        if(EXISTS "${GIT_DIR}/${HEAD_REF}")
            list(APPEND GIT_DEPENDS ${GIT_DIR}/${HEAD_REF})
            file(READ ${GIT_DIR}/${HEAD_REF} HEAD_REF)
        elseif(EXISTS "${GIT_DIR}/packed-refs")
            list(APPEND GIT_DEPENDS ${GIT_DIR}/packed-refs)
            file(READ "${GIT_DIR}/packed-refs" PACKED_REFS)
            if(${PACKED_REFS} MATCHES "([0-9a-z]*) ${HEAD_REF}")
                set(HEAD_REF ${CMAKE_MATCH_1})
            else()
                set(HEAD_REF "")
            endif()
        else()
            set(HEAD_REF "")
        endif()
    endif()
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${GIT_DEPENDS})

    string(STRIP ${HEAD_REF} HEAD_REF)
    if(HEAD_REF STREQUAL "")
        message(WARNING "Cannot determine git HEAD")
    else()
        set(GIT_COMMIT_HASH ${HEAD_REF} PARENT_SCOPE)
    endif()
endfunction()
get_git_commit_hash()
