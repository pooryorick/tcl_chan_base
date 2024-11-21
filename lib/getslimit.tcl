#! /usr/bin/env tclsh

# Copyright	2017-2021	Poor Yorick 
#	ethereum 0x0b5049C148b00a216B29641ab16953b6060Ef8A6
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU Affero General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# A copy of the GNU Affero General Public License is available in the "LICENSE"
# file, and at <https://www.gnu.org/licenses/agpl-3.0.en.html>. 


package require {chan base}

namespace export *
namespace ensemble create

proc new name {
    variable systemroutine
    set name [uplevel 1 [list ::tcllib::chan::base::base create $name]]
    oo::objdefine $name {
	mixin getslimit
    }
    return $name
}


oo::class create getslimit
oo::define getslimit {
    method .init args {
	my variable eof buf bufcount getslimit
	set eof 0
	set buf {}
	set bufcount 0
	set getslimit -1
	next {*}$args
	self
    }
    export .init


    method configure args {
	my variable getslimit
	if {[llength $args] == 1} {
	    switch [lindex $args 0] {
		-getslimit {
		    return $getslimit
		}
	    }
	} else {
	    dict size $args
	    foreach {key val} $args[set args {}] {
		if {$key eq {-getslimit}} {
		    set getslimit $val
		} else {
		    lappend args $key $val
		}
	    }
	}
	set res [next {*}$args]
    }


    method eof {} {
	my variable bufcount eof
	return [expr {$eof || ( $bufcount == 0 && [next])}]
    }


    method gets args {
	my variable buf bufcount chan eof getslimit
	switch [llength $args] {
	    1 {
		lassign $args varname
		upvar 1 $varname resvar
	    }
	    0 {}
	    default {
		#this is just to generate the error message
		::gets $chan {*}$args
	    }
	}

	if {$eof} {
	    if {[info exists varname]} {
		set resvar {}
		return -1
	    }
	    return {}
	}

	if {[string first \n $buf] < 0 && ![::eof $chan]} {
	    if {$getslimit >= 0} {
		append buf [my read $getslimit]
	    } else {
		append buf [my read]
	    }
	}

	if {[regexp {^(.*?)\n(.*)$} $buf -> res remainder]} {
	    set buf $remainder
	    set bufcount [expr {$bufcount - [string length $res] - 1}]
	} else {
	    # must be at eof
	    set res $buf
	    set buf {}
	    set bufcount 0
	    if {[::eof $chan]} {
		set eof 1
	    }
	}


	if {[llength $args]} {
	    set args [lassign $args[set args {}] varname]
	    set resvar $res
	    if {$res eq {} && $eof} {
		return -1
	    } else {
		return [string length $res]
	    }
	} else {
	    return $res
	}
    }


    method read args {
	my variable buf eof bufcount
	if {$eof} {
	    return {}
 	}
	if {$bufcount} {
	    if {[llength $args]} {
		lassign $args size
		if {$size <= $bufcount} {
		    set res [string range $buf 0 [expr {$size - 1}]]
		    set buf [string range $buf $size end]
		    incr bufcount -[string length $res]
		} else {
		    set readsize [expr {$size - $bufcount}]
		    set res $buf[set buf {}][next $readsize]
		    set bufcount 0
		}
 	    } else {
 		set bufcount 0
		set res $buf[set buf {}][next {*}$args]
 	    }
 	} else {
	    set res [next {*}$args]
 	}
	return $res
     }
}


package provide tcllib::chan::getslimit 1
