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

package ifneeded {chan getslimit} 0.1 [list ::apply {dir {
    namespace eval ::tcllib::chan::getslimit [
		list ::source [file join $dir getslimit.tcl]]
    package provide {chan getslimit} 0.1
    namespace eval ::tcllib::chan {
	namespace export getslimit
    }
}} $dir]


package ifneeded {chan base} 0.1 [list ::apply {dir {
	namespace eval ::tcllib::chan::base [
		list ::source [file join $dir base.tcl]]
    namespace eval ::tcllib::chan {
		namespace export base
    }
    package provide {chan base} 0.1
}} $dir]


package ifneeded {chan coroutine} 0.1 [list ::apply {dir {
    namespace eval ::tcllib::chan::coroutine [
		list ::source [file join $dir coroutine.tcl]]
    package provide {chan coroutine} 0.1
    namespace eval ::tcllib::chan {
	namespace export coroutine
    }
}} $dir]
