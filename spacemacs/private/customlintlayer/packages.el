(setq customlintlayer-packages
      '( flycheck))

(defun customlintlayer/post-init-flycheck ()
  (with-eval-after-load 'flycheck
    (dolist (checker '(javascript-eslint javascript-standard))
      (flycheck-add-mode checker 'js2-mode)))

  (defun react/use-eslint-from-node-modules ()
    (let* ((root (locate-dominating-file
                  (or (buffer-file-name) default-directory)
                  "node_modules"))
           (local-eslint (expand-file-name "node_modules/.bin/eslint"
                                           root))
           (global-eslint (executable-find "eslint"))
           (eslint (if (file-executable-p local-eslint)
                       local-eslint
                     global-eslint)))
      (setq-local flycheck-javascript-eslint-executable eslint)))


  (defun add-node-modules-path ()
    (defcustom add-node-modules-path-debug nil
    "Enable verbose output when non nil."
    :type 'boolean)

    (defcustom add-node-modules-max-depth 20
    "Max depth to look for node_modules."
    :type 'integer)

    (let* ((default-dir (expand-file-name default-directory))
           (file (or (buffer-file-name) default-dir))
           (home (expand-file-name "~"))
           (iterations add-node-modules-max-depth)
           (root (directory-file-name (or (and (buffer-file-name) (file-name-directory (buffer-file-name))) default-dir)))
           (roots '()))
      (while (and root (> iterations 0))
        (setq iterations (1- iterations))
        (let ((bindir (expand-file-name "node_modules/.bin/" root)))
          (when (file-directory-p bindir)
            (add-to-list 'roots bindir)))
        (if (string= root home)
            (setq root nil)
          (setq root (directory-file-name (file-name-directory root)))))
      (if roots
          (progn
            (make-local-variable 'exec-path)
            (while roots
              (add-to-list 'exec-path (car roots))
              (when add-node-modules-path-debug
                (message (concat "added " (car roots) " to exec-path")))
              (setq roots (cdr roots))))
        (when add-node-modules-path-debug
          (message (concat "node_modules/.bin not found for " file))))))
(add-hook 'js2-mode-hook #'react/use-eslint-from-node-modules)
(add-hook 'js2-mode-hook #'add-node-modules-path)

(spacemacs/add-flycheck-hook 'js2-mode))
