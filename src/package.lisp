;;;;; -*- mode: common-lisp;   common-lisp-style: modern;    coding: utf-8; -*-
;;;;;

(in-package :cl-user)

(defpackage :manardb
  (:nicknames :mm)
  (:use :closer-common-lisp :contextl :iterate)
  (:import-from :contextl :layer :layers :process-layered-access-slot-specification)
  (:export
    :*mmap*
    :*mtagmaps-may-mmap*
    :*allocate-base-pathname*

    :lisp-object-to-mptr-impl
    :lisp-object-to-mptr
    :mptr-to-lisp-object
    :mptr
    :meq
    
    :mm-object
    :defmmclass
    :mm-metaclass
    
    :gc
    :rewrite-gc

    :print-all-mmaps
    :close-all-mmaps
    :open-all-mmaps
    :wipe-all-mmaps

    :doclass
    :dosubclasses
    :mm-subclasses
    :count-all-instances
    :retrieve-all-instances

    :marray
    :make-marray
    :marray-ref
    :marray-length
    :marray-to-list
    :list-to-marray
    :index-of-marray
    :in-marray

    :make-mm-fixed-string
    :mm-fixed-string-value

    :ensure-manardb
    :clean-mmap-dir
    :clear-caches
    :clear-caches-hard    
    :with-object-cache
    :with-cached-slots
    :direct-slot-numeric-maref
    
    :mcons
    :mcar
    :mcdr
    :mcadr
    :mcddr
    :mconsp
    :empty
    :emptyp
    :mlist
    :as-list
    :mpush
    :mpop

    :basic-persistent-class
    :layered-persistent-class
    :transactional-standard-class
    :transactional-persistent-class
    :standard-persistent-class

    :define-basic-persistent-class
    :define-layered-persistent-class
    :define-transactional-standard-class    
    :define-transactional-persistent-class
    :define-persistent-class
        
    :atomic
    :call-atomic
    :roll-back
    :commit-transaction
    :retry-transaction
    :*tries*
    :*timeout*
    :*current-transaction*
    :transaction
    :most-recent-transaction
    :transaction-status
        
    :stm-mode
    :direct-update-mode
    :deferred-update-mode
    :isolated-update-mode
    :globally-enable-direct-update-mode
    :globally-enable-deferred-update-mode
    :globally-enable-isolated-update-mode))



