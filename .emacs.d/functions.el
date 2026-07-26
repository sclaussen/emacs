;;-----------------------------------------------------------------------------
;; unassigned
;;
;; This is a default function for use by key bindings that don't have keys
;; bound to them.
;;-----------------------------------------------------------------------------
(defun unassigned ()
  (interactive)
  (ding)
  (message "This key is currently not mapped to an emacs function."))


(defun unfill-paragraph ()
  "Transform a filled paragraph into a single line of text."
  (interactive)
  (let ((fill-column (point-max)))
    (fill-paragraph nil)))


;;-----------------------------------------------------------------------------
;; find-files
;;-----------------------------------------------------------------------------
(defun find-files (&optional initial-buffers-file)
  "Load multiple files into Emacs buffers as specified in INITIAL-BUFFERS-FILE.

INITIAL-BUFFERS-FILE defaults to '~/.emacs.d/initial-buffers.txt'.

eEach line in INITIAL-BUFFERS-FILE should contain the full path to a file.
Files are loaded into buffers without switching to them.

This function is non-interactive and can be called programmatically."
  (let ((default-file (expand-file-name "~/.emacs.d/initial-buffers.txt"))
        (file-list '())
        (loaded-files 0)
        (skipped-files 0)
        (skipped-file-basenames '()))
    ;; Determine the path to initial-buffers.txt
    (setq initial-buffers-file (or initial-buffers-file default-file))
    ;; Check if the file exists
    (if (file-exists-p initial-buffers-file)
        (progn
          ;; Read the file line by line and collect file paths
          (with-temp-buffer
            (insert-file-contents initial-buffers-file)
            (setq file-list
                  (delq nil
                        (mapcar (lambda (line)
                                  (let ((trimmed-line (string-trim line)))
                                    ;; Skip empty lines and commented lines (starting with #)
                                    (when (and (not (string-empty-p trimmed-line))
                                               (not (string-prefix-p "#" trimmed-line)))
                                      trimmed-line)))
                                (split-string (buffer-string) "\n" t)))))
          ;; Remove duplicates for efficiency
          (setq file-list (delete-dups file-list))
          ;; Iterate over each file path and load it into a buffer
          (dolist (file file-list)
            (if (file-exists-p file)
                (progn
                  (find-file-noselect file)
                  (setq loaded-files (1+ loaded-files)))
              (setq skipped-files (1+ skipped-files))
              ;; Collect the basename of the skipped file
              (push (file-name-nondirectory file) skipped-file-basenames)))
          ;; Summary message with list of skipped files
          (if (not (equal skipped-files 0))
              (message "find-files: Loaded %d files; Skipped %s."
                       loaded-files
                       (mapconcat #'identity (reverse skipped-file-basenames) ", "))
            (message "find-files: Loaded %d files." loaded-files)))
      ;; If initial-buffers.txt does not exist, log a message
      (message "find-files: Initial buffers file not found: %s" initial-buffers-file))))


(defun first-line-p ()
  "Return non-nil if point is on the first line of the buffer."
  (eq (line-number-at-pos) 1))

(defun last-line-p ()
  "Return non-nil if point is on the last line of the buffer."
  (eq (line-number-at-pos (point))
      (line-number-at-pos (point-max))))

;;-----------------------------------------------------------------------------
;; my-beginning-of-buffer
;;-----------------------------------------------------------------------------
(defun my-beginning-of-buffer ()
  (interactive)
  (beginning-of-buffer)
  (goto-char (point-min))
  (message "Beginning of buffer"))

;;-----------------------------------------------------------------------------
;; my-end-of-buffer
;;-----------------------------------------------------------------------------
(defun my-end-of-buffer ()
  (interactive)
  (end-of-buffer)
  (previous-line 1)
  (beginning-of-line)
  (recenter-bottom)
  (message "End of buffer"))

;;-----------------------------------------------------------------------------
;; scroll-down-hard
;;-----------------------------------------------------------------------------
(defun scroll-down-hard ()
  "Scroll down.
If the end of the buffer is already on the screen, move point to it."
  (interactive)
  (if (not (pos-visible-in-window-p (point-max)))
      ;;then
      (scroll-up)
    ;;else
    (my-end-of-buffer)))

;;-----------------------------------------------------------------------------
;; scroll-up-hard
;;-----------------------------------------------------------------------------
(defun scroll-up-hard ()
  "Scroll up.
If the end of the buffer is already on the screen, move point to it."
  (interactive)
  (if (not (pos-visible-in-window-p (point-min)))
      ;;then
      (scroll-down)
    ;;else
    (my-beginning-of-buffer)))

(defun indent-buffer ()
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (set-mark-command nil)
    (end-of-buffer)
    (indent-region (region-beginning) (region-end) nil)
    ))

(defun my-uncomment-region ()
  (interactive)
  (comment-region (region-beginning) (region-end) (quote -)))

(defun camel-up ()
  (interactive)
  (forward-word 1)
  (backward-word 1)
  (forward-char 1)
  (insert " ")
  (backward-word 1)
  (capitalize-word 1)
  (delete-horizontal-space)
  (backward-word 1))

(defun camel-down ()
  (interactive)
  (forward-word 1)
  (backward-word 1)
  (forward-char 1)
  (insert " ")
  (backward-word 1)
  (downcase-word 1)
  (delete-horizontal-space)
  (backward-word 1))

(defun buffer-pretty ()
  (interactive)
  (save-excursion
    (mark-whole-buffer)
    (indent-region (save-excursion
                     (beginning-of-buffer)
                     (point))
                   (save-excursion
                     (end-of-buffer)
                     (point)))))

;;-----------------------------------------------------------------------------
;; scroll-point-to-top-of-window
;;-----------------------------------------------------------------------------
(defun recenter-top ()
  "Recenter the line the cursor is currently on to the top of the window."
  (interactive)
  (recenter 0))

;;-----------------------------------------------------------------------------
;; scroll-point-to-bottom-of-window
;;-----------------------------------------------------------------------------
(defun recenter-bottom ()
  "Recenter the line the cursor is on to the bottom of the window."
  (interactive)
  (recenter (- (window-height) 2)))

;; ;;-----------------------------------------------------------------------------
;; ;; toggle-truncate-lines
;; ;;-----------------------------------------------------------------------------
;; (defun toggle-truncate-lines ()
;;   (interactive)
;;   (if (equal truncate-partial-width-windows t)
;;       (progn
;;         (message "truncate-lines was t, making it nil")
;;         (set-variable 'truncate-partial-width-windows nil)
;;         (set-variable 'truncate-lines nil))
;;     (progn
;;       (message "truncate-lines was nil, making it t")
;;       (set-variable 'truncate-partial-width-windows t)
;;       (set-variable 'truncate-lines t))))

;;-----------------------------------------------------------------------------
;; toggle-case-fold-search
;;-----------------------------------------------------------------------------
;; (defun toggle-case-fold-search ()
;;   (interactive)
;;   (make-variable-buffer-local 'case-fold-search)
;;   (if (equal case-fold-search t)
;;       (progn
;;         (set-variable 'case-fold-search nil)
;;         (setq case-fold-search nil)
;;         (message "Searching is case SENSITIVE"))
;;     (progn
;;       (set-variable 'case-fold-search t)
;;       (setq case-fold-search t)
;;       (message "Searching is NOT case SENSITIVE"))))

;;-----------------------------------------------------------------------------
;; indent-defun
;;-----------------------------------------------------------------------------
(defun indent-defun ()
  "Indents the current function based on the current mode's indentation style."
  (interactive)
  (save-excursion
    (mark-defun)
    (indent-region
     (region-beginning) (region-end) nil)))

;;-----------------------------------------------------------------------------
;; end-of-buffer-other-window
;;-----------------------------------------------------------------------------
;; This bit of code should make sure there really is another window before
;; attempting this task
(defun other-window-end-of-buffer ()
  (interactive)
  (other-window 1)
  (end-of-buffer)
  (other-window -1))

;;-----------------------------------------------------------------------------
;; scroll-up-hard
;;-----------------------------------------------------------------------------
;; (defun toggle-tab-width ()
;;   (interactive)
;;   (if (equal tab-width 4)
;;       (setq tab-width 8)
;;     (setq tab-width 4))
;;   (recenter))

;;-----------------------------------------------------------------------------
;;
;;-----------------------------------------------------------------------------
(defun remove-vertical-whitespace ()
  (interactive)
  (save-excursion
    (if (progn
          (beginning-of-line)
          (looking-at "^[ \t]*$"))

        (progn

          ;; Move to the first empty line - either at the beginning of the
          ;; buffer, or directly after the first non-blank line
          (while (and (not (bobp))
                      (looking-at "^[ \t]*$"))
            (kill-line 1)
            (previous-line 1))

          ;; Move to the next blank line if necessary
          (if (or (not (bobp))
                  (and (bobp)
                       (not (looking-at "^[ \t]*$"))))
              (next-line 1))

          ;; Remove all remaining blank lines
          (while (looking-at "^[ \t]*$")
            (kill-line 1))))))

(defun delete-horizontal-and-all-following-vertical-whitespace ()
  (interactive)
  (delete-horizontal-space)
  (while (looking-at "\n")
    (delete-char 1)
    (delete-horizontal-space)))

(defun delete-horizontal-and-all-prior-vertical-whitespace ()
  (interactive)
  (delete-horizontal-space)
  (while (bolp)
    (c-electric-backspace nil)
    (delete-horizontal-space)))

(defun add-integer-in-buffer ()
  (interactive)
  (let* ((number-string (save-excursion
                          (buffer-substring (point)
                                            (progn
                                              (forward-word 1)
                                              (point)))))
         (number-string-2 (number-to-string (+ (string-to-number number-string) 1))))
    (kill-word 1)
    (insert number-string-2)
    (backward-word 1)))

(defun subtract-integer-in-buffer ()
  (interactive)
  (let* ((number-string (save-excursion
                          (buffer-substring (point)
                                            (progn
                                              (forward-word 1)
                                              (point)))))
         (number-string-2 (number-to-string (- (string-to-number number-string) 1))))
    (kill-word 1)
    (insert number-string-2)
    (backward-word 1)))

;; kill-line
(defun my-kill-line (&optional arg)
  (interactive "P")
  (if buffer-read-only
      (progn
        (kill-new (buffer-substring-no-properties (point) (line-end-position)))
        (message "Copied..."))
    (kill-line arg)))

;; kill-region
(defun my-kill-region (beg end &optional region)
  (interactive (list (region-beginning) (region-end) 'region))
  (if buffer-read-only
      (progn
        (kill-ring-save beg end region)
        (message "Copied..."))
    (kill-region beg end region)))
