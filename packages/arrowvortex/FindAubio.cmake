find_package(PkgConfig QUIET)
if(PkgConfig_FOUND)
  pkg_check_modules(PC_AUBIO QUIET aubio)
endif()

find_path(AUBIO_INCLUDE_DIR
  NAMES aubio/aubio.h
  PATHS ${PC_AUBIO_INCLUDE_DIRS}
  DOC "Aubio include directory"
)
mark_as_advanced(AUBIO_INCLUDE_DIR)

find_library(AUBIO_LIBRARY
  NAMES aubio
  PATHS ${PC_AUBIO_LIBRARY_DIRS}
  DOC "Aubio library"
)
mark_as_advanced(AUBIO_LIBRARY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Aubio DEFAULT_MSG
  AUBIO_LIBRARY
  AUBIO_INCLUDE_DIR
)

if(Aubio_FOUND)
  if(NOT TARGET Aubio::aubio)
    add_library(Aubio::aubio UNKNOWN IMPORTED)
    set_target_properties(Aubio::aubio PROPERTIES
      IMPORTED_LOCATION "${AUBIO_LIBRARY}"
      INTERFACE_INCLUDE_DIRECTORIES "${AUBIO_INCLUDE_DIR}"
      INTERFACE_COMPILE_OPTIONS "${PC_AUBIO_CFLAGS_OTHER}"
    )
  endif()
endif()