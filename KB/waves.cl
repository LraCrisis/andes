;;;;
;;;;                   Waves and oscillations
;;;;

;;;;
;;;;  The wavelength and wavenumber of a wave
;;;;

(def-qexp wavelength (wavelength ?wave)
  :units |m|
  :restrictions positive  ;needed for harmonics problems to work
  :english ("the wavelength of ~A" (nlg ?wave))
  :fromworkbench `(wavelength ,body))

(defoperator define-wavelength (?wave)
  :preconditions((bind ?lambda-var (format-sym "lamb_~A" (body-name ?wave))))
  :effects ((variable ?lambda-var (wavelength ?wave))
	    (define-var (wavelength ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for the wavelength of ~A by using the Add Variable command on the Variable menu and selecting wavelength."  ?wave))))

(def-qexp wavenumber (wavenumber ?wave)
  :units |rad/m|
  :restrictions nonnegative  
  :english ("the wavenumber of ~A" (nlg ?wave))
   :fromWorkbench `(wavenumber ,body))

(defoperator define-wavenumber (?wave)
  :preconditions ( (bind ?wn-var (format-sym "kwave_~A" (body-name ?wave))) )
  :effects ( (variable ?wn-var (wavenumber ?wave))
             (define-var (wavenumber ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for the wave number of the ~A by using the Add Variable command on the Variable menu and selecting wave number."  ?wave))))

;;; Equation of the wavenumber of the wave, wavenumber*lambda = 2*pi
(def-psmclass wavenumber-lambda-wave (wavenumber-lambda-wave ?wave)
  :complexity major  ; must explicitly use
  :english ("relation between wavelength and wavenumber")
  :ExpFormat ("Applying the equation relating wavenumber and wavelength")
  :EqnFormat ("wavenumber*wavelength = 2*pi")) 


 (defoperator wavenumber-lambda-wave-contains (?sought)
   :preconditions (
		   (any-member ?sought ((wavelength ?wave)
					(wavenumber ?wave))))
   :effects (
     (eqn-contains (wavenumber-lambda-wave ?wave ) ?sought)))


(defoperator wavenumber-lambda-wave (?wave)
   :preconditions (
       (variable  ?lamb  (wavelength ?wave))
       (variable  ?kwave  (wavenumber ?wave))
   )
   :effects (
    (eqn  (= (* ?lamb ?kwave) (* 2 $p))  ;For pi, must use $p
                (wavenumber-lambda-wave ?wave))
   )
   :hint (
      (point (string "You can use equation for the wavenumber of a wave"))
      ;(teach (string "The equation-of-wavenumber-of-wave states that the wavenumber of a wave is (2*pi)/wavelength"))
      (bottom-out (string "Write the equation ~A" 
			  ((= (* ?kwave   ?lamb) (*2 $p)) algebra) ))
      ))

;;;
;;; The frequency, period, and angular frequency of a wave
;;;

(def-qexp frequency (frequency ?wave)
  :units |Hz|
  :restrictions nonnegative 
  :english ("the frequency of ~A" (nlg ?wave))
  :fromworkbench `(frequency ,body))

(defoperator define-frequency (?wave)
  :preconditions((bind ?freq-var (format-sym "freq_~A" (body-name ?wave))))
  :effects ((variable ?freq-var (frequency ?wave))
	    (define-var (frequency ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for the frequency of ~A by using the Add Variable command on the Variable menu and selecting frequency."  ?wave))))

;;;
;;;  For doppler problems, we have to introduce a frequency as
;;;  observed by someone
;;;

(def-qexp observed-frequency (observed-frequency ?wave ?me)
  :units |Hz|
  :restrictions nonnegative 
  :english ("the frequency of ~A as observed by ~A" 
	       (nlg ?wave) (nlg ?me))
  :fromworkbench `(at (observed-frequency ,body) ,time))

(defoperator define-observed-frequency (?wave ?me ?t)
  :preconditions
  ((bind ?freq-var (format-sym "freq_~A_~A_~A" 
			       (body-name ?wave) (body-name ?me) 
			       (time-abbrev ?t))))
  :effects ((variable ?freq-var (at (observed-frequency ?wave ?me) ?t))
	    (define-var (at (observed-frequency ?wave ?me) ?t)))
  :hint ((bottom-out 
	  (string "Define a variable for the frequency of ~A as observed by ~A by using the Add Variable command on the Variable menu and selecting observed frequency."  ?wave ?me))))

;;
;; period is used in some circular motion rules:
;;
;; We don't have time on a period. The definition in terms of velocity 
;; allows it to be an instantaneous quantity -- time it *would* take object to 
;; make a complete revolution at its instantaneous speed at t. So period 
;; could change over time as speed does and object never needs to actually 
;; make a complete revolution in its period at a time.  In uniform circular
;; motion velocity is constant, so period could be defined for the interval 
;; of uniform circular motion.  However, in our circular motion problems we 
;; usually represent this constant state by analyzing a representative instant 
;; which is usually the only instant in the problem.  So we just assume that 
;; and leave out time.
;;

(def-qexp period (period ?body)
   :units |s|
   :restrictions positive
   :fromWorkbench `(period ,body)
   :english ("the period of the motion of ~A" (nlg ?body)))

(defoperator define-period-var (?b)
  :preconditions ( 
        (bind ?T-var (format-sym "T_~A" (body-name ?b)))
  )
  :effects (
      (variable ?T-var (period ?b))
      (define-var (period ?b))
   )
 :hint
  ((bottom-out (string "Use the Add Variable command located under 'variable' on the top menu bar and select Period to define a variable for the period of the motion of ~A." ?b))
   ))

(def-qexp angular-frequency (angular-frequency ?wave)
  :units |rad/s|
  :restrictions nonnegative 
  :english ("the angular-frequency of ~A" (nlg ?wave))
  :fromworkbench `(angular-frequency ,body))

(defoperator define-angular-frequency (?wave)
  :preconditions((bind ?omega-var (format-sym "omega_~A" (body-name ?wave))))
  :effects ((variable ?omega-var (angular-frequency ?wave))
	    (define-var (angular-frequency ?wave)))
  :hint (
	 (bottom-out (string "Define a variable for the angular-frequency of ~A by using the Add Variable command on the Variable menu and selecting wavelength."  ?wave))))

;;equation of the frequency of the wave, frequency = angular-frequency/2*pi
(def-psmclass frequency-of-wave (frequency-of-wave ?object)
  :complexity minor  
  :english ("the equation for the frequency of a wave")
  :ExpFormat ("Applying the equation for the frequency of a wave")
  :EqnFormat ("frequency = angular-frequency/(2*$p)")) 

(defoperator frequency-of-wave-contains (?sought)
  :preconditions (
		  (any-member ?sought ( 
				       (angular-frequency ?object)
				       (frequency ?object))))
  :effects ((eqn-contains (frequency-of-wave ?object) ?sought)))

(defoperator frequency-of-wave (?object)
  :preconditions (
		  (variable  ?omega  (angular-frequency ?object))
		  (variable  ?freq  (frequency ?object))
		  )
  :effects (
	    (eqn  (= ?omega (* 2 $p ?freq)) ; pi must be $p
	    (frequency-of-wave ?object)))
  :hint (
	 (point (string "You can use equation for the frequency of a wave"))
	 ;;(teach (string "The equation-of-frequency-of-wave states that the frequency of a wave is angular-frequency/(2*pi)"))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?omega (*2 $p ?freq))  algebra) ))
	 ))

