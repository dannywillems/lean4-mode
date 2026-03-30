;;; lean4-project-test.el --- Tests for project.el backend  -*- lexical-binding: t; -*-

;; Licensed under the Apache License, Version 2.0.

;;; Code:

(require 'ert)
(require 'project)
(require 'lean4-lake)

(ert-deftest lean4-project-finds-lakefile-lean ()
  "project.el finds a Lean project with lakefile.lean."
  (let ((dir (make-temp-file "lean4-proj" t)))
    (unwind-protect
        (progn
          (write-region "" nil
                        (expand-file-name "lakefile.lean" dir))
          (let ((proj (lean4-lake-project-find dir)))
            (should proj)
            (should (eq (car proj) 'lean4))
            (should (file-equal-p (project-root proj) dir))))
      (delete-directory dir t))))

(ert-deftest lean4-project-finds-lakefile-toml ()
  "project.el finds a Lean project with lakefile.toml."
  (let ((dir (make-temp-file "lean4-proj" t)))
    (unwind-protect
        (progn
          (write-region "" nil
                        (expand-file-name "lakefile.toml" dir))
          (let ((proj (lean4-lake-project-find dir)))
            (should proj)
            (should (eq (car proj) 'lean4))))
      (delete-directory dir t))))

(ert-deftest lean4-project-returns-nil-without-lakefile ()
  "project.el returns nil when no lakefile exists."
  (let ((dir (make-temp-file "lean4-proj" t)))
    (unwind-protect
        (should-not (lean4-lake-project-find dir))
      (delete-directory dir t))))

(ert-deftest lean4-project-finds-from-subdir ()
  "project.el finds project root from a subdirectory."
  (let ((dir (make-temp-file "lean4-proj" t)))
    (unwind-protect
        (let ((sub (expand-file-name "src/lib" dir)))
          (make-directory sub t)
          (write-region "" nil
                        (expand-file-name "lakefile.lean" dir))
          (let ((proj (lean4-lake-project-find sub)))
            (should proj)
            (should (file-equal-p (project-root proj) dir))))
      (delete-directory dir t))))

(provide 'lean4-project-test)
;;; lean4-project-test.el ends here
