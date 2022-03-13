;;; org-link-google-sheet.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2022 Cash Weaver
;;
;; Author: Cash Weaver <cashbweaver@gmail.com>
;; Maintainer: Cash Weaver <cashbweaver@gmail.com>
;; Created: March 13, 2022
;; Modified: March 13, 2022
;; Version: 0.0.1
;; Homepage: https://github.com/cashweaver/org-link-google-sheet
;; Package-Requires: ((emacs "27.1"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  This library provides an google-sheet link in org-mode.
;;
;;; Code:

(require 'ol)
(require 's)

(defcustom org-link-google-sheet-url-base
  "https://docs.google.com/spreadsheets/d"
  "The URL of Google-Sheet."
  :group 'org-link-follow
  :type 'string
  :safe #'stringp)

(defun org-link-google-sheet--build-uri (google-sheet-id)
  "Return a uri for the provided PATH."
  (url-encode-url
   (s-format
    "${base-url}/${google-sheet-id}"
    'aget
    `(("base-url" . ,org-link-google-sheet-url-base)
      ("google-sheet-id" . ,google-sheet-id)))))

(defun org-link-google-sheet-open (google-sheet-id arg)
  "Opens an google-sheet type link."
  (let ((uri
         (org-link-google-sheet--build-uri
          google-sheet-id)))
    (browse-url
     uri
     arg)))

(defun org-link-google-sheet-export (google-sheet-id desc backend info)
  "Export an google-sheet link.

- GOOGLE-SHEET-ID: the id of the sheetument.
- DESC: the description of the link, or nil.
- BACKEND: a symbol representing the backend used for export.
- INFO: a a plist containing the export parameters."
  (let ((uri
         (org-link-google-sheet--build-uri
          google-sheet-id)))
    (pcase backend
      (`md
       (format "[%s](%s)" (or desc uri) uri))
      (`html
       (format "<a href=\"%s\">%s</a>" uri (or desc uri)))
      (`latex
       (if desc (format "\\href{%s}{%s}" uri desc)
         (format "\\url{%s}" uri)))
      (`ascii
       (if (not desc) (format "<%s>" uri)
         (concat (format "[%s]" desc)
                 (and (not (plist-get info :ascii-links-to-notes))
                      (format " (<%s>)" uri)))))
      (`texinfo
       (if (not desc) (format "@uref{%s}" uri)
         (format "@uref{%s, %s}" uri desc)))
      (_ uri))))

(org-link-set-parameters
 "google-sheet"
 :follow #'org-link-google-sheet-open
 :export #'org-link-google-sheet-export)


(provide 'org-link-google-sheet)
;;; org-link-google-sheet.el ends here
