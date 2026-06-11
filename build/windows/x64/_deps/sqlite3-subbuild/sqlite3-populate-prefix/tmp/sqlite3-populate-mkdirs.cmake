# Distributed under the OSI-approved BSD 3-Clause License.  See accompanying
# file Copyright.txt or https://cmake.org/licensing for details.

cmake_minimum_required(VERSION 3.5)

file(MAKE_DIRECTORY
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-src"
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-build"
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix"
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix/tmp"
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix/src/sqlite3-populate-stamp"
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix/src"
  "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix/src/sqlite3-populate-stamp"
)

set(configSubDirs Debug)
foreach(subDir IN LISTS configSubDirs)
    file(MAKE_DIRECTORY "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix/src/sqlite3-populate-stamp/${subDir}")
endforeach()
if(cfgdir)
  file(MAKE_DIRECTORY "D:/Project Flutter/my_manage/build/windows/x64/_deps/sqlite3-subbuild/sqlite3-populate-prefix/src/sqlite3-populate-stamp${cfgdir}") # cfgdir has leading slash
endif()
