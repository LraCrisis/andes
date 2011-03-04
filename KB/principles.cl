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
;;;;
;;;;       list of PSMclasses grouped into catagories
;;;;   


(defparameter *principle-tree* 
  '(((:LABEL . "Kinematics")
     (:ITEMS
      
      ((:LABEL . "Translational")
       (:ITEMS 
	((:PSM . SDD))
	((:PSM . AVG-VELOCITY) (:BINDINGS (?AXIS . X)))
	((:PSM . AVG-VELOCITY) (:BINDINGS (?AXIS . Y)))
	((:PSM . LK-NO-S)
	 (:EQNFORMAT
	  "a(avg)<sub>~a</sub> = (vf<sub>~a</sub> - vi<sub>~a</sub>)/t"
	  (AXIS-NAME ?AXIS) (AXIS-NAME ?AXIS) (AXIS-NAME ?AXIS))
	 (:BINDINGS (?AXIS . X)))
	((:PSM . LK-NO-S)
	 (:EQNFORMAT
	  "a(avg)<sub>~a</sub> = (vf<sub>~a</sub> - vi<sub>~a</sub>)/t"
	  (AXIS-NAME ?AXIS) (AXIS-NAME ?AXIS) (AXIS-NAME ?AXIS))
	 (:BINDINGS (?AXIS . Y)))
	((:PSM . LK-NO-VF) (:BINDINGS (?AXIS . X)))
	((:PSM . LK-NO-VF) (:BINDINGS (?AXIS . Y)))
	((:PSM . LK-NO-S) (:BINDINGS (?AXIS . X)))
	((:PSM . LK-NO-S) (:BINDINGS (?AXIS . Y)))
	((:PSM . LK-NO-T) (:BINDINGS (?AXIS . X)))
	((:PSM . LK-NO-T) (:BINDINGS (?AXIS . Y)))
	((:PSM . SDD-CONSTVEL) (:BINDINGS (?AXIS . X)))
	((:PSM . SDD-CONSTVEL) (:BINDINGS (?AXIS . Y)))
	((:PSM . CONST-V) (:BINDINGS (?AXIS . X)))
	((:PSM . CONST-V) (:BINDINGS (?AXIS . Y)))
	((:PSM . CENTRIPETAL-ACCEL))
	((:PSM . CENTRIPETAL-ACCEL-COMPO) (:BINDINGS (?AXIS . X)))
	((:PSM . CENTRIPETAL-ACCEL-COMPO) (:BINDINGS (?AXIS . Y)))
	((:PSM . RELATIVE-VEL) (:BINDINGS (?AXIS . X)))
	((:PSM . RELATIVE-VEL) (:BINDINGS (?AXIS . Y)))
	((:PSM . NET-DISP) (:BINDINGS (?AXIS . X)))
	((:PSM . NET-DISP) (:BINDINGS (?AXIS . Y)))
	((:PSM . FREE-FALL-ACCEL))
	((:PSM . STD-CONSTANT-G))
	((:PSM . PERIOD-CIRCLE))))

      ((:LABEL . "Rotational")
       (:ITEMS 
	((:PSM . ANG-SDD))
	((:PSM . RK-NO-S))
	((:PSM . RK-NO-S)
	 (:EQNFORMAT . "&alpha;(avg)<sub>z</sub> = (&omega;f<sub>z</sub> - &omega;i<sub>z</sub>)/t"))
	((:PSM . RK-NO-VF))
	((:PSM . RK-NO-T))
	((:PSM . LINEAR-VEL))
	((:PSM . ROLLING-VEL))))))
 
   ((:LABEL . "Newton's Laws")
     (:ITEMS
      ((:LABEL . "Translational")
       (:ITEMS
	((:PSM . NSL) (:BINDINGS (?AXIS . X)))
	((:PSM . NSL) (:BINDINGS (?AXIS . Y)))
	((:PSM . NET-FORCE) (:BINDINGS (?AXIS . X)))
	((:PSM . NET-FORCE) (:BINDINGS (?AXIS . Y)))
	((:PSM . NTL))
	((:PSM . NTL-VECTOR) (:BINDINGS (?AXIS . X)))
	((:PSM . NTL-VECTOR) (:BINDINGS (?AXIS . Y)))
	((:PSM . UG))
	((:LABEL . "Force Laws")
	 (:ITEMS 
	  ((:PSM . WT-LAW))
	  ((:PSM . KINETIC-FRICTION))
	  ((:PSM . STATIC-FRICTION))
	  ((:PSM . SPRING-LAW))
	  ((:PSM . TENSIONS-EQUAL))
	  ((:PSM . THRUST-FORCE))
	  ((:PSM . THRUST-FORCE-VECTOR) (:BINDINGS (?AXIS . X)))
	  ((:PSM . THRUST-FORCE-VECTOR) (:BINDINGS (?AXIS . Y)))
	  ((:PSM . DRAG-FORCE-TURBULENT))))
	((:LABEL . "Compound Bodies")
	 (:ITEMS
	  ((:PSM . MASS-COMPOUND))
	  ((:PSM . VOLUME-COMPOUND))
	  ((:PSM . KINE-COMPOUND) (:BINDINGS (?VEC-TYPE . VELOCITY)))
	  ((:PSM . KINE-COMPOUND) (:BINDINGS (?VEC-TYPE . ACCELERATION)))
	  ((:PSM . FORCE-COMPOUND))))))
      ((:LABEL . "Rotational")
       (:ITEMS 
	((:PSM . NFL-ROT))
	((:PSM . NSL-ROT))
	((:PSM . MAG-TORQUE))
	((:PSM . TORQUE) (:BINDINGS (?XYZ . X)))
	((:PSM . TORQUE) (:BINDINGS (?XYZ . Y)))
	((:PSM . TORQUE) (:BINDINGS (?XYZ . Z)))
	((:PSM . NET-TORQUE-ZC))
	((:LABEL . "Moment of Inertia")
	 (:ITEMS 
	  ((:PSM . I-PARTICLE)) 
	  ((:PSM . PARALLEL-AXIS-THEOREM))
	  ((:PSM . I-DISK-CM))
	  ((:PSM . I-ROD-CM))
	  ((:PSM . I-ROD-END))
	  ((:PSM . I-HOOP-CM))
	  ((:PSM . I-RECT-CM))
	  ((:PSM . I-COMPOUND))))))))
    
    ((:LABEL . "Work Energy and Power")
     (:ITEMS 
      ((:PSM . WORK))
      ((:PSM . NET-WORK))
      ((:PSM . WORK-NC))
      ((:PSM . WORK-ENERGY))
      ((:PSM . MECHANICAL-ENERGY))
      ((:PSM . CHANGE-ME))
      ((:PSM . CONS-ENERGY))
      ((:PSM . POTENTIAL-ENERGY-DEFINITION))
      ((:PSM . KINETIC-ENERGY))
      ((:PSM . ROTATIONAL-ENERGY))
      ((:PSM . GRAV-ENERGY))
      ((:PSM . GRAVITATIONAL-ENERGY-POINT))
      ((:PSM . HEIGHT-DY))
      ((:PSM . SPRING-ENERGY))
      ((:PSM . ELECTRIC-ENERGY))
      ((:PSM . POWER))
      ((:PSM . NET-POWER))
      ((:PSM . INST-POWER))
      ((:PSM . SPHERICAL-INTENSITY-TO-POWER))
      ((:PSM . UNIFORM-INTENSITY-TO-POWER))
      ((:PSM . NET-INTENSITY))
      ((:PSM . INTENSITY-TO-DECIBELS))
      ((:PSM . INTENSITY-TO-DECIBELS)
       (:EQNFORMAT . "I = Iref 10<sup>&beta;/10</sup>"))
      ((:PSM . INTENSITY-TO-POYNTING-VECTOR-MAGNITUDE))))
    
    ((:LABEL . "Momentum and Impulse")
     (:ITEMS
      ((:LABEL . "Translational")
       (:ITEMS
	((:PSM . MOMENTUM-COMPO) (:BINDINGS (?AXIS . X)))
	((:PSM . MOMENTUM-COMPO) (:BINDINGS (?AXIS . Y)))
	((:PSM . CONS-LINMOM) (:BINDINGS (?AXIS . X)))
	((:PSM . CONS-LINMOM) (:BINDINGS (?AXIS . Y)))
	((:PSM . CONS-KE-ELASTIC))
	((:PSM . IMPULSE-FORCE) (:BINDINGS (?AXIS . X)))
	((:PSM . IMPULSE-FORCE) (:BINDINGS (?AXIS . Y)))
	((:PSM . IMPULSE-MOMENTUM) (:BINDINGS (?AXIS . X)))
	((:PSM . IMPULSE-MOMENTUM) (:BINDINGS (?AXIS . Y)))
	((:PSM . NTL-IMPULSE))
	((:PSM . NTL-IMPULSE-VECTOR) (:BINDINGS (?AXIS . X)))
	((:PSM . NTL-IMPULSE-VECTOR) (:BINDINGS (?AXIS . Y)))
	((:PSM . CENTER-OF-MASS-COMPO) (:BINDINGS (?AXIS . X)))
	((:PSM . CENTER-OF-MASS-COMPO) (:BINDINGS (?AXIS . Y)))))
      ((:LABEL . "Rotational")
       (:ITEMS
	((:PSM . ANG-MOMENTUM))
	((:PSM . CONS-ANGMOM))))))

    ((:LABEL . "Fluids")
     (:ITEMS 
      ((:PSM . PRESSURE-HEIGHT-FLUID))
      ((:PSM . BERNOULLI))
      ((:PSM . EQUATION-OF-CONTINUITY))
      ((:PSM . PRESSURE-FORCE))
      ((:PSM . DENSITY))
      ((:PSM . ARCHIMEDES))
      ((:PSM . PRESSURE-AT-OPEN-TO-ATMOSPHERE))
      ((:PSM . STD-CONSTANT-PR0) (:BINDINGS . 0))))

    ((:LABEL . "Electricity and Magnetism")
     (:ITEMS 
      ((:PSM . CHARGED-PARTICLES)) 
      ((:PSM . COULOMB))
      ((:PSM . COULOMB-COMPO) (:BINDINGS (?AXIS . X)))
      ((:PSM . COULOMB-COMPO) (:BINDINGS (?AXIS . Y)))
      ((:PSM . CHARGE-FORCE-EFIELD-MAG))
      ((:PSM . CHARGE-FORCE-EFIELD) (:BINDINGS (?AXIS . X)))
      ((:PSM . CHARGE-FORCE-EFIELD) (:BINDINGS (?AXIS . Y)))
      ((:PSM . POINT-CHARGE-EFIELD-MAG))
      ((:PSM . POINT-CHARGE-EFIELD) (:BINDINGS (?AXIS . X)))
      ((:PSM . POINT-CHARGE-EFIELD) (:BINDINGS (?AXIS . Y)))
      ((:PSM . NET-FIELD-ELECTRIC) (:BINDINGS (?AXIS . X)))
      ((:PSM . NET-FIELD-ELECTRIC) (:BINDINGS (?AXIS . Y)))
      ((:PSM . ELECTRIC-FLUX-CONSTANT-FIELD))
      ((:PSM . ELECTRIC-FLUX-CONSTANT-FIELD-CHANGE)) 
      ((:PSM . SUM-FLUXES))
      ((:PSM . POINT-CHARGE-POTENTIAL))
      ((:PSM . NET-POTENTIAL))
      ((:PSM . ELECTRIC-ENERGY))
      ((:PSM . GAUSS-LAW))
      ((:PSM . ELECTRIC-DIPOLE-MOMENT-MAG))
      ((:PSM . ELECTRIC-DIPOLE-MOMENT) (:BINDINGS (?AXIS . X)))
      ((:PSM . ELECTRIC-DIPOLE-MOMENT) (:BINDINGS (?AXIS . Y)))
      ((:PSM . ELECTRIC-DIPOLE-TORQUE-MAG))
      ((:PSM . ELECTRIC-DIPOLE-TORQUE) (:BINDINGS (?AXIS . Z)))
      ((:PSM . ELECTRIC-DIPOLE-ENERGY))
      ((:PSM . CHARGE-FORCE-BFIELD-MAG))
      ((:PSM . CHARGE-FORCE-BFIELD) (:BINDINGS (?AXIS . X)))
      ((:PSM . CHARGE-FORCE-BFIELD) (:BINDINGS (?AXIS . Y)))
      ((:PSM . CHARGE-FORCE-BFIELD) (:BINDINGS (?AXIS . Z)))
      ((:PSM . CURRENT-FORCE-BFIELD-MAG))
      ((:PSM . BIOT-SAVERT-POINT-PARTICLE-MAG))
      ((:PSM . BIOT-SAVERT-POINT-PARTICLE) (:BINDINGS (?AXIS . X)))
      ((:PSM . BIOT-SAVERT-POINT-PARTICLE) (:BINDINGS (?AXIS . Y)))
      ((:PSM . BIOT-SAVERT-POINT-PARTICLE) (:BINDINGS (?AXIS . Z)))
      ((:PSM . STRAIGHT-WIRE-BFIELD)) 
      ((:PSM . CENTER-COIL-BFIELD))
      ((:PSM . INSIDE-SOLENOID-BFIELD))
      ((:PSM . NET-FIELD-MAGNETIC) (:BINDINGS (?AXIS . X)))
      ((:PSM . NET-FIELD-MAGNETIC) (:BINDINGS (?AXIS . Y)))
      ((:PSM . NET-FIELD-MAGNETIC) (:BINDINGS (?AXIS . Z)))
      ((:PSM . MAGNETIC-FLUX-CONSTANT-FIELD))
      ((:PSM . MAGNETIC-FLUX-CONSTANT-FIELD-CHANGE)) 
      ((:PSM . FARADAYS-LAW))
      ((:PSM . AMPERES-LAW))
      ((:PSM . MAGNETIC-DIPOLE-MOMENT-MAG))
      ((:PSM . MAGNETIC-DIPOLE-MOMENT) (:BINDINGS (?AXIS . X)))
      ((:PSM . MAGNETIC-DIPOLE-MOMENT) (:BINDINGS (?AXIS . Y)))
      ((:PSM . MAGNETIC-DIPOLE-MOMENT) (:BINDINGS (?AXIS . Z)))
      ((:PSM . MAGNETIC-DIPOLE-TORQUE-MAG))
      ((:PSM . MAGNETIC-DIPOLE-TORQUE) (:BINDINGS (?AXIS . X)))
      ((:PSM . MAGNETIC-DIPOLE-TORQUE) (:BINDINGS (?AXIS . Y)))
      ((:PSM . MAGNETIC-DIPOLE-TORQUE) (:BINDINGS (?AXIS . Z)))
      ((:PSM . MAGNETIC-DIPOLE-ENERGY))
      ((:PSM . ELECTROMAGNETIC-WAVE-FIELD-AMPLITUDE))))

    ((:LABEL . "Circuits")
     (:ITEMS 
      ((:PSM . LOOP-RULE))
      ((:PSM . JUNCTION-RULE))
      ((:PSM . ELECTRIC-POWER))
      ((:LABEL . "Resistance")
       (:ITEMS
	((:PSM . EQUIV-RESISTANCE-SERIES))
	((:PSM . EQUIV-RESISTANCE-PARALLEL))
	((:PSM . OHMS-LAW))))
      ((:LABEL . "Capacitance")
       (:ITEMS 
	((:PSM . CAPACITANCE-DEFINITION))
	((:PSM . EQUIV-CAPACITANCE-PARALLEL))
	((:PSM . EQUIV-CAPACITANCE-SERIES))
	((:PSM . CHARGE-SAME-CAPS-IN-BRANCH))
	((:PSM . JUNCTION-RULE-CAP))
	((:PSM . CAP-ENERGY))
	((:PSM . RC-TIME-CONSTANT))
	((:PSM . CHARGING-CAPACITOR-AT-TIME))
	((:PSM . DISCHARGING-CAPACITOR-AT-TIME))
	((:PSM . CURRENT-IN-RC-AT-TIME))
	((:PSM . CHARGE-CAPACITOR-PERCENT-MAX))))
      ((:LABEL . "Inductance")
       (:ITEMS 
	((:PSM . INDUCTOR-EMF))
	((:PSM . MUTUAL-INDUCTOR-EMF))
	((:PSM . INDUCTOR-ENERGY))
	((:PSM . SOLENOID-SELF-INDUCTANCE))
	((:PSM . LR-TIME-CONSTANT))
	((:PSM . LR-CURRENT-GROWTH))
	((:PSM . LR-GROWTH-IMAX))
	((:PSM . LR-CURRENT-DECAY))
	((:PSM . LR-DECAY-IMAX))
	((:PSM . LC-ANGULAR-FREQUENCY))
	((:PSM . RLC-TIME-CONSTANT))
	((:PSM . RLC-ANGULAR-FREQUENCY))
	((:PSM . TRANSFORMER-VOLTAGE)) 
	((:PSM . TRANSFORMER-POWER))))))

    ((:LABEL . "Optics")
     (:ITEMS 
      ((:PSM . LENS-EQN))
      ((:PSM . MAGNIFICATION-EQN))
      ((:PSM . FOCAL-LENGTH-MIRROR))
      ((:PSM . LENS-COMBO))
      ((:PSM . COMBO-MAGNIFICATION))
      ((:PSM . COMPOUND-FOCAL-LENGTH))
      ((:PSM . WAVE-SPEED-REFRACTION)) 
      ((:PSM . REFRACTION-VACUUM))
      ((:PSM . SNELLS-LAW)) 
      ((:PSM . TOTAL-INTERNAL-REFLECTION))
      ((:PSM . BREWSTERS-LAW))
      ((:PSM . POLARIZER-INTENSITY) (:BINDINGS (?FRACTION . 1)))
      ((:PSM . POLARIZER-INTENSITY) (:BINDINGS (?FRACTION . 0)))
      ((:PSM . SLIT-INTERFERENCE)) 
      ((:PSM . FRAUENHOFER-DIFFRACTION))
      ((:PSM . RESOLUTION-CIRCULAR-APERTURE)) 
      ((:PSM . RADIATION-PRESSURE))))

    ((:LABEL . "Waves and Oscillations")
     (:ITEMS 
      ((:PSM . WAVENUMBER-LAMBDA-WAVE)) 
      ((:PSM . FREQUENCY-OF-WAVE))
      ((:PSM . PERIOD-OF-WAVE)) 
      ((:PSM . SPEED-OF-WAVE))
      ((:PSM . SPEED-EQUALS-WAVE-SPEED)) 
      ((:PSM . WAVE-SPEED-STRING))
      ((:PSM . MAX-TRANSVERSE-SPEED-WAVE))
      ((:PSM . MAX-TRANSVERSE-ABS-ACCELERATION-WAVE))
      ((:PSM . SPRING-MASS-OSCILLATION)) 
      ((:PSM . PENDULUM-OSCILLATION))
      ((:PSM . DOPPLER-FREQUENCY)) 
      ((:PSM . HARMONIC-OF))
      ((:PSM . BEAT-FREQUENCY)) 
      ((:PSM . ENERGY-DECAY))
      ((:PSM . WAVE-SPEED-LIGHT))))

 ((:LABEL . "Vectors and geometry")
  (:ITEMS
   ((:PSM . PROJECTION) (:BINDINGS (?AXIS . X)))
   ((:PSM . PROJECTION) (:BINDINGS (?AXIS . Y)))
   ((:PSM . PYTH-THM))
   ((:PSM . VECTOR-MAGNITUDE))
   ((:PSM . UNIT-VECTOR-MAG))
   ((:PSM . COMPLIMENTARY-ANGLES)) 
   ((:PSM . SUPPLEMENTARY-ANGLES))
   ((:PSM . RIGHT-TRIANGLE-TANGENT))
   ((:PSM . AREA-OF-RECTANGLE))
   ((:PSM . AREA-OF-RECTANGLE-CHANGE)) 
   ((:PSM . AREA-OF-CIRCLE))
   ((:PSM . CIRCUMFERENCE-OF-CIRCLE-R)) 
   ((:PSM . CIRCUMFERENCE-OF-CIRCLE-D))
   ((:PSM . VOLUME-OF-CYLINDER))))

 ((:LABEL . "Connect Quantities")
  (:ITEMS 
   ((:PSM . EQUALS)) 
   ((:PSM . ANGLE-DIRECTION))
   ((:PSM . DISPLACEMENT-DISTANCE)) 
   ((:PSM . CURRENT-THRU-WHAT))
   ((:PSM . NUM-FORCES)) 
   ((:PSM . GIVEN-FRACTION))
   ((:PSM . OPPOSITE-RELATIVE-POSITION))
   ((:PSM . RELATIVE-POSITION-DISPLACEMENT) (:BINDINGS (?AXIS . X)))
   ((:PSM . RELATIVE-POSITION-DISPLACEMENT) (:BINDINGS (?AXIS . Y)))
   ((:PSM . SUM-TIMES)) 
   ((:PSM . SUM-DISTANCES))
   ((:PSM . SUM-DISTANCE))
   ((:PSM . CONNECTED-ACCELS))
   ((:PSM . CONNECTED-VELOCITIES))
   ((:PSM . TENSIONS-EQUAL))
   ((:PSM . RDIFF) (:BINDINGS (?AXIS . X)))
   ((:PSM . RDIFF) (:BINDINGS (?AXIS . Y))) 
   ((:PSM . MASS-PER-LENGTH-EQN))
   ((:PSM . TURNS-PER-LENGTH-DEFINITION)) 
   ((:PSM . AVERAGE-RATE-OF-CHANGE))))))
  
