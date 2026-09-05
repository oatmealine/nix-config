find_package(PkgConfig REQUIRED)

set(_ffmpeg_components libavcodec libavformat libavutil libswresample)

set(FFMPEG_INCLUDE_DIRS "")
set(FFMPEG_LIBRARY_DIRS "")
set(FFMPEG_LIBRARIES "")
set(FFMPEG_FOUND TRUE)

foreach(_comp ${_ffmpeg_components})
  pkg_check_modules(PC_${_comp} QUIET ${_comp})
  if(NOT PC_${_comp}_FOUND)
    set(FFMPEG_FOUND FALSE)
    message(WARNING "FindFFMPEG: missing pkg-config module ${_comp}")
  else()
    list(APPEND FFMPEG_INCLUDE_DIRS ${PC_${_comp}_INCLUDE_DIRS})
    list(APPEND FFMPEG_LIBRARY_DIRS ${PC_${_comp}_LIBRARY_DIRS})
    list(APPEND FFMPEG_LIBRARIES ${PC_${_comp}_LIBRARIES})
  endif()
endforeach()

list(REMOVE_DUPLICATES FFMPEG_INCLUDE_DIRS)
list(REMOVE_DUPLICATES FFMPEG_LIBRARY_DIRS)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(FFMPEG
  REQUIRED_VARS FFMPEG_LIBRARIES FFMPEG_INCLUDE_DIRS
)