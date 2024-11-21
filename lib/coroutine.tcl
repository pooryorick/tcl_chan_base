#! /usr/bin/tclsh

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

package require coroutine


proc new chan {
	set chan [uplevel 1 [list ::namespace which $chan[set chan {}]]]
	oo::objdefine $chan [list mixin [namespace which coroutine]]
	return $chan
}

oo::class create coroutine 
oo::objdefine coroutine {
	method gets args {
		my variable chan
		tailcall ::coroutine::util::gets $chan {*}$args
	}


	method read args {
		my variable chan
		tailcall ::coroutine::util::read $chan {*}$args
	}
}

