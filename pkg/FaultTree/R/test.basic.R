 ## test.basic
# copyright 2016, openreliability.org
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

## this functions will remain internal to the FaultTree package
## it performs a uniform set of tests for all basic component events
## and sets some informational variables
## the information is returned as a vector to the  calling function


test.basic<-function(DF, at,  display_under, tag)  {

	if(!test.ftree(DF)) stop("first argument must be a fault tree")

	parent<-which(DF$ID== at)
	if(length(parent)==0) {stop("connection reference not valid")}
	thisID<-max(DF$ID)+1
	if(DF$Type[parent]<10) {stop("non-gate connection requested")}

	if(!DF$MOE[parent]==0) {
		stop("connection cannot be made to duplicate nor source of duplication")
	}

	if(tag!="")  {
		if (length(which(DF$Tag == tag) != 0)) {
		stop("tag is not unique")
		}
		prefix<-substr(tag,1,2)
		if(prefix=="E_" || prefix=="G_" || prefix=="H_") {
		stop("Prefixes 'E_', 'G_', and 'H_' are reserved for auto-generated tags.")
		}
	}


## There is no need to limit connections to OR gates for calculation reasons
## Since AND gates are calculated in binary fashion, these too should not
## require a connection limit, practicality suggests 3 is a good limit.
## All conditional combination gates must be limited to binary feeds only
## The Combination speicalty gate (Type 15) is limited to a single feed.

	if(DF$Type[parent]==15) {
		if(length(which(DF$CParent==at))>0)  {
		stop("connection slot not available")
		}
## Test for content of attached object(must have both fail rate and probability)
## Can only be performed in ftree.calc
	}

	if(DF$Type[parent]==11 && length(which(DF$Parent==at))>2) {
		warning("More than 3 connections to AND gate.")
	}

	condition=0
	if(DF$Type[parent]>11 && DF$Type[parent]<15 )  {
		if(length(which(DF$CParent==at))>1)  {
		stop("connection slot not available")
		}
		if( length(which(DF$CParent==at))==0)  {
			if(DF$Cond_Code[parent]<10)  {
				condition=1
			}
		}else{
##  length(which(DF$CParent==at))==1
			if(DF$Cond_Code[parent]>9)  {
				condition=1
			}
		}
	}

	gp<-at
	if(length(display_under)!=0)  {
		if(DF$Type[parent]!=10) {stop("Component stacking only permitted under OR gate")}
## test for a character object in display under and interpret here
		if (is.character(display_under) & length(display_under) == 1) {
			# display_under argument is a string
				siblingDF<-DF[which(DF$CParent==DF$ID[parent]),]
				display_under<-siblingDF$ID[which(siblingDF$Tag==display_under)]
			}
		if(!is.numeric(display_under)) {
		stop("display under request not found")
		}

## now resume rest of original display under code with display_under interpreted as an ID
		if(DF$CParent[which(DF$ID==display_under)]!=at) {stop("Must stack at component under same parent")}
		if(length(which(DF$GParent==display_under))>0 )  {
			stop("display under connection not available")
		}else{
			gp<-display_under
		}
	}

	info_vec<-c(thisID, parent, gp, condition)

info_vec
}
