(cl:in-package #:sicl-argument-processing)

(defun check-even-number-of-keyword-arguments (argument-count-location
                                               dynamic-environment-location
                                               error-function-location
                                               first-index)
  (let* ((remaining-argument-count-location
           (make-instance 'cleavir-ir:lexical-location :name 'remainin-argument-count))
         (quotient-location
           (make-instance 'cleavir-ir:lexical-location :name 'quotient))
         (remainder-location
           (make-instance 'cleavir-ir:lexical-location :name 'remainder))
         (constant-input-2
           (make-instance 'cleavir-ir:constant-input :value 2))
         (constant-input-0
           (make-instance 'cleavir-ir:constant-input :value 0))
         (first-index-input (make-instance 'cleavir-ir:constant-input :value first-index))
         (nop (make-instance 'cleavir-ir:nop-instruction
                :dynamic-environment-location dynamic-environment-location))
         (error-branch
           (call-error 'odd-number-of-keyword-arguments
                       error-function-location
                       dynamic-environment-location
                       remaining-argument-count-location)))
    (let ((first (make-instance 'cleavir-ir:fixnum-equal-instruction
                   :inputs (list constant-input-0 remainder-location)
                   :successors (list nop error-branch)
                   :dynamic-environment-location dynamic-environment-location)))
      (setf first
            (make-instance 'cleavir-ir:fixnum-divide-instruction
              :rounding-mode 'floor
              :inputs (list remaining-argument-count-location constant-input-2)
              :outputs (list quotient-location remainder-location)
              :successor first
              :dynamic-environment-location dynamic-environment-location))
      (setf first
            (make-instance 'cleavir-ir:fixnum-sub-instruction
              :inputs (list argument-count-location first-index-input)
              :outputs (list quotient-location remainder-location)
              :successors (list first first)
              :dynamic-environment-location dynamic-environment-location))
      (values first nop))))

(defun check-keywords-valid (keywords
                             argument-count-location
                             dynamic-environment-location
                             error-function-location
                             first-index)
  (let* ((keyword-location (make-instance 'cleavir-ir:lexical-location :name 'keyword))
         (first-index-input (make-instance 'cleavir-ir:constant-input :value first-index))
         (index-location (make-instance 'cleavir-ir:lexical-location :name 'index))
         (constant-input-2
           (make-instance 'cleavir-ir:constant-input :value 2))
         (nop (make-instance 'cleavir-ir:nop-instruction
                :dynamic-environment-location dynamic-environment-location))
         (first
           (call-error 'invalid-keyword
                       error-function-location
                       dynamic-environment-location
                       keyword-location)))
    (let ((add-2 (make-instance 'cleavir-ir:fixnum-add-instruction
                   :inputs (list index-location constant-input-2)
                   :dynamic-environment-location dynamic-environment-location)))
      (loop for keyword in (cons :allow-other-keys (reverse keywords))
            for input = (make-instance 'cleavir-ir:constant-input :value keyword)
            do (setf first
                     (make-instance 'cleavir-ir:eq-instruction
                       :inputs (list input keyword-location)
                       :successors (list add-2 first)
                       :dynamic-environment-location dynamic-environment-location)))
      (setf first
            (make-instance 'cleavir-ir:argument-instruction
              :input index-location
              :output keyword-location
              :successor first
              :dynamic-environment-location dynamic-environment-location))
      (setf first
            (make-instance 'cleavir-ir:fixnum-less-instruction
              :inputs (list index-location argument-count-location)
              :successors (list first nop)
              :dynamic-environment-location dynamic-environment-location))
      (setf (cleavir-ir:successors add-2) (list first first))
      (setf first
            (make-instance 'cleavir-ir:assignment-instruction
              :input first-index-input
              :output index-location
              :successor first
              :dynamic-environment-location dynamic-environment-location)))
    (values first nop)))

(defun check-for-allow-other-keys (argument-count-location
                                   dynamic-environment-location
                                   first-index)
  (let* ((keyword-location (make-instance 'cleavir-ir:lexical-location :name 'keyword))
         (value-location (make-instance 'cleavir-ir:lexical-location :name 'value))
         (first-index-input (make-instance 'cleavir-ir:constant-input :value first-index))
         (index-location (make-instance 'cleavir-ir:lexical-location :name 'index))
         (temp-location (make-instance 'cleavir-ir:lexical-location :name 'temp))
         (constant-input-1
           (make-instance 'cleavir-ir:constant-input :value 1))
         (constant-input-2
           (make-instance 'cleavir-ir:constant-input :value 2))
         (constant-input-nil
           (make-instance 'cleavir-ir:constant-input :value nil))
         (constant-input-allow-other-keys
           (make-instance 'cleavir-ir:constant-input :value :allow-other-keys))
         (add-2 (make-instance 'cleavir-ir:fixnum-add-instruction
                  :inputs (list index-location constant-input-2)
                  :dynamic-environment-location dynamic-environment-location))
         (nop-false (make-instance 'cleavir-ir:nop-instruction
                      :dynamic-environment-location dynamic-environment-location))
         (nop-true (make-instance 'cleavir-ir:nop-instruction
                     :dynamic-environment-location dynamic-environment-location))
         (first nop-true))
    (setf first
          (make-instance 'cleavir-ir:eq-instruction
            :inputs (list value-location constant-input-nil)
            :successors (list nop-false first)
            :dynamic-environment-location dynamic-environment-location))
    (setf first
          (make-instance 'cleavir-ir:argument-instruction
            :input temp-location
            :output value-location
            :successor first
            :dynamic-environment-location dynamic-environment-location))
    (setf first
          (make-instance 'cleavir-ir:fixnum-add-instruction
            :inputs (list constant-input-1 index-location)
            :output temp-location
            :successors (list first first)
            :dynamic-environment-location dynamic-environment-location))
    (setf first
          (make-instance 'cleavir-ir:eq-instruction
            :inputs (list constant-input-allow-other-keys keyword-location)
            :successors (list first add-2)
            :dynamic-environment-location dynamic-environment-location))
    (setf first
          (make-instance 'cleavir-ir:argument-instruction
            :input index-location
            :output keyword-location
            :successor first
            :dynamic-environment-location dynamic-environment-location))
    (setf first
          (make-instance 'cleavir-ir:fixnum-not-greater-instruction
            :inputs (list argument-count-location index-location)
            :successors (list nop-false first)
            :dynamic-environment-location dynamic-environment-location))
    (setf first
          (make-instance 'cleavir-ir:assignment-instruction
            :input first-index-input
            :output index-location
            :successor first
            :dynamic-environment-location dynamic-environment-location))
    (values first nop-false nop-true)))
