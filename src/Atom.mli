(*******************************************************************************
 * Time-stamp: <2017-11-14 CET 14:06:50 David Chemouil>
 * 
 * electrod - a model finder for relational first-order linear temporal logic
 * 
 * Copyright (C) 2016-2017 ONERA
 * Authors: Julien Brunel (ONERA), David Chemouil (ONERA)
 * 
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * SPDX-License-Identifier: MPL-2.0
 * License-Filename: LICENSES/MPL-2.0.txt
 ******************************************************************************)

(** Atoms (= urelements). *)

(** Type of atoms. *)
type t 

(** [atom ~loc:loc s] creates an atom with name [s] and optional location [loc]. *)
val atom : ?loc:Location.t -> string -> t

(** creates an atom out of a raw_ident. *)
val of_raw_ident : Raw_ident.t -> t

(** Prints a list of atoms as a bound. *)
val pp_list : t list CCFormat.printer

val hash : t -> int
  

include Intf.Print.S with type t := t
  
include Intf.COMPARE with type t := t
