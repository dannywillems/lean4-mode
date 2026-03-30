;;; lean4-lake.el --- Lean4-Mode Lake Integration  -*- lexical-binding: t; -*-

;; This file is not part of GNU Emacs.

;; Licensed under the Apache License, Version 2.0 (the "License"); you
;; may not use this file except in compliance with the License.  You
;; may obtain a copy of the License at
;;
;;     http://www.apache.org/licenses/LICENSE-2.0
;;
;; Unless required by applicable law or agreed to in writing, software
;; distributed under the License is distributed on an "AS IS" BASIS,
;; WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
;; implied.  See the License for the specific language governing
;; permissions and limitations under the License.

;;; Commentary:

;; This library provides integration with Lake, Lean 4 build system and package
;; manager.

;;; Code:

(require 'project)
(require 'lean4-util)
(require 'lean4-settings)

(defun lean4-root-dir-p (dir)
  "Check if directory DIR contains \"lakefile.lean\" or \"lakefile.toml\"."
  (or
   (file-exists-p (expand-file-name "lakefile.lean" dir))
   (file-exists-p (expand-file-name "lakefile.toml" dir))))

(defun lean4-lake-find-dir ()
  "Find a parent directory of the current file with a Lake file.

  It looks for files named \"lakefile.lean\" or \"lakefile.toml\" file."
  (and (buffer-file-name)
       (locate-dominating-file (buffer-file-name) #'lean4-root-dir-p)))

(defun lean4-lake-find-dir-safe ()
  "Call `lean4-lake-find-dir', error on failure."
  (or (lean4-lake-find-dir)
      (error "Cannot find lakefile in any directory above %s" (buffer-file-name))))

(defun lean4-lake-build ()
  "Call lake build."
  (interactive)
  (let ((default-directory (file-name-as-directory (lean4-lake-find-dir-safe))))
    (compile (concat (lean4-get-executable lean4-lake-name) " build"))))

;;; project.el integration

(cl-defmethod project-root ((project (head lean4)))
  "Return the root directory of a Lean 4 PROJECT."
  (cdr project))

(defun lean4-lake-project-find (dir)
  "Return a Lean 4 project for DIR if a lakefile is found."
  (when-let ((root (locate-dominating-file dir #'lean4-root-dir-p)))
    (cons 'lean4 (file-name-as-directory
                  (expand-file-name root)))))

(add-hook 'project-find-functions #'lean4-lake-project-find)

(provide 'lean4-lake)
;;; lean4-lake.el ends here
