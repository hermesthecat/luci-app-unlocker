#!/usr/bin/env php
<?php
// check if run from cli
if (PHP_SAPI != "cli") exit;

$file=file_get_contents(__DIR__.DIRECTORY_SEPARATOR."Makefile");
$version_number=preg_match('/PKG_VERSION:=(.*)/', $file);
$file=preg_replace('/PKG_VERSION:=(.*)/', "PKG_VERSION:=".($version_number+0.1), $file);
$pkg_number=preg_match('/PKG_RELEASE:=(.*)/', $file);
$file=preg_replace('/PKG_RELEASE:=(.*)/', "PKG_RELEASE:=".($pkg_number+1), $file);
file_put_contents(__DIR__.DIRECTORY_SEPARATOR."Makefile", $file, LOCK_EX);
