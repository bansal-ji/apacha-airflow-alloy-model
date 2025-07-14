open signatures

fun upstream[t : Task] : set Task { t.~downstream }

fun MAX_RETRIES : Int { 2 }  

fun DEFAULT_CAP : Int { 2 }

