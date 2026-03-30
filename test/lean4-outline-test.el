;;; lean4-outline-test.el --- Tests for outline-mode support  -*- lexical-binding: t; -*-

;; Licensed under the Apache License, Version 2.0.

;;; Code:

(require 'ert)
(require 'lean4-syntax)

(defun lean4-test--outline-matches-p (text)
  "Return non-nil if TEXT matches the outline regexp."
  (string-match-p lean4-outline-regexp text))

(defun lean4-test--outline-level-of (text)
  "Return the outline level for a line containing TEXT."
  (with-temp-buffer
    (insert text)
    (goto-char (point-min))
    (lean4-outline-level)))

(ert-deftest lean4-outline-matches-namespace ()
  (should (lean4-test--outline-matches-p "namespace Foo")))

(ert-deftest lean4-outline-matches-section ()
  (should (lean4-test--outline-matches-p "section Bar")))

(ert-deftest lean4-outline-matches-end ()
  (should (lean4-test--outline-matches-p "end Foo")))

(ert-deftest lean4-outline-matches-def ()
  (should (lean4-test--outline-matches-p "def foo := 0")))

(ert-deftest lean4-outline-matches-theorem ()
  (should (lean4-test--outline-matches-p "theorem bar : True := trivial")))

(ert-deftest lean4-outline-matches-structure ()
  (should (lean4-test--outline-matches-p "structure Point where")))

(ert-deftest lean4-outline-matches-private-def ()
  (should (lean4-test--outline-matches-p "private def helper := 0")))

(ert-deftest lean4-outline-level-namespace-is-1 ()
  (should (= (lean4-test--outline-level-of "namespace Foo") 1)))

(ert-deftest lean4-outline-level-section-is-1 ()
  (should (= (lean4-test--outline-level-of "section Bar") 1)))

(ert-deftest lean4-outline-level-end-is-1 ()
  (should (= (lean4-test--outline-level-of "end Foo") 1)))

(ert-deftest lean4-outline-level-def-is-2 ()
  (should (= (lean4-test--outline-level-of "def foo := 0") 2)))

(ert-deftest lean4-outline-level-theorem-is-2 ()
  (should (= (lean4-test--outline-level-of "theorem bar : True := trivial") 2)))

(provide 'lean4-outline-test)
;;; lean4-outline-test.el ends here