;;; 
;;;            List of Andes distribution homework sets
;;;
;; This list was generated by applying the following perl script
;; to problems/*.aps & problems/index.html.
;; Remove videos *.wmv by hand and supplemental sets by hand.
;;
;; cd problems; perl -w -n -e 'if(m/"(.*?\.aps)">(.*?)</){open F,"< $1" or next;my @y=<F>;close F;shift @y;chomp(@y);print "(\"$2\" (@y))\n";}' index.html
;;
(defparameter *sets* '(("Vectors" (vec1ay vec1a vec1b vec1c vec1d vec1e vec1f vec2a vec2b vec2c vec2d vec2e vec2f vec3a vec3b vec3c vec3d vec4a vec4b vec4c vec4d vec5a vec5b vec5c vec5d vec6a vec6b vec6c vec6d vec7a vec8a vec8b vec8c vec9 relvel1a relvel2a relvel3a mot1 mot2 mot3 mot4 vec20 vec21))
("Kinematics Graphs" (kgraph1 kgraph2 kgraph3 kgraph4 kgraph5 kgraph5b kgraph5c kgraph5d kgraph5e kgraph5f kgraph6 kgraph7 kgraph8 kgraph8b kgraph8c kgraph8d kgraph8e kgraph8f kgraph8g kgraph9 kgraph9b kgraph10 kgraph10b kgraph11 kgraph12 kgraph13 kgraph14 kgraph16 kgraph17 kgraph18 kgraph19 kgraph20 kgraph21 kgraph22 kgraph30 kgraph31))
("Translational Kinematics" (kt1a kt1b kt2a kt2b kt3a kt3b kt4a kt4b kt4c kt5a kt6a kt6b kt7a kt7b kt8a kt8b kt9a kt9b kt9c kt10a kt10c kt11a kt11b kt11c kt12a kt12b kt12c kt13a kt13b kt13c kt13d kt14a kt14b kt20 kt21))
("Free Body Diagrams" (fbd1a fbd1b fbd2a fbd3a fbd4a fbd5a fbd6a fbd8 fbd9 fbd10 fbd11 fbd12 fbd13 fbd14 fbd15 fbd16))
("Statics" (s1a s1b s1c s1d s1e s1f s2a s2b s2c s2d s2e s3a s3b s3c s4a s4b s5a s6a s7a s7b s8a s9a s10a s11a s11b s12a s13 s14 s15 s16 s17 s18 s19))
("Translational Dynamics" (dq1 dt1a dt1b dt1c dt2a dt3a dt3b dt3c dt4a dt4b dt5a dt6a dt6b dt6c dt7a dt7b dt8a dt9a dt9b dt10a dt11a dt11b dt12a dt13a dt13b dt14a dt14b dt16 dt17 dt18 dt19 dt20 dt21 dt22 dt23 dt24))
("Circular Motion" (rots1a rots1b rots1c rots2a rots3a rots4a rots5a rots6a rots6b rots6c rots7a rots8a rots8b rots20 rots21 rots22 rots23 rots24))
("Work and Energy" (weq1 weq2 weq4 weq5 e1a e1b e1c e2a e2b e2c e3a e3b e3c e3d e4a e4b e4c e5a e5b e6a e7a e7b e8a e8b e9a e9b e10a e11a we1a we2a we3a we4a we5 we6 we8 we9 we10 egrav1 egrav2 egrav3 egrav4 egrav5 we20 we21 we22))
("Power" (pow1a pow1b pow2a pow3a pow4a pow4b pow5a pow5b pow5c pow5d pow6a pow10 pow11 pow12 pow13 pow14))
("Linear Momentum" (mom1 mom2 mom3 lmom1a lmom1b lmom2a lmom2b lmom3a lmom3b lmom3c lmom4a lmom5 lmom5b lmom5c lmom6 lmom7 lmom8 lmom9 lmom10 lmom11 pgraph1 pgraph2 pgraph3 imp1 imp2 imp3a imp3b imp3c imp4 cm1 cm2 cm3 roc1 roc2 roc3 roc4 roc5 roc6 lmom20 lmom21 lmom22 lmom23 lmom24))
("Rotational Kinematics" (kr8 kr9 kr1a kr1b kr1c kr2a kr2b kr3a kr3b kr3c kr4a kr4b kr5a kr6a kr7a kr10 kr20 kr21  ))
("Angular Momentum" (momr1a momr1b momr2a momr2b momr3a momr4a momr10 momr11 momr12 momr13 momr14))
("Rotational Dynamics" (dr1a dr2a dr2b dr3a dr4a dr5a dr6a dr6b dr7a dr8a dr20 dr21 erot2 erot3 erot4 erot5 erot6 grav1 grav2 grav3 grav4 grav5 grav6))
("Fluids" (fluids1 fluids2 fluids3 fluids4 fluids5 fluids6 fluids7 fluids8 fluids9 fluids11 fluids12 fluids13 fluids14 fluids15 fluids20 fluids21 fluids22 fluids23 fluids24))
("Oscillations" (osc1 osc2 osc3 osc4 osc5 osc6 osc7 osc8 osc10 osc11 osc12 osc13 osc14))
("Waves" (wave1 wave2 wave3 wave4 wave5 wave6 wave8 wave9 wave10 wave11 wave12 wave13 wave14 wave15 wave16 wave17 wave18 wave24 wave30 wave31))
("Electric Field" (charge1a charge1b charge2 coul1a coul1b coul1c coul2a coul2b coul2c coul3 ediag1 ediag2 ediag3 ediag4 efield1a efield1b efield1c efield1d efield1e efield2 efield3 efield4a efield4b efield5 efield6 for1a for1b for1c for2a for2b for4a for4b for4c for5 for7a for7b for8a for8b for9a for9b for10a for10b for11a for11b for11c elec1a elec1b elec1d elec1e elec2 elec3b elec4b elec5b elec6b elec7 elec8 elec9 elec10 elec11 gauss1 gauss3 gauss4 gauss5 gauss6 gauss8 gauss9 gauss10 gauss11 gauss12 gauss13 dip1a dip1b dip2 dip3))
("Electric Potential" (epot1a epot1b epot1c epot2 epot3 epot4 epot5 epot6 epot7 epot8 pot1a pot1b pot2a pot2b pot2c pot3a pot3b pot4 pot5 pot6 pot7 pot8 pot10 pot11))
("Resistance" (eqres1a eqres1b eqres1c eqres1d eqres1e eqres2a eqres2b eqres3a eqres3b eqres4a eqres4b eqres5a eqres6a eqres7a eqres7b eqres8a eqres8b res10 res11 res12 res13 res14))
("Capacitance" (eqcap1a eqcap1b eqcap1c eqcap1d eqcap2a eqcap2b eqcap3a eqcap3b eqcap4a eqcap4b eqcap5a eqcap6a cap1a cap1b cap2a cap2b cap3a cap4a cap5a cap6a cap6b cap9a cap9b cap20 cap21 cap22 cap23 cap24 cap25))
("DC Circuits" (kir1a kir1b kir1c kir1d kir1e kir1f kir2a kir3a kir3b kir3c kir4a kir5a kir7a epow1 epow2 epow3 epow4 rc1a rc1b rc1c rc2a rc3a rc3b rc4a rc4b rc5a rc6a rc7a rc7b rc8 rc9 circuits1 circuits2 circuits3 circuits4 circuits5))
("Magnetic Field" (mag1a mag1b mag1c mag2a mag2b mag3a mag3b mag4a mag5a mag5b mag5c mag5d mag5e mag5f magtor1a magtor1b magtor1c magtor1d magdip1 magdip2 magdip3 magdip4 mag6a mag6b mag6c mag7 mag8a mag8b mag9 mag10 mag11 mag12 mag20 mag21 mag22 mag23 mag24))
("Electromagnetic Induction" (fara1a fara1b fara2a fara2b fara3a fara3b fara4a fara4b fara5a fara5b fara5c fara6a fara6b fara7a fara7b fara7c fara7d fara8a fara8b fara8c fara9 fara10a fara10b fara11a fara11b amp1 induct1 induct2 induct3 induct4 induct5))
("Inductance" (ind1a ind1b ind1c ind2a ind3a ind3b ind3c ind4 LR1a LR1b LR1c LR1d LR2a LR2b LR3a LR3b LC1a LC2a LC2b LRC1a LRC2a ind10 ind11 ind12 ind13 ind14))
("Electromagnetic Waves" (emwave1 wave19 emwave3a emwave4 emwave5 emwave10 emwave11 emwave12 emwave13 emwave14))
("Optics" (mirror1 mirror2 mirror3 mirror4 lens1a lens1b lens2a lens2b lens3a lens3b lens4a lens4b lens5a lens5b ref1 ref2a ref2b ref2c ref3a ref3b ref4a ref4b ref5a ref5b ref6 int1a int1b int1c int1d int2a int2b opt10 opt11 opt12 opt13 opt14))))

;;
;; Median completion times gotten from running LogProcessing/onelog.pl
;; over USNA from Fall 2005 to Spring 2008
;; 
(defparameter *times-scores* '( 
(amp1 236 92) (cap1a 584 64) (cap1b 328.5 89.5) (cap2a 380 78) (cap2b 202 94) 
(cap3a 506.5 68) (cap4a 526 65.5) (cap5a 593 78.5) (cap6a 222 98)
(cap6b 145 99) (cap9a 29 94)
(cap9b 21.5 92) (charge1a 658 75)
(charge1b 198 86) (charge2 31 100)
(cm1 640.5 57.5) (cm2 526.5 56.5)
(cm3 512 74)
(coul1a 643.5 77)
(coul1b 524 82)
(coul1c 514 57)
(coul2a 1379.5 39)
(coul2b 1204.5 73.5)
(coul2c 469 45.5)
(coul3 1077 43)
(dip1a 947.5 60)
(dip1b 954 43.5)
(dq1 32 95)
(dr1a 120 95)
(dr2a 663 75.5)
(dr2b 491.5 83)
(dr3a 789 83)
(dr4a 714 78)
(dr5a 945 61)
(dr6a 417.5 81.5)
(dr6b 342 81)
(dr7a 1093.5 38)
(dr8a 813.5 72)
(dt10a 2496 37)
(dt11a 1668 53)
(dt11b 1525.5 33)
(dt12a 595 77)
(dt13a 338 85)
(dt13b 496.5 87.5)
(dt14a 242 94.5)
(dt14b 302 93)
(dt1a 572 72)
(dt1b 372 76)
(dt1c 534 78)
(dt2a 419 94)
(dt3a 418 88)
(dt3b 428.5 54)
(dt4a 564.5 84.5)
(dt4b 418 91)
(dt5a 466 82)
(dt6a 1260.5 58)
(dt6c 1468 93)
(dt7a 285 99)
(dt7b 540.5 92)
(dt7bplan 218 100)
(dt8a 299.5 64.5)
(dt9a 719 83)
(e10a 507 89)
(e11a 510 92)
(e1a 238 98)
(e1b 292 96)
(e1c 271 96)
(e2a 489 88)
(e2b 327 98)
(e2c 750 95)
(e3a 292 97)
(e4a 673 77)
(e4b 379 95)
(e4c 263.5 84.5)
(e5a 304 94)
(e5b 236 100)
(e6a 238 99)
(e7a 647 88)
(e7aplan 313 100)
(e7b 327 91)
(e8a 828.5 79.5)
(e8b 671.5 87)
(e9a 636.5 87.5)
(e9b 733 84)
(efield1a 239.5 94)
(efield1b 125 98)
(efield1c 181 92)
(efield1d 182 93)
(efield1e 256 86)
(efield2 36 100)
(efield3 41 96)
(efield4a 151 95)
(efield4b 124 94)
(elec1a 612 82.5)
(elec1b 158.5 42.5)
(elec2 369 30)
(elec3b 901 59)
(elec4b 485.5 89)
(elec5b 439 88)
(elec6b 1086.5 39)
(emwave1 162 93)
(emwave2a 306.5 84.5)
(emwave3a 330.5 83.5)
(emwave4 306 84)
(emwave5 351 75)
(epot1a 59.5 94)
(epot1b 37 92)
(epot1c 50 90)
(epot2 27 94)
(epow1 243 83)
(epow2 293 88)
(epow3 382 82)
(epow4 368 89)
(eqcap1a 182 90)
(eqcap1b 67 98)
(eqcap1c 161 96)
(eqcap1d 114.5 87)
(eqcap2a 130 60.5)
(eqcap2b 134.5 87.5)
(eqcap3a 162.5 98)
(eqcap3b 83 69)
(eqcap4a 209 92)
(eqcap4b 131 70)
(eqcap5a 171 95)
(eqcap6a 300 95)
(eqres1a 143 95)
(eqres1b 78 100)
(eqres1c 95 99)
(eqres1d 143 71)
(eqres1e 122 100)
(eqres2a 78 90)
(eqres2b 102 75)
(eqres3a 89.5 70)
(eqres3b 68 59)
(eqres4a 86 80)
(eqres4b 174.5 66.5)
(eqres5a 149.5 99)
(eqres6a 440 81)
(eqres7a 54 93)
(eqres7b 26.5 97)
(eqres8a 35 94)
(eqres8b 31 93)
(erot2 572 83)
(erot3 1366.5 89.5)
(erot4 46 89)
(fara10a 239 98)
(fara10b 188.5 99)
(fara11a 667 49)
(fara11b 433 71.5)
(fara1a 78.5 93)
(fara1b 34 97)
(fara2a 28 97)
(fara2b 24 97)
(fara3a 38 94)
(fara3b 21.5 97)
(fara4a 23 97)
(fara4b 18 97)
(fara5a 44 94)
(fara5b 26 97)
(fara5c 24 94)
(fara6a 44.5 94)
(fara6b 26 94)
(fara7a 40 93)
(fara7b 19 96)
(fara7c 19 96)
(fara7d 17.5 96)
(fara8a 44.5 96)
(fara8b 29 92)
(fara8c 23 96)
(fara9 721 48)
(fbd1a 371 79)
(fbd1b 132.5 94)
(fbd2a 180 93)
(fbd3a 155 95)
(fbd4a 157.5 86.5)
(fbd5a 116.5 97)
(fbd6a 269 88)
(fbd8 73 100)
(fbd9 99 83)
(fluids1 432 89)
(fluids11 438.5 84)
(fluids12 290 94)
(fluids13 637 85)
(fluids14 616.5 75)
(fluids15 493 69)
(fluids2 418.5 93)
(fluids3 243 99)
(fluids4 191 98)
(fluids5 501 88)
(fluids6 416.5 95.5)
(fluids7 750 58.5)
(fluids8 907.5 49.5)
(fluids9 618 78)
(for1 382.5 99)
(for10 485 92.5)
(for10a 506 63)
(for10b 706 78)
(for11a 1063.5 48.5)
(for11b 853 58)
(for11c 669 69)
(for1a 547 92.5)
(for1b 283.5 78.5)
(for1c 797 85)
(for2 143 99)
(for2a 213 92)
(for2b 193 99)
(for4 277.5 99)
(for4a 284 92)
(for4b 289 97)
(for5 223 91)
(for7 400 96)
(for7a 319.5 48.5)
(for7b 205 96)
(for8 370 97.5)
(for8a 578 65)
(for8b 412 90)
(for9 759.5 88.5)
(for9a 884 76)
(for9b 1076 82)
(gauss1 59 94)
(gauss10 602 78)
(gauss11 978 56)
(gauss3 578 53)
(gauss4 42 96)
(gauss5 241 83)
(gauss6 552 96)
(gauss8 617 53.5)
(gauss9 856 80)
(imp1 578 77)
(imp2 525 79)
(imp3a 490 94)
(imp3b 362 76)
(imp3c 447.5 90.5)
(ind1a 188 94)
(ind1b 104 98)
(ind1c 110 99)
(ind2a 77 98)
(ind3a 416 90)
(ind3b 321 90.5)
(ind3c 167 97)
(ind4 419 79)
(int1a 657 62)
(int1b 307 89)
(int1c 171 94)
(int1d 51 95)
(int2a 356.5 84)
(int2b 127 96)
(kgraph1 73 100)
(kgraph10 264 42)
(kgraph11 26 91)
(kgraph12 318 42)
(kgraph13 35 94)
(kgraph14 98 97)
(kgraph16 303 35)
(kgraph17 153 66)
(kgraph18 17 50)
(kgraph19 33 20)
(kgraph2 37 100)
(kgraph21 523 44)
(kgraph3 51 97)
(kgraph4 48 97)
(kgraph5 39 100)
(kgraph6 49 97)
(kgraph7 29.5 100)
(kgraph8 37 92)
(kgraph9 260 84)
(kir1a 225 97)
(kir1b 60 91)
(kir2a 498 74)
(kir3a 169 90)
(kir3b 121 44)
(kir3c 27 19)
(kir4a 336.5 86.5)
(kir5a 698 85.5)
(kir7a 432 72.5)
(kr1a 323 83)
(kr1b 186 88)
(kr2a 258 89)
(kr2b 261 85)
(kr3a 289 84)
(kr3b 412.5 88.5)
(kr4a 502 83)
(kr5a 407 83)
(kr6a 586.5 75.5)
(kr7a 281 90)
(kt10a 863 82)
(kt10c 529 93)
(kt11a 504 98)
(kt11b 634 89)
(kt12a 646 92)
(kt12b 464 39)
(kt12c 1000 59)
(kt13a 469.5 50.5)
(kt13b 526.5 53.5)
(kt13c 793 83)
(kt14a 396 79)
(kt14b 1194 38)
(kt1a 261 97)
(kt1b 176 98.5)
(kt2a 829 75)
(kt2b 1010 4)
(kt3a 1148 83)
(kt3b 753.5 85)
(kt4a 348 93)
(kt4b 1171 66)
(kt5a 781 80)
(kt6a 307 95)
(kt6b 565 93)
(kt7a 1327 75)
(kt7b 63 29)
(kt8a 981 68)
(kt8b 742 67)
(kt9a 827 85)
(kt9b 524 93)
(lc1a 400 84)
(lc2a 242 88)
(lc2b 145 97)
(lens1a 98 98)
(lens1b 88 98)
(lens2a 99.5 99)
(lens2b 123 98)
(lens3a 416 89)
(lens3b 282.5 96)
(lens4a 255.5 89)
(lens4b 194 83)
(lens5a 502 73)
(lens5b 280 91)
(lmom1a 457 69)
(lmom1b 378 94)
(lmom2a 502 80)
(lmom2b 1090 74)
(lmom3a 1397 68)
(lmom4a 828 86)
(lmom4aplan 60 100)
(lmom5 1277 57)
(lmom6 1379 67)
(lmom7 1032 64)
(lr1a 385 77)
(lr1b 280 73)
(lr1c 561.5 72)
(lr1d 237.5 79.5)
(lr2a 270.5 84.5)
(lr2b 138 59)
(lr3a 361 74)
(lr3b 400 72)
(lrc1a 470 81)
(lrc2a 629 69)
(mag10 1199 59)
(mag11 589.5 57.5)
(mag12 464 69)
(mag1a 547.5 77)
(mag1b 222 94)
(mag1c 513 83)
(mag2a 364 83)
(mag2b 237 92)
(mag3a 587 89)
(mag3b 552 87)
(mag4a 564.5 61.5)
(mag5a 519 73)
(mag5b 300.5 83)
(mag6a 370 93)
(mag6b 200 86)
(mag6c 128 92)
(mag7 406 71)
(mag8a 241 88.5)
(mag8b 198 93)
(mag9 1155 69)
(magdip1 492 79.5)
(magdip2 649 69)
(magdip3 381 92)
(magdip4 722 61)
(magtor1a 176 87)
(magtor1b 60 100)
(magtor1c 63 94)
(magtor1d 49 95)
(mirror1 167.5 92)
(mirror2 210.5 94)
(mirror3 146 92)
(mirror4 150.5 97)
(momr1a 349 86)
(momr1b 215.5 83)
(momr2a 279 92)
(momr2b 226 93)
(momr3a 360 76)
(momr4a 551.5 75)
(mot1 76 92)
(mot2 33 100)
(mot3 31 100)
(mot4 1027 92)
(osc1 276.5 79)
(osc2 201 97)
(osc3 166 97)
(osc4 669.5 51)
(osc5 408 81)
(osc6 156.5 98)
(osc7 235.5 96.5)
(osc8 256 98)
(pgraph1 66 92)
(pgraph2 25.5 93)
(pgraph3 24 92)
(posttest 1728 100)
(pot1a 579 78)
(pot1b 589.5 89.5)
(pot2a 786 79)
(pot2b 471.5 77.5)
(pot2c 689 71.5)
(pot3a 683 76.5)
(pot3b 624.5 80)
(pot4 613 83)
(pot5 550 64)
(pot6 428.5 77.5)
(pot7 523.5 54)
(pot8 277 78)
(pow1a 373 94)
(pow1b 372.5 92)
(pow2a 368 84)
(pow3a 477 82)
(pow4a 869 68)
(pow4b 930 73)
(pow5a 1205.5 57)
(pow5aplan 279.5 100)
(pow5b 695 79)
(pow5c 493 96.5)
(pow5d 723.5 83)
(pow6a 1032 63)
(pretest 855 100)
(rc1a 304 83.5)
(rc1b 262.5 87)
(rc1c 270.5 95)
(rc2a 174.5 94)
(rc3a 214 90)
(rc3b 357 90)
(rc4a 287 73)
(rc4b 250.5 16)
(rc5a 331 79)
(rc6a 282.5 80)
(rc7a 222 84)
(rc7b 435 80.5)
(rc9 1 19)
(ref1 389 84)
(ref2a 399 75)
(ref2aa 33 31)
(ref2b 248 89)
(ref2c 380 81.5)
(ref3a 529 60)
(ref3b 235 87.5)
(ref4a 347 84)
(ref4b 178.5 95)
(ref5a 310 80)
(ref5b 238 86.5)
(ref6 289 71)
(relvel1a 989 81)
(relvel2a 410 85)
(relvel3a 642.5 88.5)
(roc1 277.5 92)
(roc2 383 84)
(roc3 388 73)
(roc4 312 85)
(roc5 800 53)
(roc6 426 93)
(rots1a 514 89)
(rots1b 549 49)
(rots1c 1807.5 95.5)
(rots2a 438 98)
(rots3a 455 91)
(rots4a 395 93)
(rots5a 358 93)
(rots6a 474 84)
(rots6b 493 98.5)
(rots6c 634 85.5)
(rots7a 572 88)
(rots8a 685 73)
(rots8b 428.5 77.5)
(s10a 381 100)
(s11a 456.5 83)
(s11b 339.5 76)
(s12a 428.5 62)
(s1a 346 64)
(s1b 427 81)
(s1c 178.5 99)
(s1d 136 100)
(s1e 304.5 92.5)
(s1f 343 88)
(s2a 128.5 82)
(s2b 771 77)
(s2c 483 78.5)
(s2d 971 54)
(s2e 830 83.5)
(s3a 400 98)
(s3c 639.5 88)
(s4a 223 93)
(s4b 566 90)
(s5a 623.5 98.5)
(s6a 1308 67)
(s6aplan 295 100)
(s7a 895 84)
(s7b 234 77)
(s8a 706 78)
(s9a 502 87)
(vec1a 698 95.5)
(vec1b 571 95)
(vec1c 565 97)
(vec1d 318.5 97)
(vec2a 225 99)
(vec2b 250.5 97)
(vec2c 141 99)
(vec2d 163.5 100)
(vec3a 558 97)
(vec3b 802.5 92)
(vec3c 490 97)
(vec4a 523 96)
(vec4b 420 98)
(vec4c 300 97)
(vec4d 299.5 99)
(vec5a 516.5 98)
(vec5b 386 98)
(vec5c 327 99)
(vec5d 374 99)
(vec6a 937.5 89)
(vec6b 395 97)
(vec6c 449 98)
(vec6d 439 98)
(vec7a 581 89.5)
(vec8a 510 98)
(vec8b 552 98)
(vec8c 378 99)
(vec9 97 96)
(wave1 493 91.5)
(wave10 477 64)
(wave11 363 89)
(wave12 332 66)
(wave13 261 98)
(wave14 462.5 75.5)
(wave15 418 84)
(wave16 367.5 89) (wave17 409 84.5)
(wave18 174 96) (wave19 349 74) (wave2 85 99) (wave3 76 99) (wave4 364.5 89)
(wave5 308 90) (wave6 356 85) (wave8 570 79) (wave9 402 74) (we1a 111 99)
(we2a 304 99) (we3a 384 99) (we4a 531 83) (we5 317.5 77.5) (we6 779.5 89.5)))

(defun sets-json-file (&key (file "sets.json"))
  "construct file sets.json"
  (let ((json:*lisp-identifier-name-to-json* #'string-downcase)
	;; cl-json makes heavy use of conditions and signals.
	;; so nested data structures can exceed the signal 
	;; recursion limit in lisp.
	#+sbcl (SB-KERNEL:*MAXIMUM-ERROR-DEPTH* 20)
	(Stream  (open file
		  :direction :output :if-exists :supersede
		  :external-format #+sbcl :utf-8 #-sbcl :default)))
    ;;  Assume stream has UTF-8 encoding (default for sbcl)
    ;;  Should test this is actually true or change the charset to match
    ;;  the actual character code being used by the stream
    ;;  something like:
    (when (streamp Stream)
      #+sbcl (unless (eq (stream-external-format Stream) ':utf-8)
	       (error "Wrong character code ~A, should be UTF-8"
		      (stream-external-format Stream))))
    (json:encode-json
     (list (cons :identifier "id")
	   (cons :label "label")
	   (cons :items 
		 (loop for set in *sets* collect
		      (let ((probs (remove-if-not
				    #'working-problem-p
				    (mapcar #'get-problem 
					    (second set)))))
			(format t "set ~a ~A~%" (car set) (length probs))
			(list (cons :id (car set))
			      (cons :label (car set))
			      (cons :items (problem-lines-json probs)))
			))))
     stream)
    (when (streamp stream) (close stream))))


 ;; special variable: dynamic scoping
(defvar jsonc "counter for unique id in tree")

(defun principles-json-file (&key (file "review/principles.json") sets)
  "Construct JSON file containing principle tree."
  ;; To list problems involving a principle, the Help system
  ;; must be running.
  (when sets (andes-init))
  (let ((jsonc 0)
	;; cl-json makes heavy use of conditions and signals.
	;; so nested data structures can exceed the signal 
	;; recursion limit in lisp.
	#+sbcl (SB-KERNEL:*MAXIMUM-ERROR-DEPTH* 20)
	(json:*lisp-identifier-name-to-json* #'string-downcase)
	(stream (open file
                 :direction :output :if-exists :supersede
		 :external-format #+sbcl :utf-8 #-sbcl :default)))
    ;;  Assume stream has UTF-8 encoding (set for sbcl)
    ;;  Should test this is actually true or change the charset to match
    ;;  the actual character code being used by the stream
    (when (streamp Stream)
      #+sbcl (unless (eq (stream-external-format Stream) ':utf-8)
	       (error "Wrong character code ~A, should be UTF-8"
		      (stream-external-format Stream))))

    ;; Test that tree contains all principles in Ontology
    ;; Alternatively, one could test that all principles contained
    ;; in the set of problems are contained in the principles tree.
    (test-principle-tree *principle-tree*)

    (json:encode-json
     (list (cons :identifier "id")
	   (cons :label "label")
	   (cons :items (mapcar
			 #'(lambda (x) (principle-groups x :sets sets))
			 *principle-tree*)))
     stream)    
    (when (streamp stream) (close stream))))

(defun has-major-complexity (p)
  "Determine if a group has any major psm's in it."
  ;; Sanity tests
  (unless (and (listp p) (every #'consp p)
	       (or (assoc :items p) (assoc :psm p)))
    (error "Need alist with :items or :psm, got ~A" p))
  (let ((items (assoc :items p)))
    (if items
	;; if it is a group, do recursion
	(some #'has-major-complexity (cdr items))
	;; if it is a psm, determine complexity
	(eql 'major 
	     (psmclass-complexity 
	      (lookup-psmclass-name (cdr (assoc :psm p))))))))

(defun test-principle-tree (&optional (p *principle-tree*) (psms *Ontology-PSMClasses*))
  ;; Verify that tree contains all PSMS in Ontology."
  (dolist (name (mapcar #'psmclass-name psms))
    (unless (has-this-psm name p) (warn "PSM ~A missing" name))))

;; On load, test that all PSMs are represented in principles tree.
(defun has-this-psm (name &optional (p *principle-tree*))
  "Determine if a group has any major psm's in it."
  (if (assoc :psm p)
      (eql (cdr (assoc :psm p)) name)
	;; if it is a group, do recursion
      (some #'(lambda (group) (has-this-psm name group)) 
	    ;; top level of tree is just a list
	    (or (cdr (assoc :items p)) p))))

(defun principle-groups (p &key sets)
  (let (result 
	(items (assoc :items p)))
    (cond
      ;; This is a group, do recursion.
      (items 
       (push (cons :id (format nil "g~A" (incf jsonc))) result)
       (push 
	(cons :items 
	      (mapcar 
	       #'(lambda (x) (principle-groups x :sets sets))
	       (cdr items)))
	result)
       (when (some #'has-major-complexity (cdr items))
	 (push '(:complexity . "major") result))
       (push (assoc :label p) result))
      ;; Else, this is a principle (leaf node).
      (t (let ((bindings (or (cdr (assoc :bindings p)) no-bindings))
	       (Eqnformat (cdr (assoc :eqnformat p)))
	       (short-name (cdr (assoc :short-name p)))
	       (pc (lookup-psmclass-name (cdr (assoc :psm p)))))
	   (unless pc (warn "no PSM in Ontology for ~A" (cdr (assoc :psm p))))
	   (push (cons :id (format nil "p~A" (incf jsonc))) result)
	   (when sets
	     (let ((probs (collect-relevant-problems pc bindings)))
	       (if probs
		   (push (cons :items probs) result)
		   (warn "PSM ~A ~A has no associated Andes problems"
			 (psmclass-name pc)
			 (subst-bindings bindings (psmclass-form pc))))))
	   (push (cons :complexity (psmclass-complexity pc)) result)
	   (unless sets
	     ;; turn off pretty-print to prevent line breaks
	     (push (cons :psm 
			 (format nil "~S"
				 (cons (psmclass-name pc) 
				       (if (eq bindings no-bindings) 
					   nil bindings))))
		   result))
	   (push (cons :label 
		       (format nil "~A    ~A~@[ ~A~]" 
			       (eval-print-spec (or EqnFormat 
						    (psmclass-EqnFormat pc)) 
						bindings)
			       (eval-print-spec (or short-name 
						    (psmclass-short-name pc)) 
						bindings)
			       (when (psmclass-tutorial pc)
				 (open-this-window-html 
				  "tutorial" 
				  (psmclass-tutorial pc)))))
		 result))))
    result))

(defun open-this-window-html (Name href &key title)
  "Html for opening web page in this directory"
  (declare (ignore name href title))
  ;; Not working yet, Bug #1808.
  ;; there are three possibilities:
  ;;    open a dialog box in same window.
  ;;    go forward in same window (in which case, need a back button).
  ;;    pop up another window.
  ;; However, the rules for doing these things in a browser are
  ;; not obvious.
  ;;
  (warn "tutorials not working yet")
  ;;(format nil "<a href=\"#\" onClick=\"window.open('~A','~A','directories=no,menubar=no,toolbar=no,location=no,status=no');\">~A</a>" href (or title name) name)
  )


(defun collect-relevant-problems (pc bindings)
  (loop for set in *sets* append
       (let ((probs (remove-if-not
		     #'(lambda (Prob)
			;; (format t "working on ~a~%" (and prob (problem-name prob)))
			 (when (working-problem-p Prob)
			   (unless (problem-graph Prob)
			     (read-problem-info (string (problem-name prob)))
			     (when *cp* (setf (problem-graph Prob) 
					      (problem-graph *cp*))))
			   (some #'(lambda (enode)
				     (unify (psmclass-form pc)
					    (enode-id enode) bindings)) 
				 (second (problem-graph Prob)))))
		     (mapcar #'get-problem (second set)))))
	 (when probs 
	   (problem-lines-json probs (car set) jsonc)))))

(defun problem-lines-json (probs &optional set id)
  (loop for prob in probs collect
       (remove nil
	       (list
		(cons :id (format nil "~(~A~)~@[~A~]" (problem-name prob) id))
		(cons :expand (format nil "~(~A~)" (problem-name prob)))
		(when (problem-graphic prob) 
		  (cons :graphic (format nil "~A" (problem-graphic prob))))
		(when set
		  (cons :set (format nil "~A" set)))
		(cons :label 
		      (format nil "~(~A~): ~@[~,1Fm~] ~@[~A%~]"
			      (problem-name prob)
			      (when (find (problem-name prob) *times-scores* :key #'car)
				(/ (second (find (problem-name prob) *times-scores* 
						 :key #'car)) 60))
			      (third (find (problem-name prob) *times-scores* :key #'car)))))
	       )
       ))


(defun problem-html-files (&optional (path #P"./"))
  "construct html files for all problems"
  (dolist (prob (listprobs))
    (when (problem-graphic prob) (format t "~A~%" (problem-graphic prob)))
    (let ((*print-pretty* NIL) ;disble line breaks
	  (stream (open (merge-pathnames 
			 (format nil "~(~A~).html" (problem-name prob)) path)
			:direction :output :if-exists :supersede
			:external-format #+sbcl :utf-8 #-sbcl :default)))
    
      ;;  Assume stream has UTF-8 encoding (default for sbcl)
      ;;  Should test this is actually true or change the charset to match
      ;;  the actual character code being used by the stream
      ;;  something like:
  (when (streamp Stream) 
    #+sbcl (unless (eq (stream-external-format Stream) ':utf-8)
             (error "Wrong character code ~A, should be UTF-8" 
                    (stream-external-format Stream))))
  (format Stream 
          (strcat
           "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">~%"
           "<html> <head>~%"
           ;;      "   <meta http-equiv=\"Content-Type\" content=\"text/html; "
	   ;;     "charset=iso-8859-1\">~%"
           "   <meta http-equiv=\"Content-Type\" content=\"text/html; charset=UT
F-8\">~%"
           "<title>Problem ~(~A~)</title>~%"
           "</head>~%"
           "<body>~%") (problem-name prob))
  (format stream "~{    ~A<br>~%~}" (problem-statement prob))
  (format stream (strcat "</body>~%" 
			 "</html>~%"))
  (when (streamp stream) (close stream)))))


(defun problem-xml-files (&optional path)
  "construct xml files for all problems"
  (dolist (prob (listprobs))
    (let ((*print-pretty* NIL) ;disble line breaks
	  (stream (open (merge-pathnames 
			 (format nil "~(~A~).xhtml" (problem-name prob)) path)
			:direction :output :if-exists :supersede
			:external-format #+sbcl :utf-8 #-sbcl :default)))
      
  ;    (format t "starting problem ~A~%" (problem-name prob))

      ;;  Assume stream has UTF-8 encoding (default for sbcl)
      ;;  Should test this is actually true or change the charset to match
      ;;  the actual character code being used by the stream
      ;;  something like:
      (when (streamp Stream) 
	#+sbcl (unless (eq (stream-external-format Stream) ':utf-8)
		 (error "Wrong character code ~A, should be UTF-8" 
			(stream-external-format Stream))))
      (format Stream 
	      (strcat
	       "<!DOCTYPE html PUBLIC "
	       "\"-//W3C//DTD XHTML 1.0 Strict//EN\"~%"
	       "  \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">~%"
	       "<html xmlns=\"http://www.w3.org/1999/xhtml\" version=\"XHTML 1.2\" xml:lang=\"en\">~%"
	       "<head>~%"
	       "  <title>~(~A~)</title>~%"
	       "</head>~%"
	       "<body>~%  <p>~%") (problem-name prob))
      (dolist (liner (problem-statement prob))
	(cond 
	  ((listp liner) nil)
	  ((equal "" (string-trim match:*whitespace* liner))
	   (format stream  "  </p>~%  <p>~%"))
	  (t (format stream "    ~A~%" liner))))
      (format stream "  </p>~%")
      (when (problem-graphic prob)
	(format stream "  <p><img src=\"/images/~A\" alt=\"figure\" /></p>~%" 
		(problem-graphic prob)))
      (format stream (strcat "</body>~%</html>~%"))
      (when (streamp stream) (close stream)))))
