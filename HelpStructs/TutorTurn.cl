;; TutorTurn.cl
;; Collin Lynch
;; 04/05/2001
;;; Modifications by Anders Weinstein 2002-2008
;;; Modifications by Brett van de Sande, 2005-2008
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
;; Tutor truns represent the interaction between the help system
;; and the workbench.  Tutor turns are generated by the manager
;; and other help modules including the what's next and what's wrong 
;; help and contain response functions to be called.
;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Changelog
;;
;; 5/17/2002 -- Added an assoc field
;;  The Assoc field is an extra pointer on the Tutor Turn that can 
;;  be linked to anything that we might wish.  In future versions 
;;  of NSH it will be associated with the goal or entry that 
;;  produced the desired hint along and its status (bottom-out, etc.)
;;  This will allow reconstruction from hints as necessary.
;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Control parameters.  
;; The following switches control the runtime use of the system.

(defparameter **play-kcds** nil
  "If t kcd ophints will be played when present.")
(defparameter **play-Minilessons** t
  "If t minilesson ophints will be played when present.")

;;; Both KCDS and minilessons can appear within hint sequences
;;; The parameters below determine the number of times that a
;;; specific kcd or minilesson can be repeated to the student as
;;; part of a hint sequence.  The workbench allows the students to 
;;; access them in other ways after they stop appearing in the 
;;; hints themselves.  
(defparameter **max-minilesson-repeats** 2 
  "The number of times that a minilesson may be repeated to the student.")
(defparameter **max-kcd-repeats** 1
  "The number of times that a kcd can be viewed by a student as part of a hint seq.")

;;; For research purposes it is necessary to set condition flags for the kcds.
;;; Specifically in order to test whether or not the KCDS show any improvement
;;; over minilessons.  Therefore we need to establish two conditions one for
;;; the kcd students and one for minilesson students.  If this flag is set to
;;; t then any hint-seq calls to kcds will cause the corresponding (same name)
;;; minilesson to be opened instead.
(defparameter **Play-KCDS-as-Minilessons** nil 
  "If t then any calls to a kcd will be treated as calls to kcd will be treated as minilessons.")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Turn Structs.
;; The tutor turn struct itself is intended to encapsulate all the responses to 
;; Andes commands in a single reliable form.  The turn includes fields for menus
;; comments and follow up as well as other commands and association flags.   
;; 
;; At runtime the tutor turns are generated and retured by the APi commands.  
;; when returned they will be added into the cmd structs that record the 
;; students actions and will be translated into one or more return strings
;; by the return-turn code before they are placed onto the stream.  
;; 
;; The fields are:
;;  coloring:  One of red, green, delete, nil (noop) (not sure about these) 
;;             Informs the workbench what to do with the associated entry.
;;  type:      One of dialog, minilesson, eqn-entry (solve-tool), 
;;             end-dialog, score-turn or nil (none).
;;  text:      If type is a dialog then this string will be displayed
;;             If type is an eq entry this is the eq to be added.
;;             If d type is minilesson this is the url to be displayed.
;;             If d type is tcard then this is card-id of training lesson.
;;  menu:      A predefined menu id or a menu spec as defined in the doc.
;;  value:     A free-form value argument that can be used to store non-text
;;             information such as the statistical values.  
;;  responder: A single-arg function called with the result of this item.
;;  Assoc:     A spare pointer for linking to goals or entries or any
;;             information that we might need. 
;;  Commands:  One or more strings that are to be sent to the workbench as 
;;             Asynchronous commands before the turn result itself is sent.
;;             In the future it might be possible to accomplish this by altering
;;             The workbench API to pack more commands in but this is probably 
;;             the most flexible way to go about it.  


(defstruct (Turn (:print-function print-Turn))
  result  ;list of items to add to reply
  id      ;object to be modified
  coloring   
  type
  text
  menu
  value
  responder
  Assoc    
  )