;;; There are two versions for beat frequency: one for
;;; the "timeless" intrinsic frequency and the other for
;;; observed-frequency.  As much as possible, these should 
;;; appear to the user as the same equation.

;;equation beat frequency for two waves
(def-psmclass beat-frequency (beat-frequency ?wbeat ?w1 ?w2 ?me ?t)
  :complexity major 
  :english ("the beat frequency of two waves")
  :ExpFormat ("finding the beat frequency of two waves")
  :EqnFormat ("fbeat = (f1-f2)/2")) 

(defoperator beat-frequency-contains (?sought)
  :preconditions 
  ( (sinusoidal ?w1)			;only valid for sine waves
    (sinusoidal ?w2)
    (beat-frequency ?wbeat ?w1 ?w2)
    (any-member ?sought ((at (observed-frequency ?wbeat ?me) ?t) 
			 (at (observed-frequency ?w1 ?me) ?t)
			 (at (observed-frequency ?w2 ?me) ?t)
			 ))
    (time ?t) )
  :effects 
  ( (eqn-contains (beat-frequency ?wbeat ?w1 ?w2 ?me ?t) ?sought) ))

(defoperator timeless-beat-frequency-contains (?sought)
  :preconditions 
  ( (sinusoidal ?w1)  ;only valid for sine waves
    (sinusoidal ?w2)
    (beat-frequency ?wbeat ?w1 ?w2)
    (any-member ?sought ((frequency ?wbeat) 
			 (frequency ?w1)
			 (frequency ?w2))) )
  :effects 
  ( (eqn-contains (beat-frequency ?wbeat ?w1 ?w2 nil nil) ?sought) ))

(defoperator write-beat-frequency (?wbeat ?w1 ?w2 ?me ?t)
  :preconditions 
  ( (variable  ?f1 (at (observed-frequency ?w1 ?me) ?t))
    (variable  ?f2 (at (observed-frequency ?w2 ?me) ?t))
    (variable  ?fbeat (at (observed-frequency ?wbeat ?me) ?t)) )
  :effects 
  ( (eqn  (= ?fbeat (* 0.5 (abs (- ?f1 ?f2)))) 
	  (beat-frequency ?wbeat ?w1 ?w2 ?me ?t)) )
  :hint 
  ( (point (string "You can use equation for the beat frequency"))
    (teach (string "The beat frequency for two waves is one half the difference in frequency."))
    (bottom-out (string "Write the equation ~A" 
			((= ?fbeat (* 0.5 (abs (- ?f1 ?f2))))  algebra) )) ))

;; it would be nice to somehow combine this with the above rule...
(defoperator write-timeless-beat-frequency (?wbeat ?w1 ?w2 ?me ?t)
  :preconditions 
  ( (test (and (equal ?me 'nil) (equal ?t 'nil)))
    (variable  ?f1 (frequency ?w1))
    (variable  ?f2 (frequency ?w2))
    (variable  ?fbeat (frequency ?wbeat)) )
  :effects 
  ( (eqn  (= ?fbeat (* 0.5 (abs (- ?f1 ?f2)))) 
	  (beat-frequency ?wbeat ?w1 ?w2 ?me ?t)) )
  :hint 
  ( (point (string "You can use equation for the beat frequency"))
    (teach (string "The beat frequency for two waves is one half the difference in frequency."))
    (bottom-out (string "Write the equation ~A" 
			((= ?fbeat (* 0.5 (abs (- ?f1 ?f2))))  algebra) )) ))

;;;
;;;  Relate frequency and period of a wave
;;;
;;equation of the period of the wave, period = 1/frequency
(def-psmclass period-of-wave (period-of-wave ?object)
  :complexity major 
  :english ("the equation for the period of a wave")
  :ExpFormat ("Applying the equation for the period of a wave")
  :EqnFormat ("period = 1/frequency")) 

