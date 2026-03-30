;;; lean4-imenu-test.el --- Tests for imenu support  -*- lexical-binding: t; -*-

;; Licensed under the Apache License, Version 2.0.

;;; Code:

(require 'ert)
(require 'lean4-syntax)

(defun lean4-test--imenu-matches (category text)
  "Return list of names matched by imenu CATEGORY in TEXT."
  (let ((entry (assoc category lean4-imenu-generic-expression)))
    (when entry
      (let ((regexp (nth 1 entry))
            (subexp (nth 2 entry))
            (matches nil))
        (with-temp-buffer
          (insert text)
          (goto-char (point-min))
          (while (re-search-forward regexp nil t)
            (push (match-string subexp) matches)))
        (nreverse matches)))))

(ert-deftest lean4-imenu-matches-def ()
  "Imenu finds def declarations."
  (should (equal (lean4-test--imenu-matches
                  "Definition" "def foo : Nat := 0")
                 '("foo"))))

(ert-deftest lean4-imenu-matches-abbrev ()
  "Imenu finds abbrev declarations."
  (should (equal (lean4-test--imenu-matches
                  "Definition" "abbrev MyType := Nat")
                 '("MyType"))))

(ert-deftest lean4-imenu-matches-private-def ()
  "Imenu finds private def declarations."
  (should (equal (lean4-test--imenu-matches
                  "Definition" "private def helper := 0")
                 '("helper"))))

(ert-deftest lean4-imenu-matches-noncomputable-def ()
  "Imenu finds noncomputable def declarations."
  (should (equal (lean4-test--imenu-matches
                  "Definition"
                  "noncomputable def myReal : Real := 0")
                 '("myReal"))))

(ert-deftest lean4-imenu-matches-theorem ()
  "Imenu finds theorem declarations."
  (should (equal (lean4-test--imenu-matches
                  "Theorem" "theorem my_thm : True := trivial")
                 '("my_thm"))))

(ert-deftest lean4-imenu-matches-lemma ()
  "Imenu finds lemma declarations."
  (should (equal (lean4-test--imenu-matches
                  "Theorem" "lemma my_lemma : True := trivial")
                 '("my_lemma"))))

(ert-deftest lean4-imenu-matches-structure ()
  "Imenu finds structure declarations."
  (should (equal (lean4-test--imenu-matches
                  "Structure" "structure Point where")
                 '("Point"))))

(ert-deftest lean4-imenu-matches-class ()
  "Imenu finds class declarations."
  (should (equal (lean4-test--imenu-matches
                  "Structure" "class Monad (m : Type) where")
                 '("Monad"))))

(ert-deftest lean4-imenu-matches-inductive ()
  "Imenu finds inductive declarations."
  (should (equal (lean4-test--imenu-matches
                  "Inductive" "inductive MyList where")
                 '("MyList"))))

(ert-deftest lean4-imenu-matches-instance ()
  "Imenu finds instance declarations."
  (should (equal (lean4-test--imenu-matches
                  "Instance" "instance instFoo : Foo Nat where")
                 '("instFoo"))))

(ert-deftest lean4-imenu-matches-namespace ()
  "Imenu finds namespace declarations."
  (should (equal (lean4-test--imenu-matches
                  "Namespace" "namespace Foo.Bar")
                 '("Foo.Bar"))))

(ert-deftest lean4-imenu-matches-section ()
  "Imenu finds section declarations."
  (should (equal (lean4-test--imenu-matches
                  "Section" "section MySection")
                 '("MySection"))))

(ert-deftest lean4-imenu-matches-multiple ()
  "Imenu finds multiple definitions in one buffer."
  (should (equal (lean4-test--imenu-matches
                  "Definition"
                  "def foo := 0\ndef bar := 1\ndef baz := 2")
                 '("foo" "bar" "baz"))))

(provide 'lean4-imenu-test)
;;; lean4-imenu-test.el ends here
