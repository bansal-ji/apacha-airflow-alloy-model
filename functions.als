open signatures

/* convenience: upstream = reverse of downstream */
fun upstream[t : Task] : set Task { t.~downstream }
