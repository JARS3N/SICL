(cl:in-package #:sicl-simple-environment)

;;; Recall that this function should return true if FUNCTION-NAME has
;;; a definition in ENVIRONMENT as an ordinary function, a generic
;;; function, a macro, or a special operator.
(defmethod sicl-env:fboundp (function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (and (not (null entry))
	 (or (not (eq (car (function-cell entry))
		      (unbound entry)))
	     (not (null (macro-function entry)))
	     (not (null (special-operator entry)))))))

(defmethod sicl-env:fmakunbound (function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (unless (null entry)
      (setf (car (function-cell entry))
	    (unbound entry))
      (setf (macro-function entry) nil)
      (setf (special-operator entry) nil)
      (setf (type entry) t)
      (setf (compiler-macro-function entry) nil)
      (setf (inline entry) nil))))

(defmethod sicl-env:special-operator (function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (if (null entry)
	nil
	(special-operator entry))))

(defmethod (setf sicl-env:special-operator)
    (new-definition function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (cond ((and (null entry) (null new-definition))
	   nil)
	  ((null entry)
	   (setf entry (ensure-function-entry env function-name))
	   (setf (special-operator entry) new-definition))
	  ((or (not (eq (car (function-cell entry))
			(unbound entry)))
	       (not (null (macro-function entry))))
	   (error "The name ~s already has a definition." function-name))
	  (t
	   (setf (special-operator entry) new-definition)))))

(defmethod sicl-env:fdefinition (function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (cond ((null entry)
	   (error 'undefined-function :name function-name))
	  ((not (eq (car (function-cell entry))
		    (unbound entry)))
	   (car (function-cell entry)))
	  ((not (null (macro-function entry)))
	   `(cl:macro-function ,(macro-function entry)))
	  ((not (null (special-operator entry)))
	   `(cl:special (special-operator entry)))
	  (t
	   (error 'undefined-function :name function-name)))))

(defmethod (setf sicl-env:fdefinition)
    (new-definition function-name (env simple-environment))
  (assert (functionp new-definition))
  (let ((entry (ensure-function-entry env function-name)))
    (if (not (null (special-operator entry)))
	(error "The name ~s has a definition as a special operator"
	       function-name)
	(progn (setf (car (function-cell entry)) new-definition)
	       (setf (macro-function entry) nil)
	       (setf (type entry) t)
	       (setf (inline entry) nil)))))

(defmethod sicl-env:macro-function (symbol (env simple-environment))
  (let ((entry (find-function-entry env symbol)))
    (if (null entry)
	nil
	(macro-function entry))))

(defmethod (setf sicl-env:macro-function)
    (new-definition function-name (env simple-environment))
  (assert (functionp new-definition))
  (let ((entry (ensure-function-entry env function-name)))
    (setf (car (function-cell entry)) (unbound entry))
    (setf (macro-function entry) new-definition)
    (setf (type entry) t)
    (setf (inline entry) nil)))

(defmethod sicl-env:compiler-macro-function (symbol (env simple-environment))
  (let ((entry (find-function-entry env symbol)))
    (if (null entry)
	nil
	(compiler-macro-function entry))))

(defmethod (setf sicl-env:compiler-macro-function)
    (new-definition function-name (env simple-environment))
  (assert (or (functionp new-definition) (null new-definition)))
  (let ((entry (ensure-function-entry env function-name)))
    (setf (compiler-macro-function entry) new-definition)))

(defmethod sicl-env:function-type (function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (if (or (null entry)
	    (eq (car (function-cell entry)) (unbound entry)))
	(error 'undefined-function :name function-name)
	(type entry))))

(defmethod (setf sicl-env:function-type)
    (new-type function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (if (or (null entry)
	    (eq (car (function-cell entry)) (unbound entry)))
	(error 'undefined-function :name function-name)
	(setf (type entry) new-type))))

(defmethod sicl-env:function-inline (function-name (env simple-environment))
  (let ((entry (find-function-entry env function-name)))
    (if (or (null entry)
	    (eq (car (function-cell entry)) (unbound entry)))
	(error 'undefined-function :name function-name)
	(inline entry))))

(defmethod (setf sicl-env:function-inline)
    (new-inline function-name (env simple-environment))
  (assert (member new-inline '(nil cl:inline cl:notinline)))
  (let ((entry (find-function-entry env function-name)))
    (if (or (null entry)
	    (eq (car (function-cell entry)) (unbound entry)))
	(error 'undefined-function :name function-name)
	(setf (inline entry) new-inline))))

(defmethod sicl-env:boundp (symbol (env simple-environment))
  (let ((entry (find-variable-entry env symbol)))
    (and (not (null entry))
	 (or (not (null (macro-function entry)))
	     (not (eq (car (value-cell entry)) (unbound env)))))))

(defmethod sicl-env:makunbound (symbol (env simple-environment))
  (let ((entry (find-variable-entry env symbol)))
    (unless (null entry)
      (setf (macro-function entry) nil)
      ;; Free up the expansion so that the garbage collector can
      ;; recycle it.
      (setf (expansion entry) nil)
      (setf (constantp entry) nil)
      (setf (car (value-cell entry)) (unbound env)))))

(defmethod sicl-env:constant-variable (symbol (env simple-environment))
  (let ((entry (find-variable-entry env symbol)))
    (if (or (null entry) (not (constantp entry)))
	(values nil nil)
	(values (car (value-cell entry)) t))))

(defmethod (setf sicl-env:constant-variable)
    (value symbol (env simple-environment))
  (let ((entry (ensure-variable-entry env symbol)))
    (cond ((or (not (null (macro-function entry)))
	       (specialp entry))
	   (error "Attempt to turn a symbol macro or a special variable into a constant variable"))
	  ((and (constantp entry)
		(not (eql (car (value-cell entry)) value)))
	   (error "Attempt to change the value of a constant variable"))
	  (t
	   (setf (constantp entry) t)
	   (setf (car (value-cell entry)) value)))))

(defmethod sicl-env:special-variable (symbol (env simple-environment))
  (let ((entry (find-variable-entry env symbol)))
    (if (or (null entry)
	    (not (specialp entry))
	    (eq (car (value-cell entry)) (unbound env)))
	(values nil nil)
	(values (car (value-cell entry)) t))))

(defmethod (setf sicl-env:special-variable)
    (value symbol (env simple-environment) initialize-p)
  (let ((entry (ensure-variable-entry env symbol)))
    (cond ((or (not (null (macro-function entry)))
	       (constantp entry))
	   (error "Attempt to turn a symbol macro or a constant variable into a special variable"))
	  (t
	   (setf (specialp entry) t)
	   (when initialize-p
	     (setf (car (value-cell entry)) value))))))

