#!/usr/bin/env awful --development-mode

;;; Musicd frontend

;; Require stuff

(use numspell     ; number->english
     miscmacros   ; inc!
     spiffy awful ; Web stuff
     html-tags    ; HTML tags
     utf8
     posix)       ; Time conversion and username


;; Setup

; XHTML mode for html-tags
(xhtml-style? #t)

(define *use-favs* #t)


;; Extra Functions

(define (image-for-folder folder)
  (let ((name (find-files (++ "/media/media/Music/" folder) test: ".*\\.jpg")))
    (if (not (null-list? name))
          (++ "/img/" (substring (car name) 19))
          "/default.png")))

; Needs to be changed for Windows
(define (get-user-name)
  (car (string-split (list-ref (user-information (current-user-id)) 4))))

; Prints a timestamp that will be transformed by jquery.timeago.js
(define (print-relative-time timestamp)
  (<span> class: "time"
          title: (time->string (seconds->local-time timestamp) "%Y-%m-%dT%k:%M:%S")
          (seconds->string timestamp)))

(define (get-folders)
  (sort
   (if *use-favs*
       '("Apocalyptica" "Arcturus"
         "Dark Tranquility" "Dead Can Dance" "Deadsoul Tribe"
         "Eths" "Ikuinen Kaamos"
         "In Mourning" "Katatonia" "Kells" "Leprous" "Machinae Supremacy"
         "Mastodon" "MONOROL" "Mr. Bungle" "My Dying Bride" "Nick Cave & the Bad Seeds"
         "Nine Inch Nails" "Opeth" "OSI -2009- Blood" "Poisonblack" "The Phantom of the Opera"
         "Unexpect"
         )
       (directory "/media/media/Music/"))
   (lambda (a b)
     (string< (string-downcase a)
              (string-downcase b)))))
  

(define-syntax output-to-string
  (syntax-rules ()
    ((_ body ...)
     (with-output-to-string
       (lambda ()
         body
         ...)))))


;; Pages

; The main template
(define-syntax define-template-page
  (syntax-rules ()
    ((_ path body ...)
     (define-page path
       (lambda ()
         (<html>
          (<head> (<title> "Musicd")
                  (<link> rel: "stylesheet" href: "/style.css"))
          (<body>
           body
           ...
           (include-javascript "/jquery.min.js")
           (<script> type: "text/javascript"
                     "$(function () {
    setInterval(function () {
        $(\"#current\").load(\"/current\");
    }, 2000);
});"))))
       no-template: #t))))

(define-page (regexp "/img/.*")
  (lambda (path)
    (let ((path (string-join (cdr (string-split path "/")) "/")))
      (call-with-input-file (++ "/media/media/Music/" path)
        (lambda (port)
          (read-all port)))))
  no-template: #t)


(define-page (regexp "/play/.*")
  (lambda (path)
    (let ((path (string-join (cdr (string-split path "/")) "/")))
      (call-with-input-pipe
       (format "/home/zanea/Documents/bin/play ~S" path)
       (lambda (port) (read-lines port))))
    (redirect-to "/"))
  no-template: #t)


(define-page "/current"
  (lambda ()
    (read-all "~/.musicd/current"))
  no-template: #t)


; Main page
(define-template-page "/"
  (<h3> "Right now, you're listening to " (<u> id: "current" (read-all "~/.musicd/current")))
  (<h4> "Oh and hey " (get-user-name) ", I found " (<u> (number->english (length (get-folders)))) " more of your favourites for you to enjoy")
  (output-to-string
   (map (lambda (entry)
          (when (directory? (++ "/media/media/Music/" entry))
                (display (<div> class: "folder"
                                (<a> href: (++ "/play/" entry)
                                     (<span> entry)
                                     (<img> src: (irregex-replace/all "[']" (image-for-folder entry) "&apos;"))
                                )))))
        (get-folders))))