(defconstant +color-red+ 'Color-Red)
(defconstant +color-green+ 'Color-Green)
(defconstant +no-op-turn+ 'No-Op-Turn)

(defconstant +dialog-turn+ 'Dialog-Turn)
(defconstant +minil-turn+ 'Minil-Turn)
(defconstant +tcard-turn+ 'TCard-Turn)
(defconstant +kcd-turn+ 'KCD-Turn)
(defconstant +eqn-turn+ 'Eqn-turn)
(defconstant +end-dialog+ 'End-Dialog)
(defconstant +stat-turn+ 'stat-turn)

(defmacro alist-warn (x)
  "Debug macro to check that x is an alist."
  (if nil  ;Turn on/off at compile-time.
      `(let ((y ,x))  
	(unless (and (listp y) (every #'consp y))
	  (warn "turn-assoc is alist, not ~A~%" y)) y)
      x))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu constants
;; These are the menus in use by the system.
;; nil menu is hide.
(defconstant +explain-more+ 'Explain-More "The Explain more/hide menu.")
(defconstant +psm-menu+ 'Psm-Menu)
(defconstant +equation-menu+ 'Equation-menu)
    
(defun print-turn (Turn &optional Stream (Level 0))
  "Print out the turn to the user."
  (pprint-indent :block Level Stream)
  (format Stream "Turn: ~A ~A~%" (Turn-Coloring Turn) (Turn-Type Turn))

  (when (Turn-Text Turn)
    (pprint-indent :block Level Stream)
    (format Stream "      ~A~%" (Turn-Text Turn)))

  (when (Turn-Menu Turn)
    (pprint-indent :block Level Stream)
    (format Stream "      ~A~%" (Turn-Menu Turn)))
  
  (when (Turn-Value Turn)
    (pprint-indent :block Level Stream)
    (format Stream "      ~A~%" (Turn-Value Turn)))
  
  (when (Turn-Responder Turn)
    (pprint-indent :block Level Stream)
    (format Stream " Responder: t~%"))
  
  (when (Turn-Assoc Turn)
    (pprint-indent :block Level Stream)
    (format Stream " Assoc: ~a~%" (Turn-Assoc Turn))))

;;----------------------------------------------------------
;; define specific tutor turn types.

(defun make-green-dialog-turn (text menu &key Responder)
  "Produce a green coloring dialog type tutor turn."
  (make-turn :coloring +color-green+
	     :type +dialog-turn+
	     :text text 
	     :menu menu 
	     :Responder Responder))
		  

(defun make-dialog-turn (text menu &key Responder Assoc)
  "Produce a dialog type tutor turn."
  (make-turn :type +dialog-turn+
	     :text text
	     :menu Menu
	     :responder Responder
	     :Assoc (alist-warn Assoc)))

(defun make-end-dialog-turn (text &key Assoc)
  "Make a turn that ends the dialog."
  (make-turn :type +dialog-turn+
	     :text text
	     :Assoc (alist-warn Assoc)))
	     
			    
(defun make-minil-turn (url &key Responder Assoc)
  "Produce a minilesson type tutor turn."
  (make-turn :type +minil-turn+
	     :text url
	     :responder Responder
	     :Assoc (alist-warn Assoc)))

;; eqn turn holds calculate or solve-for result.
;; eqn turn text may hold EITHER result equation if successful OR error 
;; message if failure.
;; we set turn coloring to red to indicate failure case, green for success.
(defun make-eqn-turn (Eqn &key id)
  "Generate an eqn entry turn."
  (unless id (warn "no id in make-eqn-turn"))
  (make-turn :type +eqn-turn+
             :coloring +color-green+
	     :id id
	     :text Eqn
	     :Responder #'(lambda (x) (declare (ignore x)) nil)))

(defun make-eqn-failure-turn (Msg &key id)
  "Generate an eqn entry turn."
  (unless id (warn "no id in make-eqn-failure-turn"))
  (make-turn :type +eqn-turn+
             :coloring +color-red+
	     :id id
	     :text Msg
	     :Responder #'(lambda (x) (declare (ignore x)) nil)))
	     
;; red/green convenience funcs take optional unsolicited message string:
(defun make-red-turn (&key id)
  (unless id (warn "no id in make-red-turn"))
  (make-turn :coloring +color-red+
	     :id id))

(defun make-green-turn (&key id)
  (unless id (warn "no id in make-green-turn"))
  (make-turn :coloring +color-green+
	     :id id))

(defun make-no-color-turn (&key id)
  "Make turn without changing the color."
  (unless id (warn "no id in make-no-color-turn"))
  (make-turn :id id))

(defun make-noop-turn ()
  (make-turn :Type +no-op-turn+))


;;; ----------------------------------------------------------------------
;;; Make-stat-turn
;;; Score turns are used to return the student's stats.  They have no 
;;; coloring or other values associated and will merely be translated 
;;; into a string of the score values.  
;;;
;;; Stat-turns, at present only make use of the type and value fields of
;;; the tutor-turn.  In the future I will add the possibility of dialog-stat
;;; turns or other combined forms that will be used to conduct dialogs
;;; with the students

(defun make-stat-turn (Stats)
  "Make a statistics turn."
  (make-turn :Type +stat-turn+ :Value Stats))


;;; This is a specialized error turn that gives the student a 
;;; "this problem is bad, move on..." message and is associated
;;; with the optional error.  This facilitates oops locations in
;;; the code.
(defun make-bad-problem-turn (assoc)
  "Make a bad-problem error turn."
  (warn "make-bad-problem-turn: ~A" assoc)
  (make-turn 
   :Coloring +color-red+
   :type +dialog-turn+
   :text "This is an incorrectly formed problem.  Please try a different problem."
   :Assoc (alist-warn assoc)))



;;=============================================================
;; Hint sequences 
;; During next step-help and whats-wrong-help it is often
;; necessary to pass the student a sequence of hints for them
;; to use.  Those sequences may consists of a set of strings
;; interspersed with a set of operator hints.  This code deals
;; with recursively building a sequence of those hints by 
;; at each step generating the necessary hint as well as any
;; followups that may be necessary.
;;
;; The arguments to the system and their response are as follows:
;;   Hints:  A list of hints to be processed
;;   &key
;;    Prefix:  An optional string that will be prefixed to all
;;             String commands.
;;    Assoc:   A value that will be associated with the turn
;;             generated for later use along with the turn type 
;;             in a list.
;;    OpTail:  If no Assoc argument is supplied then any Ophints
;;             will have a custom Assoc generated for them.  If
;;             This arg is supplied then the contents of it will
;;             be appended onto the tail of the assoc.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; String hints
;; String hints or nlg'd goals are simply passed to the
;; student in a dialog turn for their use.  The string itself
;; will be followed by a menu prompting the student for their
;; next choice.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Operator Hints 
;; Operator hints are attached to each operator in the 
;; Knowledge base.  At runtime those hints are translated 
;; into tutor turn sequences for the students.  The hints 
;; are of the form: (<Type> . <Specs>) where: 
;;  <Type> is one of POINT, TEACH, or APPLY.  
;;  <Specs> is a list of hint specifications of the form 
;;   (<class> <string> . <vars>)
;;   where:
;;     <Class> is one of STRING KCD MINILESSON or EVAL or FUNCTION
;;     <String> is a format string complete with ~A's.
;;     <Vars> is alist of operator vars that will be
;;            substituted into the string via a format.
;;
;; When an operator hint is passed into the make-hint-seq
;; code it will be turned into one or more of the appropriate
;; hints.  This may be a dialog hint, kcd hint or minilesson
;; hint.  Each operator hint contains one or more hint specs
;; pone of these will be selected to become the appropriate 
;; hint type and will be passed to the user.
;;
;; If the user also wishes they can pass in a function to be 
;; called this function will be called and in so doing terminate
;; the hint sequence irrespective of what follows the function.
;;
;; For some damn reason functionp is not working the compilation
;; step prevents it from succeeding.  Accordingly there is a new
;; hintspec type called 'function this will then call the element
;; immediately following on on the rest of the elements in the
;; hintspec.  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; continuations
;; As long as there are more hints in the stack for the 
;; student to see they will be offered the +explain-more+
;; menu and given the option (even after kcd's and minilessons)
;; of moving on down the stack.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; end-sequence
;; When the sequence has ended the last turn will offer the student
;; only the ok menu to choose from and then the turn sequence will end.
;;
;; When supplied the prefix argument will be prepended to the 
;; first hint if possible.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Assoc
;; Assoc is presumed to be a value that we want added to the 
;; Assoc field of the next hint.  If an assoc is passed in 
;; at the top level then it will be perpetuated to all 
;; successive hints.  
;;
;; If no assoc is passed in then, if ophints are encountered 
;; then they will set the assoc fields to reflect their types
;; and values.  they will be of the form (op, <type> <Class>)
;; where type is one of {Point, Teach, Apply} and <Class> is
;; one of {String, KCD, MiniLesson, etc.}  


(defun make-hint-seq (Hints &key (Prefix nil) (Assoc nil) (OpTail nil))
  "make the appropriate hint sequence."
  (when Hints
    ;;(pprint (functionp (car hints)))
    (if (null (cdr hints))
	(make-end-hseq (car Hints) Prefix Assoc OpTail)
      (make-next-hseq (car Hints) (cdr Hints) Prefix Assoc OpTail))))


;;; When there are remaining hints in the list to be dealt with
;;; generate the appropriate turn types ending with an 
;;; +explain-more+ option for the students.
(defun make-next-hseq (Hint Rest &optional (Prefix "") (Assoc Nil) (OpTail Nil))
  (cond ((stringp Hint)              (make-string-hseq Hint Rest Prefix Assoc OpTail))
	((not (listp Hint))          (error "Invalid hint form supplied."))
	((OpHint-p Hint)             (make-ophint-hseq Hint rest Prefix Assoc OpTail))
	((eq (car Hint) 'goal)       (make-goalhint-hseq Hint rest Prefix Assoc OpTail))
	((eq (car Hint) 'String)     (make-string-hseq Hint rest Prefix Assoc OpTail))
	((eq (car Hint) 'KCD)        (error "KCD's have been removed."))
	((eq (car Hint) 'Minilesson) (make-minil-hseq Hint Rest Assoc OpTail))
	((eq (car Hint) 'Eval)       (make-eval-hseq Hint Rest))
	((eq (car Hint) 'Function)   (make-function-hseq (cdr Hint) Prefix))
	(t (Error "Unrecognized hint type supplied."))))


;;; When there are no more hints in the list then the system
;;; will generate an end-dialog style hint of the appropriate
;;; type and return it.
(defun make-end-hseq (Hint &optional (Prefix "") (Assoc Nil) (OpTail Nil))
  ;;(if (listp hint) (pprint (car Hint)))
  (cond ((stringp Hint)	             (make-string-end-hseq Hint Prefix Assoc))
	((not (listp Hint)) 	     (error "Invalid hint form supplied."))
	((OpHint-p Hint)             (make-ophint-end-hseq Hint Prefix Assoc OpTail))
	((eq (car Hint) 'goal)       (make-goalhint-end-hseq Hint Prefix Assoc))
	((eq (car Hint) 'String)     (make-string-end-hseq Hint Prefix Assoc))
	((eq (car Hint) 'KCD) 	     (error "KCD's have been removed."))
	((eq (car Hint) 'Minilesson) (make-minil-end-hseq (cadr Hint) Assoc))
	((eq (car Hint) 'Eval)       (make-eval-hseq (cadr Hint)))
	((eq (car Hint) 'function)   (make-function-hseq (cdr Hint) Prefix))
	(t (Error "Unrecognized hint type supplied."))))





;;-------------------------------------------------------------
;;--------------------------------------------------------------
;; OpHints
;; Operator hints as I specified above are of the form
;; (<Type> <HintSpecs>) where <HintSpecs> is a list of hintspecs
;; The make-ophint-hseq and end-hseq functions select the 
;; hintspec that is to be used and pass it to the appropriate
;; subfunctions.  Because the Operator hints contain specialized 
;; assocs, they will  be passed to special hintformatting 
;; funcs described below.  
;;
;; Args:
;;  Hint:  The unformattred hintspec.
;;  Rest:  The remaining hints to be formatted.
;;  Prefix:  A string prefix for the hint.
;;  Assoc:   An optional Assoc that will override the 
;;           generrated assoc if provided.
;;  OpTail:  An operator name that will be part of the 
;;           generated assoc.
;;
;; The hintspec will be formatted and passed to the student with an
;; +explain-more+ responder.  If the student selects explain more
;; then they will be taken to the next hint in the sequence.
;;
;; The hints itself will be formatted and provided to the student 
;; using one or more of the special ophint formatters below.  
;;
;; If the optional Assoc argument is proviuded then it will be used
;; if not then the system will generate an ophint assoc using the 
;; supplied information.  Note that this has been supplanted by the 
;; Operator 
;; 
;; The selection ordering is:
;;   KCD if *play-kcds* is t and there exists a kcd that has not
;;   been played yet.
;; 
;;   Minilesson if *play-minilessons* is t and there exists a 
;;   minil that has not been played yet.
;;
;;   String.

;; Ultimately I want this to dynamically build an assoc if one is 
;; not supplied by the system.  For now it does not work with KCDs.
;; Otherwise the code will use a separate assoc 

(defun make-ophint-hseq (Hint Rest Prefix &optional Assoc OpTail)
  (when (pick-kcd-spec (Ophint-HintSpecs Hint))
    (error "KCD's have been removed"))
  (let (S)
    (cond ((setq S (pick-minil-spec (Ophint-HintSpecs Hint)))
	   (make-minil-ophseq S Rest Assoc (OpHint-Type Hint) OpTail))
	  ((setq S (pick-other-spec (OpHint-HintSpecs Hint)))
	   (if (or (stringp S) (equalp (Hintspec-type S) 'String))

	       (make-string-Ophseq S Rest Prefix Assoc (OpHint-Type Hint)  OpTail)
	     (make-next-hseq S Rest Prefix Assoc OpTail)))
	  (t (make-error-hseq Rest)))))


(defun make-ophint-end-hseq (Hint Prefix &optional Assoc OpTail)
  (when (pick-kcd-spec (Ophint-HintSpecs Hint))
    (error "KCD's have been removed"))
  (let (S)
    (cond ((setq S (pick-minil-spec (Ophint-HintSpecs Hint)))
	   (make-minil-end-ophseq S Assoc (OpHint-Type Hint) OpTail))
	  ((setq S (pick-other-spec (OpHint-HintSpecs Hint)))
	   (if (or (stringp S) (equalp (Hintspec-type S) 'String))
	       (make-string-end-ophseq S Prefix Assoc (OpHint-Type Hint) OpTail)
	     (make-end-hseq S Prefix Assoc)))
	  (t (make-error-end-hseq)))))



;;; The Use-*-spec code determines returns a hint spec
;;; iff the relevant flag *play-kcd* or *play-minilesson*
;;; is set to t, and a hint of the specified type can be
;;; found within the specs.  Lastly in the case of kcds
;;; and minilessons provided they have not been played 
;;; already to the student.

(defun pick-kcd-spec (Specs)
  "Can a kcd spec be used?"
  (let ((lst (member 'kcd Specs :key #'hintspec-type)))
    (when (and **play-kcds** lst)
      (car lst))))

(defun pick-minil-spec (Specs)
  "Can a kcd spec be used?"
  (let ((lst (member 'minilesson Specs :key #'hintspec-type)))
    (when (and **play-minilessons** lst)
      (if (probe-minilesson (car lst))
	  (car lst)
	  (pick-minil-spec (cdr lst))))))

(defun probe-minilesson (minilesson)
  "Determine if the minilesson file is present."
  (probe-file (andes-path (strcat "review\\" (cadr minilesson)))))

(defun pick-other-spec (Specs)
  "Can a Minilesson spec be used?"
  (random-elt 
   (remove-if 
    #'(lambda (S) 
	(or (eq (car S) 'minilesson)
	    (eq (car S) 'kcd)))
    Specs)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; String OpHints.
;; String hints when encountered will be turned into dialog
;; hints or end-dialog hints depending upon whether or not
;; they have any successors.

(defun make-string-Ophseq (Hint Next &optional (Prefix "") Assoc OHType OpTail)
  "Make a string Hseq from the car of the hints."
  (make-dialog-turn 
   (strcat Prefix (if (hintspec-p Hint)
			  (format-hintspec Hint)
			Hint))
   +explain-more+
   :responder #'(lambda (r)
		  (when (eql R +explain-more+)
		    (make-hint-seq Next :Assoc (alist-warn Assoc) :OpTail OpTail)))
   :Assoc (alist-warn (or Assoc `((OpHint ,OHType String . ,OpTail))))))


(defun make-string-end-Ophseq (Hint &optional (Prefix "") Assoc OHType OpTail)
  "Make an end-hseq string hint."
  (make-end-dialog-turn
   (strcat Prefix (if (hintspec-p Hint)
		      (format-hintspec Hint)
		    Hint))
   :Assoc (alist-warn (or Assoc `((OpHint ,OHType String . ,OpTail))))))
     


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Minilesson Hints.
;; Minilesson turns pop up a small set of andes tutorials.  These
;; minilessons will be played to the student and then control will
;; be returned to the tutor mode of the system.  If there are more
;; elements remaining in the hint sequences then the student will 
;; see a dialog turn asking them if they wish to continue or not.
;; otherwize the system will return no turn and control will return
;; to the user.
;;
;; As with the kcd the minilesson passed in is assumed to be a 
;; minilesson hintspec that will be formatted and then used.
(defun make-minil-Ophseq (Minil Next &optional Assoc OHType OpTail)
  "Make a continuation minilesson turn."
  (make-minil-turn 
   (format-hintspec Minil)
   :responder #'(lambda (R) 
		  (when (eq R 'Close-Lesson)
		    (make-hint-seq 
		     (cons "Do you wish for more hints?"
			   Next)
		     :Assoc (alist-warn Assoc)
		     :OpTail OpTail)))
   :Assoc (alist-warn (or Assoc `((OPHint ,OHType MiniLesson ,(format-hintspec Minil) . ,OpTail))))))


(defun make-minil-end-Ophseq (Minil &optional Assoc OHType OpTail)
  "Make the end minilesson turn."
  (make-minil-turn 
   (format-hintspec MiniL)
   :responder #'(lambda (R)
		  (when (eq R 'Close-Lesson)
		    (make-end-dialog-turn
		     (strcat "If you wish for more "
			     "help run NSH again."))))
      :Assoc (alist-warn (or Assoc `((OPHint ,OHType MiniLesson ,(format-hintspec Minil) . , OpTail))))))


;;---------------------------------------------------------------
;; Goal hints are of the form (goal <Str> <Goaltag>)  where 
;; 'Goal' is the header tag that identifies them.  <Str> is 
;; the hint str that will be delivered.  <GoalTag> is a tag 
;; that will be stored in the assoc to identify the goal.
;; goal hints are predominatly produced via NSH for later use.
;;
;; for now if assoc is supplied it overrides.

(defun make-goalhint-hseq (Hint Next &optional (Prefix "") Assoc OpTail)
  "Make a string Hseq from the car of the hints."
  (make-dialog-turn 
   (strcat Prefix (nth 1 Hint))
   +explain-more+
   :responder #'(lambda (r)
		  (when (eql R +explain-more+)
		    (make-hint-seq Next :Assoc (alist-warn Assoc) :OpTail OpTail)))
   :Assoc (alist-warn (or Assoc (list (nth 2 hint))))))

(defun make-goalhint-end-hseq (Hint &optional (Prefix "") Assoc)
  "Make an end-hseq string hint."
  (make-end-dialog-turn
   (strcat Prefix (nth 1 Hint))
   :Assoc (alist-warn (or Assoc (list (nth 2 Hint))))))
	      

;;---------------------------------------------------------------
;; String Hints.
;; String hints when encountered will be turned into dialog
;; hints or end-dialog hints depending upon whether or not
;; they have any successors.

(defun make-string-hseq (Hint Next &optional (Prefix "") Assoc OpTail)
  "Make a string Hseq from the car of the hints."
  (make-dialog-turn 
   (strcat Prefix (if (hintspec-p Hint)
			  (format-hintspec Hint)
			Hint))
   +explain-more+
   :responder #'(lambda (r)
		  (when (eql R +explain-more+)
		    (make-hint-seq Next :Assoc (alist-warn Assoc) :OpTail OpTail)))
   :Assoc (alist-warn Assoc)))


(defun make-string-end-hseq (Hint &optional (Prefix "") Assoc)
  "Make an end-hseq string hint."
  (make-end-dialog-turn
   (strcat Prefix (if (hintspec-p Hint)
		      (format-hintspec Hint)
		    Hint))
   :Assoc (alist-warn Assoc)))
     

;;----------------------------------------------------------------
;; Minilesson Hints.
;; Minilesson turns pop up a small set of andes tutorials.  These
;; minilessons will be played to the student and then control will
;; be returned to the tutor mode of the system.  If there are more
;; elements remaining in the hint sequences then the student will 
;; see a dialog turn asking them if they wish to continue or not.
;; otherwize the system will return no turn and control will return
;; to the user.
;;
;; As with the kcd the minilesson passed in is assumed to be a 
;; minilesson hintspec that will be formatted and then used.
(defun make-minil-hseq (Minil Next &optional Assoc OpTail)
  "Make a continuation minilesson turn."
  (make-minil-turn 
   (format-hintspec Minil)
   :responder #'(lambda (R) 
		  (when (eq R 'Close-Lesson)
		    (make-hint-seq 
		     (cons "Do you wish for more hints?"
			   Next)
		     :Assoc (alist-warn Assoc)
		     :OpTail OpTail)))
   :Assoc (alist-warn Assoc)))


(defun make-minil-end-hseq (Minil &optional Assoc)
  "Make the end minilesson turn."
  (make-minil-turn 
   (format-hintspec MiniL)
   :responder #'(lambda (R)
		  (when (eq R 'Close-Lesson)
		    (make-end-dialog-turn
		     (strcat "If you wish for more "
			     "help run NSH again.")
		     :Assoc (alist-warn Assoc))))
      :Assoc (alist-warn Assoc)))



;;--------------------------------------------------------------
;; Eval hints.
;; Occasionally it is necessary to embed code within the hints
;; so that the step hints can modify themselves based upon the 
;; problem state or the student's location.  The format for the
;; Hints is (Eval <Contents>)  where <Contents> is a set of lisp
;; code that will be funcalled via a progn for legal reasons.
(defun make-eval-hseq (Hint &optional (Rest nil))
  "Call the hseq function with args and return."
  (make-hint-seq (cons (func-eval (cdr Hint)) Rest)))


;;--------------------------------------------------------------
;; function hints
;; Occasionally it is necessary to call a specific function
;; The function hint types are function expressions that will
;; be evaluated at runtime and should return a tutor turn.  
;; An optional rest argument can be supplied to continue the 
;; sequence of hints.  Note that for printing reasons
(defun make-function-hseq (Hint &optional (Prefix ""))
  "Call the specified function."
  (let ((result (apply (car Hint) (cdr Hint))))
    (when (eq (type-of result) 'turn) ; succeeded w/turn
       ; prepend prefix to existing text in result turn.
       (setf (turn-text result)
             (strcat Prefix (turn-text result))))
    result))  ; return value
       



;;---------------------------------------------------------------
;; Error codes.
;; In the event of an error being encountered in the processing
;; of entries the functions below will print a suitable message 
;; for the student (if desired) and recurse (if possible).

(defun make-error-hseq (Next)
  "In the event of a runtime error send a message to the student."
  (make-string-hseq 
   (strcat "An error has occured in the help sequence.  You "
	   "may still continue but please inform your professor "
	   "or the Andes Development team of the Problem.")
   Next))


(defun make-error-end-hseq ()
  "End the sequence with an error message."
  (make-string-end-hseq
   (strcat "An error has occured in the help sequence.  You "
	   "may still continue but please inform your professor "
	   "or the Andes Development team of the Problem.")))

