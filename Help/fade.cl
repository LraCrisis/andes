;;; Copyright 2009 by Kurt Vanlehn and Brett van de Sande
;;;  This file is part of the Andes Intelligent Tutor Stystem.
;;;
;;;  The Andes Intelligent Tutor System is free software: you can redistribute
;;;  it and/or modify it under the terms of the GNU Lesser General Public 
;;;  License as published by the Free Software Foundation, either version 3 
;;;  of the License, or (at your option) any later version.
;;;
;;;  The Andes Solver is distributed in the hope that it will be useful,
;;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;;  GNU Lesser General Public License for more details.
;;;
;;;  You should have received a copy of the GNU Lesser General Public License
;;;  along with the Andes Intelligent Tutor System.  If not, see 
;;;  <http:;;;www.gnu.org/licenses/>.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;
;;;             Implements method for "fading"
;;;

(defvar *fades*) ;list of problem fades.

(defun initialize-fades (problem)
  "Initialize *fades* based on problem"
  ;; match to either a systementry, a bubblegraph node, solver-tool
  ;; invocation or an answer variable.
  (setf *fades* 
	(loop for fade in (problem-fade problem) collect
	      (cons 
	       (when (car fade)
		 ;; uses *sg-entries*
		 (or (find-systementry (car fade))
		     (match-exp->bgnode (car fade) (problem-graph problem))
		     ;; Solve for quantity that is in problem bubblegraph.
		     (and (listp (car fade))
			  (eql (first (car fade)) 'solve-for-var)
			  (match-exp->qnode (second (car fade)) 
					    (problem-graph *cp*))
			  (car fade))
		     ;; 
		     (and (listp (car fade))
			  (eql (first (car fade)) 'answer)
			  (member (second (car fade)) (problem-soughts *cp*)
				  :test #'unify)
			  (car fade))
		     (warn "No systementry, bgnode, solver, or answer match for ~A"
			   (car fade))))
	       (copy-list (cdr fade))))))


;; This should be called after any entries may have been completed.
(defun update-fades (result)
  "update list of fades, removing finished entries and returning a list of replies"
  ;; Go through list and remove any that have been completed.
  (dolist (fade (copy-list *fades*)) ;copy so we can remove elements.
    ;; (format webserver:*stdout* "fade ~A~%" fade)
    (when (and (car fade)
	       (or (and (SystemEntry-p (car fade))
			(SystemEntry-entered (car fade)))
		   (and (bgnode-p (car fade))
			(nsh-principle-completed-p (car fade)))
		   ;; See if this variable was solved for.
		   (and (listp (car fade))
			(eql (first (car fade)) 'solve-for-var)
			(member (car fade) *StudentEntries* 
				:key #'StudentEntry-prop
				:test #'unify))
		   ;; If it is an answer, find any corresponding Student Entry
		   ;; and see if it is correct.
		   (and (listp (car fade))
			(eql (first (car fade)) 'answer)
			(let ((this-answer (find (car fade) *StudentEntries* 
						 :key #'StudentEntry-prop
						 :test #'unify)))
			  (and this-answer (eql (studententry-state
						 this-answer) **correct**))))))
      (setf *fades* (remove fade *fades*))))
  ;; When not on canvas, prompt next step in hint window.
  (when *fades*
    (let ((text (cdr (assoc :text (cdr (car *fades*))))))
      (push `((:action . "show-hint") (:text . ,text))
	    result)))
  result)