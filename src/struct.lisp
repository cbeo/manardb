(in-package #:manardb)

(deftype mptr ()
  `(unsigned-byte ,+mptr-bits+))

(deftype mtag ()
  `(unsigned-byte ,+mtag-bits+))

(deftype mindex ()
  `(unsigned-byte ,+mindex-bits+))

(deftype machine-pointer ()
  (type-of (cffi:null-pointer)))

(defun stored-cffi-type (type)
  (let ((cffi-type 
	 (alexandria:switch (type :test 'subtypep)
	   ('(unsigned-byte 8) :unsigned-char)
	   ('(unsigned-byte 64) :unsigned-long-long)
	   ('(signed-byte 64) :long-long)
	   ('single-float :float)
	   ('double-float :double))))
    cffi-type))

(defun stored-type-size (type)
  (cffi:foreign-type-size (or (stored-cffi-type type) (stored-cffi-type 'mptr))))

(defmacro d (machine-pointer &optional (index 0) (type '(unsigned-byte 8)))
  `(cffi:mem-aref ,machine-pointer ,(stored-cffi-type type) ,index))

(defun-speedy mptr-tag (mptr)
  (declare (type mptr mptr) (optimize (safety 0)))
  (the mtag (logand mptr (1- (ash 1 +mtag-bits+))))) ; Allegro  8.1 is too stupid to optimize ldb

(defun-speedy mptr-index (mptr)
  (declare (type mptr mptr) (optimize (safety 0)))
  (the mindex (ash mptr (- +mtag-bits+))))

(declaim (ftype (function (mtag mindex) mptr) make-mptr))
(defun-speedy make-mptr (tag index)
  (declare (type mtag tag) (type mindex index))
  (logior (ash index +mtag-bits+) tag))

(deftype mm-object-instantiator ()
  `(function (mindex) t)
 
  ;; Allegro 8.1 has a horrible bug with function type specifiers and the
  #+allegro `t
)

(defstruct mtagmap  
  (fd -1 :type fixnum)
  (ptr (cffi:null-pointer) :type machine-pointer)
  (len 0 :type mindex)

  metaclass
  layout
  object-instantiator)

(deftype mtagmaps-array ()
  `(simple-array (or mtagmap null) (,+mtags+)))

(defvar *mtagmaps* (the mtagmaps-array (make-array +mtags+ :initial-element nil :element-type 
					     '(or mtagmap null))))
(declaim (type mtagmaps-array *mtagmaps*))

(defun-speedy mtagmap (mtag)
  (declare (type mtag mtag))
  (aref (the mtagmaps-array *mtagmaps*) mtag))

(defun (setf mtagmap) (val mtag)
  (check-type mtag mtag)
  (check-type val (or null mtagmap))
  (setf (aref (the mtagmaps-array *mtagmaps*) mtag) val))

(defmacro mm-object-instantiator-for-tag (mtag)
  `(the mm-object-instantiator (mtagmap-object-instantiator (the mtagmap (mtagmap ,mtag)))))

(defun next-available-tag ()
  (loop for i from 0
	thereis (unless (mtagmap i) i)))

(defun-speedy mpointer (mtag mindex)
  (cffi:inc-pointer (mtagmap-ptr (the mtagmap (mtagmap mtag))) mindex))

(defun-speedy mptr-pointer (mptr)
  (mpointer (mptr-tag mptr) (mptr-index mptr)))

(defun-speedy mptr-to-lisp-object (mptr)
  (funcall (the mm-object-instantiator (mm-object-instantiator-for-tag (mptr-tag mptr))) 
	   (mptr-index mptr)))

(defmacro define-lisp-object-to-mptr ()
  `(defun-speedy lisp-object-to-mptr (obj)
     (typecase obj
       (mm-object (%ptr obj))
       (t (box-object obj)))))

(define-lisp-object-to-mptr) ;; should be redefined after box-object is
			   ;; defined, which needs many types to be
			   ;; defined, in a circular fashion

(defmacro with-constant-tag-for-class ((tagsym classname) &body body)
  (check-type tagsym symbol)
  (check-type classname symbol)
  (alexandria:with-gensyms (tag)
    `(macrolet ((,tag ()
		  (let ((tag (mm-metaclass-tag (find-class ',classname))))
		    (check-type tag mtag)
		    tag)))
       (eval-when (:load-toplevel :compile-toplevel :execute)
	 (assert (= (,tag) ,(mm-metaclass-tag (find-class classname)))
		 () "The tag for classname ~A has changed; compiled code may be invalid" ',classname))
       (symbol-macrolet ((,tagsym (,tag)))
	 ,@body))))