(defoperator period-of-wave-contains (?sought)
  :preconditions (
		  (any-member ?sought ( 
				       (period ?object)
				       (frequency ?object))))
  :effects (
	    (eqn-contains (period-of-wave ?object) ?sought)))

(defoperator period-of-wave (?object)
  :preconditions (
		  (variable  ?period (period ?object))
		  (variable  ?freq  (frequency ?object)))
  :effects (
	    (eqn  (= (* ?freq ?period) 1) 
		  (period-of-wave ?object)))
  :hint (
	 (point (string "You can use equation for the period of a wave"))
	 ;;(teach (string "The equation-of-period-of-wave states that the frequency of a wave is 1/period"))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?freq (/ 1 ?period))  algebra) ))
	 ))

;;;
;;;  Hamonics of standing waves
;;;  The allows one to do things in terms of either frequency or wavelength
;;;

(def-psmclass harmonic-of (harmonic-of ?wave1 ?wave0 ?form)
  :complexity minor
  :english ("harmonic of a standing wave")
  :eqnFormat ("fn = (n+1)*f0 or $ln = $l0/(n+1)"))

(defoperator harmonic-of-contains (?sought)
  :preconditions (
		  (harmonic-of ?wave1 ?mult ?wave0)
		  (any-member ?sought (
				       (wavelength ?wave1)
				       (frequency ?wave1)
				       (wavelength ?wave0)
				       (frequency ?wave0)))
		  (bind ?form (first ?sought)) ;form is wavelength or frequency
		  )
  :effects ( (eqn-contains (harmonic-of ?wave1 ?wave0  ?form) ?sought)
	     ))


(defoperator write-harmonic-of (?wave1 ?wave0 ?quant)
  :preconditions (
		  (harmonic-of ?wave1 ?mult ?wave0) ;get ?mult		  
		  (variable ?v1 (?quant ?wave1))
		  (variable ?v2 (?quant ?wave0))
		  ;; write factor as a rational number
		  (bind ?fact (if (eq ?quant 'frequency) 
				    (+ 1 ?mult) `(/ 1 ,(+ 1 ?mult))))
		  )
  :effects ( (eqn (= ?v1 (* ?fact ?v2)) (harmonic-of ?wave1 ?wave0 ?quant)))
  :hint (
	 (point (string "~A is the ~:R harmonic of ~A" ;prints as ordinal
			?wave1 (?mult 'identity) ;so nlg just returns ?mult  
			?wave0)) 
	 (teach (string "You can determine ~A of ~A from ~A of ~A" 
			 ?quant ?wave1 ?quant ?wave0)) 
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?v1 (* ?fact ?v2)) algebra)))
	  ))


;;;
;;;   Wave speed, this is |phase velocity|
;;;

(def-qexp wave-speed (wave-speed ?wave)
  :units |m/s|
  :restrictions nonnegative 
  :english ("|the wave velocity of ~A|" (nlg ?wave))
  :fromworkbench `(wave-speed ,body))

(defoperator define-wave-speed (?wave)
  :preconditions((bind ?wv-var (format-sym "wv_~A" (body-name ?wave))))
  :effects ((variable ?wv-var (wave-speed ?wave))
	    (define-var (wave-speed ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for the |velocity| of ~A by using the Add Variable command on the Variable menu and selecting amplitude."  ?wave))))

;;; equation of the speed of the wave, speed = freq* wavelength
;;; Only for sinusoidal waves (where freq & wavelength are well-defined)
(def-psmclass speed-of-wave (speed-of-wave ?object)
  :complexity major ; must use explicitly 
  :english ("the equation of the speed of a wave")
  :ExpFormat ("Applying the equation of the speed of a wave")
  :EqnFormat ("v = lambda*freq")) 

(defoperator speed-of-wave-contains (?sought)
  :preconditions (
		  (sinusoidal ?object)
		  (any-member ?sought ( 
				       (wave-speed ?object)
				       (wavelength ?object)
				       (frequency ?object)))  )
  :effects (
	    (eqn-contains (speed-of-wave ?object) ?sought)))

(defoperator speed-of-wave (?object)
  :preconditions (
		  (variable  ?v  (wave-speed ?object))
		  (variable  ?lam  (wavelength ?object))
		  (variable  ?freq  (frequency ?object))
		  )
  :effects (
	    (eqn  (= ?v (* ?lam ?freq)) 
		  (speed-of-wave ?object)))
  :hint (
	 (point (string "You can use equation for the speed of a wave"))
	 ;;(teach (string "The equation-of-speed-of-wave states that the speed of a wave is wavelength*frequency"))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?v (* ?lam ?freq)) algebra) ))
	 ))

;; wave speeds of two things are identical
(def-psmclass wave-speeds-equal (wave-speeds-equal . ?quants)
  :complexity minor ; used implicitly 
  :english ("The speed of any wave is the same")
  :ExpFormat ("using the fact that the waves have the same speed")
  ) 

(defoperator wave-speeds-equal-contains (?sought)
  :preconditions (
		  ;; only if defined this way in the problem
		  (in-wm (same-wave-speed ?wave1 ?wave2))
		  (any-member ?sought ( 
				       (wave-speed ?wave1)
				       (wave-speed ?wave2)))
		  ;; sort quants in id so A=B and B=A get same id.
		  (bind ?quants (sort (list ?wave1 ?wave2) #'expr<)))
  :effects (
	    (eqn-contains (wave-speeds-equal . ?quants) 
			  ?sought)))

(defoperator wave-speeds-equal (?wave1 ?wave2)
  :preconditions (
		  (variable  ?v1  (wave-speed ?wave1))
		  (variable  ?v2  (wave-speed ?wave2)))
  :effects (
	    (eqn  (= ?v1 ?v2) 
		  (wave-speeds-equal ?wave1 ?wave2) ))
  :hint (
	 (point (string "The velocity of any wave on a given string, rope, et cetera is the same."))
      (point (string "If there are two waves on a string, then they have equal speeds."))
      (bottom-out (string "Write the equation ~A" 
			  ((= ?v1 ?v2) algebra) ))
      ))

;; speed of object is wave speed
(def-psmclass speed-equals-wave-speed (speed-equals-wave-speed ?object ?rope ?t)
  :complexity minor ; used implicitly 
  :english ("The speed of any wave is the same")
  :ExpFormat ("applying the speed of any wave is the same")
  ) 

(defoperator speed-equals-wave-speed-contains (?sought)
  :preconditions (
		  ;; only if defined this way in the problem
		  (in-wm (same-wave-speed ?object ?rope))
		  (any-member ?sought ( 
				       (wave-speed ?rope)
				       (at (speed ?object) ?t)
				       (duration ?t)))
		  (time ?t))
  :effects (
	    (eqn-contains (speed-equals-wave-speed ?object ?rope ?t) 
			  ?sought)))

(defoperator speed-equals-wave-speed (?object ?rope ?t)
  :preconditions (
		  (variable  ?v1  (wave-speed ?rope))
		  (variable  ?v2  (at (speed ?object) ?t)))
  :effects (
	    (eqn  (= ?v1 ?v2) 
		  (speed-equals-wave-speed ?object ?rope ?t) ))
  :hint (
	 (point (string "The velocity of any wave on a given string, rope, et cetera is the same."))
	 (point (string "If there are two waves on a string, then they have equal speeds."))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?v1 ?v2) algebra) ))
	 ))

;;;;
;;;;  Wave speed for various objects   
;;;;

;;;
;;; speed of light "c", see notes for "grav-constant"
;;;
(def-qexp speed-of-light (speed-of-light)
  :units |m/s|
  :restrictions positive
  :english ("the speed of light in a vacuum"))

(defoperator c-contains()
  :effects ( (eqn-contains (std-constant speed-of-light) (speed-of-light)) ))

(defoperator write-value-of-c ()
  :preconditions 
    ( (variable ?c-var (speed-of-light)) )
  :effects ( 
    (eqn (= ?c-var (dnum 2.998E8 |m/s|)) (std-constant speed-of-light)) 
   )
  :hint
  ((point (string "You can find the value of the speed of light c in your textbook.  Use four significant digits."))
   (teach (string "You can use 2.998E8 N.m/kg^2 as the value of c."))
   (bottom-out (string "Write the equation ~A" 
		       ((= ?c-var (dnum 2.998E8 |m/s|)) algebra) ))
    ))

(defoperator define-c ()
 :effects ( (variable |c| (speed-of-light)) ))

;;; If object is "light" then set its wave-speed to c
(def-psmclass wave-speed-light (wave-speed-light ?wave)
  :complexity minor
  :english ("the speed of a light or radio wave")
  :ExpFormat("setting wave speed to c")
  :EqnFormat("v=c"))

(defoperator wave-speed-light-contains (?sought)
  :preconditions (
		  (light ?wave)
		  (any-member ?sought ((wave-speed ?wave))))
  :effects (
	    (eqn-contains (wave-speed-light ?wave) ?sought)))

(defoperator wave-speed-light (?wave)
  :preconditions (
		  (variable  ?v (wave-speed ?wave))
		  (variable ?c (speed-of-light)))
  :effects (
	    (eqn  (= ?v ?c) 
		  (wave-speed-light ?wave)))
  :hint (
	 (point (string "Light waves and radio waves have a special speed"))
	 (teach (string "What is the speed of light?"))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?v ?c)  algebra) ))
	 ))

