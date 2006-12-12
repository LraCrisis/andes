;;; script for regenerating all problem files
;;; grep minutes make-prbs.log | sort -g -k7
;;;  ls Problems/*.prb | sed "s/Problems\/\(.*\).prb/\1/"
;;; sbcl < make-prbs.cl >& make-prbs.log &
 (rkb)
 (defvar t0 (get-internal-run-time))
 (make-prbs '(
DR8A
DT10A
DT11A
DT11B
DT13B
DT14A
DT14B
DT4A
DT4B
DT5A
DT6A
DT6B
DT6C
DT7A
DT7B
DT8A
DT9A
E10A
E12A
E1A
E1B
E1C
E2A
E2B
E2C
E3A
E4A
E4BB
E4B
E4CC
E4C
E5AA
E5A
E5B
E6A
E7A
E7B
E8A
E8B
E9A
E9B
ELEC1A
ELEC2
ELEC6A
ELEC6B
EROT1
EROT2
EROT3
EROT4
FLUIDS11
FLUIDS12
FLUIDS13
FLUIDS14
FLUIDS15
FLUIDS1
FLUIDS2
FLUIDS3
FLUIDS4
FLUIDS5
FLUIDS6
FLUIDS7
FLUIDS8
FLUIDS9
KT10A
KT10C
KT11A
KT11B
KT12A
KT12B
KT12C
KT13A
KT13B
KT13C
KT9A
KT9B
LMOM5
MAG11
MAG1E
MAG4B
OSC5
OSC6
OSC7
OSC8
POW1B
POW2A
POW3A
POW5A
POW5B
POW5C
POW5D
POW6A
ROC2
ROC3
ROC4
ROC5
ROC6
ROTS1A
ROTS1B
ROTS2A
ROTS3A
ROTS4A
ROTS6A
ROTS6B
ROTS6C
ROTS7A
S10A
S11A
S11B
S12A
S1A
S1B
S1C
S1D
S1E
S1F
S2A
S2B
S2C
S2D
S2E
S3A
S3B
S3C
S4B
S5A
S6A
S7A
S8A
S9A
WE1A
WE1B
WE2B
WE3A
WE3B
WE4A
WE4B
WE5
WE6
))
;; time to do this is:
(format t "~F hours~%" (/ (- (get-internal-run-time) t0) 
			  (* 3600 internal-time-units-per-second)))
(quit)

