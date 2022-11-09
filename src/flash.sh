#!/usr/bin/env bash

set -e

# This file is separated out, so we can do more advanced output parsing, but use the
# simple TUI of charmbraclet/gum

keyboard=$1

make system76/$keyboard:default:dfu > tmp
