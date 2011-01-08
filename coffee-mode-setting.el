(require 'ansi-color)

(unless (fboundp 'with-named-progn) 
  (defmacro with-named-progn (comment &rest body)
    `(progn ,@body)))


(defun cur-dir ()
  (if load-in-progress (file-name-directory load-file-name) default-directory))

(defun coffee-send-buffer () (interactive)
  (coffee-send-region (point-min) (point-max)))

(defun coffee-send-region (beg end) (interactive "r")
  (comint-simple-send (coffee-get-repl-proc)
                      (buffer-substring-no-properties beg end)))
                      

(defun coffee-get-repl-proc () 
  (unless (comint-check-proc "*CoffeeREPL*")
    (coffee-repl))
  (get-buffer-process "*CoffeeREPL*"))

(defun coffee-compile-file* () (interactive)
  (and-let* ((file (buffer-file-name)))
    (compile (format "cat %s | coffee -s -p" file))))

(with-named-progn coffee-script-setting
  (add-to-list 'load-path (cur-dir))
  (require 'coffee-mode)

  (add-to-list 'auto-mode-alist '("\\.coffee$" . coffee-mode))
  (add-to-list 'auto-mode-alist '("[Ca]kefile" . coffee-mode))

    (defun coffee-selfish-setup ()
      (ansi-color-for-comint-mode-on)

      (set (make-local-variable 'tab-width) 2)
      (setq coffee-js-mode 'javascript-mode)
      (setq coffee-cleanup-whitespace nil)
      ;; ;; If you don't want your compiled files to be wrapped
      ;; (setq coffee-args-compile '("-c" "--no-wrap"))

      ;; *Messages* spam
      (setq coffee-debug-mode t)

      (let1 mapping '(("\C-c\C-@" . coffee-compile-file*)
                      ("\C-c@" . coffee-compile-file)
                      ("\C-c\C-l" . coffee-send-buffer)
                      ("\\" . insert-pair-escaped-after)
                      ("\C-c\C-r" . coffee-send-region)
                      ("\C-cS" . coffee-repl))
        (loop for (k . f) in mapping
              do (define-key coffee-mode-map k f))))

    (let1 key-pairs-mapping '(("(" . ")")
                              ("\"" . "\"")
                              ("'" . "'")
                              ("{"  "}" "{")
                              ("[" "]" "["))
          (loop for (l . r) in key-pairs-mapping
                if (atom r)
                do (define-key coffee-mode-map l (insert-pair-make l r))
                else
                do (destructuring-bind (r key) r
                     (define-key coffee-mode-map key (insert-pair-make l r key)))))

  (add-hook 'coffee-mode-hook 'coffee-selfish-setup)
)            
  
