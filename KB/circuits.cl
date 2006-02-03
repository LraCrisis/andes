;;;;
;;; (voltage R1) when PtA is left of R1 and PtB is right of R1 
;;; means the potential(PtB)-Potential(PtA)
;;; (current R1) means from PtA to PtB

;; BvdS:  This file contains some pretty ugly lisp code!
;;        Here is a Band-aid:
(defvar ?a) (defvar ?b) (defvar ?d) (defvar ?new) (defvar ?res) (defvar ?temp)
(defvar ?x) (defvar ?y) (defvar ?z) (defvar ?len) (defvar a) (defvar ans)
(defvar b) (defvar done) (defvar temp) (defvar np) (defvar loc) (defvar len)
(defvar lr) (defvar fans) (defvar fr) (defvar sm) (defvar w) (defvar x)
(defvar y) (defvar z)

;;; FUNCTIONS
; is ?x is (R_1  2  3) it returns the symbol R_123
; Called by comp-name
(defun convert-to-symbol (x)
  (intern (format nil "~{~a~}" x))) ;BvdS: this was 10 lines of buggy code

    
;If ?res = (R1 R2 R3), this returns the R_123  
;Called by define-resistance-var
(defun comp-name (?res ?what)
  ; if res name is atomic, just return it unchanged
  (when (atom ?res) 
      (return-from comp-name ?res)) 
  ; else go on to construct name for compound
  (setf ?res (flatten ?res))  
  (setf ?len (length ?res))
  (setf ?new (first ?res))
  (cond ((eq ?what 'R)
         (setf ?d (string-left-trim "R" (string ?new)))
         (setf ?d (concatenate 'string "R_" ?d)))
        ((eq ?what 'C)
         (setf ?d (string-left-trim "C" (string ?new)))
         (setf ?d (concatenate 'string "C_" ?d))))

  (multiple-value-bind (ans num)
      (read-from-string ?d) 
    (setf ?new ans))
  (setf ?temp (list ?new))
  (do ((counter 1 (+ counter 1)))
      ((= counter ?len) ?temp)
    (cond ((eq ?what 'R)
           (setf ?a (string-left-trim "R" (string (nth counter ?res)))))
          ((eq ?what 'C)
           (setf ?a (string-left-trim "C" (string (nth counter ?res))))))

    (multiple-value-bind (ans num)
        (read-from-string ?a)
             (setf ?temp (append ?temp (list ans)))))
  (convert-to-symbol ?temp))


;If ?x = R_R123, this returns (R1 R2 R3)
; Called by current-in-branch-contains
(defun explode-resistor (?x)
  (setf ?res (string-left-trim "R_" (string ?x))) ;?res="123"
  (setf ?len (- (length (string ?x)) 3))
  (setf ?temp (list))
  (do ((counter 0 (+ counter 1)))
      ((= counter ?len) ?temp)
    (setf ?a (string (char ?res counter)))  ;pull off each number
    (setf ?b (concatenate 'string "R" ?a))  ; make it "R1"
    (multiple-value-bind (ans num)
        (read-from-string ?b)               ; make it R1
      (setf ?temp (append ?temp (list ans))))))

;Accepts '(a b c) and returns '((a b) (b c))
(defun form-adj-pairs (x)
  (setf temp '())
  (do ((c 0 (+ c 1)))
      ((= c (- (length x) 1)) (reverse temp))
    (setf a (nth c x))
    (setf b (nth (+ c 1) x))
    (setf temp (append (list(list a b)) temp ))))

(defun remove-paths (r p)
  (setf np '())
  (do ((c 0 (+ c 1)))
      ((= c (length p)) (reverse np))
    (cond ((not (eq nil (intersection (nth c p) r :test #'equal)))
           (setf np (append (list (nth c p)) np)))
          (t (setf np np)))))

;Called by same-elements
(defun check-list (x y)
  (cond ((null y) t)
        ((eq x (car y)) (check-list x (cdr y)))
        (t nil)))

;Returns t if all the elements of a list are the same
;Called by find-parallel-resistors
(defun same-elements (x)
  (cond ((null x) nil)
        (t (check-list (car x) (cdr x)))))



;if ?x = BrR123, this returns BrR_123
(defun convert-series-branch-name (?x)
  (setf ?y (string-left-trim "BrR" (string ?x))) ;?y="123"
  (setf ?b (concatenate 'string "BrR_" ?y))  ; make it "BrR_123"
  (multiple-value-bind (ans num)
      (read-from-string ?b)
    (setf ?temp ans)))
  
; if p = (JunA PtB R1 PtC R2 PtD JunE) and res-list = (R1 R2)
; it returns (JunA PtB (R1 R2) PtD JunE)
(defun convert-path (p res-list)
  (cond ((atom res-list) (setf res-list (list res-list))))
  (setf fr (car res-list))
  (setf lr (car (reverse res-list)))
  (append (reverse (cdr (member fr (reverse p)))) (list res-list) (cdr (member lr p))))

;Returns the list of branches coming out of a junction
(defun get-out-br (br-list names path jun)
  (setf temp '())
  (setf len (length br-list))
  (do ((c 0 (+ c 1)))
      ((= c len) temp)
       (setf x (nth c br-list))
       (setf y (position x names))
       (setf z (nth y path))
    (if (equal jun (first z)) 
        (setf temp (cons (nth c br-list) temp))
      temp))
  (reverse temp))

;Returns the list of branches going into of a junction
(defun get-in-br (br-list names path jun)
  (setf temp '())
  (setf len (length br-list))
  (do ((c 0 (+ c 1)))
      ((= c len) temp)
    (setf x (nth c br-list))
       (setf y (position x names))
       (setf z (nth y path))
    (if (equal jun (first (last z))) 
        (setf temp (cons (nth c br-list) temp))
      temp))
  (reverse temp))


;Returns the first capacitor in a path 
;Doesn't work if capacitor is in a nested list    
(defun find-cap (path)
  (setf done nil)
  (do ((c 0 (+ c 1)))
      ((or (eq done t) (= c (length path))) ans)
    (setf ans (nth c path))
    (if (equal #\C (char (string ans) 0)) (setf done t) (setf ans nil))))

;Returns a path with only one capacitor
(defun strip-cap (path)
  (setf x (first path))
  (setf y (last path))
  (setf z (find-cap path))
  (cons x (cons z y)))

;Returns a list of paths with no more than one capacitor per path
(defun modify (paths caps)
  (setf fans '())
  (do ((c 0 (+ c 1)))
      ((= c (length paths)) fans)
    (setf x (nth c paths))
    (if (= 1 (length (intersection x caps))) (setf fans (append (list x) fans))
      (setf fans (append (list (strip-cap x)) fans)))))

;y is a list contain x. This returns a list containing x and the element in front or behind it
(defun shrink (x y)
  (setf len (length y))
  (setf loc (position x y))
  (cond ((= len (+ loc 1)) 
         (setf a (nth (- loc 1) y))
         (list a x))
        (t (setf a (nth (+ loc 1) y))
           (list x a))))

;Returns the list of paths coming out of a junction
(defun get-out-paths (br-list names paths jun)
  (setf temp '())
  (setf len (length br-list))
  (do ((c 0 (+ c 1)))
      ((= c len) temp)
       (setf x (nth c br-list))
       (setf y (position x names))
       (setf z (nth y paths))
    (if (equal jun (first z)) 
        (setf temp (append (list z) temp))
      temp))
  (reverse temp))

;Returns the list of paths going into of a junction
(defun get-in-paths (br-list names paths jun)
  (setf temp '())
  (setf len (length br-list))
  (do ((c 0 (+ c 1)))
      ((= c len) temp)
    (setf x (nth c br-list))
       (setf y (position x names))
       (setf z (nth y paths))
    (if (equal jun (first (last z))) 
        (setf temp (append (list z) temp))
      temp))
  (reverse temp))

           
;their intersection won't work on :test #'equal
(defun our-intersection (x y)
  (intersection (flatten x) (flatten y)))


;;;EQUIVALENT RESISTANCE
(defoperator define-resistance-var (?res)   
  :preconditions (
		  (bind ?r-var (format-sym "~A" (comp-name ?res 'R)))
		  )
  :effects (
	    (variable ?r-var (resistance ?res))
	    (define-var (resistance ?res))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting resistance." ((resistance ?res) def-np)))
	 ))

(def-psmclass equiv-resistance-series (equiv-resistance-series ?res-list) 
  :complexity major
  :english ("Equivalent resistance of series resistors")
  :eqnFormat ("Req = R1 + R2 + ...") )

(defoperator equiv-resistance-series-contains (?sought)
  :preconditions (
		  (any-member ?sought ((resistance ?res-list)))
		  (test (listp ?res-list))
		  )
  :effects(
	   (eqn-contains (equiv-resistance-series ?res-list) ?sought)
	   ))

(
 def-psmclass equiv-resistance-parallel (equiv-resistance-parallel ?res-list) 
 :complexity major
 :english ("Equivalent resistance of parallel resistors")
 :eqnFormat ("1/Req = 1/R1 + 1/R2 + 1/R3 + ...") )

(defoperator equiv-resistance-parallel-contains (?sought)
  :preconditions (
		  (any-member ?sought ((resistance ?res-list)))
		  (test (listp ?res-list))
		  )
  :effects(
	   (eqn-contains (equiv-resistance-parallel ?res-list) ?sought)
	   ))



(defoperator equiv-resistance-series (?res-list)
  :specifications "doc"
  :preconditions (
		  ;; verify sought list equivalent to some set of series resistors
		  ;; For simplicity we just put info about series resistors into givens. 
		  ;; List can include complex equivalents, e.g (series-resistors (R1 (R2 R3 R4) (R5 R6)))
		  ;; but should only contain one level of nesting, a list of sets of atoms

		  (series-resistors ?series-list)
		  ;; make sure the set of atomic resistors in series-list
		  ;; equals to the set of resistors sought in res-list. 
		  (test (null (set-exclusive-or (flatten ?series-list) 
						?res-list)))
		  (map ?res ?series-list
		       (variable ?r-var (resistance ?res))
		       ?r-var ?r-vars)
		  (variable ?tot-res (resistance ?res-list))
		  )
  :effects(
	   (resistance ?tot-res)                
	   (eqn (= ?tot-res (+ . ?r-vars)) (equiv-resistance-series ?res-list))
	   )
  :hint(
	(point (string "Write an equation for the equivalent resistance in terms of the individual resistances that are in series."))
	(point (string "The resistors that are in series are ~a" (?series-list conjoined-names)))
	(teach (string "The equivalent resistance for resistors in series is equal to the sum of the individual resistances."))
	(bottom-out (string "You need to add the individual resistances for ~a, and set it equal to the equivalent resistance ~a" 
			    (?series-list conjoined-names) (?tot-res algebra)))  
	))


(defoperator equiv-resistance-parallel (?res-list)
  :specifications "doc"
  :preconditions(
		 ;; verify sought list equivalent to some list of parallel resistors
		 ;; List can include complex 
		 ;; equivalents, e.g (parallel-resistors (R1 (R2 R3 R4) (R5 R6)))
		 ;; but should only contain one level of nesting, a list of sets of atoms
             
		 (parallel-resistors ?parallel-list) 
		 ;; make sure the set of atomic resistors in parallel-list
		 ;; equals to the set of resistors sought in res-list. 
		 (test (null (set-exclusive-or (flatten ?parallel-list) 
					       ?res-list)))
              
		 ;; pull out terms for each resistance
		 (map ?res ?parallel-list
		      (variable ?r-var (resistance ?res))
		      ?r-var ?r-vars)
 
		 (map ?res ?r-vars
		      (bind ?x (list '/ 1 '?res))
		      ?x ?rec-r-vars)
		 (variable ?tot-res (resistance ?res-list))
		 )
  :effects (
	    (resistance ?tot-res)
	    (eqn (= (/ 1 ?tot-res) (+ .  ?rec-r-vars)) (equiv-resistance-parallel ?res-list))
	    )
  :hint(
	(point (string "Write an equation for the equivalent resistance in terms of the individual resistances that are in parallel."))
	(point (string "The resistors that are in parallel are ~a"  (?parallel-list conjoined-names)))
	(teach (string "The reciprocal of the equivalent resistance for resistors in parallel is equal to the sum of the reciprocals of the individual resistances."))
	(bottom-out (string "Write the equation ~a" ((= (/ 1 ?tot-res) (+ .  ?rec-r-vars)) algebra)))
	))



;;;CURRENTS
(def-psmclass current-thru-what (current-thru-what ?what ?branch ?t) 
  :complexity minor 
  :english ("Current in branch")
  :Expformat ("Relating the current through ~A to the current in the branch containing it" ?what)
  :eqnFormat ("Icomp = Ibranch"))

(defoperator current-pt-or-comp-contains (?sought)
  :preconditions (
		  (any-member ?sought ((current-thru ?what :time ?t)))
		  (branch ?branch ?dontcare1 ?dontcare2 ?path)
		  (test (member ?what ?path :test #'equal) )
		  )
  :effects (
	    (eqn-contains (current-thru-what ?what ?branch ?t) ?sought)
	    ))

(defoperator current-in-branch-same-resistor-contains (?sought)
  :preconditions (
		  (any-member ?sought ((current-in ?branch :time ?t)))
		  (branch ?branch ?dontcare1 ?dontcare2 ?path)
		  (circuit-component ?what ?comp-type)
		  (test (member ?comp-type '(resistor inductor)))
		  (test (member ?what ?path :test #'equal))
		  )
  :effects (
	    (eqn-contains (current-thru-what ?what ?branch ?t) ?sought)
	    ))

(defoperator write-current-thru-what (?what ?branch ?t)
  :specifications "doc"
  :preconditions (
		  (variable ?i-what-var (current-thru ?what :time ?t))
		  (variable ?i-br-var (current-in ?branch :time ?t))
		  )
  :effects (
	    (eqn (= ?i-what-var ?i-br-var) (current-thru-what ?what ?branch ?t))
	    )
  :hint(
	(point (string "Write an equation relating the current through a circuit component to the current through a branch of the circuit containing the component."))
	(point (string "Consider the current through the circuit component ~a" (?what adj)))
	(teach (string "The current through a circuit component is equal to the current through the branch of the circuit containing the component."))
	(bottom-out (string "The current through the component, ~a is the same as the current through the branch of the circuit, ~a." (?i-what-var algebra) (?i-br-var algebra)))
	))




(defoperator current-in-branch-contains (?sought)
  :preconditions (
		  (any-member ?sought ((current-in ?branch :time ?t)))
		  (setf ?res-list (explode-resistors ?branch))
		  (branch ?branch ?dontcare1 ?dontcare2 ?path)
		  )
  :effects (
	    (resistance ?res-list)
	    (eqn-contains (equiv-resistance-series ?res-list) ?sought)
	    ))

(defoperator define-current-thru-var (?what ?t)
  :preconditions (
		  ;; ?what could be a list naming a compound (equivalent) circuit element.
		  (bind ?i-what-var (format-sym "I_~A$~A" (comp-name ?what 'R) (time-abbrev ?t)))
		  )
  :effects (
	    (variable ?i-what-var (current-thru ?what :time ?t))
	    (define-var  (current-thru ?what :time ?t))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting current." ((current-thru ?what :time ?t) def-np)))
	 ))
		       

;;If we need time the change the bind
(defoperator define-current-in-var (?branch ?t)
  :preconditions (
		  (bind ?i-br-var (format-sym "I_~A$~A" ?branch (time-abbrev ?t)))
		  )
  :effects (
	    (variable ?i-br-var (current-in ?branch :time ?t))
	    (define-var (current-in ?branch :time ?t))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting current." ((current-in ?branch :time ?t) def-np)))
	 ))

(def-psmclass ohms-law (ohms-law ?res ?t) 
  :complexity definition
  :english ("Ohm's Law")
  :eqnFormat ("V = I * R"))

;;May need to uncomment (resistance) as a sought to get currents to work
(defoperator ohms-law-contains-resistor (?sought)
  :preconditions(
		 (any-member ?sought ((current-thru ?res :time ?t)
				      (voltage-across ?res :time ?t)))
		 (time ?t)
		 (circuit-component ?res resistor)
		 ;;Added mary/Kay 7 May
		 ;;(branch ?br-res ?dontcare1 ?dontcare2 ?path)
		 ;;(test (member ?res ?path :test #'equal))     
		 )
  :effects(
	   (eqn-contains (ohms-law ?res ?t) ?sought)
	   ))

(defoperator single-resistance-contains (?sought)
  :preconditions(
		 (any-member ?sought ((resistance ?res)))
		 ;; only apply for resistance of atomic resistor:
		 ;; (Why? -- AW)
		 (test (atom ?res))
		 (time ?t)
		 (circuit-component ?res resistor)
		 ;;(branch ?br-res ?dontcare1 ?dontcare2 ?path)
		 ;;(test (member ?res ?path))
		 )
  :effects(
	   (eqn-contains (ohms-law ?res ?t) ?sought)
	   ))

(defoperator ohms-law (?res ?t)
  :specifications "doc"
  :preconditions(
		 ;; if we want to use branch current var:
		 ;;(branch ?br-res ?dontcare1 ?dontcare2 ?path)
		 ;;(test (member ?res ?path))
		 ;;(variable ?i-var (current-in ?br-res :time ?t))
		 (variable ?r-var (resistance ?res))
		 (variable ?i-var (current-thru ?res :time ?t))
		 (variable ?v-var (voltage-across ?res :time ?t))
		 )
  :effects(
	   (eqn (= ?v-var (* ?r-var ?i-var)) (ohms-law ?res ?t))
	   )
  :hint(
	(point (string "Apply Ohm's Law to the resistor, ~a." ?res))
	(point (string "Write an equation relating the voltage across the resistor ~a to the current through the resistor ~a and the resistance ~a." (?v-var algebra) (?i-var algebra) (?r-var algebra)))
	(teach (string "The voltage across the resistor is equal to product of the current through the resistor and the resistance."))
	(bottom-out (string "The voltage across the resistor ~a is equal to the current through the resistor ~a times the resistance ~a." (?v-var algebra) (?i-var algebra) (?r-var algebra)))
	))


 
(def-psmclass current-equiv (currents-same-equivalent-branches ?res ?br-res ?t) 
  :complexity minor
  :english ("Current in equivalent branches")
  :eqnFormat ("Iequiv = Iorig"))
             
(defoperator currents-same-equivalent-branches-contains (?sought)
  :preconditions(
		 (any-member ?sought ((current-in ?br-res :time ?t)
				      (current-in ?br-res2 :time ?t)))
		 (solve-using-both-methods)
		 (time ?t)
		 (branch ?br-res given ?dontcare1 ?path1)
		 (branch ?br-res2 combined ?dontcare1 ?path2)
		 (setof (circuit-component ?comp1 ?dontcare4) ?comp1 ?all-comps)
		 (bind ?path-comps1 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						   ?path1))
		 (bind ?path-comps2 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						   ?path2))
		 (test (or (equal (car ?path-comps1) ?path-comps2) 
			   (equal (car ?path-comps2) ?path-comps1)))
		 (test (eq (car ?path1) (car ?path2)))
		 (test (eq (car (reverse ?path1)) (car (reverse ?path2))))          
		 )
  :effects(
	   (eqn-contains (currents-same-equivalent-branches ?br-res ?br-res2 ?t) ?sought)
	   ))

(defoperator currents-same-equivalent-branches (?br-res ?br-res2 ?t)
  :preconditions (
		  (variable ?i-var1 (current-in ?br-res :time ?t))
		  (variable ?i-var2 (current-in ?br-res2 :time ?t))
		  )
  :effects (
	    (eqn (= ?i-var1 ?i-var2) (currents-same-equivalent-branches ?br-res ?br-res2 ?t))
	    )
  :hint(
	(point (string "What do you know about the current through a set of series resistors and the current through the equivalent resistor?"))
	(point (string "Consider the branch ~a and the branch ~a." (?br-res adj) (?br-res2 adj)))
	(teach (string "The current through a set of series resistors is equal to the current through the equivalent resistor."))
	(bottom-out (string "Set the current in branch ~a equal to the current in branch ~a." (?br-res adj) (?br-res2 adj)))
	))


(defoperator define-voltage-across-var-resistor (?comp ?t)
  :preconditions 
  ((bind ?v-var (format-sym "deltaV_~A~@[_~A~]" (comp-name ?comp 'R)
			    (time-abbrev ?t))))
  :effects (
	    (variable ?v-var (voltage-across ?comp :time ?t))
	    (define-var (voltage-across ?comp :time ?t))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting voltage." ((voltage-across ?comp :time ?t) def-np)))
	 ))

(def-psmclass loop-rule  (loop-rule ?branch-list ?t)  
  :complexity major 
  :english ("Kirchoff's loop rule")
  :eqnFormat ("V1 + V2 + V3 ... = 0"))

(defoperator loop-rule-contains (?comp ?t)
  :preconditions (
		  (closed-loop ?branch-list ?p1 ?p2 ?path ?reversed)
		  (test (member ?comp ?path :test #'equal)))
  :effects (
	    (eqn-contains (loop-rule ?branch-list ?t) (voltage-across ?comp :time ?t))
	    ))


(defoperator closed-branch-is-loop (?branch)
  :preconditions (
		  (branch  ?branch ?dontcare  closed ?path)
		  )
  :effects (
	    (closed-loop ?branch ?path ?path ?path 0)
	    ))



(defoperator form-two-branch-loop (?br1 ?br2)
  :preconditions 
  (
   (branch ?br1 ?dontcare1 open ?path1)
   (branch ?br2 ?dontcare2 open ?path2)
   ;; test not a self loop
   (setof (circuit-component ?comp1 ?dontcare4) ?comp1 ?all-comps)
   (bind ?path-comps1 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
				     ?path1))
   (bind ?path-comps2 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
				     ?path2))
                       
   (test (null (and (our-intersection ?path-comps1 ?path2)
		    (our-intersection ?path-comps2 ?path1))))
                             
   ;; only try if branch names are in loop-id order
   (test (expr< ?br1 ?br2))
                             
   ;; test paths are connected. Two cases, depending on whether
   ;; path2 or (reverse path2) is needed to make a closed loop
   (test (or (and (equal (car (last ?path1)) (first ?path2))
		  (equal (car (last ?path2)) (first ?path1)))
	     (and (equal (first ?path1) (first ?path2))
		  (equal (car (last ?path1)) (car (last ?path2))))))
   ;; loop-id is sorted branch list
   (bind ?branch-list (list ?br1 ?br2))
                             
   ;; build loop path. Duplicate starting point at end to ensure all
   ;; components have two terminal points in path.
   (bind ?loop-path (if (not (equal (first ?path1) (first ?path2)))
			(append ?path1 (subseq ?path2 1))
		      (append ?path1 (subseq (reverse ?path2) 1))))
   (bind ?reversed (if (not (equal (first ?path1) (first ?path2))) 0 1))
   )
  :effects (
	    (closed-loop ?branch-list ?path-comps1 ?path-comps2 ?loop-path ?reversed)
	    ))

(defoperator form-three-branch-loop (?br1 ?br2)
  :preconditions (
		  (branch ?br1 ?dontcare1 open ?path1)
		  (branch ?br2 ?dontcare2 open ?path2)
		  (branch ?br3 ?dontcare3 open ?path3)
		  ;; only try if branch names are in loop-id order
		  (test (and (expr< ?br1 ?br2) (expr< ?br2 ?br3)))
 
		  ;;(test (and (not (equal ?br1 ?br2))
		  ;;               (not (equal ?br2 ?br3))
		  ;;               (not (equal ?br3 ?br1))))
		  ;; test not a self loop
		  (setof (circuit-component ?comp1 ?dontcare4) ?comp1 ?all-comps)
		  (bind ?path-comps1 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path1))
		  (bind ?path-comps2 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path2))
		  (bind ?path-comps3 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path3))

		  (test (null (and (our-intersection ?path-comps1 ?path2)
				   (our-intersection ?path-comps1 ?path3)
				   (our-intersection ?path-comps2 ?path3)
				   )))
                             
                            
		  ;; test paths are connected. Two cases, depending on whether
		  ;; path2 or (reverse path2) is needed to make a closed loop
		  (test (and (equal (car (last ?path1)) (first ?path2))
			     (equal (car (last ?path2)) (first ?path3))
			     (equal (car (last ?path3)) (first ?path1))))
                                        
		  ;; loop-id is sorted branch list
		  (bind ?branch-list (list ?br1 ?br2 ?br3))
                             
		  ;; build loop path. Duplicate starting point at end to ensure all
		  ;; components have two terminal points in path.
		  (bind ?path-comps4 (append ?path-comps1 ?path-comps2))
		  (bind ?loop-path (append ?path1 (subseq ?path2 1) (subseq ?path3 1)))
                             
		  (bind ?reversed 0)	;did not reverse
		  ;; (bind ?reversed (if (not (equal (first ?path1) (first ?path2))) 0 1))
		  )
  :effects (
	    (closed-loop ?branch-list ?path-comps4 ?path-comps3 ?loop-path ?reversed)
	    ))

(defoperator form-four-branch-loop (?br1 ?br2)
  :preconditions (
		  (branch ?br1 ?dontcare1 open ?path1)
		  (branch ?br2 ?dontcare2 open ?path2)
		  (branch ?br3 ?dontcare3 open ?path3)
		  (branch ?br4 ?dontcare4 open ?path4)
		  ;; only try if branch names are in loop-id order
		  (test (and (expr< ?br1 ?br2) (expr< ?br2 ?br3) (expr< ?br3 ?br4)))

		  (test (and (= (length (intersection ?path1 ?path2)) 1)
			     (= (length (intersection ?path2 ?path3)) 1)
			     (= (length (intersection ?path3 ?path4)) 1)
			     (= (length (intersection ?path1 ?path4)) 1)
			     (= (length (intersection ?path2 ?path4)) 0)
			     (= (length (intersection ?path1 ?path3)) 0)
			     ))



		  ;; test not a self loop
		  (setof (circuit-component ?comp1 ?dontcare5) ?comp1 ?all-comps)
		  (bind ?path-comps1 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path1))
		  (bind ?path-comps2 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path2))
		  (bind ?path-comps3 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path3))
		  (bind ?path-comps4 (remove-if-not #'(lambda(elt) (member elt ?all-comps :test #'equal)) 
						    ?path4))



		  (test (null (and (our-intersection ?path-comps1 ?path2)
				   (our-intersection ?path-comps1 ?path3)
				   (our-intersection ?path-comps1 ?path4)
				   (our-intersection ?path-comps2 ?path3)
				   (our-intersection ?path-comps2 ?path4)
				   (our-intersection ?path-comps3 ?path4)
				   )))

                             
		  ;; test paths are connected. Two cases, depending on whether
		  ;; path2 or (reverse path2) is needed to make a closed loop
		  (test (and (equal (car (last ?path1)) (first ?path2))
			     (equal (car (last ?path2)) (first ?path3))
			     (equal (car (last ?path3)) (first ?path4))
			     (equal (car (last ?path4)) (first ?path1))))
                                       
		  ;; loop-id is sorted branch list
		  (bind ?branch-list (list ?br1 ?br2 ?br3 ?br4))
                             
		  ;; build loop path. Duplicate starting point at end to ensure all
		  ;; components have two terminal points in path.
		  (bind ?path-comps5 (append ?path-comps1 ?path-comps2))
		  (bind ?path-comps6 (append ?path-comps3 ?path-comps4))
		  (bind ?loop-path (append ?path1 (subseq ?path2 1) (subseq ?path3 1) (subseq ?path4 1)))
                             
		  (bind ?reversed 0)	;did not reverse
		  )
  :effects (
	    (closed-loop ?branch-list ?path-comps5 ?path-comps6 ?loop-path ?reversed)
	    ))




(defoperator write-loop-rule-resistors (?branch-list ?t)
  :preconditions (
		  ;;Stop this rule for RC/LRC problems
		  (not (circuit-component ?dontcare capacitor))
		  (not (circuit-component ?dontcare inductor))

		  (in-wm (closed-loop ?branch-list ?p1 ?p2 ?path ?reversed))

		  ;;Make sure ?p2 is a list
		  ;;If ?rev ends up nil then ?p2 was reversed in ?path
		  (bind ?rev (member (second ?p2) (member (first ?p2) ?path :test #'equal) :test #'equal))
		  (bind ?p3 (if (equal ?rev nil) (reverse ?p2) ?p2))
                       
		  ;;get the set of resistors
		  (setof (circuit-component ?comp1 resistor)
			 ?comp1 ?all-res)
		  ;;get the set of batteries
		  (setof (circuit-component ?comp2 battery)
			 ?comp2 ?all-batts)
                      
		  ;;get all the resistor delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-res :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-res1-vars)

		  ;;get all the battery delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-batts :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-batt1-vars)

		  ;;get all the resistor delta variables for ?p2
		  (map ?comp (intersection ?p3 ?all-res :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-res2-vars)

		  ;;get all the battery delta variables for ?p2
		  (map ?comp (intersection ?p3 ?all-batts :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-batt2-vars)

		  ;;determine whether ?p1 + ?p2 or ?p1 - ?p2
		  (bind ?sign (if (equal ?reversed 0) '+ '-))
		  (test (or (not (equal ?v-res1-vars nil))
			    (not (equal ?v-res2-vars nil))))
		  (test (or (not (equal ?v-batt1-vars ?v-batt2-vars))
			    (and (equal ?v-batt1-vars nil) (equal ?v-batt2-vars nil))))
		  )
  :effects (
	    (eqn (= 0 (?sign (- (+ . ?v-batt1-vars) (+ . ?v-res1-vars))
			     (- (+ . ?v-batt2-vars) (+ . ?v-res2-vars))))
		 (loop-rule ?branch-list ?t))
	    )
  :hint(
	(point (string "Find a closed loop in this circuit and apply Kirchhoff's Loop Rule to it."))
	(point (string "To find the closed loop, pick any point in the circuit and find a path through the circuit that puts you back at the same place."))
	(point (string "You can apply Kirchoff's Loop Rule to the loop formed by the branches ~A." (?branch-list conjoined-names)))
	(point (string "Once you have identified the closed loop, write an equation that sets the sum of the voltage across each component around the closed circuit loop to zero."))
	(teach (string "The sum of the voltage around any closed circuit loop must be equal to zero.  If you are going in the same direction as the current the voltage across a resistor is negative, otherwise it is positive. If you go across the battery from the negative to the positive terminals, the voltage across the battery is positive, otherwise it is negative."))
	(teach (string "Pick a consistent direction to go around the closed loop. Then write an equation summing the voltage across the battery and the voltages across the resistors, paying attention to whether you are going with or against the current."))
	(bottom-out (string "Write the equation ~a."
			    ((= 0 (?sign (- (+ . ?v-batt1-vars) (+ . ?v-res1-vars))
					 (- (+ . ?v-batt2-vars) (+ . ?v-res2-vars)))) algebra) ))
	))


(defoperator write-single-loop-rule (?branch-list ?t)
  :preconditions (
		  (in-wm (closed-loop ?branch-list ?p1 ?p1 ?path ?reversed))
                     
		  ;;get the set of resistors
		  (setof (circuit-component ?comp1 resistor)
			 ?comp1 ?all-res)
		  ;;get the set of batteries not switched out at t
		  (setof (active-battery ?comp2 ?t)
			 ?comp2 ?all-batts)
		  ;;get the set of capacitors
		  (setof (circuit-component ?comp3 capacitor)
			 ?comp3 ?all-caps)
		  ;;get the set of all inductors
		  (setof (circuit-component ?comp4 inductor)
			 ?comp4 ?all-inds)

		  ;;get all the resistor delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-res :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-res1-vars)

		  ;;get all the battery delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-batts :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-batt1-vars)
                             
		  ;;get all the capacitor delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-caps :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-cap-vars)

		  ;; get all the inductor delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-inds :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-ind-vars)
		  ;; list batteries and inductors for positive sum
		  (bind ?emf-vars (append ?v-batt1-vars ?v-ind-vars))
		  ;; list capacitors and resistors for negative term
		  (bind ?drop-vars (append ?v-res1-vars ?v-cap-vars))
		  )
  :effects (
	    (eqn (= 0 (- (+ . ?emf-vars) (+ . ?drop-vars)))
		 (loop-rule ?branch-list ?t))
	    )
  :hint(
	;;(point (string "Apply Kirchhoff's Loop Rule to the circuit."))
	(point (string "You can apply Kirchoff's Loop Rule to the loop formed by the branches ~A." (?branch-list conjoined-names)))
	;;(point (string "Write an equation that sets the sum of the voltage across each component around the closed circuit loop to zero."))
	(teach (string "Kirchoff's Loop Rule states that the sum of the voltages around any closed circuit loop must be equal to zero."))
	(teach (string "Pick a consistent direction to go around the closed loop. Then write an equation summing the voltage across the battery and the voltages across the circuit components, paying attention to whether you are going with or against the current."))
	(bottom-out (string "Write the equation ~A"
			    ((= 0 (- (+ . ?emf-vars) (+ . ?drop-vars))) algebra) ))
	))

;; filter to use when fetching batteries for loop rule, because a battery 
;; may be present in problem but switched out as for LC decay.
;; Used only by lr3b.
;; BvdS:  this is certainly the wrong way to do this.  If the 
;;        circuit topology changes with time, then the topology should
;;        be given time dependence
(defoperator get-active-battery (?bat ?t)
  :preconditions (
		  (in-wm (circuit-component ?bat battery))
		  (not (switched-out ?bat ?t))
		  ) :effects ( (active-battery ?bat ?t) ))

(defoperator loop-rule-contains (?sought)
  :preconditions (
		  (closed-loop ?compo-list :time ?tt)
		  (any-member ?sought ((voltage-across ?compo :time ?t)))
		  (test (member ?compo ?compo-list :test #'eql))
		  (test (tinsidep-include-endpoints ?t ?tt))
		  )
  :effects ((eqn-contains (loop-rule ?compo-list ?t) ?sought)))

(defoperator write-loop-rule-two (?c1 ?c2 ?t)
  :preconditions (
		  (variable ?v1 (voltage-across ?c1 :time ?t))
		  (variable ?v2 (voltage-across ?c2 :time ?t))		  
		  )
  :effects ((eqn (= ?v1 ?v2) (loop-rule (?c1 ?c2) ?t)))
  :hint 
  (
   (point (string "The components ~A and ~A are in parallel~@[~A]." 
		  ?c1 ?c2 (?t time))) 
   (teach (string "The voltage across any components in parallel is equal."))
   (bottom-out (string "Write the equation ~A." ((= ?v1 ?v2) algebra)))
   ))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;               Junction rule
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(def-psmclass junction-rule  (junction-rule ?br-list1 ?br-list2 ?t)  
  :complexity major 
  :english ("Kirchoff's junction rule")
  :eqnFormat ("Iin = Iout"))

(defoperator junction-rule-contains (?Sought)
  :preconditions 
  (
   (in-branches ?jun ?br-list1)
   (out-branches ?jun ?br-list2)
   (any-member ?sought ((current-in ?branch :time ?t)))
   (time ?t)
   (test (or (member ?branch ?br-list1) (member ?branch ?br-list2)))
   )
  :effects (
	    (eqn-contains (junction-rule ?br-list1 ?br-list2 ?t) ?sought)
	    ))

(defoperator junction-rule (?br-list1 ?br-list2 ?t )
  :preconditions (
		  ;;find the in branches current variables
		  (map ?br ?br-list1
		       (variable ?v-var (current-in ?br :time ?t))
		       ?v-var ?v-in-br-vars)
                             
		  ;;find the out branches current variables
		  (map ?br ?br-list2
		       (variable ?v-var (current-in ?br :time ?t))
		       ?v-var ?v-out-br-vars)
		  )
  :effects (
	    (eqn (= (+ . ?v-in-br-vars) (+ . ?v-out-br-vars))
		 (junction-rule ?br-list1 ?br-list2 ?t))
	    )
  :hint(
	(point (string "Apply Kirchhoff's Junction Rule to this circuit."))
	(point (string "Pick a junction. A junction occurs when two or more branches meet."))
	(teach (string "The sum of the currents into a junction must equal the sum of the currents out of the junction."))
	(teach (string "Set the sum of the currents into the junction equal to the sum of the currents out of the junction."))
	(bottom-out (string "Write the equation ~A"
			    ((= (+ . ?v-in-br-vars) (+ . ?v-out-br-vars)) algebra) ))
	))


(defoperator find-out-branches ()
  :preconditions (
		  (junction ?jun ?br-list)                        
		  ;; find all branches 
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?name ?all-names)

		  ;; find all the paths
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?path ?all-paths)
		  (bind ?out-br (get-out-br ?br-list ?all-names ?all-paths ?jun)) 
		  (test (not (equal nil ?out-br)))
		  )
  :effects (
	    (out-branches ?jun ?out-br)
	    ))


(defoperator find-in-branches ()
  :preconditions (
		  (junction ?jun ?br-list)                        
		  ;; find all branches 
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?name ?all-names)

		  ;; find all the paths
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?path ?all-paths)
		  (bind ?in-br (get-in-br ?br-list ?all-names ?all-paths ?jun))
		  (test (not (equal nil ?in-br)))
		  )
  :effects(
	   (in-branches ?jun ?in-br)
	   ))


;;;EQUIVALENT CAPACITORS
(defoperator define-capacitance-var (?cap)   
  :preconditions (
		  (bind ?c-var (format-sym "~A" (comp-name ?cap 'C)))
		  )
  :effects (
	    (variable ?c-var (capacitance ?cap))
	    (define-var (capacitance ?cap))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting capacitance." ((capacitance ?cap) def-np)))
	 ))

(def-psmclass equiv-capacitance-series (equiv-capacitance-series ?cap-list) 
  :complexity major
  :english ("Equivalent capacitance of series capacitors")
  :eqnFormat ("1/Ceq = 1/C1 + 1/C2 + ...") )

(defoperator equiv-capacitance-series-contains (?sought)
  :preconditions (
		  (any-member ?sought ((capacitance ?cap-list)))
		  (test (listp ?cap-list))
		  )
  :effects(
	   (eqn-contains (equiv-capacitance-series ?cap-list) ?sought)
	   ))

(def-psmclass equiv-capacitance-parallel (equiv-capacitance-parallel ?cap-list) 
  :complexity major
  :english ("Equivalent capacitance of parallel capacitors")
  :eqnFormat ("Ceq = C1 + C2 + ...") )

(defoperator equiv-capacitance-parallel-contains (?sought)
  :preconditions (
		  (any-member ?sought ((capacitance ?cap-list)))
		  (test (listp ?cap-list))
		  )
  :effects(
	   (eqn-contains (equiv-capacitance-parallel ?cap-list) ?sought)
	   ))


(defoperator equiv-capacitance-series (?cap-list)
  :specifications "doc"
  :preconditions (
		  ;; verify sought list equals some list of series capacitors
		  ;; For simplicity we just put info about series capacitors into givens. 
		  ;; List can include complex equivalents, e.g (series-capacitors (C1 (C2 C3 C4) (C5 C6)))
		  ;; but should only contain one level of nesting, a list of sets of atoms

		  (series-capacitors ?series-list)
		  ;; make sure the ones found equal the sought cap-list
		  (test (null (set-exclusive-or (flatten ?series-list) 
						?cap-list)))
		  (map ?cap ?series-list
		       (variable ?c-var (capacitance ?cap))
		       ?c-var ?c-vars)
		  (map ?cap ?c-vars
		       (bind ?x (list '/ 1 '?cap))
		       ?x ?cap-c-vars)
		  (variable ?tot-cap (capacitance ?cap-list))
		  )
  :effects (
	    ;; (capacitance ?tot-cap)
	    (eqn (= (/ 1 ?tot-cap) (+ .  ?cap-c-vars)) (equiv-capacitance-series ?cap-list))
	    )
  :hint(
	(point (string "You can write an equation for the equivalent capacitance in terms of the individual capacitances that are in series."))
	(point (string "The capacitors that are in series are ~a" (?series-list conjoined-names)))
	(teach (string "The reciprocal of the equivalent capacitance for capacitors in series is equal to the sum of the reciprocals of the individual capacitances."))
	(bottom-out (string "Write the equation ~a"  ((= (/ 1 ?tot-cap) (+ .  ?cap-c-vars)) algebra)))
	))



(defoperator equiv-capacitance-parallel (?cap-list)
  :specifications "doc"
  :preconditions(
		 ;; verify sought list equals some list of parallel capacitors
		 ;; This list may not be able to include complex 
		 ;; equivalents, e.g (parallel-capacitors (C1 (C2 C3 C4) (R5 C6)))
		 ;; but should only contain one level of nesting, a list of sets of atoms
             
		 (parallel-capacitors ?parallel-list) 
		 ;; make sure the ones found equal the sought cap-list
		 (test (null (set-exclusive-or (flatten ?parallel-list) 
					       ?cap-list)))
              
		 ;; pull out terms for each capacitance
		 (map ?cap ?parallel-list
		      (variable ?c-var (capacitance ?cap))
		      ?c-var ?c-vars)
		 (variable ?tot-cap (capacitance ?cap-list))
		 )
  :effects(
	   (capacitance ?tot-cap)                
	   (eqn (= ?tot-cap (+ . ?c-vars)) (equiv-capacitance-parallel ?cap-list))
	   )
  :hint(
	(point (string "You can write an equation for the equivalent capacitance in terms of the individual capacitances that are in parallel."))
	(point (string "The capacitors ~a are in parallel." (?parallel-list conjoined-names)))
	(teach (string "The equivalent capacitance for capacitors in parallel is equal to the sum of the individual capacitances."))
	(bottom-out (string "You need to add the individual capacitances for ~a, and set it equal to the equivalent capacitance ~a" (?parallel-list conjoined-names) (?tot-cap algebra)))  
	))



;;;CHARGES ON CAPACITORS
(defoperator define-constant-charge-on-cap-var (?what)
  :preconditions (
		  (not (changing-voltage))
		  (circuit-component ?what capacitor)
		  (bind ?q-what-var (format-sym "Q_~A" 
						(comp-name ?what 'C)))
		  )
  :effects (
	    (variable ?q-what-var (charge-on ?what))
	    (define-var (charge-on ?what))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting charge." ((charge-on ?what) def-np)))
	 ))

(defoperator define-changing-charge-on-cap-var (?what ?t)
  :preconditions (
		  (in-wm (changing-voltage))
		  (time ?t)
		  (test (not (eq ?t 'inf)))
		  (circuit-component ?what capacitor)
		  (bind ?q-what-var (format-sym "Q_~A_~A" (comp-name ?what 'C) 
						(time-abbrev ?t)))
		  )
  :effects (
	    (variable ?q-what-var (charge-on ?what :time ?t))
	    (define-var (charge-on ?what :time ?t))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting charge." 
			     ((charge-on ?what :time ?t) def-np)))
	 ))


(def-psmclass cap-defn (cap-defn ?cap ?t) 
  :complexity definition
  :english ("Definition of capacitance")
  :eqnFormat ("C = q/V"))

(defoperator capacitor-definition-contains (?sought)
  :preconditions(
		 (any-member ?sought ((charge-on ?cap :time ?t ?t)
				      (voltage-across ?cap :time ?t)))
		 (time ?t)
		 (circuit-component ?cap capacitor)
		 )
  :effects(
	   (eqn-contains (cap-defn ?cap ?t) ?sought)
	   ))

(defoperator capacitor-definition-single-contains (?sought)
  :preconditions(
		 (any-member ?sought ((capacitance ?cap) ))
		 (test (atom ?cap))
		 (time ?t)
		 (circuit-component ?cap capacitor)
		 )
  :effects(
	   (eqn-contains (cap-defn ?cap ?t) ?sought)
	   ))

(defoperator write-cap-defn (?cap ?t)
  :specifications "doc"
  :preconditions(
		 (variable ?c-var (capacitance ?cap))
		 (variable ?q-var (charge-on ?cap :time ?t ?t))
		 (variable ?v-var (voltage-across ?cap :time ?t))
		 )
  :effects(
	   ;; handles zero charge OK
	   (eqn (= (* ?c-var ?v-var) ?q-var) (cap-defn ?cap ?t))
	   )
  :hint(
	(point (string "Write an equation for the capacitance of ~a." (?cap adj)))
	(point (string "The capacitance of the capacitor ~a is defined in terms of its charge and the voltage across it." (?cap adj)))
	(teach (string "The capacitance is defined as the charge on the capacitor divided by the voltage across the capacitor."))
	(bottom-out (string "Write the equation defining the capacitance ~a as charge ~a divided by voltage ~a." (?c-var algebra) (?q-var algebra) (?v-var algebra)))
	))


(defoperator write-loop-rule-capacitors (?branch-list ?t)
  :preconditions (
		  ;;Stop this rule for LC/LRC problems
		  (not (circuit-component ?dontcare inductor))

		  (in-wm (closed-loop ?branch-list ?p1 ?p2 ?path ?reversed))
		  ;;Make sure ?p2 is a list
		  ;;If ?rev ends up nil then ?p2 was reversed in ?path
		  (bind ?rev (member (second ?p2) (member (first ?p2) ?path :test #'equal) :test #'equal))
		  (bind ?p3 (if (equal ?rev nil) (reverse ?p2) ?p2))

		  ;;get the set of capacitors
		  (setof (circuit-component ?comp1 capacitor)
			 ?comp1 ?all-cap)
		  ;;get the set of batteries
		  (setof (circuit-component ?comp2 battery)
			 ?comp2 ?all-batts)
                      
		  ;;get all the capacitor delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-cap :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-cap1-vars)

		  ;;get all the battery delta variables for ?p1
		  (map ?comp (intersection ?p1 ?all-batts :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-batt1-vars)

		  ;;get all the capacitor delta variables for ?p2
		  (map ?comp (intersection ?p3 ?all-cap :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-cap2-vars)

		  ;;get all the battery delta variables for ?p2
		  (map ?comp (intersection ?p3 ?all-batts :test #'equal)
		       (variable ?v-var (voltage-across  ?comp :time ?t))
		       ?v-var ?v-batt2-vars)

		  ;;determine whether ?p1 + ?p2 or ?p1 - ?p2
		  (bind ?sign (if (equal ?reversed 0) '+ '-))
		  (test (or (not (equal ?v-cap1-vars nil))
			    (not (equal ?v-cap2-vars nil))))
		  (test (or (not (equal ?v-batt1-vars ?v-batt2-vars))
			    (and (equal ?v-batt1-vars nil) (equal ?v-batt2-vars nil))))
		  )
  :effects (
	    (eqn (= 0 (?sign (- (+ . ?v-batt1-vars) (+ . ?v-cap1-vars))
			     (- (+ . ?v-batt2-vars) (+ . ?v-cap2-vars))))
		 (loop-rule ?branch-list ?t))
	    )
  :hint(
	(point (string "Find a closed loop in this circuit and apply Kirchhoff's Loop Rule to it.  To find the closed loop, pick any point in the circuit and find a path around the circuit that puts you back at the same place."))
	(point (string "You can apply Kirchoff's Loop Rule to the loop formed by the branches ~A." (?branch-list conjoined-names)))
	;;(point (string "Once you have identified the closed loop, write an equation that sets the sum of the voltage across each component around the closed circuit loop to zero."))
	(teach (string "The sum of the voltages around any closed circuit loop must be zero.  Take the side of the capacitor closest to the positive terminal of the battery to be at high potential. If you reach this side of the capacitor first as you go around the loop, subtract the voltage across the capacitor from the battery voltage, otherwise add it."))
	;;(bottom-out (string "Pick a consistent direction to go around the closed loop. Then write an equation summing the voltage across the battery and the voltages across the capacitors, paying attention to whether you should add or subtract the voltage across each capacitor."))
	(bottom-out (string "The loop rule for ~A can be written as ~A" (?branch-list conjoined-names)
			    ((= 0 (?sign (- (+ . ?v-batt1-vars) (+ . ?v-cap1-vars))
					 (- (+ . ?v-batt2-vars) (+ . ?v-cap2-vars)))) algebra)  ))
	))



(defoperator junction-rule-cap-contains (?Sought)
  :preconditions 
  (
   (in-paths ?dontcare ?path-list1)
   (out-paths ?dontcare ?path-list2)
   (branch ?branch-dontcare ?dontcare1 ?dontcare2 ?path)
   (test (or (member ?path ?path-list1) (member ?path ?path-list2)))
   (any-member ?sought ((charge-on ?cap :time ?t ?t)))
   (circuit-component ?cap capacitor)
   (test (member ?cap ?path))
   (time ?t)
   ;;Stop a=b+c and b+c=a from both coming out
   (test (expr< ?path-list1 ?path-list2))
   )		  
  :effects 
  (
   (eqn-contains (junction-rule-cap ?path-list1 ?path-list2 ?t) ?sought)
   ))

(defoperator junction-rule-cap (?path-list1 ?path-list2 ?t )
  :preconditions 
  (
   ;;find the charge variables for capacitor going into the branch                            
   (setof (in-wm (circuit-component ?cap capacitor))
	  ?cap ?all-caps)
   
   (bind ?p-list1 (modify ?path-list1 ?all-caps))
   
   (bind ?in-caps (intersection ?all-caps (flatten ?p-list1)))
   (test (not (equal nil ?in-caps)))
   (map ?x ?in-caps  
	(variable ?q-var (charge-on ?x :time ?t ?t))
	?q-var ?q-in-path-vars)
   
   ;;find the charge variables for capacitor going into the branch  
   (bind ?p-list2 (modify ?path-list2 ?all-caps))
   
   (bind ?out-caps (intersection ?all-caps (flatten ?p-list2)))
		  (test (not (equal nil ?out-caps)))

		  (map ?x ?out-caps
		       (variable ?q-var (charge-on ?x :time ?t ?t))
		       ?q-var ?q-out-path-vars)
		  )
  :effects (
	    (eqn (= (+ . ?q-in-path-vars) (+ . ?q-out-path-vars))
		 (junction-rule-cap ?path-list1 ?path-list2 ?t))
	    )
  :hint(
	(point (string "What do you know about the charges on capacitors connected to a junction where two or more branches meet?"))
	;;(point (string "Find the capacitors closest to the junction on both sides."))
	(teach (string "The sum of the charges on one side of a junction must equal the sum of the charges on the other side of the junction."))
	(bottom-out (string "Set the sum of the charges on one side of the junction equal to the sum of the charges on the other side of the junction: Write the equation ~A" ((= (+ . ?q-in-path-vars) (+ . ?q-out-path-vars)) algebra)
			    ))
	))


(defoperator find-out-paths ()
  :preconditions (
		  (junction ?jun ?br-list)                        
		  ;; find all branches 
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?name ?all-names)

		  ;; find all the paths
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?path ?all-paths)

		  (bind ?out-path (get-out-paths ?br-list ?all-names ?all-paths ?jun)) 
		  (test (not (equal nil ?out-path)))
		  )
  :effects (
	    (out-paths ?jun ?out-path)
	    ))


(defoperator find-in-paths ()
  :preconditions (
		  (junction ?jun ?br-list)                        
		  ;; find all branches 
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?name ?all-names)

		  ;; find all the paths
		  (setof (in-wm (branch ?name given ?dontcare ?path))
			 ?path ?all-paths)
		  (bind ?in-path (get-in-paths ?br-list ?all-names ?all-paths ?jun))
		  (test (not (equal nil ?in-path)))
		  )
  :effects(
	   (in-paths ?jun ?in-path)
	   ))


(def-psmclass charge-same-caps-in-branch (charge-same-caps-in-branch ?cap ?t) 
  :complexity major
  :english ("Charge on series capacitors")
  :expformat("Using the fact that series capacitors have the same charge.")
  :eqnFormat ("q1 = q2"))

(defoperator charge-same-caps-in-branch-contains (?sought)
  :preconditions(
		 (any-member ?sought ((charge-on ?cap1 :time ?t ?t)))
		 (time ?t)
		 (branch ?br-res given ?dontcare1 ?path)
		 (test (member ?cap1 ?path) :test #'equal)
		 ;;Are there other capacitors in path
		 (setof (in-wm (circuit-component ?cap capacitor))
			?cap ?all-caps)
		 (bind ?path-caps (intersection ?all-caps ?path))
		 (test (> (length ?path-caps) 1))
		 ;;Stops a=b coming out twice for when a & b are both sought
		 (bind ?temp-caps (shrink (second ?sought) ?path-caps))
		 )
  :effects(
	   (eqn-contains (charge-same-caps-in-branch ?temp-caps ?t) ?sought)
	   ))

  
(defoperator charge-same-caps-in-branch (?temp-caps ?t)
  :preconditions (
		  ;; (bind ?temp-caps (shrink (second ?sought) ?path-caps))
		  (map ?cap ?temp-caps
		       (variable ?q-var (charge-on ?cap :time ?t ?t))
		       ?q-var ?q-path-cap-vars)
		  (bind ?adj-pairs (form-adj-pairs ?q-path-cap-vars))
		  (bind ?pair (first ?adj-pairs))
		  (bind ?first (first ?pair))
		  (bind ?second (second ?pair))
		  )
  :effects (
	    (eqn (= ?first ?second) (charge-same-caps-in-branch ?temp-caps ?t))
	    )
  :hint(
	(point (string "Find two capacitors in series.  Two capacitors are in series when they occur in the same branch."))
	(teach (string "When two capacitors are in series their charges are the same."))
	(bottom-out (string "Set the charge ~a equal to the charge ~a." (?first algebra) (?second algebra)))
	))

(def-psmclass cap-energy (cap-energy ?cap ?t) 
  :complexity major 
  :english ("The formula for energy stored in a capacitor")
  :expformat("Applying the formula for energy stored in a capacitor to ~A" (nlg ?cap))
  :eqnFormat ("U = (1/2)*Q*V"))

(defoperator cap-energy-contains (?sought)
  :preconditions (
		  (any-member ?sought ( (charge-on ?cap :time ?t ?t)
					(voltage-across ?cap :time ?t)
					(stored-energy ?cap :time ?t)))
		  (circuit-component ?cap capacitor)
		  (time ?t) ;not always bound
		  (test (time-pointp ?t))
		  ) :effects ( 
		  (eqn-contains (cap-energy ?cap ?t) ?sought) 
		  ))

(defoperator write-cap-energy (?cap ?t)
  :preconditions (
		  (variable ?Q (charge-on ?cap :time ?t ?t))
		  (variable ?V (voltage-across ?cap :time ?t))
		  (variable ?U (stored-energy ?cap :time ?t))
		  )
  :effects (
	    (eqn (= ?U (* 0.5 ?Q ?V)) (cap-energy ?cap ?t))
	    )
  :hint (
	 (teach (string "The electric energy stored in a capacitor can be calculated as one half times the charge on the capacitor times the voltage across the capacitor.  This formula can be combined with the definition of capacitance to calculate the energy from other variables."))
	 (bottom-out (string "Write the equation ~A" ((= ?U (* 0.5 ?Q ?V)) algebra)))
	 ))

(defoperator define-stored-energy-cap-var (?cap ?t)
  :preconditions (
		  (circuit-component ?cap capacitor)
		  (bind ?U-var (format-sym "U_~A~@[_~A~]" (comp-name ?cap 'C) 
					   (time-abbrev ?t)))
		  ) :effects (
		  (variable ?U-var (stored-energy ?cap :time ?t))
		  (define-var (stored-energy ?cap :time ?t))
		  ) :hint (
		  (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting Stored Energy." 
				      ((stored-energy ?cap :time ?t) def-np)))
		  ))

;;; RC CIRCUITS

;; ?quants are ordered, see (def-qexp time-constant ...)
(defoperator define-time-constant (?quants)
  :preconditions 
  ( (bind ?tau-var (format-sym "tau~{_~A~}" (mapcar #'body-name ?quants))) )
  :effects ( (variable ?tau-var (time-constant orderless . ?quants))
	    (define-var (time-constant orderless . ?quants)) )
  :hint 
  ( (bottom-out (string "Define a variable for the time constant for ~A by using the Add Variable command and selecting Time Constant"  (?quants 'conjoined-defnp) ))
    ))

(def-psmclass RC-time-constant (RC-time-constant ?res ?cap) 
  :complexity definition 
  :english ("RC time constant")
  :eqnFormat ("$t = RC"))

(defoperator RC-time-constant-contains (?sought)
  :preconditions (
		  (circuit-component ?cap capacitor)
		  (circuit-component ?res resistor)
		  (any-member ?sought ((time-constant orderless ?res ?cap)
				       (capacitance ?cap)
				       (resistance ?res)))
		  )
  :effects (
	    (eqn-contains (RC-time-constant ?res ?cap) ?sought)
	    ))

(defoperator write-RC-time-constant (?res ?cap)
  :preconditions 
  (
   (variable ?tau (time-constant orderless ?res ?cap))
   (variable ?c-var (capacitance ?cap))
   (variable ?r-var (resistance ?res))
   )
  :effects (
	    (eqn (= ?tau (* ?c-var ?r-var)) (RC-time-constant ?res ?cap))
	    )
  :hint (
	 (point (string "You need to define the RC time constant."))
	 (bottom-out (string "Write the equation ~A" ((= ?tau (* ?c-var ?r-var)) algebra)))
	 ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  circuit with resistor and capacitor in series.
;;;

(def-psmclass discharging-capacitor-at-time (discharging-capacitor-at-time 
					     ?components ?time) 
  :complexity major
  :english ("Charge on capacitor in RC circuit, initially full")
  :eqnFormat ("q = qi*exp(-t/$t)"))

(defoperator discharging-capacitor-at-time-contains (?sought)
  :preconditions
  (
   ;; should generalize to cyclic permutations of loop 
   ;; and time intervals containing ?t1 ?t2
   (closed-loop (?res ?cap) :time (during ?t1 ?t2))
   (circuit-component ?res resistor)
   (circuit-component ?cap capacitor)
   (any-member ?sought ((charge-on ?cap :time ?t1)
			(charge-on ?cap :time ?t2)
			(duration (during ?t1 ?t2))
			(time-constant orderless ?res ?cap)
			))
   ;; make sure we have a time interval:
   (time (during ?t1 ?t2))
   )
  :effects(
	   (eqn-contains (discharging-capacitor-at-time (?res ?cap) (during ?t1 ?t2)) ?sought)
	   ))

(defoperator discharging-capacitor-at-time (?res ?cap ?t1 ?t2)
  :preconditions 
  (
   (variable ?q1-var (charge-on ?cap :time ?t1))
   (variable ?q2-var (charge-on ?cap :time ?t2))
   (variable ?c-var (capacitance ?cap))
   (variable ?t-var (duration (during ?t1 ?t2)))
   (variable ?tau-var (time-constant orderless ?res ?cap))
   )
  :effects 
  ((eqn (= ?q2-var (* ?q1-var (exp (/ (- ?t-var) ?tau-var))))
	(discharging-capacitor-at-time (?res ?cap) (during ?t1 ?t2))))
  :hint
  (
   (point (string "Write the equation for the charge on the capacitor ~a at time ~a." ?cap (?t2 time)))
   (bottom-out (string "Write the equation ~a"
		       ((= ?q2-var (* ?q1-var (exp (/ (- ?t-var) ?tau-var)))) algebra) ))
   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;;  circuit with battery, resistor, and capacitor in series.
;;;

(def-psmclass charging-capacitor-at-time (charging-capacitor-at-time 
					  ?components ?time) 
  :complexity major
  :english ("Charge on capacitor in RC circuit, initially empty")
  :eqnFormat ("q = C*Vb*(1 - exp(-t/$t))"))

(defoperator charging-capacitor-at-time-contains (?sought)
  :preconditions
  (
   ;; in principle, should matching under cyclic permutations
   ;; maybe do this by an extension to unify
   ;; also, could generalize the time to contain ?t1 and ?t2
   (closed-loop (?bat ?res ?cap) :time (during ?t1 ?t2))
   (circuit-component ?bat battery)
   (circuit-component ?res resistor)
   (circuit-component ?cap capacitor)
   (any-member ?sought ((charge-on ?cap :time ?t2)
			(duration (during ?t1 ?t2))
			(time-constant orderless ?res ?cap)
			))
   (time (during ?t1 ?t2))		;sanity test
   (given (charge-on ?cap :time ?t1) 0) ;boundary condition
   )
  :effects(
	   (eqn-contains (charging-capacitor-at-time (?bat ?res ?cap) (during ?t1 ?t2)) ?sought)
	   ))

(defoperator charging-capacitor-at-time (?bat ?res ?cap ?t1 ?t2)
  :preconditions 
  (
   (variable ?q-var (charge-on ?cap :time ?t2))
   (variable ?c-var (capacitance ?cap))
   (variable ?v-var (voltage-across ?bat :time (during ?t1 ?t2)))
   (variable ?t-var (duration (during ?t1 ?t2)))
   (variable ?tau-var (time-constant orderless ?res ?cap))
   )
  :effects 
  ((eqn (= ?q-var (* ?c-var ?v-var (- 1 (exp (/ (- ?t-var) ?tau-var)))))
	(charging-capacitor-at-time (?bat ?res ?cap) (during ?t1 ?t2))))
  :hint
  (
   (point (string "Write the equation for the charge on the capacitor ~a at time ~a." ?cap (?t2 time)))
   (bottom-out (string "Write the equation ~a"
		       ((= ?q-var (* ?c-var ?v-var (- 1 (exp (/ (- ?t-var) ?tau-var))))) algebra) ))
   ))

;;;
;;;  BvdS:  Why is this a separate law????
;;;

(def-psmclass current-in-RC-at-time (current-in-RC-at-time ?components ?time) 
  :complexity major
  :english ("Current in RC circuit")
  :eqnFormat ("I = (Vb/R)*exp(-t/$t))"))

(defoperator current-in-RC-at-time-contains (?sought)
  :preconditions
  (
   ;; in principle, should test for matching under cyclic permutations
   ;; also, could generalize the time to contain ?t1 and ?t2
   (closed-loop (?bat ?res ?cap) :time (during ?t1 ?t2))
   (circuit-component ?bat battery)
   (circuit-component ?cap capacitor)
   (circuit-component ?res resistor)
   (any-member ?sought ((current-thru ?res :time ?t2)
			;; also contains V, R, C, t
			(time-constant orderless ?res ?cap)
			))
   (time (during ?t1 ?t2))		;sanity test
   (given (charge-on ?cap :time ?t1) 0) ;boundary condition
   )
  :effects
  ((eqn-contains (current-in-RC-at-time (?bat ?res ?cap) (during ?t1 ?t2)) ?sought)
   ))


(defoperator write-current-in-RC-at-time (?bat ?res ?cap ?t1 ?t2)
  :preconditions 
  (
   (variable ?i-var (current-thru ?res :time ?t2))
   (variable ?v-var (voltage-across ?bat :time (during ?t1 ?t2)))
   (variable ?r-var (resistance ?res))
   (variable ?t-var (duration (during ?t1 ?t2)))
   (variable ?tau-var (time-constant orderless ?res ?cap))
   )
  :effects 
  ((eqn (= ?i-var (* (/ ?v-var ?r-var) (exp (/ (- ?t-var) ?tau-var))))
	(current-in-RC-at-time (?bat ?res ?cap) (during ?t1 ?t2)))  
   )
  :hint
  (
   (point (string "Write the equation for the current in the RC circuit at time ~a." (?t2 time)))
   (bottom-out (string "Write the equation ~a"
		       ((= ?i-var (* (/ ?v-var ?r-var) (exp (/ (- ?t-var) ?tau-var)))) algebra) ))
   ))

;;;
;;;  BvdS:  This could be rewritten in terms of (fraction-of ....)
;;;

(def-psmclass charge-on-capacitor-percent-max (charge-on-capacitor-percent-max ?cap ?time) 
  :complexity minor 
  :english ("RC charge as percent of maximum")
  :eqnFormat ("q = percent*C*V"))

(defoperator charge-on-capacitor-percent-max-contains (?sought)
  :preconditions(
		 (any-member ?sought ((charge-on ?cap :time ?t2)
				      ;;(max-charge ?cap :time inf)
				      ;; also contains C and V
				      ))
		 (percent-max ?cap ?value ?t2)
		 (circuit-component ?cap capacitor)
		 (given (charge-on ?cap :time ?t1) 0) ;boundary condition
		 )
  :effects(
	   (eqn-contains (charge-on-capacitor-percent-max ?cap ?t1 ?t2) ?sought)
	   ))


(defoperator charge-on-capacitor-percent-max (?cap ?t)
  :preconditions (
		  (variable ?C-var (capacitance ?cap))
					; use constant Vb defined across charging interval.
		  (circuit-component ?bat battery)	 
		  (variable ?V-var (voltage-across ?bat :time (during ?t0 ?t)))
		  (variable ?q-var (charge-on ?cap :time ?t ?t))
		  (percent-max ?cap ?fraction ?t)
		  )
  :effects (
	    (eqn (= ?q-var (* ?fraction ?C-var ?V-var))
		 (charge-on-capacitor-percent-max ?cap ?t0 ?t))  
	    )
  :hint(
	(point (string "Write the equation for the charge on the capacitor ~a ~a in terms of the percentage of the maximum charge." ?cap (?t pp)))
	(point (string "Use the definition of capacitance, remembering that when the charge on the capacitor is at its maximum, the voltage across the capacitor ~a equals the voltage across the battery ~a." ?cap ?bat))
	(teach (string "The maximum charge on a capacitor equals the capacitance times the battery voltage. You can express the charge at ~a as a fraction of this quantity." (?t pp)))
	(bottom-out (string "Write the equation ~A"  
			    ((= ?q-var (* ?fraction ?C-var ?V-var)) algebra) ))
	))

;;;;---------------------------------------------------------------------------
;;;;
;;;;                               Inductance
;;;;
;;;;---------------------------------------------------------------------------

;; define inductance var
(defoperator define-inductance-var (?ind)   
  :preconditions (
		  (circuit-component ?ind inductor)
		  (bind ?L-var (format-sym "~A" (comp-name ?ind 'L)))
		  )
  :effects (
	    (variable ?L-var (inductance ?ind))
	    (define-var (inductance ?ind))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting inductance." 
			     ((inductance ?ind) def-np)))
	 ))

;; define mutual inductance var
(defoperator define-mutual-inductance-var (?inds)   
  :preconditions 
  (
   (test (orderless-p ?inds))
   (bind ?ind1 (second ?inds))
   (bind ?ind2 (third ?inds))
   (bind ?L-var (format-sym "M_~A_~A" (body-name ?ind1) (body-name ?ind2)))
   )
  :effects (
	    (variable ?L-var (mutual-inductance . ?inds))
	    (define-var (mutual-inductance . ?inds))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting mutual inductance." 
			     ((mutual-inductance . ?inds) def-np)))
	 ))

;;;              Magnetic field inside a long solenoid

(def-psmclass solenoid-self-inductance (solenoid-self-inductance ?solenoid)
  :complexity major
  :english ("the self-inductance of a long, uniform solenoid")
  :ExpFormat ("finding the self-inductance of ~A" (nlg ?solenoid))
  :EqnFormat ("L = $m0*N^2*A/l" ))

(defoperator solenoid-self-inductance-contains (?sought)
  :preconditions 
  (
   (inside-solenoid ?inside ?solenoid)  ;given that there is a solenoid
   (vacuum ?inside)  ;air-core solenoid
   (any-member ?sought (
			(length ?solenoid)
			(turns ?solenoid)
			(area ?solenoid)
			(inductance ?solenoid)
			))
   )
  :effects ((eqn-contains (solenoid-self-inductance ?solenoid) ?sought)))

(defoperator write-solenoid-self-inductance (?solenoid)
  :preconditions 
  ( 
   (variable ?length (length ?solenoid))
   (variable ?N (turns ?solenoid))
   (variable ?A (area ?solenoid))
   (variable ?L (inductance ?solenoid))
   )
  :effects ( 
	    (eqn (= (* ?L ?length) (* |mu0| ?N ?N ?A))
		 (solenoid-self-inductance ?solenoid))
	    )
  :hint 
  (
   (point (string "What is the self-inductance of ~A?" ?solenoid))
   (teach (string "Find the formula for the self-inductance of a long, uniformly wound, solenoid."))
   (bottom-out (string "Write the equation ~A"  
		       ((= (* ?L ?length) (* |mu0| (^ ?N 2) ?A)) algebra) ))
   ))

;; define variable for time rate-of-change of current, dI/dt
;; Rate of change may defined over either interval, for average rate of change, or instant,
;; just like acceleration.  Problems using average rate of change over interval will 
;; generally use a constant rate of change. 
;;
;; The derivative is a function of a function, so the form for this quantity
;; embeds another quantity form (sans time) as argument:
;;   (rate-of-change ?quantity-form :time ?time)
;; This rate-of-change form is thus a perfectly generic time derivative notation --
;; any time-varying quantity forms could be used as argument.  We don't have any rules 
;; for dealing generically with derivatives yet, but possibly some could be added in the future.
;; (Of course velocities and accelerations are names for derivatives with their own notation.)
;; For now we only apply this to currents.
;;
;; Unfortunately we have two current quantities -- (current-thru ?comp) and (current-in ?branch)
;; For now we always use current-thru ?comp, since current through the inductor is most germane
;; for these problems.
(defoperator define-dIdt-var (?comp ?time)
  :preconditions (
					; might want to require student to define a current var first on Andes interface
		  (bind ?dIdt-var (format-sym "dI_~A_dt_~A" ?comp (time-abbrev ?time)))
		  )
  :effects (
	    (variable ?dIdt-var (rate-of-change (current-thru ?comp :time ?time)))
	    (define-var         (rate-of-change (current-thru ?comp :time ?time)))
	    )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting Current Change Rate." 
			     ((rate-of-change (current-thru ?comp :time ?time)) var-or-quant) ))
	 ))

;; voltage across an inductor V = -L*dI/dt
(def-psmclass inductor-emf (inductor-emf ?inductor ?time) 
  :complexity major
  :english ("EMF (voltage) across inductor")
  :eqnFormat ("V = -L*dIdt") 
  )

(defoperator inductor-emf-contains (?sought)
  :preconditions (
		  (circuit-component ?ind inductor)
		  (any-member ?sought ( (voltage-across ?ind :time ?time)
					(inductance ?ind)
					(rate-of-change (current-thru ?ind :time ?time)) ))
		  (time ?time)
		  )
  :effects ( (eqn-contains (inductor-emf ?ind ?time) ?sought) ))

(defoperator inductor-emf (?ind ?time)
  :preconditions (
		  (variable ?V (voltage-across ?ind :time ?time))
		  (variable ?L (inductance ?ind))
		  (variable ?dIdt (rate-of-change (current-thru ?ind :time ?time)))
		  )
  :effects (
	    (eqn (= ?V (- (* ?L ?dIdt))) (inductor-emf ?ind ?time))
	    )
  :hint (
	 (point (string "The voltage across the ends of an inductor is related to the inductance and the rate at which the current through it is changing"))
	 (teach (string "The EMF (voltage) produced between the ends of an inductor is proportional to its inductance and the instantaneous time rate of change of the current.  The voltage is conventionally shown as negative for increasing positive current to indicate that the induced EMF opposes the change."))
	 (bottom-out (string "Write the equation ~A" ((= ?V ( - (* ?L ?dIdt))) algebra) ))
	 ))

;; Mutual inductance version of inductor-emf

(def-psmclass mutual-inductor-emf (mutual-inductor-emf ?ind1 ?ind2 ?time) 
  :complexity major
  :english ("induced EMF (voltage) across ~A due to ~A" 
	    (nlg ?ind1) (nlg ?ind2))
  :eqnFormat ("V2 = -M12*dI1dt") 
  )

(defoperator mutual-inductor-emf-contains (?sought)
  :preconditions 
  (
   (mutual-inductor . ?inds)
   (any-member ?sought ((mutual-inductance . ?inds)))
   (bind ?ind2 (second ?inds))
   (bind ?ind1 (third ?inds))
   (time ?time)
   )
  :effects ( (eqn-contains (mutual-inductor-emf ?ind1 ?ind2 ?time) ?sought) ))

(defoperator mutual-inductor-emf-contains2 (?sought)
  :preconditions 
  (
   (mutual-inductor . ?inds)
   (bind ?ind1 (second ?inds))
   (bind ?ind2 (third ?inds))
   (any-member ?sought ((mutual-inductance orderless ?ind1 ?ind2) 
			(voltage-across ?ind1 :time ?time)
			(rate-of-change (current-thru ?ind2 :time ?time)) ))
   (time ?time)
   )
  :effects ( (eqn-contains (mutual-inductor-emf ?ind1 ?ind2 ?time) ?sought) ))

(defoperator write-mutual-inductor-emf (?ind1 ?ind2 ?time)
  :preconditions 
  (
   (variable ?V (voltage-across ?ind1 :time ?time))
   (variable ?M (mutual-inductance orderless ?ind1 ?ind2))
   (variable ?dIdt (rate-of-change (current-thru ?ind2 :time ?time)))
		  )
  :effects (
	    (eqn (= ?V (- (* ?M ?dIdt))) 
		 (mutual-inductor-emf ?ind1 ?ind2 ?time))
	    )
  :hint 
  (
   (point (string "The voltage across ~A is related to the change in the current through ~A" ?ind1 ?ind2))
   (teach (string "The EMF (voltage) generated in a coil due to changing current in a second coil is given by the mutual inductance of the two coils times the instantaneous rate of current change in the second coil.  The voltage is conventionally shown as negative for increasing positive current to indicate that the induced EMF opposes the change."))
   (bottom-out (string "Write the equation ~A" ((= ?V (- (* ?M ?dIdt))) algebra) ))
   ))

;; need rule that average rate of change dIdt12 = (I2-I1)/t12

(def-psmclass avg-rate-current-change (avg-rate-current-change ?ind ?time)
  :complexity major 
  :english ("definition of average rate of current change")
  :eqnFormat ("dIdt_avg = (I2 - I1)/t12") 
  )

(defoperator avg-rate-current-change-contains (?sought)
  :preconditions 
  (
   (any-member ?sought ( (rate-of-change 
			  (current-thru ?ind :time (during ?t1 ?t2)))
			 (current-thru ?ind :time ?t2)
			 (current-thru ?ind :time ?t1) 
			 (duration (during ?t1 ?t2))))
   ;; ?ind is not bound by ?sought = (duration ...)
   (circuit-component ?ind ?whatever-type)
   (time (during ?t1 ?t2))
   )
  :effects 
  (
   (eqn-contains (avg-rate-current-change ?ind (during ?t1 ?t2)) 
		 ?sought)
   ))

(defoperator avg-rate-current-change (?ind ?t1 ?t2)
  :preconditions 
  (
   (variable ?dIdt (rate-of-change (current-thru ?ind :time (during ?t1 ?t2))))
   (variable ?I2 (current-thru ?ind :time ?t2))
   (variable ?I1 (current-thru ?ind :time ?t1))
   (variable ?t12 (duration (during ?t1 ?t2)))
   )
  :effects (
	    (eqn (= ?dIdt (/ (- ?I2 ?I1) ?t12)) 
		 (avg-rate-current-change ?ind (during ?t1 ?t2)))
	    )
  :hint (
	 (teach (string "The average rate of change of current over a time interval is simply the difference between the final value of the current and the initial value divided by the time. If the rate of change is constant, then the average rate of change will equal the instantaneous rate of change at any point during the time period"))
	 (bottom-out (string "Write the equation ~a" ((= ?dIdt (/ (- ?I2 ?I1) ?t12)) algebra) ))
	 ))

;; Perhaps also that instantaneous = average if it is given as constant,
;; for any point in the interval 
;; Also possibly need something dIbranch/dt = dIcomp/dt where Ibranch = Icomp

					; energy stored in an inductor

(def-psmclass inductor-energy (inductor-energy ?ind ?t) 
  :complexity major 
  :english ("The formula for energy stored in a inductor")
  :expformat("Applying the formula for energy stored in a inductor to ~A" (nlg ?ind))
  :eqnFormat ("U = 0.5*L*I^2"))

(defoperator inductor-energy-contains (?sought)
  :preconditions (
		  (any-member ?sought ( (inductance ?inductor)
					(current-thru ?inductor :time ?t)
					(stored-energy ?inductor :time ?t)))
		  (time ?t)
		  (test (time-pointp ?t))
		  ) :effects ( 
		  (eqn-contains (inductor-energy ?inductor ?t) ?sought) 
		  ))

(defoperator write-inductor-energy (?inductor ?t)
  :preconditions (
		  (variable ?U (stored-energy ?inductor :time ?t))
		  (variable ?L (inductance ?inductor))
		  (variable ?I (current-thru ?inductor :time ?t))
		  )
  :effects (
	    (eqn (= ?U (* 0.5 ?L (^ ?I 2))) (inductor-energy ?inductor ?t))
	    )
  :hint (
	 (teach (string "The electric energy stored in the magnetic field of an a inductor can be calculated as one half times the inductance times the square of the current. ")) 
	 (bottom-out (string "Write the equation ~A" ((= ?U (* 0.5 ?L (^ ?I 2)) algebra)) ))
	 ))

(defoperator define-stored-energy-inductor-var (?inductor ?t)
  :preconditions (
		  (circuit-component ?inductor inductor)
		  (bind ?U-var (format-sym "U_~A~@[_~A~]" 
					   (comp-name ?inductor 'L) 
					   (time-abbrev ?t)))
		  ) :effects (
		  (variable ?U-var (stored-energy ?inductor :time ?t))
		  (define-var (stored-energy ?inductor :time ?t))
		  ) :hint (
		  (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting Stored Energy." 
				      ((stored-energy ?inductor :time ?t) def-np)))
		  ))

;;
;; LR circuits
;;

;;; Some formula use tau for the LR-time constant L/R. 

(def-psmclass LR-time-constant (LR-time-constant ?ind ?res) 
  :complexity definition 
  :english ("LR time constant")
  :eqnFormat ("$t = L/R"))


(defoperator LR-time-constant-contains (?sought ?ind ?res)
  :preconditions (
		  (circuit-component ?ind inductor)
		  (circuit-component ?res resistor)
		  (any-member ?sought ((time-constant orderless ?ind ?res)
				       (inductance ?ind)
				       (resistance ?res)))
		  )
  :effects (
	    (eqn-contains (LR-time-constant ?ind ?res) ?sought)
	    ))


(defoperator write-LR-time-constant (?ind ?res)
  :preconditions (
		  (variable ?tau     (time-constant orderless ?ind ?res))
		  (variable ?L-var   (inductance ?ind))
		  (variable ?r-var   (resistance ?res))
		  )
  :effects (
	    (eqn (= ?tau (/ ?L-var ?R-var)) (LR-time-constant ?ind ?res))
	    )
  :hint (
	 (point (string "The inductive time constant $t of an LR circuit is a function of the inductance and the resistance in the circuit."))
	 (teach (string "The inductive time constant of an LR circuit is equal to the inductance divided by the resistance."))
	 (bottom-out (string "Write the equation ~A" ((= ?tau (/ ?L-var ?R-var)) algebra)))
	 ))


(def-psmclass LR-current-growth (LR-current-growth ?ind ?res ?time) 
  :complexity major
  :english ("Current growth in LR circuit")
  :eqnFormat ("I = Imax*(1 - exp(-t/$t)"))

(defoperator LR-current-growth-contains (?sought)
  :preconditions(
					; Following in the givens tells us that circuit and switch
					; are configured so current grows during this interval.
		 (LR-current-growth ?branch (during ?t1 ?tf))
		 (circuit-component ?ind inductor)
		 (circuit-component ?res resistor)
		 (any-member ?sought ((current-in ?branch :time ?t2)
				      (duration (during ?t1 ?t2))
				      (time-constant orderless ?ind ?res)
				      ))
					; this applies to any t2 between t1 and tf
		 (time ?t2)	       ; have to bind if sought is tau
		 (test (time-pointp ?t2))
		 (test (< ?t2 ?tf))
		 )
  :effects(
	   (eqn-contains (LR-current-growth ?ind ?res (during ?t1 ?t2)) ?sought)
	   ))

(defoperator LR-current-growth (?ind ?res ?t1 ?t2)
  :preconditions (
		  (LR-current-growth ?branch (during ?t1 ?tf))
		  (circuit-component ?bat battery)
		  (variable ?i-var (current-in ?branch :time ?t2))
		  (variable ?Imax-var (current-in ?branch :time ?tf))
		  (variable ?t-var (duration (during ?t1 ?t2)))
		  (variable ?tau-var (time-constant orderless ?ind ?res))
		  )
  :effects (
	    (eqn (= ?i-var (* ?Imax-var (- 1 (exp (/ (- ?t-var) ?tau-var)))))
		 (LR-current-growth ?ind ?res (during ?t1 ?t2)))  
	    )
  :hint(
	(point (string "After the battery is switched in, the current in an LR circuit rises towards its maximum value as an exponential function of time"))
	(teach (string "The rising current in an LR circuit at a time equals the maximum current multiplied by a factor of 1 less a decreasing exponential term. The exponential term is given by e raised to a negative exponent (so this term goes to zero over time) of the time over the inductive time constant, tau. In ANDES you express e raised to the x power by the function exp(x)."))
	(bottom-out (string "Write the equation ~a"
			    ((= ?i-var (* ?Imax-var (- 1 (exp (/ (- ?t-var) ?tau-var))))) algebra) ))
	))

					; Formula Imax = Vb/R is true for both LR growth and decay, but we treat as two psms because we
					; show different variables in the two cases, "If" for growth vs. "I0" for decay.
					; Whether it is best to treat as two psms or one w/two ways of writing the equation depends 
					; mainly on how we want our review page to look.

(def-psmclass LR-growth-Imax (LR-growth-Imax ?time)
  :complexity major 
  :english ("LR growth final current")
  :eqnFormat ("Imax = Vb/R"))

(defoperator LR-growth-Imax-contains (?sought)
  :preconditions (
					; have to be told we have LR-current growth over interval
		  (LR-current-growth ?branch (during ?ti ?tf))
		  (any-member ?sought ( (current-in ?branch :time ?tf)
					(voltage-across ?bat) (during ?ti ?tf))
			      (resistance ?res) )
		  )
  :effects (  (eqn-contains (LR-growth-Imax (during ?ti ?tf)) ?sought) ))

(defoperator LR-growth-Imax (?ti ?tf)
  :preconditions (
		  (LR-current-growth ?branch (during ?ti ?tf))
		  (circuit-component ?res resistor)
		  (circuit-component ?bat battery)
		  (variable ?Imax-var (current-in ?branch :time ?tf))
		  (variable ?v-var (voltage-across ?bat :time (during ?ti ?tf)))
		  (variable ?r-var (resistance ?res))
		  )
  :effects ( (eqn (= ?Imax-var (/ ?v-var ?r-var)) (LR-growth-Imax (during ?ti ?tf))) )
  :hint (
	 (point (string "What must the maximum value of the current be?"))
	 (point (string "At its maximum value, the current in an LR circuit is nearly constant, so there is no EMF due to the inductor. Since the only source of EMF at this time is the battery, Ohm's Law V = I*R determines the current through the resistor to be the battery voltage divided by resistance."))
	 (bottom-out (string "Write the equation ~a" ((= ?Imax-var (/ ?v-var ?r-var)) algebra)))
	 ))

					; LR circuit decay:

(def-psmclass LR-current-decay (LR-current-decay ?ind ?res ?time) 
  :complexity major
  :english ("Current decay in LR circuit")
  :eqnFormat ("I = I0*exp(-t/$t)"))

(defoperator LR-current-decay-contains (?sought)
  :preconditions
  (
   ;; Following in the givens tells us that circuit and switch
   ;; are configured so current decays during this interval.
   (LR-current-decay ?branch (during ?t1 ?tf))
   (circuit-component ?res resistor)
   (circuit-component ?ind inductor)
   (any-member ?sought ((current-in ?branch :time ?t2)
			(duration (during ?t1 ?t2))
			(time-constant orderless ?ind ?res)
			;; also contains I0
			))
   ;; this applies to any t2 between t1 and tf
   (test (time-pointp ?t2))
   (test (<= ?t2 ?tf))
   )
  :effects(
	   (eqn-contains (LR-current-decay ?ind ?res (during ?t1 ?t2)) ?sought)
	   ))

(defoperator LR-current-decay (?ind ?res ?t1 ?t2)
  :preconditions 
  (
   (LR-current-decay ?branch (during ?t1 ?tf))
   (circuit-component ?bat battery)
   (variable ?i-var (current-in ?branch :time ?t2))
   (variable ?I0-var (current-in ?branch :time ?t1))
   (variable ?t-var (duration (during ?t1 ?t2)))
   (variable ?tau-var (time-constant orderless ?ind ?res))
   )
  :effects (
	    (eqn (= ?i-var (* ?I0-var (exp (/ (- ?t-var) ?tau-var))))
		 (LR-current-decay ?ind ?res (during ?t1 ?t2)))  
	    )
  :hint(
	(point (string "When the battery is switched out, the initial current in an LR circuit decays towards zero as an exponential function of time"))
	(teach (string "The decaying current in an LR circuit at a time equals the initial current multipled by a factor of a decreasing exponential term. The exponential term is given by e raised to a negative exponent (so this term goes to zero over time) of the time over the inductive time constant, tau. In ANDES you express e raised to the x power by the function exp(x)."))
	(bottom-out (string "Write the equation ~a"
			    ((= ?i-var (* ?I0-var (exp (/ (- ?t-var) ?tau-var)))) algebra) ))
	))

(def-psmclass LR-decay-Imax (LR-growth-Imax ?time)
  :complexity major 
  :english ("LR decay initial current")
  :eqnFormat ("I0 = Vb/R"))

(defoperator LR-decay-Imax-contains (?sought)
  :preconditions (
					; have to be told we have LR-current decay over interval
		  (LR-current-decay ?branch (during ?ti ?tf))
		  (any-member ?sought ( (current-in ?branch :time ?ti)
					(voltage-across ?bat) (during ?ti ?tf))
			      (resistance ?res) )
		  )
  :effects (  (eqn-contains (LR-decay-Imax (during ?ti ?tf)) ?sought) ))

(defoperator LR-decay-Imax (?ti ?tf)
  :preconditions (
		  (LR-current-decay ?branch (during ?ti ?tf))
		  (circuit-component ?res resistor)
		  (circuit-component ?bat battery)
		  (variable ?Imax-var (current-in ?branch :time ?ti))
		  (variable ?v-var (voltage-across ?bat :time (during ?ti ?tf)))
		  (variable ?r-var (resistance ?res))
		  )
  :effects ( (eqn (= ?Imax-var (/ ?v-var ?r-var)) (LR-decay-Imax (during ?ti ?tf))) )
  :hint (
	 (point (string "What is the initial value of the current when the switch is opened?"))
	 (point (string "At its maximum value, the current in an LR circuit is nearly constant, so there is no EMF due to the inductor. Since the only source of EMF at this time is the battery, Ohm's Law V = I*R determines the current through the resistor to be the battery voltage divided by resistance."))
	 (bottom-out (string "Write the equation ~a" ((= ?Imax-var (/ ?v-var ?r-var)) algebra)  ))
	 ))


;;; Power "through" component = V*I
(def-psmclass electric-power (electric-power ?comp ?t)
  :complexity major
  :english ("the formula for electric power")
  :eqnFormat ("P = I*V"))

(defoperator electric-power-contains (?sought)
  :preconditions ( 
		  (any-member ?sought ( (voltage-across ?comp :time ?t) 
					(current-thru ?comp :time ?t)
					(electric-power ?comp :time ?t) )) ; omit "agent" for electric power ?
					; we only apply this to batteries and resistors
		  (in-wm (circuit-component ?comp ?comp-type))
		  (test (member ?comp-type '(battery resistor)))
		  ) 
  :effects ( (eqn-contains (electric-power ?comp ?t) ?sought) ))

(defoperator electric-power (?comp ?t)
  :preconditions (
		  (variable ?V (voltage-across ?comp :time ?t) )
		  (variable ?I (current-thru ?comp :time ?t))
		  (variable ?P  (electric-power ?comp :time ?t)) 
		  )
  :effects (
	    (eqn (= ?P (* ?V ?I)) (electric-power ?comp ?t))
	    )
  :hint (
	 (point (string "Power specifies the rate at which energy is transferred. Think about how the rate of energy transferred as charge moves across a component can be related to the current and the difference in electric potential across the endpoints."))
	 (teach (string "The potential difference (voltage) between two points is defined as the work needed to move a unit charge between those points. Power is the rate of doing work. For a battery with EMF V to produce a current I, it must move I unit charges per second through a potential difference of V, so its power output equals V*I. The same formula will give the amount of power DRAWN by a resistor as charge moves through it from higher to lower potential, when the electrical potential energy is converted to other forms of energy such as heat or light and dissipated from the circuit.)"))
	 (bottom-out (string "Write the equation ~a" ((= ?P (* ?V ?I)) algebra)))
	 ))

(defoperator define-electric-power-var (?b ?t)
  :preconditions (
		  (bind ?power-var (format-sym "power_~A_~A" (body-name ?b) (time-abbrev ?t)))
		  ) :effects (
		  (define-var (electric-power ?b :time ?t))
		  (variable ?power-var (electric-power ?b :time ?t))
		  )
  :hint (
	 (bottom-out (string "Define a variable for ~A by using the Add Variable command on the Variable menu and selecting power." ((electric-power ?b :time ?t) def-np) ))
	 ))
