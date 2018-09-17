#!/usr/bin/env php
<?php
// check if run from cli
if (PHP_SAPI != "cli") exit;

$file=file_get_contents(__DIR__.DIRECTORY_SEPARATOR."Makefile");
preg_match('/PKG_VERSION:=(.*)/', $file,$version_number);
$version_number=$version_number[1];
//echo "$version_number\n";
$file=preg_replace('/PKG_VERSION:=(.*)/', "PKG_VERSION:=".($version_number+0.1), $file);
preg_match('/PKG_RELEASE:=(.*)/', $file,$pkg_number);
$pkg_number=$pkg_number[1];
//echo "$pkg_number\n";
$file=preg_replace('/PKG_RELEASE:=(.*)/', "PKG_RELEASE:=".($pkg_number+1), $file);
file_put_contents(__DIR__.DIRECTORY_SEPARATOR."Makefile", $file, LOCK_EX);
