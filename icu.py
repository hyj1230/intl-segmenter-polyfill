# Copyright 2018 The Emscripten Authors.  All rights reserved.
# Emscripten is available under two separate licenses, the MIT license and the
# University of Illinois/NCSA Open Source License.  Both these licenses can be
# found in the LICENSE file.

import logging
import os
import shutil

TAG = 'release-78.3'
VERSION = '78.3'
HASH = '81d764afc52e622bf22b39318db2d9c273d1809b5c4692f4c25e30910cce87d7666e3e2e9d287be11bd5e68e1bb5f2760056ba4344e7ad169f4cc7ca7b5a21f0'
SUBDIR = ''

def get(ports, settings, shared):
  if settings.USE_ICU != 1:
    return []

  url = 'https://github.com/unicode-org/icu/releases/download/%s/icu4c-%s-sources.zip' % (TAG, VERSION)
  ports.fetch_project('icu', url, 'icu', sha512hash=HASH)
  libname = ports.get_lib_name('libicuuc')

  def create():
    logging.info('building port: icu')

    source_path = os.path.join(ports.get_dir(), 'icu', 'icu')
    dest_path = os.path.join(shared.Cache.get_path('ports-builds'), 'icu')

    shutil.rmtree(dest_path, ignore_errors=True)
    print(source_path)
    print(dest_path)
    shutil.copytree(source_path, dest_path)

    final = os.path.join(dest_path, libname)
    ports.build_port(os.path.join(dest_path, 'source', 'common'), final, [os.path.join(dest_path, 'source', 'common')], ['-DU_COMMON_IMPLEMENTATION=1', '-std=c++17'])

    ports.install_header_dir(os.path.join(dest_path, 'source', 'common', 'unicode'))
    return final

  return [shared.Cache.get(libname, create)]


def clear(ports, shared):
  shared.Cache.erase_file(ports.get_lib_name('libicuuc'))


def process_args(ports, args, settings, shared):
  if settings.USE_ICU == 1:
    get(ports, settings, shared)
  return args


def show():
  return 'icu (USE_ICU=1; Unicode License)'
