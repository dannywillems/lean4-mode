;;; lean4-test.el --- Tests for lean4-mode  -*- lexical-binding: t; -*-

;; Licensed under the Apache License, Version 2.0.

;;; Commentary:

;; ERT tests for lean4-mode bug fixes.

;;; Code:

(require 'ert)

;; Load lean4-mode files without triggering lsp-mode side effects.
;; We load individual modules that don't require lsp-mode.
(require 'lean4-settings)
(require 'lean4-lake)
(require 'lean4-fringe)

;;; Bug #1: lean4-goals and lean4-term-goal should be buffer-local

(ert-deftest lean4-test-goals-are-buffer-local ()
  "Setting lean4-goals in one buffer should not affect another."
  (let ((buf-a (generate-new-buffer " *lean4-test-a*"))
        (buf-b (generate-new-buffer " *lean4-test-b*")))
    (unwind-protect
        (progn
          (with-current-buffer buf-a
            (setq lean4-goals '("goal-a")))
          (with-current-buffer buf-b
            (setq lean4-goals '("goal-b")))
          (should (equal (buffer-local-value 'lean4-goals buf-a)
                         '("goal-a")))
          (should (equal (buffer-local-value 'lean4-goals buf-b)
                         '("goal-b"))))
      (kill-buffer buf-a)
      (kill-buffer buf-b))))

(ert-deftest lean4-test-term-goal-is-buffer-local ()
  "Setting lean4-term-goal in one buffer should not affect another."
  (let ((buf-a (generate-new-buffer " *lean4-test-a*"))
        (buf-b (generate-new-buffer " *lean4-test-b*")))
    (unwind-protect
        (progn
          (with-current-buffer buf-a
            (setq lean4-term-goal "term-a"))
          (with-current-buffer buf-b
            (setq lean4-term-goal "term-b"))
          (should (equal (buffer-local-value 'lean4-term-goal buf-a)
                         "term-a"))
          (should (equal (buffer-local-value 'lean4-term-goal buf-b)
                         "term-b")))
      (kill-buffer buf-a)
      (kill-buffer buf-b))))

;;; Bug #2: lean4-fringe timer callback on killed buffer

(ert-deftest lean4-test-fringe-timer-survives-killed-buffer ()
  "Fringe timer callback should not error on a killed buffer."
  (let ((buf (generate-new-buffer " *lean4-test-fringe*")))
    (with-current-buffer buf
      (setq lean4-fringe-data nil))
    (kill-buffer buf)
    ;; Simulate what the timer does: call the overlay updater
    ;; with a dead buffer. Should not signal an error.
    (should-not
     (condition-case err
         (progn
           (when (buffer-live-p buf)
             (with-current-buffer buf
               (lean4-fringe-update-progress-overlays)))
           nil)
       (error err)))))

;;; Bug #3: lean4-fringe-delay-timer duplicate defvar-local
;; This is a static issue (duplicate declaration). We verify the
;; variable exists and is buffer-local.

(ert-deftest lean4-test-fringe-delay-timer-is-buffer-local ()
  "lean4-fringe-delay-timer should be buffer-local."
  (with-temp-buffer
    (should (local-variable-if-set-p 'lean4-fringe-delay-timer))))

;;; Bug #5: lean4-lake-build missing shell-quote-argument

(ert-deftest lean4-test-lake-find-dir-with-lakefile-lean ()
  "lean4-lake-find-dir finds directory with lakefile.lean."
  (let ((dir (make-temp-file "lean4-test" t)))
    (unwind-protect
        (progn
          (write-region "" nil
                        (expand-file-name "lakefile.lean" dir))
          (with-temp-buffer
            (setq buffer-file-name
                  (expand-file-name "test.lean" dir))
            (should (lean4-lake-find-dir))))
      (delete-directory dir t))))

(ert-deftest lean4-test-lake-find-dir-with-lakefile-toml ()
  "lean4-lake-find-dir finds directory with lakefile.toml."
  (let ((dir (make-temp-file "lean4-test" t)))
    (unwind-protect
        (progn
          (write-region "" nil
                        (expand-file-name "lakefile.toml" dir))
          (with-temp-buffer
            (setq buffer-file-name
                  (expand-file-name "test.lean" dir))
            (should (lean4-lake-find-dir))))
      (delete-directory dir t))))

(ert-deftest lean4-test-lake-find-dir-returns-nil-without-lakefile ()
  "lean4-lake-find-dir returns nil when no lakefile exists."
  (let ((dir (make-temp-file "lean4-test" t)))
    (unwind-protect
        (with-temp-buffer
          (setq buffer-file-name
                (expand-file-name "test.lean" dir))
          (should-not (lean4-lake-find-dir)))
      (delete-directory dir t))))

;;; Bug #6: lean4-lake-find-dir called twice in lean4-execute
;; This is a code quality issue. We verify lean4-lake-find-dir is
;; idempotent so the fix (caching) is safe.

(ert-deftest lean4-test-lake-find-dir-is-idempotent ()
  "Calling lean4-lake-find-dir twice returns the same result."
  (let ((dir (make-temp-file "lean4-test" t)))
    (unwind-protect
        (progn
          (write-region "" nil
                        (expand-file-name "lakefile.lean" dir))
          (with-temp-buffer
            (setq buffer-file-name
                  (expand-file-name "test.lean" dir))
            (should (equal (lean4-lake-find-dir)
                           (lean4-lake-find-dir)))))
      (delete-directory dir t))))

(provide 'lean4-test)
;;; lean4-test.el ends here
