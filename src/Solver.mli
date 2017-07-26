(** Abstraction of solver-specific LTL and models wrt any concrete
    implementation in a given model-checker.  *)

(** Abstract type for atomic propositions of LTL.  *)
module type ATOMIC_PROPOSITION =
  sig
    type t
      
    val make : Name.t -> Tuple.t -> t
      
    val compare : t -> t -> int
    val equal : t -> t -> bool
    val hash  : t -> int

    (** [split s] returns the name and tuple that produced this string, [None]
        in case no such pair has arrived *)
    val split : string -> (Name.t * Tuple.t) option
                                
    val pp : t Fmtc.t
  end

(** Abstract type of LTL (contains past connectives as well as basic counting
    capabilities).  *)
module type LTL = sig
  module Atomic : ATOMIC_PROPOSITION
    
  type tcomp = 
    | Lte 
    | Lt
    | Gte
    | Gt
    | Eq 
    | Neq

  type t = t_node Hashcons_util.hash_consed

  and t_node = private
    | Comp of tcomp * term * term
    | True
    | False
    | Atomic of Atomic.t
    | Not of t
    | And of t * t
    | Or of t * t
    | Imp of t * t
    | Iff of t * t
    | Xor of t * t
    | Ite of t * t * t
    | X of t
    | F of t
    | G of t
    | Y of t
    | O of t
    | H of t
    | U of t * t
    | R of t * t
    | S of t * t
    | T of t * t               

  and term = term_node Hashcons_util.hash_consed

  and term_node = private
    | Num of int 
    | Plus of term * term
    | Minus of term * term
    | Neg of term 
    | Count of t list

  val true_ : t
  val false_ : t

  val atomic : Atomic.t -> t

  val not_ : t -> t

  val and_ : t -> t Lazy.t -> t
  val or_ : t -> t Lazy.t -> t
  val implies : t -> t Lazy.t -> t
  val xor : t -> t -> t
  val iff : t -> t -> t

  val conj : t list -> t
  val disj : t list -> t

  val wedge : range:('a Sequence.t) -> ('a -> t Lazy.t) -> t
  val vee : range:('a Sequence.t) -> ('a -> t Lazy.t) -> t

  val ifthenelse : t -> t -> t -> t

  val next : t -> t
  val always : t -> t
  val eventually : t -> t

  val yesterday : t -> t
  val once : t -> t
  val historically : t -> t

  val until : t -> t -> t
  val releases : t -> t -> t
  val since : t -> t -> t
  val trigerred : t -> t -> t

  val num : int -> term
  val plus : term -> term -> term
  val minus : term -> term -> term
  val neg : term -> term
  val count : t list -> term

  val comp : tcomp -> term -> term -> t
  val lt : tcomp
  val lte : tcomp
  val gt : tcomp
  val gte : tcomp
  val eq : tcomp
  val neq : tcomp

  module Infix : sig
    (* precedence: from strongest to weakest *)
    (* 1 *)
    val ( !! ) : t -> t 
    (* 2 *)
    val ( +|| ) : t -> t Lazy.t -> t
    val ( +&& ) : t -> t Lazy.t -> t
    (* 3 *)
    val ( @=> ) : t -> t Lazy.t -> t
    val ( @<=> ) : t -> t -> t
  end

  val pp : Format.formatter -> t -> unit

  val pp_hasconsing_assessment :
           Format.formatter ->
           (Format.formatter -> t -> unit) -> unit
end


(** Builds an LTL implementation out of an implementation of atomicic
    propositions. *)
module LTL_from_Atomic :
  functor (At : ATOMIC_PROPOSITION) -> LTL with module Atomic = At

type outcome =
  | No_trace
  | Trace of Trace.t

val pp_outcome : Format.formatter -> outcome -> unit

type script_type =
  | Default of string
  | File of string

(* Abstract type for a complete model to be given to a solver.  *)
module type MODEL = sig
  type ltl

  type atomic

  type t = private {
    rigid : atomic Sequence.t;
    flexible : atomic Sequence.t;    
    invariant : ltl Sequence.t;
    property : ltl 
  }

  val make :
    rigid:atomic Sequence.t
    -> flexible:atomic Sequence.t
    -> invariant:ltl Sequence.t 
    -> property:ltl -> t
    
  (** [analyze domain script filename model] runs the solver on [model]
      ([filename helps creating a temporary file name]): in case of [Error], the
      result contains the POSIX error code and the error string output by the
      solver. If [script] is [None], then a default command script is used;
      otherwise it contains the name of a script file. [elo] is the Electrod
      model (used to interpret back a resulting trace). *)
  val analyze : cmd:string 
    -> script:script_type
    -> keep_files:bool
    -> elo:Elo.t
    -> file:string -> t -> outcome

  val pp : ?margin:int -> Format.formatter -> t -> unit

end
