(defun todo-buffer-display ()
  (interactive)
  (let ((todo-buffer (get-file-buffer "~/.todo.org")))
    (if todo-buffer
        (switch-to-buffer todo-buffer)
      (find-file  "~/.todo.org"))))

(defun todo-next-line ()
  (interactive)
  (next-line 1)
  (beginning-of-line))

(defun todo-previous-line ()
  (interactive)
  (previous-line 1)
  (beginning-of-line))

(defun todo-edit ()
  (interactive)
  (setq mode-name "Todo Edit")
  (todo-toggle-keys mode-name)
  (force-mode-line-update))

(defun todo-quit-edit ()
  (interactive)
  (setq mode-name "Todo")
  (todo-toggle-keys mode-name)
  (force-mode-line-update))

(defun todo-completed ()
  (interactive)
  (next-line 1)
  (beginning-of-line))

(defun todo-cancel ()
  (interactive))

(defun todo-raise-priority ()
  (interactive))

(defun todo-lower-priority ()
  (interactive))

(defun todo-create-p1 ()
  (interactive)
  (save-excursion
    (todo-create "1")))

(defun todo-create-p2 ()
  (interactive)
  (save-excursion
    (todo-create "2")))

(defun todo-create-p3 ()
  (interactive)
  (save-excursion
    (todo-create "3")))

(defun todo-create-p4 ()
  (interactive)
  (save-excursion
    (todo-create "4")))

(defun todo-update-p1 ()
  (interactive)
  (save-excursion
    (todo-update-priority "1")))

(defun todo-update-p2 ()
  (interactive)
  (save-excursion
    (todo-update-priority "2")))

(defun todo-update-p3 ()
  (interactive)
  (save-excursion
    (todo-update-priority "3")))

(defun todo-update-p4 ()
  (interactive)
  (save-excursion
    (todo-update-priority "4")))

(defvar todo-category-list '("pkg" "pkgdesigner" "pkgadmin" "pkgdev" "distribution" "lcm" "workflow" "rules")
  "List of possible categories for TODO items.")

(defun todo-create (&optional priority description category)
  (save-excursion
    (let* ((priority (or priority (read-from-minibuffer "Priority: ")))
           (category (or category (completing-read "Category: " todo-category-list nil nil nil nil)))
           (description (or description (read-from-minibuffer "Description: "))))
      (beginning-of-buffer)
      (insert (concat priority " " category " " description " (" (get-date) ")\n"))
      (save-buffer 1))))

(defun todo-update-priority (priority)
  (save-excursion
    (let ((todo (buffer-substring (progn (beginning-of-line) (point))
                                  (progn (end-of-line) (point)))))

      ;;find todo in current file
      (beginning-of-buffer)
      (search-forward todo nil nil)

      ;;update current file
      (delete-region (progn (beginning-of-line) (point))
                     (+ 1 (progn (end-of-line) (point))))

      (if (progn
            (beginning-of-buffer)
            (equal nil (re-search-forward
                        (concat "^Priority: " priority) nil t)))
          (progn
            (ding)
            (message (concat "Priority " priority " not found.")))

        (progn
          (beginning-of-line)
          (next-line 2)
          (insert todo "\n")
          (save-buffer 1)
          (message (concat "Todo moved to section " priority ".")))))))

(defun todo-done ()

  (interactive)

  (save-excursion
    (beginning-of-line)
    (let ((todo (buffer-substring (+ 2 (point)) (progn (end-of-line) (point))))
          (todo-buffer (current-buffer))
          (todo-complete-buffer (get-file-buffer todo-file-completed))
          (comments (read-from-minibuffer "Comments: ")))

      ;;find todo in current file
      (beginning-of-buffer)
      (search-forward todo nil nil)

      ;; Delete the todo (current line) from the todo buffer
      (delete-region (progn (beginning-of-line) (point))
                     (+ 1 (progn (end-of-line) (point))))
      (save-buffer 1)

      ;; Switch to the todo completed buffer
      (if todo-complete-buffer
          (switch-to-buffer todo-complete-buffer)
        (find-file todo-file-completed))

      ;; Append the todo to the end of the todo completed buffer
      (end-of-buffer)
      (insert (get-date) " " todo "\n")
      (insert "    " todo-current-user ": " comments "\n")
      (save-buffer 1)
      (kill-buffer (current-buffer))

      (switch-to-buffer todo-buffer)
      (message ""))))

(defun get-date ()

  (let* ((current-date (current-time-string))
         (month (substring current-date 4 7))
         (day (substring current-date 8 10)))

    (message day)

    (if (eq " " (substring day 0 1))
        (setq day (concat "0" (substring day 1))))

    (cond
     ((equal month "Jan")
      (concat "01/" day))
     ((equal month "Feb")
      (concat "02/" day))
     ((equal month "Mar")
      (concat "03/" day))
     ((equal month "Apr")
      (concat "04/" day))
     ((equal month "May")
      (concat "05/" day))
     ((equal month "Jun")
      (concat "06/" day))
     ((equal month "Jul")
      (concat "07/" day))
     ((equal month "Aug")
      (concat "08/" day))
     ((equal month "Sep")
      (concat "09/" day))
     ((equal month "Oct")
      (concat "10/" day))
     ((equal month "Nov")
      (concat "11/" day))
     ((equal month "Dec")
      (concat "12/" day)))))

(defun todo-toggle-keys (mode)
  (define-key todo-mode-map "a" (if (eq mode "Todo") 'todo-create 'self-insert-command))
  (define-key todo-mode-map "n" (if (eq mode "Todo") 'todo-next-line 'self-insert-command))
  (define-key todo-mode-map "p" (if (eq mode "Todo") 'todo-previous-line 'self-insert-command))
  (define-key todo-mode-map "e" (if (eq mode "Todo") 'todo-edit 'self-insert-command))
  (define-key todo-mode-map "c" (if (eq mode "Todo") 'todo-cancel 'self-insert-command))
  (define-key todo-mode-map "d" (if (eq mode "Todo") 'todo-done 'self-insert-command))
  (define-key todo-mode-map "," (if (eq mode "Todo") 'todo-raise-priority 'self-insert-command))
  (define-key todo-mode-map "." (if (eq mode "Todo") 'todo-lower-priority 'self-insert-command))
  (define-key todo-mode-map "1" (if (eq mode "Todo") 'todo-create-p1 'self-insert-command))
  (define-key todo-mode-map "2" (if (eq mode "Todo") 'todo-create-p2 'self-insert-command))
  (define-key todo-mode-map "3" (if (eq mode "Todo") 'todo-create-p3 'self-insert-command))
  (define-key todo-mode-map "4" (if (eq mode "Todo") 'todo-create-p4 'self-insert-command))
  (define-key todo-mode-map "\C-c\C-c" 'todo-quit-edit))
