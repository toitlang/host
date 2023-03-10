// Copyright (C) 2023 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

import expect show *
import host.pipe
import host.os
import host.file

main args:
  pathext := os.env.get "PATHEXT"
  if pathext:
    // Add the null extension so we can run Unix executables on Wine.
    os.env["PATHEXT"] = pathext + ";."

  if args.size < 1:
    print "Usage: env_test.toit <toit_exe>"
    exit 1

  if not file.is_file "tests/echo.toit":
    print "Cannot find toit file 'echo.toit' in tests directory"
    exit 1

  toit_exe := args[0]

  if not file.is_file toit_exe:
    print "Cannot find toit executable '$toit_exe'"
    exit 1

  pipe.system "$toit_exe tests/echo.toit FOO=\$FOO"
  pipe.system --environment={"FOO": 123} "$toit_exe tests/echo.toit FOO=\$FOO"

  shell := platform == "Windows" ? ["cmd", "/s", "/C"] : ["sh", "-c"]

  expect_equals "BAR=1.5"
      (pipe.backticks --environment={"BAR": 1.5} toit_exe "tests/echo.toit" "BAR=\$BAR").trim
  expect_equals "BAR="
      (pipe.backticks shell + ["$toit_exe tests/echo.toit BAR=\$BAR"]).trim

  fd := pipe.from --environment={"FISH": "HORSE"} toit_exe "tests/echo.toit" "\$FISH"
  expect_equals "HORSE" fd.read.to_string.trim

  user := os.env.get "USER"
  if user:
    expect_equals "$user"
      (pipe.backticks shell + ["$toit_exe tests/echo.toit \$USER"]).trim
    user_fd := pipe.from --environment={"USER": null} toit_exe "tests/echo.toit" "\$USER"
    expect_equals "" user_fd.read.to_string.trim
