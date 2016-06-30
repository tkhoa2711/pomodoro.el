;;; pomodoro.el - Pomodoro technique with Emacs

;;                  work
;;            ,---------------------.
;;            |                     |
;;            |     break           |
;;            |   ,-->[break]-------'
;;            |  /
;;    start   v /   stop
;; -------->[work]------->[[done]]
;;            ^ \
;;            |  \
;;            |   `-->[long-break]--.
;;            |  long-break         |
;;            |                     |
;;            `---------------------'
;;                  work

(defgroup pomodoro nil
  "Pomodoro practice with Emacs."
  :group 'convenience)

(require 'alert)
(require 'log4e)

;; enable logging and setup logs format

(log4e:deflogger "pomodoro" "%t [%l] %m" "%H:%M:%S")
(pomodoro--log-enable-logging)
(pomodoro--log-enable-messaging "*pomodoro-log*")

;; customizable settings

(defvar pomodoro-work-duration (* 25 60.0)
  "Duration of a `work'.")

(defvar pomodoro-break-duration (* 5 60.0)
  "Duration of a short break.")

(defvar pomodoro-break-long-duration (* 15 60)
  "Duration of a long break after a series of short breaks.")

(defvar pomodoro-break-num 4
  "The limit of number of short breaks before a long break.")

;; internal variables

(defvar pomodoro-work-state nil
  "The current status i.e. whether `work or `break.")

(defvar pomodoro-break-count 0
  "Keep track the number of breaks.")

(defvar pomodoro-timer nil
  "The internal timer.")

(defun pomodoro-notify (text)
  "Show TEXT message from pomodoro."
  (pomodoro--log-info text)
  (alert text :title "pomodoro" :style 'pomodoro))

(defun pomodoro-work ()
  "Let's get it started!"
  (interactive)
  (pomodoro-notify "Let's get it started!")
  (setq pomodoro-work-state 'work)
  (setq pomodoro-timer (run-at-time pomodoro-work-duration nil 'pomodoro-timer-handler)))

(defun pomodoro-break (duration)
  "Break time!"
  (interactive)
  (pomodoro-notify (format "Have a break! [%s minutes]" (/ duration 60)))
  (setq pomodoro-work-state 'break)
  (setq pomodoro-timer (run-at-time duration nil 'pomodoro-timer-handler)))

(defun pomodoro-stop ()
  "Done for the day!"
  (interactive)
  (pomodoro-notify "Done!")
  (setq pomodoro-work-state nil)
  (setq pomodoro-break-count 0)
  (setq pomodoro-timer (cancel-timer pomodoro-timer)))

(defun pomodoro-timer-handler ()
  (pcase pomodoro-work-state
    (`work
     (setq pomodoro-break-count (1+ pomodoro-break-count))
     (cond
      ((= pomodoro-break-count pomodoro-break-num)
       (setq pomodoro-break-count 0)
       (pomodoro-break pomodoro-break-long-duration))
      (t
       (pomodoro-break pomodoro-break-duration))))
    (`break
     (pomodoro-work))))

(provide 'pomodoro)

;;; pomodoro.el ends here
