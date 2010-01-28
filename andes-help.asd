;;;; -*- Lisp -*-

(in-package :cl-user)
(defpackage :help-asd (:use :cl :asdf))
(in-package :help-asd)

;;;;   Load the source file, without compiling
;;;;   asdf:load-op reloads all files, whether they have been
;;;;   changed or not.

(defclass no-compile-file (cl-source-file) ())
(defmethod perform ((o compile-op) (s no-compile-file)) nil)
(defmethod output-files ((o compile-op) (s no-compile-file))
  (list (component-pathname s)))


(defsystem :andes-help
  :name "Andes help"
  :description "Andes physics tutor system: helpsystem"
  :depends-on (problems web-server clsql clsql-mysql)
  :components (
	       (:module "Base"
			:components ((:file "memoize")
				     (:file "match")
				     ;; mt19937 had its own asd file, 
				     ;; but we don't use it
				     (:file "mt19937") 
				     (:file "random" 
					    :depends-on ("mt19937"))))
	       (:module "HelpStructs"
			:depends-on ("Base")
			;; PsmGraph, StudentEntry SystemEntry are also 
			;; defined in "andes"
			:components ((:file "StudentEntry")
				     (:file "SystemEntry")
				     (:file "PsmGraph")
				     (:file "TutorTurn"
					    :depends-on ("CMD"))
				     (:file "ErrorInterp")
				     (:file "CMD")
				     (:file "RuntimeTestScore")
				     (:file "RuntimeTest")
				     ))
	       (:module "Help"
			:depends-on ("HelpStructs" "Base")
			:components (
 				     ;; Solution graph
	 			     (:file "SolutionGraph")
				     
                                     (:file "utilities")

				     ;; depends on clsql and clsql-mysql
				     (:file "database")
				     				     
				     ;; Entry Intepreter: generic + non-eq
				     (:file "symbols")
				     (:file "State"
					    :depends-on ("symbols" "grammar"))
				     (:file "Entry-API"
					    :depends-on ("HelpMessages" "symbols"
							 "SolutionGraph"))
				     
				     ;; Equation parser/interpreter
				     (:file "grammar")
				     (:file "physics-algebra-rules")
				     (:file "parse"
					    :depends-on ("utilities" "symbols"))
				     (:file "algebra"
					    :depends-on ("symbols"))
				     (:file "in2pre")
				     (:file "parse-andes"
					    :depends-on ("SolutionGraph" "symbols"
							 "grammar" "icons"))
				     (:file "interpret-equation"
					    :depends-on ("SolutionGraph"))
				     
				     ;;  Help
				     (:file "nlg") ;Natural language.
				     (:file "icons")
				     (:file "HelpMessages")
				     (:file "whatswrong")
				     (:file "NextStepHelp"
					    :depends-on ("icons" "symbols"))
				     (:file "IEA")
				     
				     ;; Automatic statistics code.
				     (:file "Statistics")
				     
				     ;; Top-level manager
		 		     (:file "Interface") ;The interface api.
	 			     (:file "Commands"
					    :depends-on ("Entry-API" "symbols"
							 "Interface" "icons"))
 				     (:file "API")
                                     (:file "fade"
					    :depends-on ("icons"))
				     (:file "sessions"
					    ;; Mostly for *help-env-vars*
					    :depends-on ("NextStepHelp"
							 "parse" "State" 
							 "database" "fade"
							 "grammar" "symbols" 
							 "Commands"))))
	       (:module "Testcode"
			:depends-on ("Help" "HelpStructs")
			:components (
				     (:file "StackProcessing")
				     (:file "StackTests")
				     (:file "UtilFuncs")
				     ;; file must be loaded before compile
				     (:no-compile-file "Tests"
						       ;;    :in-order-to ((compile-op (load-source-op "Tests")))
						       )
				     ))
	       ))

;;;  make source file extension "cl"  See asdf manual

(defmethod source-file-type ((c cl-source-file) 
			     (s (eql (find-system :andes-help)))) "cl")
