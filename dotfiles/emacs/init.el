(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(setq package-selected-packages '(evil iceberg-theme))

;; Install missing packages; leave updates to the package menu.
(unless (seq-every-p #'package-installed-p package-selected-packages)
  (package-refresh-contents)
  (dolist (pkg package-selected-packages)
    (unless (package-installed-p pkg)
      (package-install pkg))))

(setq evil-want-abbrev-expand-on-insert-exit nil)
(require 'evil)
(evil-mode 1)

(require 'iceberg-theme)
(iceberg-theme-create-theme-file)
(load-theme 'solarized-iceberg-dark t)
