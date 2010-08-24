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

;; Not sure how to handle punctuation here.
;;
;; Syntax <model>: (<model> ...)  ordered sequence
;;                 (and <model> ...) orderless sequence 
;;                 (or <model> ...)  this is exclusive or
;;                 (preferred <model>) optional, but hinted for
;;                 (allowed <model>)  optional, but not hinted for
;;                 (conjoin <conjunction> <model> ...)  conjoin orderless
;;                               sequence (<model> ...) using <conjunction>, 
;;                               where <conjunction> is of type <model>.
;;                 (var <quant> :namespace <space>)  match student variable 
;;                               for <quant> in namespace <space>.
;;                 (eval <lisp>)  execute <lisp> as lisp code 
;;                 (<atom> ...)  if <atom> matches none of above, 
;;                               match with ontology
;;                 <string>      leaf nodes, after resolution, are strings
;;
;; (var ...) and (eval ...) are not handled by functions in this file.
;; Parse of student sentence is (<string> ...)
;; Could also have more complicated structure:
;;     <student>: (<student> ...)
;;                <string>
;; which would allow chunking based on punctuation.  But matching
;; to the model is much more difficult in that case.
;;

;; operations:  Resolve <quant> references, break up strings.
;;              Expand to expression (or <string> ...) for testing
;;                  with flag for preferred/allowed. 
;;              Compare <student> with <model> giving a distance metric.
;;                  Metric is minimum number of words added and deleted to
;;                  match model sentence.
;;              Make <model> subtrees (preferred ...) based on Gricean 
;;                  conversational maxims (minimum needed to distinguish
;;                  quantity).
;;

;; ctl-c ctl-k compiles entire file 
(in-package :cl-user)

(defpackage :match
	  (:use :cl)
	  (:export :*whitespace* :best-model-matches :word-parse 
		   :matches-model-syntax :word-string :*grammar-names*))

