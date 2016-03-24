#!/bin/sh

cat > const-info.c << END_OF_HEAD
/* WARNING! This file is generated by the mk-const-info.c.sh program.
 * Do not edit manually!
 */
#include <stdlib.h>
#include "getdns/getdns.h"
#include "getdns/getdns_extra.h"
#include "const-info.h"

static struct const_info consts_info[] = {
	{   -1, NULL, "/* <unknown getdns value> */" },
END_OF_HEAD
gawk '/^[ 	]+GETDNS_[A-Z_]+[ 	]+=[ 	]+[0-9]+/{ key = sprintf("%4d", $3); consts[key] = $1; }/^#define GETDNS_[A-Z_]+[ 	]+[0-9]+/ && !/^#define GETDNS_RRTYPE/ && !/^#define GETDNS_RRCLASS/ && !/^#define GETDNS_OPCODE/  && !/^#define GETDNS_RCODE/ && !/_TEXT/{ key = sprintf("%4d", $3); consts[key] = $2; }/^#define GETDNS_[A-Z_]+[ 	]+\(\(getdns_(return|append_name)_t) [0-9]+ \)/{ key = sprintf("%4d", $4); consts[key] = $2; }END{ n = asorti(consts, const_vals); for ( i = 1; i <= n; i++) { val = const_vals[i]; name = consts[val]; print "\t{ "val", \""name"\", "name"_TEXT },"}}' getdns/getdns.h.in getdns/getdns_extra.h.in | sed 's/,,/,/g' >> const-info.c
cat >> const-info.c << END_OF_TAIL
};

static int const_info_cmp(const void *a, const void *b)
{
	return ((struct const_info *) a)->code - ((struct const_info *) b)->code;
}
struct const_info *
_getdns_get_const_info(int value)
{
	struct const_info key = { value, "", "" };
	struct const_info *i = bsearch(&key, consts_info,
	    sizeof(consts_info) / sizeof(struct const_info),
	    sizeof(struct const_info), const_info_cmp);
	if (i)
		return i;
	return consts_info;
}

const char *
getdns_get_errorstr_by_id(uint16_t err)
{
	struct const_info key = { (int)err, "", "" };
	struct const_info *i = bsearch(&key, consts_info,
	    sizeof(consts_info) / sizeof(struct const_info),
	    sizeof(struct const_info), const_info_cmp);
	if (i)
		return i->text;
	else
		return NULL;
}
END_OF_TAIL
