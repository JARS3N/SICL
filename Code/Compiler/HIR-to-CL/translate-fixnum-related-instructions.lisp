(cl:in-package #:sicl-hir-to-cl)

(defmethod translate-final-instruction (client
                                        (instruction cleavir-ir:fixnum-add-instruction)
                                        context)
  (destructuring-bind (input1 input2)
      (cleavir-ir:inputs instruction)
    (destructuring-bind (successor1 successor2)
        (cleavir-ir:successors instruction)
      (let ((output (first (cleavir-ir:outputs instruction))))
        `((setq ,(cleavir-ir:name output)
                (+ ,(translate-input input1) ,(translate-input input2)))
          (if (typep ,(cleavir-ir:name output) 'fixnum)
              (progn (go ,(tag-of-basic-block (basic-block-of-leader successor1))))
              (progn (go ,(tag-of-basic-block (basic-block-of-leader successor2))))))))))

(defmethod translate-final-instruction (client
                                        (instruction cleavir-ir:fixnum-sub-instruction)
                                        context)
  (destructuring-bind (input1 input2)
      (cleavir-ir:inputs instruction)
    (destructuring-bind (successor1 successor2)
        (cleavir-ir:successors instruction)
      (let ((output (first (cleavir-ir:outputs instruction))))
        `((setq ,(cleavir-ir:name output)
                (- ,(translate-input input1) ,(translate-input input2)))
          (if (typep ,(cleavir-ir:name output) 'fixnum)
              (progn (go ,(tag-of-basic-block (basic-block-of-leader successor1))))
              (progn (go ,(tag-of-basic-block (basic-block-of-leader successor2))))))))))

(defmethod translate-final-instruction (client
                                        (instruction cleavir-ir:fixnum-equal-instruction)
                                        context)
  (destructuring-bind (input1 input2)
      (cleavir-ir:inputs instruction)
    (destructuring-bind (successor1 successor2)
        (cleavir-ir:successors instruction)
      `((if (= ,(translate-input input1) ,(translate-input input2))
            (progn (go ,(tag-of-basic-block (basic-block-of-leader successor1))))
            (progn (go ,(tag-of-basic-block (basic-block-of-leader successor2)))))))))


(defmethod translate-final-instruction (client
                                        (instruction cleavir-ir:fixnum-less-instruction)
                                        context)
  (destructuring-bind (input1 input2)
      (cleavir-ir:inputs instruction)
    (destructuring-bind (successor1 successor2)
        (cleavir-ir:successors instruction)
      `((if (< ,(translate-input input1) ,(translate-input input2))
            (progn (go ,(tag-of-basic-block (basic-block-of-leader successor1))))
            (progn (go ,(tag-of-basic-block (basic-block-of-leader successor2)))))))))


(defmethod translate-final-instruction (client
                                        (instruction cleavir-ir:fixnum-not-greater-instruction)
                                        context)
  (destructuring-bind (input1 input2)
      (cleavir-ir:inputs instruction)
    (destructuring-bind (successor1 successor2)
        (cleavir-ir:successors instruction)
      `((if (<= ,(translate-input input1) ,(translate-input input2))
            (progn (go ,(tag-of-basic-block (basic-block-of-leader successor1))))
            (progn (go ,(tag-of-basic-block (basic-block-of-leader successor2)))))))))
