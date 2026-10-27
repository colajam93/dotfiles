;; Load Evil
(setq evil-want-abbrev-expand-on-insert-exit nil)
(add-to-list 'load-path "~/.emacs.d/evil")
(require 'evil)
(evil-mode 1)

(load-theme 'iceberg t)
