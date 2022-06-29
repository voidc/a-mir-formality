#lang racket
(require redex/reduction-semantics
         "../decl-to-clause.rkt"
         "../grammar.rkt"
         "../prove.rkt"
         "../../ty/grammar.rkt"
         "../../ty/user-ty.rkt"
         "../../util.rkt")

(module+ test
  ;; Program:
  ;;
  ;; trait Foo { type FooItem; }
  ;; trait Bar { type BarItem; }
  ;; 
  ;; impl Foo for () {
  ;;     type FooItem = <() as Bar>::BarItem;
  ;; }
  ;; 
  ;; impl Bar for () {
  ;;     type BarItem = <() as Foo>::FooItem;
  ;; }
  (redex-let*
   formality-decl

   ((Ty_Unit (term (mf-apply user-ty ())))
    (TraitDecl_Foo (term (trait Foo[(type Self)] where [] {
      (type FooItem[] (: (type T) []) where [])
    })))
    (TraitDecl_Bar (term (trait Bar[(type Self)] where [] {
      (type BarItem[] (: (type T) []) where [])
    })))
    (TraitImplDecl_FooImpl (term (impl[] (Foo[Ty_Unit]) where [] {
      (type FooItem[] = (mf-apply user-ty (< () as Bar[] > :: BarItem[])) where [])
    })))
    (TraitImplDecl_BarImpl (term (impl[] (Foo[Ty_Unit]) where [] {
      (type FooItem[] = (mf-apply user-ty (< () as Bar[] > :: BarItem[])) where [])
    })))
    (CrateDecl (term (TheCrate (crate (TraitDecl_Foo TraitDecl_Bar TraitImplDecl_FooImpl TraitImplDecl_BarImpl)))))
    (Env (term (env-for-crate-decl CrateDecl)))
    )

   (traced '()
           (decl:test-cannot-prove
            Env
            (∀ ((type T))
               (normalizes-to (alias-ty (Foo FooItem) [Ty_Unit]) T))))

   )
  )
