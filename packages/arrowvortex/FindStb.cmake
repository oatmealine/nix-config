find_path(Stb_INCLUDE_DIR
  NAMES stb_image.h
  PATH_SUFFIXES stb
  DOC "stb single-file libraries include directory"
)
mark_as_advanced(Stb_INCLUDE_DIR)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Stb DEFAULT_MSG Stb_INCLUDE_DIR)