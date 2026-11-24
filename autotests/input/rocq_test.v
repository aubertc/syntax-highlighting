(* ==========================================================================
Rocq Syntax Highlighter Stress Test
========================================================================== *)

(** This is a documentation comment.
    It contains nested comments: (* like this one *)
    And unclosed strings that shouldn't bleed out: "string inside comment
    It also tests keywords inside comments: Module, Inductive, Definition. *)

From Stdlib Require Import Utf8 (* Tests Unicode support if enabled *)
From Stdlib Require Import String

Declare Scope test_scope.
Delimit Scope test_scope with test.

(* 1. Complex String Literals and Escapes *)
Definition stress_string : string :=
  "String with ""nested quotes"" and %s formatting characters. (* simulation *)".

(* 2. Custom Binding and Complex Notations *)
(* Highlighters often fail on custom binders, turnstiles, and mixfix symbols *)
Notation "'γ' x .. y , f" := (fun x => .. (fun y => f) ..)
  (at level 200, x binder, y binder, right associativity).

Reserved Notation "A ⊧ B ⤳ C" (at level 80, B at next level).

Inductive PseudoEval : Type -> Type -> Type -> Type :=
| PEval : forall {A B C : Type}, A -> B -> C -> PseudoEval A B C.

Notation "A ⊧ B ⤳ C" := (PEval A B C) : test_scope.

(* 3. Module Hierarchy and Subtyping with Module Types *)
Module Type SIG.
  Parameter t : Type.
  Parameter dynamic_cast : forall A : Type, t -> option A.
End SIG.

Module CoreModule <: SIG.
  Definition t : Type := Empty_set.

  (* Dependent pattern matching layout that messes up structural highlighters *)
  Definition dynamic_cast (A : Type) (x : t) : option A :=
    match x return option A with
    (* Empty match: no branches needed, testing parser handling of 'with' and 'end' *)
    end.
End CoreModule.

(* 4. Gallina Extensions: Section Variables and Implicit Arguments *)
Section StressSection.
  Context {A : Type} (compare : A -> A -> bool).

  Variable (default_val : A).

  Fixpoint deep_nested_match (depth : nat) (l : list A) : A :=
    match depth with
    | O => match l with
           | nil => default_val
           | x :: _ => x
           | _ => default_val  (* Redundant but valid pattern testing *)
           end
    | S n =>
        let '(_, value) := (n, deep_nested_match n l) in
        value
    end.
End StressSection.

(* 5. Tacticals and Anonymous Proof Blocks *)
Lemma proof_highlighter_trap : forall (P Q : Prop), P -> Q -> P /\ Q.
Proof.
  (* Testing multi-line tactical structures, anonymous selectors, and bullets *)
  intros P Q hp hq; split.
  - [hp]: exact hp. (* Named goal selectors / advanced tactic formatting *)
  - Clear hq. Fail exact hp. exact hq.
Qed.

(* 6. Attribute and Macro Metadata *)
#[local] Hint Resolve proof_highlighter_trap : core.
#[deprecated(since="2026", note="Use a better structure.")]
Definition legacy_identifier_test := true.

(* 7. Explicit Scope Stack Manipulation *)
Open Scope test_scope.
Definition check_notation := nat ⊧ true ⤳ "text"%string.
Close Scope test_scope.
