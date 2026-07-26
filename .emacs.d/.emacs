(setq vc-follow-symlinks t)

;;=============================================================================
;; Package manager
;;=============================================================================
(require 'package)
(setq package-archives
      '(("melpa"  . "https://melpa.org/packages/")
        ("gnu"    . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))
(unless package-archive-contents
  (package-refresh-contents))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;;=============================================================================
;; Load my basic extensions and configuration
;;=============================================================================
(load "~/.emacs.d/functions.el")
(load "~/.emacs.d/keys.el")
(load "~/.emacs.d/vars.el")
(load "~/.emacs.d/org.el")


;;=============================================================================
;; Doom Configuration
;;=============================================================================
(add-to-list 'custom-theme-load-path "~/.emacs.d")
(use-package doom-themes
  :ensure t
  :config
  (load-theme 'doom-shane t)
  (global-hl-line-mode +1)
  (setq custom-theme-name 'dark))


;;=============================================================================
;; TypeScript
;;=============================================================================
;; init.el / early-init.el
(setq major-mode-remap-alist
      '((typescript-mode . typescript-ts-mode)   ; .ts
        (tsx-mode        . tsx-ts-mode)))        ; .tsx (Emacs 30)

;; Optional: enable treesit font-lock and indentation globally
(setq treesit-font-lock-level 4)

;; (use-package typescript-mode
;;   :ensure t
;;   :mode ("\\.ts\\'" "\\.tsx\\'")
;;   :hook (typescript-mode . tide-setup))

;; (use-package tide
;;   :ensure t
;;   :after (typescript-mode company flycheck)
;;   :hook ((typescript-mode . tide-hl-identifier-mode)
;;          (before-save     . tide-format-before-save)))

;; (defun switch-theme ()
;;   "Toggle between 'doom-shane' (dark) and 'doom-one-light' (light) themes."
;;   (interactive)
;;   (cond
;;    ((memq 'doom-shane custom-enabled-themes)
;;     ;; Currently using dark theme; switch to light theme.
;;     (load-theme 'doom-one-light t t)
;;     (disable-theme 'doom-shane)
;;     (message "Switched to light theme"))
;;    ((memq 'doom-one-light custom-enabled-themes)
;;     ;; Currently using light theme; switch to dark theme.
;;     (load-theme 'doom-shane t t)
;;     (disable-theme 'doom-one-light)
;;     (message "Switched to dark theme"))
;;    (t
;;     ;; Neither theme is active; default to dark theme.
;;     (load-theme 'doom-shane t t)
;;     (message "No theme detected. Loaded dark theme by default"))))

;; (global-set-key (kbd "C-c t") #'switch-theme)


;;=============================================================================
;; Vertico Configuration
;;
;; Provides a minimalistic vertical completion UI for minibuffer
;; prompts, enhancing the default completion experience.
;;=============================================================================
(use-package vertico
  :ensure t
  :init
  (vertico-mode))

(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "SPC") nil)
  (define-key vertico-map (kbd "SPC") #'minibuffer-complete-word))


;;=============================================================================
;; Marginalia Configuration (additional file/buffer annotations)
;;
;; Adds rich annotations to minibuffer completions, providing
;; additional context like documentation, file sizes, etc.
;;=============================================================================
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode)
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-multiline nil)
  (setq marginalia-annotators '(marginalia-annotators-heavy)))


;;=============================================================================
;; Embark Configuration
;;
;; Provides context-sensitive actions (a "do what I mean" menu) for
;; things at point, integrating with completion frameworks.
;;=============================================================================
(use-package embark
  :ensure t
  ;; Optionally bind a key for embark-act globally, e.g.,:
  :bind
  (("C-." . embark-act)
   ("C-;" . embark-dwim)))


;;=============================================================================
;; Writeroom Mode Configuration
;;
;; A distraction-free editing mode that centers text and hides UI
;; elements for a focused writing environment.
;;=============================================================================
(use-package writeroom-mode
  :ensure t
  :commands (writeroom-mode)
  :init
  (setq writeroom-width 120)
  (setq writeroom-fullscreen-effect 'maximized))
:config

(global-set-key (kbd "C-c w") 'writeroom-mode)


;;=============================================================================
;; Which Key Configuration
;;
;; Displays available keybindings in a popup after a short delay,
;; helping discover commands bound to prefixes.
;;=============================================================================
(use-package which-key
  :ensure t
  :init
  (setq which-key-idle-delay 2              ; Time before popup shows up
        which-key-max-description-length 25 ; Max length of descriptions
        which-key-separator " → "           ; Separator between keys
        which-key-prefix-prefix "+ ")       ; Prefix for prefix keys
  :config
  (which-key-mode)                          ; Enable which-key
  (which-key-setup-side-window-bottom)      ; Position the popup at the bottom
  ;; Optional: Customize the appearance
  (setq which-key-popup-type 'side-window)  ; 'frame, 'minibuffer, 'side-window, etc.
  (which-key-add-major-mode-key-based-replacements 'emacs-lisp-mode
    "C-c C-c" "Compile current buffer"
    "C-c C-k" "Kill Compilation"))


;;=============================================================================
;; Python Mode Configuration
;;=============================================================================
(setq python-indent-offset 4)
(use-package python-mode
  :defer t)


;;=============================================================================
;; YAML Model Configuration
;;=============================================================================
(use-package yaml-mode
  :ensure t
  :mode ("\\.yml\\'" "\\.yaml\\'" "\\.template\\'")
  :hook (yaml-mode . (lambda ()
                       (define-key yaml-mode-map "\C-m" 'newline-and-indent))))


;;=============================================================================
;; Markdown Mode Configuration
;;=============================================================================
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'"       . markdown-mode))
  :init
  ;; If you want to interpret YAML front matter in your .md
  ;; (add-hook 'markdown-mode-hook 'flyspell-mode)  ; Disabled - no spell checker installed
  (setq markdown-enable-math t)
  (setq markdown-command "pandoc --from markdown --to html5 --mathjax")) ;; brew install pandoc


;;=============================================================================
;; Text Mode Configuration
;;=============================================================================
(defun my-text-mode-setup ()
  "Configure settings specific to `text-mode`."
  (auto-fill-mode 1)                ;; Enable auto-fill-mode explicitly
  (setq-local fill-column 77))      ;; Set fill-column to 77 in the buffer

(add-hook 'text-mode-hook #'my-text-mode-setup)


;;=============================================================================
;; Start the server enabling emacsclient to open files
;;=============================================================================
(server-start)


;;=============================================================================
;; Automatically create buffers for everything in initial-buffers.txt
;;=============================================================================
(defvar my-find-files-loaded nil
  "Indicates whether `find-files` has been executed.")
(unless my-find-files-loaded
  (find-files)                  ;; Replace with your actual function call
  (setq my-find-files-loaded t)) ;; Set the flag to indicate execution

(set-register ?e (cons 'file "~/.emacs"))
(set-register ?o (cons 'file "~/.emacs.d/org.el"))
(setq register-preview-delay 0) ;; Show registers ASAP


;;=============================================================================
;; Remove scratch buffer
;;=============================================================================
(if (get-buffer "*scratch*")
    (kill-buffer "*scratch*"))


(load "~/src/sync/tasks.el")

;; Ensure .tasks files automatically open in task-mode
(add-to-list 'auto-mode-alist '("\\.tasks\\'" . task-mode-for-tasks-file))

(message "Welcome!")