;;;
;;; Speed of transverse wave on a string
;;;


;;; First, define tension of a rope.
;;; In principle, this should be connected with the
;;; tension force applied to an object...

(def-qexp string-tension (string-tension ?rope)
  :units |N|
  :restrictions nonnegative 
  :english ("the string-tension of ~A" (nlg ?rope))
  :fromworkbench `(string-tension ,body))

(defoperator define-string-tension (?rope)
  :preconditions(
		 (string ?rope)
		 (bind ?t-var (format-sym "Ft_~A" (body-name ?rope))))
  :effects (
	    (variable ?t-var (string-tension ?rope))
	    (define-var (string-tension ?rope)))
  :hint ((bottom-out 
	  (string "Define a variable for the tension of ~A by using the Add Variable command on the Variable menu and selecting tension."  ?rope))))

;;; speed of transverse waves on a string
(def-psmclass wave-speed-string (wave-speed-string ?wave)
  :complexity major			; must explicitly use
  :english ("Transverse wave velocity of a string")
  :ExpFormat ("using formula for transverse wave speed on a string")
  :EqnFormat ("v_wave = sqrt(F_T/mu)")) 


(defoperator wave-speed-string-contains (?sought)
  :preconditions (
		  (string ?wave)
		  (any-member ?sought ((mass-per-length ?wave)
				       (string-tension ?wave)
				       (wave-speed ?wave))))
  :effects (
	    (eqn-contains (wave-speed-string ?wave ) ?sought)))

(defoperator wave-speed-string (?string)
  :preconditions (
		  (variable  ?mu-var  (mass-per-length ?string))
		  (variable  ?vw  (wave-speed ?string))
		  (variable ?tension (string-tension ?string))
		  )
  :effects (
	    (eqn  (= (* ?vw ?vw) (/ ?tension ?mu-var))
		  (wave-speed-string ?string))
	    )
  :hint (
	 (point (string "In your textbook, find a formula for the speed of transverse waves on a string."))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?vw (sqrt (/ ?tension ?mu-var))) algebra) ))
	 ))

;;;; 
;;;;   The amplitude of a wave and associated quantities
;;;;   (usually, the amplitude is just given in a problem
;;;;    and the student must identify the quantity.
;;;;

(def-qexp amplitude (amplitude ?wave)
  :units |m|
  :restrictions nonnegative 
  :english ("the amplitude of ~A" (nlg ?wave))
  :fromworkbench `(amplitude ,body))

