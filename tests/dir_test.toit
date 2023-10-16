// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

import expect show *

import host.pipe
import host.directory
import semver

main args:
  if platform == "Windows" and (semver.compare vm-sdk-version "v2.0.0-alpha.114") < 0:
    print "This test requires a newer version of the SDK."
    exit 0

  if args[0] == "--run-test":
    test_not_existing
    return

  toit_run := args[0]
  test_not_existing

  5.repeat:
    pipe.run_program toit_run "tests/dir_test.toit" "--run-test"

test_not_existing:
  50.repeat:
    exception := catch:
      files := directory.DirectoryStream "not-existing"
      unreachable
    expect_not_null exception
