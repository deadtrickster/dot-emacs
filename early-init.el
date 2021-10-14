(setenv "LIBRARY_PATH" "/usr/local/opt/gcc/lib/gcc/11:/usr/local/opt/libgccjit/lib/gcc/11:/usr/local/opt/gcc/lib/gcc/11/gcc/x86_64-apple-darwin20/11.2.0")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
