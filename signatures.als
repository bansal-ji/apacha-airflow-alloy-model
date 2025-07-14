open util/integer

abstract sig Pool {
    cap : one Int
}

abstract sig Task {
    downstream : set Task,
    pool : one Pool,
    var state    : one TaskState,
    var retriesLeft : one Int
}

enum TaskState {
    NONE, SCHEDULED, QUEUED, RUNNING,
    SUCCESS, FAILED, UP_FOR_RETRY, UPSTREAM_FAILED
}
