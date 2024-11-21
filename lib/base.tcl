#! /usr/bin/env tclsh
# Copyright	2017-2021	Poor Yorick 
#	ethereum 0x0b5049C148b00a216B29641ab16953b6060Ef8A6

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

namespace ensemble create
namespace export *

oo::class create base

oo::define base {
    destructor {
	my variable chan close closed
	if {$close && !$closed} {
	    my close
	}
    }


    method .init {channame args} {
	my variable chan close closed
	if {$channame ni [::chan names]} {
	    error [list {unknown channel} $channame]
	}
	set chan $channame
	set closed 0
	set close 1
	if {[llength $args]} {
	    my configure {*}$args
	}
	self
    }
    export .init


    method close args {
	my variable chan closed
	set closed 1
	close $chan
    }


    method configure args {
	my variable close chan
	if {[llength $args] == 1} {
	    lassign $args key
	    switch $key {
		-chan {
		    return $chan
		}
	    }
	    set res [chan configure $chan {*}$args]
	} elseif {[llength $args]} {
	    dict size $args
	    foreach {key val} $args[set args {}] {
		switch $key {
		    -chan {
			set chan $val
		    }
		    -close {
			set close [expr {!!$val}]
		    }
		    default {
			lappend args $key $val
		    }
		}
	    }
	    if {[llength $args]} {
		::chan configure $chan {*}$args
	    }
	    set res {}
	} else {
	    set res [list {*}[chan configure $chan {*}$args] -chan $chan]
	}
	return $res
    }


    method copy target {
	my variable chan
	::chan copy $chan $target
    }


    method gets args {
	my variable chan
	uplevel 1 [list ::gets $chan {*}$args]
    }


    method pending args {
	my variable chan
	uplevel 1 [list ::pending {*}$args $chan]
    }


    method puts args {
	my variable chan
	uplevel 1 [list ::puts {*}[lrange $args 0 end-1] $chan {*}[
	    lrange $args end end]]
    }


    method read args {
	my variable chan
	uplevel 1 [list ::read {*}[lrange $args 0 end-1] $chan {*}[
	    lrange $args end end]]
    }


}

apply [list {} {
    foreach name {
	blocked eof event flush names pop posteven push seek tell
	truncate
    } {
	oo::define base [list method $name args [string map [
	    list @name@ [list $name]] {
	    
	    my variable chan

	    ::chan @name@ $chan {*}$args
	}]]
    }
} [namespace current]]


proc new name {
    variable systemroutine
    set name [uplevel 1 [list [namespace which base] create $name]]
    return $name
}
