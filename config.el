(use-package which-key
  :ensure t
  :diminish which-key-mode
  :config
  (which-key-mode)
  (setq which-key-idle-delay 1))

(use-package diminish
  :ensure t)

;; These functions are useful. Activate them. This use of #'put is
;; strange, but this feature uses symbol properties.
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

;; Answering just 'y' or 'n' will do
(defalias 'yes-or-no-p 'y-or-n-p)

;; Keep all backup and auto-save files in one directory
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

;; UTF-8 please
(setq locale-coding-system 'utf-8) ; pretty
(set-terminal-coding-system 'utf-8) ; pretty
(set-keyboard-coding-system 'utf-8) ; pretty
(set-selection-coding-system 'utf-8) ; please
(prefer-coding-system 'utf-8) ; with sugar on top

;; tabs never in code. 
(setq-default indent-tabs-mode nil)
(setq-default indicate-empty-lines t)

;; Don't count two spaces after a period as the end of a sentence.
;; Just one space is needed.
(setq sentence-end-double-space nil)

;; delete the region when typing, as is conventional these days.
(delete-selection-mode t)

(show-paren-mode t)

(column-number-mode t)

(global-visual-line-mode)
(diminish 'visual-line-mode)

(setq uniquify-buffer-name-style 'forward)

;; -i gets alias definitions from .bash_profile
(setq shell-command-switch "-ic")

;; Don't beep at me
(setq visible-bell t)

;; when editing a script file, make sure it's executable when you save
;; it.

(add-hook 'after-save-hook
          'executable-make-buffer-file-executable-if-script-p)

(use-package page-break-lines
  :straight t)

(eval-after-load "dired"
  '(progn
     (define-key dired-mode-map "F" 'my-dired-find-file)
     (defun my-dired-find-file (&optional arg)
       "Open each of the marked files, or the file under the
        point, or when prefix arg, the next N files. "
       (interactive "P")
       (let* ((fn-list (dired-get-marked-files nil arg)))
         (mapc 'find-file fn-list)))))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (if (string-equal system-type "darwin")
        (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face))
      (set-face-attribute (car face) nil :font "Droid Sans" :weight 'regular :height (cdr face))))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(efs/org-font-setup)

(setq org-use-speed-commands t)
(require 'org-tempo)

(setq org-image-actual-width 550)

(setq org-highlight-latex-and-related '(latex script entities))

(setq org-refile-targets
  '(("Archive.org" :maxlevel . 1)
    ("Tasks.org" :maxlevel . 1)))

;; Save Org buffers after refiling!
(advice-add 'org-refile :after 'org-save-all-org-buffers)

(use-package orgtbl-aggregate
  :straight t
  :after org)

(bind-key "C-c c" 'org-capture)
(setq org-default-notes-file "~/Dropbox/Notes/notes.org")

(setq org-agenda-files
      (delq nil
            (mapcar (lambda (x) (and (file-exists-p x) x))
                    (list (expand-file-name "personal-agenda.org" site-org-files)
                          (expand-file-name "notes.org" site-org-files)
                          (expand-file-name "todos.org" site-org-files)
                          (expand-file-name "Tasks.org" site-org-files)
                          (expand-file-name "people.org" site-org-files)
                          (expand-file-name "Archive.org" site-org-files)))))

;; when we finish a todo, just mark it DONE and fold down the entry.
(defun org-toggle-todo-and-fold ()
  (interactive)
  (save-excursion
    (org-back-to-heading t) ;; Make sure command works even if point is
    ;; below target heading
    (cond ((looking-at "\*+ TODO")
           (org-todo "DONE")
           (hide-subtree))
          ((looking-at "\*+ DONE")
           (org-todo "TODO")
           (hide-subtree))
          (t (message "Can only toggle between TODO and DONE.")))))

(define-key org-mode-map (kbd "C-c C-d") 'org-toggle-todo-and-fold)

(bind-key "C-c l" 'org-store-link)
(bind-key "C-c c" 'org-capture)
(bind-key "C-c a" 'org-agenda)

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :after org
  :straight t
  :hook (org-mode . efs/org-mode-visual-fill))

(use-package org-bullets
  :straight t
  :after org
    :hook (org-mode . org-bullets-mode)
    :custom
    (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(setq org-tags-column 45)

(setq org-tag-alist
      '((:startgroup)
                                        ; Put mutually exclusive tags here
        (:endgroup)
        ("@errand" . ?E)
        ("@home" . ?H)
        ("@work" . ?W)
        ("agenda" . ?a)
        ("planning" . ?p)
        ("publish" . ?P)
        ("batch" . ?b)
        ("note" . ?n)
        ("idea" . ?i)))

;; Configure custom agenda views
(setq org-agenda-custom-commands
      '(("d" "Dashboard"
         ((agenda "" ((org-deadline-warning-days 7)))
          (todo "NEXT"
                ((org-agenda-overriding-header "Next Tasks")))
          (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

        ("n" "Next Tasks"
         ((todo "NEXT"
                ((org-agenda-overriding-header "Next Tasks")))))

        ("W" "Work Tasks" tags-todo "+work-email")

        ;; Low-effort next actions
        ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
         ((org-agenda-overriding-header "Low Effort Tasks")
          (org-agenda-max-todos 20)
          (org-agenda-files org-agenda-files)))

        ("w" "Workflow Status"
         ((todo "WAIT"
                ((org-agenda-overriding-header "Waiting on External")
                 (org-agenda-files org-agenda-files)))
          (todo "REVIEW"
                ((org-agenda-overriding-header "In Review")
                 (org-agenda-files org-agenda-files)))
          (todo "PLAN"
                ((org-agenda-overriding-header "In Planning")
                 (org-agenda-todo-list-sublevels nil)
                 (org-agenda-files org-agenda-files)))
          (todo "BACKLOG"
                ((org-agenda-overriding-header "Project Backlog")
                 (org-agenda-todo-list-sublevels nil)
                 (org-agenda-files org-agenda-files)))
          (todo "READY"
                ((org-agenda-overriding-header "Ready for Work")
                 (org-agenda-files org-agenda-files)))
          (todo "ACTIVE"
                ((org-agenda-overriding-header "Active Projects")
                 (org-agenda-files org-agenda-files)))
          (todo "COMPLETED"
                ((org-agenda-overriding-header "Completed Projects")
                 (org-agenda-files org-agenda-files)))
          (todo "CANC"
                ((org-agenda-overriding-header "Cancelled Projects")
                 (org-agenda-files org-agenda-files)))))))

(use-package doct
  :straight t)

(setq org-capture-templates
    `(("t" "Tasks / Projects")
      ("tt" "Task" entry (file+olp "~/Dropbox/OrgFiles/Tasks.org" "Inbox")
           "* TODO %?\n  %U\n  %a\n  %i" :empty-lines 1)

      ("j" "Journal Entries")
      ("jj" "Journal" entry
           (file+olp+datetree "~/Dropbox/OrgFiles/Journal.org")
           "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
           ;; ,(dw/read-file-as-string "~/Notes/Templates/Daily.org")
           :clock-in :clock-resume
           :empty-lines 1)
      ("jm" "Meeting" entry
           (file+olp+datetree "~/Dropbox/OrgFiles/Journal.org")
           "* %<%I:%M %p> - %a :meetings:\n\n%?\n\n"
           :clock-in :clock-resume
           :empty-lines 1)

      ("w" "Workflows")
      ("we" "Checking Email" entry (file+olp+datetree "~/Dropbox/OrgFiles/Journal.org")
           "* Checking Email :email:\n\n%?" :clock-in :clock-resume :empty-lines 1)

      ;; ("m" "Metrics Capture")
      ;; ("mw" "Weight" table-line (file+headline "~/Dropbox/OrgFiles/Metrics.org" "Weight")
      ;;  "| %U | %^{Weight} | %^{Notes} |" :kill-buffer t)
      ))

(use-package ob-restclient
  :straight t
  :after org)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (C . t)
   (calc . t)
   (latex . t)
   (java . t)
   (ruby . t)
   (lisp . t)
   (scheme . t)
   (shell . t)
   (sqlite . t)
   (js . t)
   (restclient . t)))


(defun my-org-confirm-babel-evaluate (lang body)
  "Do not confirm evaluation for these languages."
  (not (or (string= lang "C")
           (string= lang "java")
           (string= lang "python")
           (string= lang "emacs-lisp")
           (string= lang "sqlite")
           (string= lang "resclient"))))

(setq org-confirm-babel-evaluate 'my-org-confirm-babel-evaluate)

(setq org-src-fontify-natively t
      org-src-window-setup 'current-window
      org-src-strip-leading-and-trailing-blank-lines t
      ;; org-src-preserve-indentation t
      org-src-tab-acts-natively t)

(use-package ox-pandoc
  :no-require t
  :defer 10
  :straight t)

(setq org-latex-pdf-process (list "latexmk -pdf %f"))

(use-package htmlize
  :straight t)

(global-set-key (kbd "C-x m") 'browse-url-at-point)

(use-package eww
  :defer t
  :init
  (setq browse-url-browser-function
        '((".*google.*maps.*" . browse-url-generic)
          ;; Github goes to firefox, but not gist
          ("http.*\/\/github.com" . browse-url-generic)
          ("groups.google.com" . browse-url-generic)
          ("docs.google.com" . browse-url-generic)
          ("melpa.org" . browse-url-generic)
          ("build.*\.elastic.co" . browse-url-generic)
          (".*-ci\.elastic.co" . browse-url-generic)
          ("internal-ci\.elastic\.co" . browse-url-generic)
          ("zendesk\.com" . browse-url-generic)
          ("salesforce\.com" . browse-url-generic)
          ("stackoverflow\.com" . browse-url-generic)
          ("apache\.org\/jira" . browse-url-generic)
          ("thepoachedegg\.net" . browse-url-generic)
          ("zoom.us" . browse-url-generic)
          ("t.co" . browse-url-generic)
          ("twitter.com" . browse-url-generic)
          ("\/\/a.co" . browse-url-generic)
          ("youtube.com" . browse-url-generic)
          ("amazon.com" . browse-url-generic)
          ("slideshare.net" . browse-url-generic)
          ("." . eww-browse-url)))
  (setq browser-url-secondary-browser-function 'browse-url-generic)
  (setq browse-url-generic-program (executable-find "nyxt"))
  (add-hook 'eww-mode-hook #'toggle-word-wrap)
  (add-hook 'eww-mode-hook #'visual-line-mode)
  :config
  (use-package s :ensure t)
  (define-key eww-mode-map "o" 'eww)
  (define-key eww-mode-map "O" 'eww-browse-with-external-browser)
  (define-key eww-mode-map "j" 'next-line)
  (define-key eww-mode-map "k" 'previous-line))

(use-package eww-lnum
    :straight t
    :after eww
    :config
    (bind-key "f" #'eww-lnum-follow eww-mode-map)
    (bind-key "U" #'eww-lnum-universal eww-mode-map))

(require 'ffap)
(defun browse-last-url-in-brower ()
  (interactive)
  (save-excursion
    (ffap-next-url t t)))

;; (global-set-key (kbd "C-c u") 'browse-last-url-in-brower)

(use-package dashboard
  :ensure t
  :config
    (dashboard-setup-startup-hook)
    (setq dashboard-startup-banner "~/.emacs.d/img/dashLogo.png")
    (setq dashboard-items '((recents  . 5)
                            (projects . 5)))
    (setq dashboard-banner-logo-title "DeepSky Emacs"))

(defvar my-term-shell "/usr/bin/zsh")
(defadvice ansi-term (before force-bash)
  (interactive (list my-term-shell)))
(ad-activate 'ansi-term)

(add-hook 'dired-mode-hook 'auto-revert-mode)
(global-auto-revert-mode t)

;; Also auto refresh dired, but be quiet about it
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)

(use-package recentf
  :bind ("C-x C-r" . helm-recentf)
  :config
  (recentf-mode t)
  (setq recentf-max-saved-items 200))

(use-package tramp
  :ensure t
  :config
  ;; tramp hangs when remote has 'weird' prompt. Check in for this terminal type.
  (setf tramp-terminal-type "tramp")
  (add-to-list 'tramp-connection-properties
               (list (regexp-quote "/ssh:fade@deepsky.com:")
                     "remote-shell" "/bin/sh")))

(bind-key "C-s-<left>"  'shrink-window-horizontally)
(bind-key "C-s-<right>" 'enlarge-window-horizontally)
(bind-key "C-s-<down>"  'shrink-window)
(bind-key "C-s-<up>"    'enlarge-window)

(defun vsplit-other-window ()
  "Splits the window vertically and switches to that window."
  (interactive)
  (split-window-vertically)
  (other-window 1 nil))
(defun hsplit-other-window ()
  "Splits the window horizontally and switches to that window."
  (interactive)
  (split-window-horizontally)
  (other-window 1 nil))

(bind-key "C-x 2" 'vsplit-other-window)
(bind-key "C-x 3" 'hsplit-other-window)

(use-package whitespace
  :bind ("s-<f10>" . whitespace-mode))

(use-package dired-single
  :ensure t
  :after dired)

(use-package all-the-icons-dired
  :straight t
  :after dired
  :hook (dired-mode . all-the-icons-dired-mode))

(defun config-visit ()
  (interactive)
  (find-file "~/.emacs.d/config.org"))
(global-set-key (kbd "C-c e") 'config-visit)

(defun config-reload ()
  "Reloads ~/.emacs.d/config.org at runtime"
  (interactive)
  (org-babel-load-file (expand-file-name "~/.emacs.d/config.org")))
(global-set-key (kbd "C-c r") 'config-reload)

(global-subword-mode 1)

(use-package beacon
  :straight t
  :config
  (beacon-mode 1))

(use-package avy
  :straight t
  :config 
  (avy-setup-default)
  (set-face-attribute 'avy-lead-face-0 nil :background "blue" :foreground "yellow")
  (set-face-attribute 'avy-lead-face-1 nil :background "purple4" :foreground "goldenrod")
  (set-face-attribute 'avy-lead-face-1 nil :background "SlateBlue4" :foreground "light goldenrod")
  :bind
  ;; ("M-s-." . avy-goto-word-or-subword-1)
  ("M-s s" . avy-goto-char))

(use-package c-eldoc
  :commands c-turn-on-eldoc-mode
  :ensure t
  :init (add-hook 'c-mode-hook #'c-turn-on-eldoc-mode))

(use-package crux
  :straight t
  :bind (("C-c o o" . crux-open-with)
         ("C-c u" . crux-view-url)))

(use-package emmet-mode
  :ensure t
  :commands emmet-mode
  :config
  (add-hook 'html-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode))

(use-package flycheck
  :ensure t
  :diminish flycheck-mode
  :init (global-flycheck-mode))

(use-package flycheck-cython
  :ensure t
  :after flycheck)

(use-package flycheck-clojure
  :ensure t
  :init (flycheck-clojure-setup))

(use-package flycheck-nim
  :ensure t
  :after flycheck)

;; vertico is the base for our Helm exodus.
(use-package vertico
  :straight t
  :init
  (vertico-mode 1)
  :custom
  (vertico-count 13)
  (vertico-resize t)
  (vertico-cycle t)
  :config
  (vertico-mode))

;; this will put most recent items at the top of any given vertico selection.
(use-package savehist
  :straight t
  :init
  (savehist-mode))

;; completion selection (narrowing) enhancements.
(use-package consult
  :straight t
  :bind
  ("s-s o" . consult-outline)
  ("C-s" . consult-line)
  ("s-s s" . consult-ripgrep))

;; this is a completion style, which defines how we match against input.
(use-package orderless
  :straight t
  :custom
  (completion-styles '(orderless))
  (completion-category-overrides '((file (styles . (partial-completion)))))
  (setq completion-category-defaults nil))

;; metadata around completion selections
(use-package marginalia
  :straight t
  :custom 
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode 1))

;; actions within completion selections
(use-package embark
  :straight t
  ;; this bind might clobber the sly mrepl shortcut command.
  :bind ("C-." . embark-act))

(use-package company
  :ensure nil
  :diminish company-mode
  ;; :bind (:map company-mode-map
  ;;             (("C-n" . company-select-next)
  ;;              ("C-p" . company-select-previous)
  ;;              ("C-d" . company-show-doc-buffer)
  ;;              ("M-." . company-show-location)))
  :config
  (progn
    ;; less than this and it disrupts typing when you aren't interested in completion.
    (setq company-idle-delay 0.9)
    (setq company-minimize-prefix-length 3)
    ;; company completion everywhere.
    (add-hook 'after-init-hook 'global-company-mode)
    (require 'color)

    (let ((bg (face-attribute 'default :background)))
      (custom-set-faces
       `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
       `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
       `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
       `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
       `(company-tooltip-common ((t (:inherit font-lock-constant-face))))))

    (with-eval-after-load 'company
      (define-key company-active-map (kbd "M-n") nil)
      (define-key company-active-map (kbd "M-p") nil)
      (define-key company-active-map (kbd "C-n") #'company-select-next)
      (define-key company-active-map (kbd "C-p") #'company-select-previous)
      (define-key company-active-map (kbd "SPC") #'company-abort))))

;; (use-package company-box
;;   :after company)

(use-package company-quickhelp
  :after (company)
  :hook (company-mode . company-quickhelp-mode)
  :config
  (setq company-quickhelp-delay 1.0)
  :ensure t)

(use-package helpful
  :ensure t
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  ;; Lookup the current symbol at point. C-c C-d is a common keybinding
  ;; for this in lisp modes.
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)

  ;; Look up *F*unctions (excludes macros).
  ;;
  ;; By default, C-h F is bound to `Info-goto-emacs-command-node'. Helpful
  ;; already links to the manual, if a function is referenced there.
  (global-set-key (kbd "C-h F") #'helpful-function)

  ;; Look up *C*ommands.
  ;;
  ;; By default, C-h C is bound to describe `describe-coding-system'. I
  ;; don't find this very useful, but it's frequently useful to only
  ;; look at interactive functions.
  (global-set-key (kbd "C-h C") #'helpful-command))

(use-package magit
  :straight t
  :defer t
  :bind ("C-c g" . magit-status)
  :config
  (define-key magit-status-mode-map (kbd "q") 'magit-quit-session))

(use-package forge
  :straight t
  :defer t
  :after magit
  :config
  (setq auth-source '("~/.authinfo")))

;; full screen magit-status
(defadvice magit-status (around magit-fullscreen activate)
  (window-configuration-to-register :magit-fullscreen)
  ad-do-it ;; ad-do-it is a special marker for 'around advice that refers to the wrapped function.
  (delete-other-windows))

(defun magit-quit-session ()
  "Restores the previous window configuration and kills the magit buffer"
  (interactive)
  (kill-buffer)
  (jump-to-register :magit-fullscreen))

(use-package multiple-cursors
  :ensure t
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->"         . mc/mark-next-like-this)
         ("C-<"         . mc/mark-previous-like-this)
         ("C-c C-<"     . mc/mark-all-like-this)
         ("C-!"         . mc/mark-next-symbol-like-this)
         ("s-d"         . mc/mark-all-dwim)))

(use-package restclient
  :ensure t
  ;; :load-path "~/SourceCode/lisp/emacs_stuff/restclient.el"
  :mode ("\\.restclient\\'" . restclient-mode))

(use-package scratch
  :ensure t
  :commands scratch)

(use-package undo-tree
  :straight t
  :diminish undo-tree-mode
  :config
  (global-undo-tree-mode)
  :custom
  (undo-tree-auto-save-history nil))

(use-package visible-mode
  :bind (("H-v" . visible-mode)
         ("s-<f2>" . visible-mode)))

(use-package yasnippet
  :straight t
  :config
  ;; (setq yas-snippet-dirs (concat user-emacs-directory "snippets"))
  (yas-reload-all)
  (yas-global-mode))

(use-package yasnippet-snippets
    :straight t
    :after yasnippet)

(use-package common-lisp-snippets
    :straight t
    :after yasnippet)

(use-package yatemplate
  :straight t)

(use-package csv-mode
  :ensure t)

(use-package sly
  ;; :load-path "~/SourceCode/lisp/sly"
  :straight t
  :defer t
  :commands sly
  :bind ("C-c M-o" . sly-mrepl-clear-repl)
  :init
  (progn
    (setq sly-lisp-implementations
          '((sbcl ("/usr/local/bin/sbcl"))
            (ccl ("/usr/bin/ccl"))
            (abcl ("/usr/local/src/abcl/abcl"))
            (clisp ("/usr/bin/clisp"))
            (ecl ("/usr/local/bin/ecl"))
            (decl ("/usr/bin/ecl"))
            (clojure ("/usr/bin/clojure"))))

    (setq sly-kill-without-query-p t
          sly-net-coding-system 'utf-8-unix
          sly-complete-symbol*-fancy t
          common-lisp-hyperspec "~/SourceCode/lisp/HyperSpec"))

  :config
  (progn
    (require 'sly-autoloads)))

(use-package sly-asdf
  ;; :load-path "~/SourceCode/lisp/sly-asdf"
  :straight t
  :after sly)

(use-package sly-macrostep
  :straight t
  :after sly)

(use-package sly-named-readtables
  :straight t
  :after sly)

(use-package sly-repl-ansi-color
  :straight t
  :after sly)

(use-package sly-quicklisp
  :straight t
  :after sly)

(use-package paredit
  :straight t
  ;; :diminish paredit-mode
  :config
  (progn
    (autoload 'enable-paredit-mode "paredit" "Turn on pseudo-structural editing of Lisp code." t)
    (add-hook 'emacs-lisp-mode-hook       #'enable-paredit-mode)
    (add-hook 'eval-expression-minibuffer-setup-hook #'enable-paredit-mode)
    (add-hook 'ielm-mode-hook             #'enable-paredit-mode)
    (add-hook 'lisp-mode-hook             #'enable-paredit-mode)
    (add-hook 'lisp-interaction-mode-hook #'enable-paredit-mode)
    (add-hook 'scheme-mode-hook           #'enable-paredit-mode)
    ;; (add-hook 'slime-repl-mode-hook       #'enable-paredit-mode)
    (add-hook 'sly-mrepl-mode-hook        #'enable-paredit-mode)
    ;; (add-hook 'slime-mode-hook            #'enable-paredit-mode)
    ;; (add-hook 'clojure-mode-hook          #'enable-paredit-mode)
    ;; (add-hook 'cider-repl-mode-hook       #'enable-paredit-mode)
    ))

(use-package js2-mode
  :ensure t
  :init
  (setq js-basic-indent 2)
  (setq-default ;; js2-basic-indent 2
                ;; js2-basic-offset 2
                ;; js2-auto-indent-p t
                ;; js2-cleanup-whitespace t
                ;; js2-enter-indents-newline t
                ;; js2-indent-on-enter-key t
                js2-global-externs (list "window" "module" "require" "buster" "sinon" "assert" "refute" "setTimeout" "clearTimeout" "setInterval" "clearInterval" "location" "__dirname" "console" "JSON" "jQuery" "$"))

  (add-hook 'js2-mode-hook
            (lambda ()
              (push '("function" . ?ƒ) prettify-symbols-alist)))

  (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))
  :custom
  (js2-basic-indent 2)
  (js2-basic-offset 2)
  (js2-auto-indent-p t)
  (js2-cleanup-whitespace t)
  (js2-enter-indents-newline t)
  (js2-indent-on-enter-key t))

(use-package color-identifiers-mode
    :ensure t
    :init
      (add-hook 'js2-mode-hook 'color-identifiers-mode))

(add-hook 'js2-mode-hook
          (lambda () (flycheck-select-checker "javascript-eslint")))

(use-package js2-refactor
  :ensure t
  :init   (add-hook 'js2-mode-hook 'js2-refactor-mode)
  :config (js2r-add-keybindings-with-prefix "C-c ."))

(use-package skewer-mode
   :ensure t
   :init (add-hook 'js2-mode-hook 'skewer-mode))

(use-package elpy
  :ensure t
  :config
  (setq elpy-rpc-backend "jedi")
  (setq python-shell-interpreter "ipython"
        python-shell-interpreter-args "-i --simple-prompt")
  (elpy-enable))

(use-package jedi
  :ensure t
  :init
  (add-hook 'python-mode-hook 'jedi:setup)
  :config
  (local-set-key (kbd "M-.") 'jedi:goto-definition)
  (local-set-key (kbd "M-,") 'jedi:goto-definition-pop-marker)
  (local-set-key (kbd "M-?") 'jedi:show-doc)
  (local-set-key (kbd "M-/") 'jedi:get-in-function-call)
  (setq jedi:complete-on-dot t))

(use-package company-jedi
  :ensure jedi
  :ensure t
  :config
  (add-to-list 'company-backends 'company-jedi))

(use-package jinja2-mode
  :ensure t)

(use-package virtualenvwrapper
  :ensure t
  :defer t
  :config
  (setq venv-location "~/.virtualenvs"))

(use-package yaml-mode
  :ensure t
  :defer t
  :config
  (add-hook 'yaml-mode-hook '(lambda () (ansible 1))))

(use-package all-the-icons
  :straight t)

(setq powerline-default-separator nil)

;; (setq line-number-mode t)
;; (setq column-number-mode t)

(setq display-time-24hr-format t)
(setq display-time-format "%H:%M - %d %B %Y")
(display-time-mode 1)

(setq inhibit-startup-message t)

(use-package color-theme-approximate
  :ensure t
  :config
  (unless (display-graphic-p)
    (autoload 'color-theme-approximate-on "color-theme-approximate")
    (color-theme-approximate-on)))

(progn
  ;; on the terminal, the theme situation needs more attention.
  (message "Loading DeepSky theme... ")
  (load-theme 'deepsky-modus-fade t)
  (message "Configuring mode-line appearance...")
  (set-face-attribute `mode-line nil
                      :box nil)
  (message "Setting cursor colour...")
  (set-cursor-color "yellow"))

(defun switch-theme (theme)
  "Disables any currently active themes and loads THEME."
  ;; This interactive call is taken from `load-theme'
  (interactive
   (list
    (intern (completing-read "Load custom theme: "
                             (mapc 'symbol-name
                                   (custom-available-themes))))))
  (let ((enabled-themes custom-enabled-themes))
    (mapc #'disable-theme custom-enabled-themes)
    (load-theme theme t)))

(defun disable-active-themes ()
  "Disables any currently active themes listed in `custom-enabled-themes'."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes))

(bind-key "s-<f12>" 'switch-theme)
(bind-key "s-<f11>" 'disable-active-themes)
