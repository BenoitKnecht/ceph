# Top-level components that can be enabled or disabled independently.
#
# Every component defaults to CEPH_COMPONENT_DEFAULT, so a build containing
# only a few components can be configured with, e.g.:
#
#   cmake -DCEPH_COMPONENT_DEFAULT=OFF -DWITH_RADOSGW=ON ..
#
# Like any option default, CEPH_COMPONENT_DEFAULT only affects components not
# yet in the CMake cache, i.e. it should be set when configuring a new build
# directory.
#
# librados, libneorados, libceph-common and the basic client tools are always
# built.
#
# These options must be declared before any dependency lookups, so that those
# can be skipped when the components needing them are disabled.

include(CMakeDependentOption)

option(CEPH_COMPONENT_DEFAULT "Default value of the WITH_<component> options" ON)

option(WITH_MON "ceph-mon is enabled" ${CEPH_COMPONENT_DEFAULT})
CMAKE_DEPENDENT_OPTION(WITH_OSD "ceph-osd is enabled" ${CEPH_COMPONENT_DEFAULT}
  "NOT WIN32" OFF)
option(WITH_RBD "Enable RADOS Block Device related targets" ${CEPH_COMPONENT_DEFAULT})
CMAKE_DEPENDENT_OPTION(WITH_KRBD "Enable Linux krbd support of 'rbd' utility" ON
  "WITH_RBD" OFF)
option(WITH_FUSE "Fuse is here" ${CEPH_COMPONENT_DEFAULT})
option(WITH_LIBCEPHFS "libcephfs client library" ${CEPH_COMPONENT_DEFAULT})
option(WITH_LIBCEPHSQLITE "libcephsqlite client library" ${CEPH_COMPONENT_DEFAULT})
option(WITH_LIBRADOSSTRIPER "build with libradosstriper support" ${CEPH_COMPONENT_DEFAULT})
option(WITH_RADOSGW "RADOS Gateway is enabled" ${CEPH_COMPONENT_DEFAULT})
option(WITH_CEPHFS "CephFS is enabled" ${CEPH_COMPONENT_DEFAULT})
CMAKE_DEPENDENT_OPTION(WITH_MGR "ceph-mgr is enabled" ${CEPH_COMPONENT_DEFAULT}
  "NOT WIN32" OFF)
option(WITH_CRIMSON "Build Crimson components" OFF)
CMAKE_DEPENDENT_OPTION(WITH_PYBIND "Python bindings for the client libraries"
  ${CEPH_COMPONENT_DEFAULT} "NOT WIN32" OFF)
option(WITH_TESTS "enable the build of ceph-test package scripts/binaries" ${CEPH_COMPONENT_DEFAULT})

set(_ceph_components
  WITH_MON WITH_OSD WITH_RBD WITH_KRBD WITH_FUSE WITH_LIBCEPHFS
  WITH_LIBCEPHSQLITE WITH_LIBRADOSSTRIPER WITH_RADOSGW WITH_CEPHFS WITH_MGR
  WITH_CRIMSON WITH_PYBIND WITH_TESTS)
set(_ceph_enabled_components)
foreach(_component ${_ceph_components})
  if(${_component})
    string(REGEX REPLACE "^WITH_" "" _name ${_component})
    list(APPEND _ceph_enabled_components ${_name})
  endif()
endforeach()
string(REPLACE ";" " " _ceph_enabled_components "${_ceph_enabled_components}")
message(STATUS "Enabled Ceph components: ${_ceph_enabled_components}")
unset(_ceph_components)
unset(_ceph_enabled_components)
unset(_component)
unset(_name)

# Internal libraries shared by several components

# kv, os and RocksDB
if(WITH_MON OR WITH_OSD OR WITH_CRIMSON)
  set(CEPH_NEED_OBJECTSTORE TRUE)
else()
  set(CEPH_NEED_OBJECTSTORE FALSE)
endif()

# erasure code plugins
if(WITH_MON OR WITH_OSD OR WITH_CRIMSON)
  set(CEPH_NEED_EC_PLUGINS TRUE)
else()
  set(CEPH_NEED_EC_PLUGINS FALSE)
endif()

# object classes, loaded by the OSDs, and by some tests through
# librados_test_stub; other components only need their client libraries
if(WITH_OSD OR WITH_CRIMSON OR WITH_TESTS)
  set(CEPH_NEED_CLS_PLUGINS TRUE)
else()
  set(CEPH_NEED_CLS_PLUGINS FALSE)
endif()