(defoperator define-amplitude (?wave)
  :preconditions((bind ?lambda-var (format-sym "amp_~A" (body-name ?wave))))
  :effects ((variable ?lambda-var (amplitude ?wave))
	    (define-var (amplitude ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for the amplitude of ~A by using the Add Variable command on the Variable menu and selecting amplitude."  ?wave))))

;;; define maximum speed of transverse motion
(def-qexp amplitude-max-speed (amplitude-max-speed ?wave)
  :units |m/s|
  :restrictions nonnegative 
  :english ("the maximum speed of ~A" (nlg ?wave))
  :fromworkbench `(amplitude-max-speed ,body))

(defoperator define-amplitude-max-speed (?wave)
  :preconditions((bind ?lambda-var (format-sym "vmax_~A" (body-name ?wave))))
  :effects ((variable ?lambda-var (amplitude-max-speed ?wave))
	    (define-var (amplitude-max-speed ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for the maximum speed of ~A by using the Add Variable command on the Variable menu and selecting maximum speed."  ?wave))))
;;; Yuck!  In the real world, one would derive this...
(def-psmclass max-transverse-speed-wave (max-transverse-speed-wave ?wave)
  :complexity major  ; must explicitly use
  :english ("Formula for maximum speed of an oscillation")
  :ExpFormat ("Applying formula for maximum speed of an oscillation")
  :EqnFormat ("v_max=A $w")) 


 (defoperator max-transverse-speed-wave-contains (?sought)
   :preconditions (
		   (sinusoidal ?wave)
		   (any-member ?sought ((amplitude-max-speed ?wave)
					(amplitude ?wave)
					(angular-frequency ?wave))))
   :effects (
     (eqn-contains (max-transverse-speed-wave ?wave ) ?sought)))


(defoperator max-transverse-speed-wave (?wave)
   :preconditions (
       (variable  ?vmax  (amplitude-max-speed ?wave))
       (variable  ?a  (amplitude ?wave))
       (variable  ?w  (angular-frequency ?wave))
   )
   :effects (
    (eqn  (= ?vmax (* ?a ?w))  
                (max-transverse-speed-wave ?wave))
   )
   :hint (
      (point (string "In your textbook, find a formula for the maximum speed of an oscillation"))
      ;(teach (string "The equation-of-wavenumber-of-wave states that the wavenumber of a wave is (2*pi)/wavelength"))
      (bottom-out (string "Write the equation ~A" 
                     ((= ?vmax (* ?a ?w)) algebra) ))
      ))


;;; define |maximum transverse accleration|
(def-qexp amplitude-max-abs-acceleration (amplitude-max-abs-acceleration ?wave)
  :units |m/s^2|
  :restrictions nonnegative 
  :english ("the |maximum acceleration of ~A|" (nlg ?wave))
  :fromworkbench `(amplitude-max-abs-acceleration ,body))

(defoperator define-amplitude-max-abs-acceleration (?wave)
  :preconditions((bind ?lambda-var (format-sym "amax_~A" (body-name ?wave))))
  :effects ((variable ?lambda-var (amplitude-max-abs-acceleration ?wave))
	    (define-var (amplitude-max-abs-acceleration ?wave)))
  :hint ((bottom-out 
	  (string "Define a variable for |maximum acceleration of ~A| by using the Add Variable command on the Variable menu and selecting |maximum acceleration|."  ?wave))))

;;; Yuck!  In the real world, one would derive this...
(def-psmclass max-transverse-abs-acceleration-wave (max-transverse-abs-acceleration-wave ?wave)
  :complexity major  ; must explicitly use
  :english ("Formula for |maximum acceleration| of an oscillation")
  :ExpFormat ("Applying formula for |maximum acceleration| of an oscillation")
  :EqnFormat ("v_max=A $w")) 

 (defoperator max-transverse-abs-acceleration-wave-contains (?sought)
   :preconditions (
		   (sinusoidal ?wave)
		   (any-member ?sought ((amplitude-max-abs-acceleration ?wave)
					(amplitude ?wave)
					(angular-frequency ?wave))))
   :effects (
     (eqn-contains (max-transverse-abs-acceleration-wave ?wave ) ?sought)))


(defoperator max-transverse-abs-acceleration-wave (?wave)
   :preconditions (
       (variable  ?amax  (amplitude-max-abs-acceleration ?wave))
       (variable  ?a  (amplitude ?wave))
       (variable  ?w  (angular-frequency ?wave))
   )
   :effects (
    (eqn  (= ?amax (* ?a ?w ?w))  
                (max-transverse-abs-acceleration-wave ?wave))
   )
   :hint (
      (point (string "In your textbook, find a formula for the maximum acceleration of an oscillation"))
      ;(teach (string "The equation-of-wavenumber-of-wave states that the wavenumber of a wave is (2*pi)/wavelength"))
      (bottom-out (string "Write the equation ~A" 
                     ((= ?amax (* ?a ?w ?w)) algebra) ))
      ))

;;;  Frequency for mass and spring.
;;;  This is kind of lousy:  only works for one spring acting
;;;  on a block and does not check any other forces that
;;;  might be acting on the block.
(def-psmclass spring-mass-oscillation (spring-mass-oscillation ?block ?spring)
  :complexity major			; must explicitly use
  :english ("Formula for period of mass and spring")
  :ExpFormat ("using formula for period of mass and spring")
  :EqnFormat ("T = 2 ?p sqrt(m/k)")) 

(defoperator spring-mass-oscillation-contains (?sought)
  :preconditions (
		  (sinusoidal ?block)
		  (spring-contact ?block ?spring . ?dontcare)
		  (any-member ?sought ((period ?block)
				       (mass ?block)
				       (spring-constant ?spring)))
		  )
  :effects (
	    (eqn-contains (spring-mass-oscillation ?block ?spring) ?sought)))

(defoperator spring-mass-oscillation (?block ?spring)
  :preconditions (
		  (variable  ?t (period ?block))
		  (variable  ?m  (mass ?block))
		  (variable ?k (spring-constant ?spring))
		  )
  :effects (
	    ;; BvdS:  No solution found if this is in sqrt form.
	    (eqn (= (* ?t ?t ?k) (* 4 $p $p ?m)) ;must use $p for pi
		 (spring-mass-oscillation ?block ?spring))
	    )
  :hint (
	 (point (string "In your textbook, find a formula for the period of oscillation of a mass and spring"))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?t (* 2 $p (sqrt (/ ?m ?k)))) algebra) ))
	 ))

