;;; pomodoro.el - Pomodoro technique with Emacs

(require 'notify)

(defvar pomodoro-work-duration (* 25 60.0))
(defvar pomodoro-break-duration (* 5 60.0))
(defvar pomodoro-break-long-duration (* 15 60))

;; internal variables

(defvar pomodoro-work-state nil
  "The current status i.e. whether `work or `break.")

(defvar pomodoro-break-count 0
  "Keep track the number of breaks.")

(defvar pomodoro-timer nil
  "The internal timer.")

(defun pomodoro-work ()
  "Let's get it started!"
  (setq pomodoro-work-state 'work)
  (notify "pomodoro" "Let's get it started!")
  (setq pomodoro-timer (run-at-time pomodoro-work-duration nil 'pomodoro-timer-handler)))

(defun pomodoro-break (duration)
  "Break time!"
  (setq pomodoro-work-state 'break)
  (notify "pomodoro" "Have a break!")
  (setq pomodoro-timer (run-at-time duration nil 'pomodoro-timer-handler)))

(defun pomodoro-stop ()
  (notify "pomodoro" "Done!")
  (cancel-timer pomodoro-timer))

(defun pomodoro-timer-handler ()
  (pcase pomodoro-work-state
    (`work
     (setq pomodoro-break-count (1+ pomodoro-break-count))
     (cond
      ((= pomodoro-break-count 4)
       (setq pomodoro-break-count 0)
       (pomodoro-break pomodoro-break-long-duration))
      (t
       (pomodoro-break pomodoro-break-duration))))
    (`break
     (pomodoro-work))))

(provide 'pomodoro)

;;; pomodoro.el ends here
