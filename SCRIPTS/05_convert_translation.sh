#!/bin/bash
# [CTCGFW]immortalwrt
# Use it under GPLv3, please.
# --------------------------------------------------------
# Convert translation files from zh-cn to en
# The script is still in testing, welcome to report bugs.

po_file="$({ find -type f | grep -E "[a-z0-9]+\.zh\-cn.+po"; } 2>"/dev/null")"
for a in ${po_file}; do
  [ -n "$(grep "Language: zh_CN" "$a")" ] && sed -i "s/Language: zh_CN/Language: en/g" "$a"
  po_new_file="$(echo -e "$a" | sed "s/zh-cn/en/g")"
  mv "$a" "${po_new_file}" 2>"/dev/null"
done

po_file2="$({ find -type f | grep "/zh-cn/" | grep "\.po"; } 2>"/dev/null")"
for b in ${po_file2}; do
  [ -n "$(grep "Language: zh_CN" "$b")" ] && sed -i "s/Language: zh_CN/Language: en/g" "$b"
  po_new_file2="$(echo -e "$b" | sed "s/zh-cn/en/g")"
  mv "$b" "${po_new_file2}" 2>"/dev/null"
done

lmo_file="$({ find -type f | grep -E "[a-z0-9]+\.en.+lmo"; } 2>"/dev/null")"
for c in ${lmo_file}; do
  lmo_new_file="$(echo -e "$c" | sed "s/en/zh-cn/g")"
  mv "$c" "${lmo_new_file}" 2>"/dev/null"
done

lmo_file2="$({ find -type f | grep "/en/" | grep "\.lmo"; } 2>"/dev/null")"
for d in ${lmo_file2}; do
  lmo_new_file2="$(echo -e "$d" | sed "s/en/zh-cn/g")"
  mv "$d" "${lmo_new_file2}" 2>"/dev/null"
done

po_dir="$({ find -type d | grep "/zh-cn" | sed "/\.po/d" | sed "/\.lmo/d"; } 2>"/dev/null")"
for e in ${po_dir}; do
  po_new_dir="$(echo -e "$e" | sed "s/zh-cn/en/g")"
  mv "$e" "${po_new_dir}" 2>"/dev/null"
done

makefile_file="$({ find -type f | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for f in ${makefile_file}; do
  [ -n "$(grep "zh-cn" "$f")" ] && sed -i "s/zh-cn/en/g" "$f"
  [ -n "$(grep "en.lmo" "$f")" ] && sed -i "s/en.lmo/zh-cn.lmo/g" "$f"
done

makefile_file="$({ find package -type f | grep Makefile | sed "/Makefile./d"; } 2>"/dev/null")"
for g in ${makefile_file}; do
  [ -n "$(grep "golang-package.mk" "$g")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/packages|g" "$g"
  [ -n "$(grep "luci.mk" "$g")" ] && sed -i "s|\.\./\.\.|$\(TOPDIR\)/feeds/luci|g" "$g"
done

exit 0