;;; mass and spring have same period
(defoperator oscillator-periods-equal-contains (?block ?rod)
  :preconditions (
		  (spring-contact ?block ?rod . ?dontcare)
		  )
  :effects ((equals (period ?block) (period ?rod))))

;;;  Frequency for simple pendulum
;;;  This is kind of lousy:  
;;;  Since it is not done as a true F=ma problem, it does not
;;;  properly check for other forces on the mass.
(def-psmclass pendulum-oscillation (pendulum-oscillation ?block ?rod ?planet)
  :complexity major			; must explicitly use
  :english ("Formula for period of mass and spring")
  :ExpFormat ("using formula for period of mass and spring")
  :EqnFormat ("T = 2 ?p sqrt(l/g)")) 

(defoperator pendulum-oscillation-contains (?sought)
  :preconditions (
		  (sinusoidal ?block)
		  (massless ?rod)
		  (pendulum ?block ?rod)
		  (near-planet ?planet)
		  (any-member ?sought ((period ?block)
				       (length ?rod)
				       (gravitational-acceleration ?planet)
				       ))
		  )
  :effects (
	    (eqn-contains (pendulum-oscillation ?block ?rod ?planet
						) ?sought)))

(defoperator pendulum-oscillation (?block ?rod ?planet
				   )
  :preconditions (
		  (near-planet ?planet)
		  (variable  ?t (period ?block))
		  (variable  ?g-var (gravitational-acceleration ?planet))
		  (variable ?l (length ?rod))
		  )
  :effects (
	    ;; BvdS:  I couldn't get this to work in sqrt form.
	    (eqn  (= (* ?t ?t ?g-var) (* 4 $p $p ?l)) ;must use $p for pi
		  (pendulum-oscillation ?block ?rod ?planet))
	    )
  :hint (
	 (point (string "In your textbook, find a formula for the period of oscillation of a pendulum"))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?t (* 2 $p (sqrt (/ ?l ?g-var)))) algebra) ))
	 ))

;;; Period of parts of pendulum are equal
(defoperator pendulum-periods-equal-contains (?block ?rod)
  :preconditions (
		  (pendulum ?block ?rod)
		  )
  :effects ((equals (period ?block) (period ?rod))))

;;;
;;;  Doppler shift in one dimension.
;;;  This assumes all velocities are defined with respect to the wave medium
;;;  Since this involves the positions of various bodies, 
;;;  we find the shift at a particular time, which is an exception
;;;  to the general strategy .
;;;
;;;  This also depends crucially on the two-dimensional notation
;;;  found in much of Andes
;;;

(def-psmclass doppler-frequency (doppler-frequency ?source ?wave ?observer 
						   ?t ?t-interval)
  :complexity major			; must explicitly use
  :english ("Formula for doppler frequency shift")
  :ExpFormat ("using formula for doppler frequency")
  :EqnFormat ("fo=fs*(vw±vo)/(vw∓vs))")) 

;;; velocities should be constant over a large enough
;;; interval.  We could demand (constant ?quant ?t-interval) but
;;; hopefully that construct will be replaced.
(defoperator doppler-frequency-contains (?sought)
  :preconditions 
  (
   (doppler-system ?source ?wave ?observer) ;so the ?wave is identified
   (time ?t) (test (time-pointp ?t))
   (time ?t-interval)
   (test (time-intervalp ?t-interval))
   (test (tinsidep-include-second-endpoint ?t ?t-interval))
   (any-member ?sought ((frequency ?source)
			(wave-speed ?wave)
			(at (observed-frequency ?source ?observer) ?t)
			;; we *assume* the interval is big enough
			(at (mag (relative-vel ?source ?wave)) ?t-interval) 
			(at (mag (relative-vel ?observer ?wave)) ?t-interval)
			(at (dir (relative-vel ?source ?wave)) ?t-interval) 
			(at (dir (relative-vel ?observer ?wave)) ?t-interval)
			(at (dir (relative-position ?source ?observer)) ?t)
			))
   (object ?source)
   (object ?observer)
   (sinusoidal ?source)
   (not (light ?wave))  ;light uses a different formula
   )
  :effects (
	    (eqn-contains (doppler-frequency ?source ?wave ?observer 
					     ?t ?t-interval) ?sought)))

