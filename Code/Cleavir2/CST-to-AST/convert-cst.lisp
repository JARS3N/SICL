(cl:in-package #:cleavir-cst-to-ast)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a symbol that has a definition as a symbol macro.

(defmethod convert-cst
    (cst (info cleavir-env:symbol-macro-info) env client)
  (let* ((form (cst:raw cst))
         (expanded-form (funcall (coerce *macroexpand-hook* 'function)
                                 (lambda (form env)
                                   (declare (ignore form env))
                                   (cleavir-env:expansion info))
                                 form
                                 env))
         (expanded-cst (cst:cst-from-expression expanded-form)))
    (with-preserved-toplevel-ness
      (convert client expanded-cst env))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a symbol that has a definition as a constant variable.

(defmethod convert-cst
    (cst (info cleavir-env:constant-variable-info) env client)
  (let ((cst (cst:cst-from-expression (cleavir-env:value info))))
    (convert-constant cst env client)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a special form represented as a CST.

(defmethod convert-cst
    (cst (info cleavir-env:special-operator-info) env client)
  (convert-special client (car (cst:raw cst)) cst env))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a compound form that calls a local macro.
;;; A local macro can not have a compiler macro associated with it.
;;;
;;; If we found a local macro in ENV, it means that ENV is not the
;;; global environment.  And it must be the same kind of agumentation
;;; environment that was used when the local macro was created by the
;;; use of MACROLET.  Therefore, the expander should be able to handle
;;; being passed the same kind of environment.

(defmethod convert-cst
    (cst (info cleavir-env:local-macro-info) env client)
  (let* ((form (cst:raw cst))
         (expanded-form (funcall (coerce *macroexpand-hook* 'function)
                                 (cleavir-env:expander info)
                                 form
                                 env))
         (expanded-cst (cst:reconstruct expanded-form cst client)))
    (with-preserved-toplevel-ness
      (convert client expanded-cst env))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a compound form that calls a global macro.
;;; A global macro can have a compiler macro associated with it.

(defmethod convert-cst
    (cst (info cleavir-env:global-macro-info) env client)
  (let ((compiler-macro (cleavir-env:compiler-macro info))
        (form (cst:raw cst)))
    (with-preserved-toplevel-ness
      (if (null compiler-macro)
          ;; There is no compiler macro, so we just apply the macro
          ;; expander, and then convert the resulting form.
          (let* ((expanded-form (funcall (coerce *macroexpand-hook* 'function)
                                         (cleavir-env:expander info)
                                         form
                                         env))
                 (expanded-cst (cst:reconstruct expanded-form cst client)))

            (convert client expanded-cst env))
          ;; There is a compiler macro, so we must see whether it will
          ;; accept or decline.
          (let ((expanded-form (funcall (coerce *macroexpand-hook* 'function)
                                        compiler-macro
                                        form
                                        env)))
            (if (eq form expanded-form)
                ;; If the two are EQ, this means that the compiler macro
                ;; declined.  Then we appply the macro function, and
                ;; then convert the resulting form, just like we did
                ;; when there was no compiler macro present.
                (let* ((expanded-form
                         (funcall (coerce *macroexpand-hook* 'function)
                                  (cleavir-env:expander info)
                                  form
                                  env))
                       (expanded-cst (cst:reconstruct expanded-form cst client)))
                  (convert client expanded-cst env))
                ;; If the two are not EQ, this means that the compiler
                ;; macro replaced the original form with a new form.
                ;; This new form must then again be converted without
                ;; taking into account the real macro expander.
                (let ((expanded-cst (cst:reconstruct expanded-form cst client)))
                  (convert client expanded-cst env))))))))

;;; Construct a CALL-AST representing a function-call form.  CST is
;;; the concrete syntax tree representing the entire function-call
;;; form.  ARGUMENTS-CST is a CST representing the sequence of
;;; arguments to the call.
(defun make-call (cst info env arguments-cst client)
  (let* ((name-cst (cst:first cst))
         (function-ast (convert-called-function-reference name-cst info env client))
         (argument-asts (convert-sequence arguments-cst env client)))
    (make-instance 'cleavir-ast:call-ast
     :callee-ast function-ast
     :argument-asts argument-asts)))

;;; Convert a form representing a call to a named global function.
;;; CST is the concrete syntax tree representing the entire
;;; function-call form.  INFO is the info instance returned form a
;;; query of the environment with the name of the function.
(defmethod convert-cst
    (cst (info cleavir-env:global-function-info) env client)
  ;; When we compile a call to a global function, it is possible that
  ;; we are in COMPILE-TIME-TOO mode.  In that case, we must first
  ;; evaluate the form.
  (when (and *current-form-is-top-level-p* *compile-time-too*)
    (cleavir-env:eval (cst:raw cst) env env))
  (let ((compiler-macro (cleavir-env:compiler-macro info))
        (notinline (eq 'notinline (cleavir-env:inline info)))
        (form (cst:raw cst)))
    (if (or notinline (null compiler-macro))
        ;; There is no compiler macro.  Create the call.
        (make-call cst info env (cst:rest cst) client)
        ;; There is a compiler macro.  We must see whether it will
        ;; accept or decline.
        (let ((expanded-form (funcall (coerce *macroexpand-hook* 'function)
                                      compiler-macro
                                      form
                                      env)))
          (if (eq form expanded-form)
              ;; If the two are EQ, this means that the compiler macro
              ;; declined.  We are left with function-call form.
              ;; Create the call, just as if there were no compiler
              ;; macro present.
              (make-call cst info env (cst:rest cst) client)
              ;; If the two are not EQ, this means that the compiler
              ;; macro replaced the original form with a new form.
              ;; This new form must then be converted.
              (let ((expanded-cst (cst:reconstruct expanded-form cst client)))
                (convert client expanded-cst env)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a CST representing a compound form that calls a local
;;; function.  A local function can not have a compiler macro
;;; associated with it.

(defmethod convert-cst
    (cst (info cleavir-env:local-function-info) env client)
  (make-call cst info env (cst:rest cst) client))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a symbol that has a definition as a special variable.
;;; We do this by generating a call to SYMBOL-VALUE.

(defmethod convert-special-variable (client cst info global-env)
  (declare (ignore global-env))
  (let ((symbol (cleavir-env:name info)))
    (make-instance 'cleavir-ast:symbol-value-ast :name symbol)))

(defmethod convert-cst
    (cst (info cleavir-env:special-variable-info) env client)
  (let ((global-env (cleavir-env:global-environment env)))
    (convert-special-variable cst info global-env client)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Converting a symbol that has a definition as a lexical variable.

(defmethod convert-cst
    (cst (info cleavir-env:lexical-variable-info) env client)
  (declare (ignore client))
  (when (eq (cleavir-env:ignore info) 'ignore)
    (warn 'ignored-variable-referenced :expr (cst:raw cst)))
  (cleavir-env:identity info))