(eval-when (:load-toplevel :compile-toplevel)
  (defparameter match:*grammar-names* 
    (mapcar #'string-upcase ;lisp symbol default is upper case.
	    '("preferred" "allowed" "and" "or" "conjoin" "var" "eval")))

  ;; For each symbol in the grammar, if the symbol is not defined somewhere 
  ;; define symbol in :cl-user.  Then import each symbol into :match.  
  ;; This allows user to use grammar independent of :match.
  ;;
  ;; If this strategy doesn't work, an alternative would be to use 
  ;; keywords for the grammar symbols.
  (dolist (symbol-string match:*grammar-names*)
    (multiple-value-bind (symbol internal) (intern symbol-string)
      (when (eql internal :internal) (export symbol))
      (import symbol :match))))

(in-package :match)

;; Now, create an internal list of these symbols from *grammar-names*
(defvar *grammar-symbols* (mapcar #'find-symbol *grammar-names*))

(defparameter *whitespace* '(#\Space #\Tab #\Newline))

(defun matches-model-syntax (form)
  "Top level of form matches model syntax." 
  ;; If this function is true, then form will not be
  ;; interpreted as being in the ontology
  (or (null form)
      (stringp form)
      (and (consp form) 
	   (or (listp (car form)) (stringp (car form)) ;list
	       (member (car form) *grammar-symbols*)))))

(defun word-parse (str &key parse)
  "Break up a string into a list of words, removing whitespace, commas."
  (let ((p (position (cons #\, *whitespace*) str
		     :test #'(lambda (x y) (member y x)))))
    (if p
	(word-parse (subseq str (+ p 1)) :parse 
		    (if (> p 0) (push (subseq str 0 p) parse) parse))
	(reverse (if (> (length str) 0) (push str parse) parse)))))

(defun join-words (x)
  "Join together a list of strings."
  (if (cdr x) (concatenate 'string (car x) " " (join-words (cdr x)))
      (car x)))

(defun word-string (model)
  "Make string phrase out of model."
  ;; Generally, we assume the given order of (and ...) and 
  ;; the first member of (or ....) is the preferred choice.
  (cond 
    ((stringp model) model)
    ((or (stringp (car model)) (listp (car model)))
     ;; mapcar copies list; subsequent operations can be destructive
     (join-words (delete nil (mapcar #'word-string model))))
    ((eql (car model) 'and)
     (when (cdr model) (word-string (cdr model))))
    ((eql (car model) 'or)
     (pop model) ;remove 'or
     ;; Find first non-null element
     (loop while model thereis (word-string (pop model))))
    ((eql (car model) 'conjoin)
     (pop model)
     (let ((conjunction (word-string (car model)))
	   ;; mapcar copies list; subsequent operations can be destructive
	   (items (delete nil (mapcar #'word-string (cdr model)))))
       (cond 
	 ((null conjunction)
	  (warn "conjoin must have conjunction ~A" model)
	  (join-words items))
	 ((cdr items) 
	  ;; doesn't add commas, as it should, when (cdr (butlast items))
	  (join-words (nconc (butlast items) 
			      (list conjunction) (last items))))
	 (t (car items)))))
    ((eql (car model) 'allowed) nil)
    ((eql (car model) 'preferred) (word-string (cdr model)))
    (t (warn "word-string can't do ~A" model))))

(defun word-count (model &key max)
  "find minimum (or maximum) word count in model"
  ;; In general, arguments of the model can be nil.
  (cond 
    ((null model) 0)
    ((stringp model) 1) ;; or count words in string
    ((or (listp (car model)) (stringp (car model)))
     (loop for x in model sum (word-count x :max max)))
    ((eql (car model) 'and)
     (word-count (cdr model) :max max))      ;remove the 'and 
    ((eql (car model) 'or)
     ;; don't use loop here because we have to switch between
     ;; maximize and minimize
     (apply (if max #'max #'min)
	    (mapcar #'(lambda (x) (word-count x :max max)) 
		    (cdr model))))
    ((eql (car model) 'conjoin)
     (let ((args (word-count (cddr model) :max max)))
       (if (> args 1) 
	   (+ args (word-count (second model) :max max)) ;add conjuction 
	   args)))  ;; 0 or 1 args, drop conjunction
    ((member (car model) '(allowed preferred)) 
     (if max (word-count (cdr model) :max max) 0))
    (t (warn "word-count found unexpected form ~A" model) (if max 10000 0))))

(defun sort-by-complexity (models)
  "Sort an alist of models by increasing complexity"
  (let ((mm (mapcar #'(lambda (x) (cons (model-complexity (car x)) x))
		   models)))
    (mapcar #'cdr (sort mm #'< :key #'car))))

(defun model-complexity (model)
  "Estimate number of alternatives, when expanded."
  ;; Here, we just count number of expansions.
  (cond 
    ((null model) nil)
    ((stringp model) 1) ;; or count words in string
    ((or (listp (car model)) (stringp (car model)))
     ;; mapcar copies list; subsequent operations can be destructive
     (apply #'* (delete nil (mapcar #'model-complexity model))))
    ((eql (car model) 'and)
     (let ((rest (delete nil (mapcar #'model-complexity (cdr model)))))
       (* (factorial (length rest))
	  (apply #'* rest))))
    ((eql (car model) 'conjoin)
     (let ((rest (delete nil (mapcar #'model-complexity (cddr model)))))
       (* (factorial (length rest))
	  (apply #'* rest)
	  (if (> (length rest) 1) 
	      (model-complexity (second model)) ;add conjunction 
	      1))))  ;; 0 or 1 args, drop conjunction
    ((eql (car model) 'or) 
     (apply #'+ (delete nil (mapcar #'model-complexity (cdr model)))))
    ((member (car model) '(allowed preferred)) 
     (+ 1 (model-complexity (cdr model))))
    (t (warn "model-complexity found unexpected form ~A" model) 0)))
  
(defun factorial (x)
  (if (> x 1) (* x (factorial (- x 1))) 1))

(defmacro update-bound (best x)
  `(let ((this ,x))
     (when (< this ,best) (setf ,best this))))

(defun match-bound (lstudent model)
  "Gives lower bound for a match based on word count"
  ;; assume student is list of words.
  (max (- lstudent (word-count model :max t))
       (- (word-count model) lstudent)
       0))

(defun match-model (student model &key (best 20000))
  "Recursive match to tree, returns minimum word insertion/addition for match."

  (declare (notinline match-model-and match-model-list)) ;for profiling
  ;; When bound is given, see if there is any hope, based on word count,
  ;; of doing better.
  (when (< best 10000)
      (let ((this (match-bound (length student) model)))
	(unless (< this best) (return-from match-model this))))

  (cond 
    ((null student) (word-count model))
    ((null model) (word-count student))
    ((stringp model)
     (let ((best 10000.0)) ;ignore any global value of best
       ;; profiling shows that just calculating is slightly
       ;; faster than also testing against the global best
       (dolist (item student)
         (update-bound best (normalized-levenshtein-distance item model)))
       ;; best fit plus any extra student words.
       (+ best (- (word-count student) 1))))
     ;; model optional
    ((member (car model) '(preferred allowed))
     (when (cddr model)
       (warn "Model grammar:  ~A can only have one argument" model))
     (update-bound best (word-count student)) ;don't match model
     (update-bound best (match-model student (second model) :best best))
     best)
    ;; Case (<model> ...)
    ((or (stringp (car model)) (listp (car model)))
     (if (cdr model)
	 (match-model-list student model :best best)
	 (match-model student (car model) :best best)))
    ((eql (car model) 'and)
     (pop model)
     (cond 
       ((cdr model) ;two or more arguments of "and"
	(match-model-and student model :best best))
       ;; and of one argument
       (model (match-model student (car model) :best best))
       (t (word-count student)))) ;empty "and"
    ((eql (car model) 'or)
     (pop model)
     (cond 
       ((cdr model) ;two or more arguments of "or"
	(dolist (item model)
	  (update-bound best (match-model student item :best best)))
	best)
       (model (match-model student (car model) :best best))
       (t (word-count student)))) ;empty "or"
    ((eql (car model) 'conjoin)
     (pop model)
     (cond 
       ((cddr model) ;two or more items to conjoin
	(match-model-conjoin student model :best best))
       ;; conjunction of one argument
       ((cdr model) (match-model student (second model) :best best))
       (model (word-count student)) ;empty conjunction
       (t (error "conjoin must always have a conjunction"))))
    (t (error "match-model:  Bad tree ~A" model))))

(defun match-model-list (student model &key best)
  (declare (notinline match-model)) ;for profiling
  ;; for n student words and m elements of the model list,
  ;; m n (n+1)/2 matches must be evaluated.  The following
  ;; is based on the Levenstein minimum edit distance algorithm.
  (let* ((width (1+ (length student)))
	 (height (1+ (length model)))
	 (d (make-array (list height width))))
    (dotimes (y width)
      (setf (aref d 0 y) y)) ;student is one word per slot

    ;; When the we can't to better than best-minus-rest for an
    ;; iteration of the z loop, then (aref d (1+ x) y) becomes 
    ;; equal to best-minus-rest, then any
    ;; matchings using that particular student word grouping will
    ;; be above the bound "best."

    (dotimes (x (length model))
      (dotimes (y width)
	(let ((mini (+ (word-count (nth x model)) (aref d x y)))
	      (best-minus-rest (- best 
				  (match-bound (- (length student) y) 
					       (cdr (nthcdr x model))))))
	  (dotimes (z y)
	    (update-bound 
	     mini
	     (+ (aref d x z)
		(match-model (subseq student z y) (nth x model)
			     :best (- (min best-minus-rest mini) 
				      (aref d x z))))))
	  (setf (aref d (1+ x) y) mini))))
    (aref d (length model) (length student))))
  

;; The problem here is a generalization of the "Assignment 
;; problem"  The generalization being that several consecutive
;; student words may be assigned to one element of the model list.
;; It is unclear whether this generalization has a polynomial-time
;; solution.

;; It is not clear that it is worth further optimizing 
;; this, since this search does not include the search over all
;; systementries.  It may make better sense to find a strategy
;; that is optimized for the search over systementries.

(defun match-model-and (student model &key best)
  (declare (notinline match-model)) ;for profiling
  (let* ((width (1+ (length student)))
	 ;; nil means skip
	 (matches (make-array (list (length model) width width)
			      :initial-element nil))
	 (model-free (loop for i below (length model) collect i)))
    ;; Blindly collecting all possible matches is itself inefficient.
    ;; A more efficient algorithm would first
    ;; calculate points in band min word-count < y-z < max word-count
    ;; and use the results to constrain what points outside that band
    ;; are calulated.
    (dotimes (m (length model))
      ;; diagonal elements are all the same.
      (dotimes (y width) 
	(setf (aref matches m y y) (word-count (nth m model))))
      ;; do one triangle of off-diagonal elements, where q=y-z
      ;; q is the number of student words.
      (do ((q 1 (+ q 1)))
	  ((= q width))
	(let ((best-minus-rest (- best (match-bound 
					(- (length student) q) 
					(remove (nth m model) model)))))
	  (do ((y q (+ y 1)))
	      ((= y width))
	    (let* ((z (- y q))			  
		   (this (match-model (subseq student z y) (nth m model) 
				      :best best-minus-rest)))
	      ;; This gives a 50% improvement.
	      (when (< this best-minus-rest) 
		(setf (aref matches m y z) this)))))))

    ;; Quick, but does not get global minimum.
    (update-bound best (match-model-greedy 
			matches model-free 
			(list (list 0 (length student)))))
    
    ;; Simply iterate through all possibilities.
    ;; For n student words and m elements of the model list,
    ;; there are m! (m+n-1)!/(n! (m-1)!) different possible matches.
    (update-bound best (match-model-slow 
			matches model-free 
			(list (cons 0 (length student)))))
    
    )
  
  ;; Simply iterate through all possibilities using by creating
  ;; a set of sequential lists.  This is even slower!
  #+never (dolist (item model)
	      (update-bound best
			    (match-model
			     student
			     ;; remove is non-destrutive
			     (list item (cons 'and (remove item model)))
			     :best best)))
  best)


;; This is designed to be fast, but is not a global best fit.
;; However, it may possibly be a starting point for a 
;; polynomial time global best fit algorithm.
(defun match-model-greedy (matches model-free student-intervals)
  "Greedy best fit tree search. Not necessarily global best."
  (let ((best-score -10000) best-m best-y best-z best-interval)
    ;; Find best match that includes the most words.
    (dolist (m model-free)
      (dolist (interval student-intervals)
	(let ((lower (first interval)) (upper (second interval)))
	  (do ((y lower (1+ y)))
	      ((= y (1+ upper))) 
	    (do ((z lower (1+ z)))
		;; Loop over lower triangle and diagonals.
		((> z y)) 
	      ;; Ignore any elements that are nil.  Thus we don't have
	      ;; to calculate elements that will never be a best fit.
	      (when (aref matches m y z) 
		(let ((score (- (- y z) ;number of student words
				;; Weight must be larger than 1 to favor
				;; fewer words when more doesn't improve match.
				;; Weight must be less than infinity to favor
				;; longer matches over shorter matches.
				(* 2 (aref matches m y z)))))
		  ;; (format t "  looping m y z=~A score=~A~%" (list m y z) score)
		  (when (> score best-score)
		    (setf best-score score)
		    (setf best-m m)
		    (setf best-interval interval)
		    (setf best-y y)
		    (setf best-z z)))))))))
    ;; (format t "choose m y z=~A score=~a~%" (list best-m best-y best-z) best-score)

    ;; remove best fit interval and add new intervals
    (let ((new-student (remove best-interval student-intervals)))
      (push (list (first best-interval) best-z) new-student)
      (push (list best-y (second best-interval)) new-student)
      
      (+ (if (remove best-m model-free)
	     ;; Find best fit with this match removed.
	     (match-model-greedy matches (remove best-m model-free) new-student)
	     ;; count remaining student words
	     (apply #'+ (mapcar #'(lambda (x) (- (second x) (first x))) 
				new-student)))
	 (aref matches best-m best-y best-z)))))

;; Simply iterate through all possibilities.
;; For n student words and m elements of the model list,
;; there are m! (m+n-1)!/(n! (m-1)!) different possible matches.

;; If this proves to be too slow, may have to find a polynomial-time
;; algorithm.  See:
;; "QuickMatch: A Very Fast Algorithm for the Assignment Problem", 
;;                  James B. Orlin, Yusin Lee
;; Lecture notes "Bipartite Matching & the Hungarian Algorithm
;;     http://www.cse.ust.hk/~golin/COMP572/Notes/Matching.pdf
;; 
(defun match-model-slow (matches model-free student-intervals)
  "Exhaustive (slow) search through all possibilities for matching student to orderless set of model phrases."
  (if model-free
      (let ((best 20000))
	(dolist (interval student-intervals)
	  (let ((lower (car interval)) (upper (cdr interval)))
	    (do ((y lower (1+ y)))
		((= y (1+ upper))) 
	      (do ((z lower (1+ z)))
		  ;; Loop over lower triangle and diagonals.
		  ((> z y)) 
		;; Ignore any elements that are nil.  Thus we don't have
		;; to calculate elements that will never be a best fit.
		(when (aref matches (car model-free) y z) 
		  ;; remove best fit interval and add new intervals
		  (let ((new-student (remove interval student-intervals)))
		    (push (cons lower z) new-student)
		    (push (cons y upper) new-student)
		    (update-bound 
		     best 
		     (+ (aref matches (car model-free) y z) 
			;; remove best fit interval and 
			;; add new intervals
			(match-model-slow matches 
					  (cdr model-free) 
					  new-student)))))))))
	  best)
	;; count remaining student words
      (reduce #'+ (mapcar #'(lambda (x) (- (cdr x) (car x))) 
			 student-intervals))))

(defun match-model-conjoin (student model &key best)
  (declare (notinline match-model)) ;for profiling
  (let ((conjunction (pop model)))
    ;; Right now, this does not handle commas at all.
    (cond 
      ((cddr model) ; more than two
       ;; For now, just use dumb recursion because we don't have
       ;; any long lists, but this is very expensive, computationally.
       (when (> (length model) 3)
	 (warn "using inefficient method for conjoin in match-model for ~A"
	       model))
       (dolist (item model)
	 (update-bound 
	  best 
	  (match-model student `(,item (conjoin ,conjunction 
					,@(remove item model)))
		       :best best))))
      ((cdr model) ;two arguments
       ;; Try the two possible orders
       (update-bound 
	best 
	(match-model student (list (first model) conjunction (second model))
		     :best best))
       (update-bound 
	best 
	(match-model student (list (second model) conjunction (first model))
		     :best best)))
      (t (error "match-model-conjoin should never reach here"))))
  best)

(defparameter *debug-print* nil)  ;; debug print in best-model-matches

(defun best-model-matches (student models &key (cutoff 5) (equiv 1.25) 
			   (epsilon 0.25))
  "Returns alist of best matches to text using match-model."
  ;; cutoff is the maximum allowed score.
  ;; equiv maximum fraction of the best score such that a fit
  ;;    is considered equivalent to the best fit.

  ;; match-model only finds matches that are better than 
  ;; than the given bound, else it may return the bound itself.  
  ;; Thus, in the case where a perfect match has been found, 
  ;; we need to adjust the bound so any other perfect matches 
  ;; may also be found.

  (unless (> cutoff 0)
    (warn "best-model-matches:  cutoff=~A  must be >0" cutoff))
  (unless (and (numberp equiv) (> equiv 1.0))
    (warn "best-model-matches:  equiv=~A  must be larger than 1" equiv))
  (let (this (best (/ cutoff equiv)) quants bound)
    ;; Do easier ones first, to establish better bound.
    ;; We have  have to do each time, since results of any eval or var 
    ;; is needed for sort.
    (dolist (x (sort-by-complexity models))
      (setf bound (max epsilon (* best equiv)))
      (let ((t0 (if *debug-print* (get-internal-run-time) 0)))
	(setf this (match-model student (car x) :best bound))
	(when *debug-print*
	  (format t "     Got ~A for match in ~Fs to~%       ~A~%" 
		  this  (/ (- (get-internal-run-time) t0) 
			   internal-time-units-per-second)
		  (car x))))
      (when (< this bound) (push (cons this (cdr x)) quants))
      (when (< this best) (setf best this)))
    ;; Remove any quantities that are not equivalent with best fit
    ;; and return result. 
    (delete-if #'(lambda (x) (> (car x) (* best equiv))) quants)))


(defun normalized-levenshtein-distance (s1 s2)
  "Normalize levenshtein-distance so complete rewrite is 1.0."
  (/ (float (levenshtein-distance s1 s2))
		    (float(max (length s1) (length s2)))))


;; Levenshtein Distance function.  
;; From http://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Common_Lisp
;; This is considerably faster than the one at 
;;        http://www.cliki.net/Levenshtein 

(defun levenshtein-distance (str1 str2)
  "Calculates the Levenshtein distance between str1 and str2, returns an editing distance (int)."
  (let ((n (length str1))
	(m (length str2)))
    ;; Check trivial cases
    (cond ((= 0 n) (return-from levenshtein-distance m))
	  ((= 0 m) (return-from levenshtein-distance n)))
    (let ((col (make-array (1+ m) :element-type 'integer))
	  (prev-col (make-array (1+ m) :element-type 'integer)))
      (declare (dynamic-extent col prev-col))
      ;; We need to store only two columns---the current one that
      ;; is being built and the previous one
      (dotimes (i (1+ m))
	(setf (svref prev-col i) i))
      ;; Loop across all chars of each string
      (dotimes (i n)
	(setf (svref col 0) (1+ i))
	(dotimes (j m)
	  (setf (svref col (1+ j))
		(min (1+ (svref col j))
		     (1+ (svref prev-col (1+ j)))
		     (+ (svref prev-col j)
			(if (char-equal (schar str1 i) (schar str2 j)) 0 1)))))
	(rotatef col prev-col))
      (svref prev-col m))))
