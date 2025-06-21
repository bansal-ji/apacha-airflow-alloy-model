sig Task {
    /* optional data-flow edges — keep even if you ignore them for now */
    downstream : set Task,

    /* mutable per-task state */
    var state  : one TaskState
}

/* full Airflow 2.x lattice (13 values) */
enum TaskState {
    NONE, SCHEDULED, QUEUED, RUNNING,
    SUCCESS, RESTARTING, FAILED, UP_FOR_RETRY,
    SKIPPED, UP_FOR_RESCHEDULE, UPSTREAM_FAILED,
    DEFERRED, REMOVED
}