(defoperator make-doppler-frequency (?source ?wave ?observer ?t ?t-interval)
  :preconditions 
  ((variable ?vs (at (mag (relative-vel ?source ?wave)) 
		     ?t-interval))
   (variable ?vo (at (mag (relative-vel ?observer ?wave)) 
				    ?t-interval))
   (variable ?vw (wave-speed ?wave))		  
   (variable ?fs (frequency ?source))		  
   (variable ?fo (at (observed-frequency ?source ?observer) ?t))
   ;; vector from observer to source
   ;; BvdS:  this is 180 deg off from phi in my notes
   (variable ?phi (at (dir (relative-position 
			    ?source ?observer)) ?t))
   ;; use vector statements so that zero velocity can be handled 
   ;; correctly.  This might prevent relative-vel from being the sought.
   (in-wm (vector ?source (at (relative-vel ?source ?wave) ?t-interval) ?sdir))
   (in-wm (vector ?observer (at (relative-vel ?observer ?wave) ?t-interval) ?odir))
   (bind ?sterm (if (eq ?sdir 'zero) ?vw 
		  `(+ ,?vw (* ,?vs (cos (- ,?phi ,?sdir))))))
   (bind ?oterm (if (eq ?odir 'zero) ?vw 
		  `(+ ,?vw (* ,?vo (cos (- ,?phi ,?odir))))))
   )
  :effects (
	    (eqn  (= (* ?fo ?sterm) (* ?fs ?oterm))
		  (doppler-frequency ?source ?wave ?observer ?t ?t-interval))
	    )
  :hint (
	 (point (string "Use the formula for doppler frequency shift."))
	 (bottom-out (string "Write the equation ~A" 
			     ((=  ?fo 
				  (* ?fs (/  ?oterm ?sterm))) algebra) ))
	 ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;   Decibels and intensity
;;;;   These quantities can be functions of time,
;;;;   but none of the problems so far require it.
;;;;
(def-qexp intensity (intensity ?wave ?agent)
  :units |W/m^2|
  :restrictions positive
  :english ("the intensity supplied to ~A due to ~A" (nlg ?wave) (nlg ?agent))
   :fromWorkbench (if (string-equal body2 '|all sources|)
                     `(at (net-intensity ,body) ,time)
                  `(at (intensity ,body ,body2) ,time)))

(defoperator define-intensity (?wave ?agent ?t)
  :preconditions
  ((bind ?intense-var (format-sym "int_~A_~A_~A" 
				 (body-name ?wave) (body-name ?agent)
				 (time-abbrev ?t))))
  :effects ((variable ?intense-var (at (intensity ?wave ?agent) ?t))
	    (define-var (at (intensity ?wave ?agent) ?t)))
  :hint ((bottom-out 
	  (string "Define a variable for the intensity of ~A due to ~A by using the Add Variable command on the Variable menu and selecting intensity."  
		  ?wave ?agent))))

;;;
;;; Net intensity is sum of all power acting on object.
;;;
(def-qexp net-intensity (net-intensity ?wave)
  :units |W/m^2|
  :restrictions positive  
  :english ("the net intensity supplied to ~A" (nlg ?wave)))

;; based on define-net-work
(defoperator define-net-intensity (?wave ?t)
  :preconditions
  ((bind ?intense-var (format-sym "netint_~A_~A" 
				  (body-name ?wave) (time-abbrev ?t))))
  :effects ((variable ?intense-var (at (net-intensity ?wave) ?t))
	    (define-var (at (net-intensity ?wave) ?t)))
  :hint ((bottom-out 
	  (string "Define a variable for the total intensity of ~A by using the Add Variable command on the Variable menu and selecting intensity."  
		  ?wave))))

;; based on net-work-contains
(defoperator net-intensity-contains (?sought)
  :preconditions 
  ((any-member ?sought  ((at (net-intensity ?b) ?t) 
	                 (at (power ?b ?agent) ?t)))
   ;; make sure we can determine all agents providing power
   (not (unknown-intensity-agents)))
  :effects 
  ((eqn-contains (net-intensity ?b ?t) ?sought)))

;;;  
;;;  Add up all intensities acting on ?b
;;;
;; based on apply-net-work
(defoperator write-net-intensity (?b ?t)
  :preconditions 
  (;; introduce net-intensity variable
   (variable ?net-intensity-var (at (net-intensity ?b) ?t))
   ;; introduce variables for power from each source. 
   ;; need to collect list of power *agents* to use in quantities.
   (setof (in-wm (power-source ?source ?b)) ?source ?sources)
   (map ?source ?sources
	(variable ?intensity-var (at (intensity ?b ?source) ?t))
	?intensity-var ?intensity-vars) 
   )
  :effects (
	    (eqn (= ?net-intensity-var (+ . ?intensity-vars)) 
		 (net-intensity ?b ?t))
	    )
  :hint (
	 (teach (string "The net power acting on ~A is the sum of the various individual powers." ?b))
	 (bottom-out (string "Write the equation ~A" ((= ?net-intensity-var (+ . ?intensity-vars)) algebra)))
	 ))
;;;
;;;  Intensity in decibels.
;;;
;;;

(def-qexp db-intensity (db-intensity ?wave ?agent)
  :units |dB|
  :english ("the intensity supplied to ~A due to ~A in decibels" 
	       (nlg ?wave) (nlg ?agent))
  :fromWorkbench (if (string-equal body2 '|all sources|)
                     `(at (net-db-intensity ,body) ,time)
                  `(at (db-intensity ,body ,body2) ,time)))

(defoperator define-db-intensity (?wave ?agent ?t)
  :preconditions
  ((bind ?dbi-var (format-sym "dbint_~A_~A_~A" 
			      (body-name ?wave) (body-name ?agent) 
			      (time-abbrev ?t))))
  :effects ((variable ?dbi-var (at (db-intensity ?wave ?agent) ?t))
	    (define-var (at (db-intensity ?wave ?agent) ?t)))
  :hint ((bottom-out 
	  (string "Define a variable for the intensity of ~A in decibels 
due to ~A by using the Add Variable command on the Variable menu and selecting decibel-intensity."  ?wave ?agent))))

;;;
;;;  net decibel intensity is not used anywhere
;;;

(def-qexp net-db-intensity (net-db-intensity ?wave)
  :units |dB|
  :english ("the total intensity supplied to ~A, in decibels" 
	       (nlg ?wave)))

(defoperator define-net-db-intensity (?wave ?t)
  :preconditions
  ((bind ?dbi-var (format-sym "dbint_~A_~A" 
			      (body-name ?wave) 
			      (time-abbrev ?t))))
  :effects ((variable ?net-dbi-var (at (net-db-intensity ?wave) ?t))
	    (define-var (at (net-db-intensity ?wave) ?t)))
  :hint ((bottom-out 
	  (string "Define a variable for the total intensity of ~A in decibels 
using the Add Variable command on the Variable menu and selecting decibel-intensity."  ?wave))))

;;;
;;;  Reference intensity, predefined constant
;;;
(def-qexp db-intensity-zero (db-intensity-zero)
  :units |W/m^2|
  :restrictions positive
  :english ("reference intensity for defining decibels"))

(defoperator iref-contains()
  :effects ( (eqn-contains (std-constant db-intensity-zero) (db-intensity-zero)) ))

(defoperator write-value-of-iref ()
  :preconditions 
    ( (variable ?iref-var (db-intensity-zero)) )
  :effects ( 
    (eqn (= ?iref-var (dnum 1.0E-12 |W/m^2|)) (std-constant db-intensity-zero))
   )
  :hint
  ((point (string "You can find the reference intensity Iref in your textbook."))
   (bottom-out (string "Write the equation ~A" 
		       ((= ?iref-var (dnum 1.0E-12 |W/m^2|)) algebra) ))
    ))

(defoperator define-iref ()
 :effects ( (variable |Iref| (db-intensity-zero)) ))

;;;
;;; Relate intensity to intensity in decibels
;;; 
(def-psmclass intensity-to-decibels (intensity-to-decibels ?wave ?t)
  :complexity major  ;must explicitly use
  :english ("express intensity in decibels")
  :ExpFormat ("Expressing the intensity in decibels")
  :EqnFormat ("I(db) = 10*log10(I/Iref)")) 


 (defoperator intensity-to-decibels-contains (?sought)
   :preconditions (
		   (time ?t)
		   (any-member ?sought ((at (intensity ?wave ?agent) ?t)
					(at (db-intensity ?wave ?agent) ?t))))
   :effects (
     (eqn-contains (intensity-to-decibels ?wave ?agent ?t) ?sought)))


(defoperator write-intensity-to-decibels (?wave ?agent ?t)
   :preconditions (
       (variable  ?int  (at (intensity ?wave ?agent) ?t))
       (variable  ?intdb  (at (db-intensity ?wave ?agent) ?t))
       (variable  ?intref  (db-intensity-zero))
   )
   :effects 
   ;; this is not the lisp (log ... 10)
   ((eqn  (= ?intdb (* 10 (log10 (/ ?int ?intref) )))
	  (intensity-to-decibels ?wave ?agent ?t)))
   :hint (
      (point (string "You can express intensity in decibels"))
      (bottom-out (string "Write the equation ~A" 
			  ((= ?intdb (* 10 (log10 (/ ?int ?intref) 
						))) algebra) ))
      ))

;;; 
;;; Relate intensity to net power output in a spherical geometry.  
;;;
(def-psmclass intensity-to-power (intensity-to-power ?wave ?source ?t)
  :complexity major  ;must explicitly use
  :english ("relate intensity to power in a spherical geometry")
  :ExpFormat ("Relatinve the intensity to power (spherical geometry)")
  :EqnFormat ("P = 4*$p*r^2")) 


(defoperator intensity-to-power-contains (?sought)
  :preconditions (
		  (spherical-emitting ?wave ?source) ;need spherical symmetry
		  (time ?t)
		  (any-member ?sought ((at (intensity ?wave ?source) ?t)
				       (at (net-power ?source) ?t)
				       (at (mag (relative-position ?wave ?source)) ?t)))
		  )
  :effects (
	    (eqn-contains (intensity-to-power ?wave ?source ?t) ?sought)))

(defoperator write-intensity-to-power (?wave ?source ?t)
  :preconditions (
		  (variable  ?int  (at (intensity ?wave ?source) ?t))
		  (variable  ?power  (at (net-power ?source) ?t))
		  (variable  ?r (at (mag (relative-position ?wave ?source)) ?t))
		  )
  :effects (
	    (eqn  (= ?power (* 4 $p ?r ?r ?int))
		  (intensity-to-power ?wave ?source ?t))
	    )
  :hint (
	 (point (string "If the power goes out in all directions, the intensity is the power divided by the area of the sphere."))
	 (teach (string "Imagine a sphere centered at the ~A of radius ~A; all of the power goes out through that sphere." ?source ?r))
	 (bottom-out (string "Write the equation ~A" 
			     ((= ?power (* 4 $p ?r ?r ?int)) algebra) ))
	 ))
