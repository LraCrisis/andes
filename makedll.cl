(generate-application
 "Helpsys"
 "c:\\cygwin\\home\\andersw\\Andes2\\"
 (list :defctype :ffcompat :foreign :list2 :loop :seq2 :defftype :process
       ; probably not used in dll version:
       :sock
       "load-runtimehelp.cl"
       ; lisp files for DLL version only:
       (load-compiled "lnk.cl")
       (load-compiled "Help\\dllapi.cl"))

 :application-type :dll
 :allow-existing-directory T
 
 ;; The following are needed to override defaults set by the IDE.
 :restart-init-function nil
 :restart-app-function nil
 :include-compiler T
 :discard-compiler T
 :include-ide nil)