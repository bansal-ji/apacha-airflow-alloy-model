open signatures
open functions

/********  basic invariants (optional but handy)  ********************/

pred isAcyclic      { all t : Task | t not in t.^downstream }
pred initAllNone    { all t : Task | t.state = NONE }

fact initWorkflow { isAcyclic and initAllNone }

/********  readiness: all upstream tasks succeeded  ******************/

pred taskIsReady[t : Task] {
    all u : upstream[t] | u.state = SUCCESS
}

/********  one-task state machine  ***********************************/

pred taskStep[t : Task] {
    /* 1. normal forward progress */
      (t.state = NONE          and t.state' = SCHEDULED)
    or (t.state = SCHEDULED     and t.state' = QUEUED)
    or (t.state = QUEUED        and taskIsReady[t]  and t.state' = RUNNING)
    or (t.state = RUNNING       and t.state' in SUCCESS + FAILED + SKIPPED + DEFERRED)
    /* 2. retry / reschedule / deferral handling */
    or (t.state = FAILED        and t.state' = UP_FOR_RETRY)
    or (t.state = UP_FOR_RETRY  and t.state' = QUEUED)
    or (t.state = DEFERRED      and t.state' = SCHEDULED)
    or (t.state = UP_FOR_RESCHEDULE and t.state' = SCHEDULED)
    or (t.state = RESTARTING    and t.state' = SCHEDULED)
    /* 3. cascaded upstream-failure short-circuit */
    or (t.state in NONE + SCHEDULED + QUEUED and
        some u : upstream[t] | u.state in FAILED + UPSTREAM_FAILED
        and t.state' = UPSTREAM_FAILED)
    /* 4. sticky terminal states (can’t leave) */
    or (t.state in SUCCESS + SKIPPED + UPSTREAM_FAILED + REMOVED
        and t.state' = t.state)
}

/********  scheduler tick: exactly one task moves  *******************/

pred singleStep {
    one t : Task | taskStep[t]                     -- choose who moves
    (Task - t).state' = (Task - t).state           -- everyone else stays
}

/********  sanity checks  ********************************************/

/* at most one task mutates per step */
assert OnlyOneTaskChanges {
    singleStep implies one t : Task | t.state != t.state'
}

/* every observed change is legal according to taskStep */
assert NoIllegalTransitions {
    singleStep implies
      all t : Task | t.state' = t.state or taskStep[t]
}

/* ready + queued tasks can only stay queued or start running */
assert ReadyTasksCanRun {
    all t : Task |
      (taskIsReady[t] and t.state = QUEUED)
      implies t.state' in QUEUED + RUNNING
}

/********  driver commands (feel free to tweak scopes)  **************/

check OnlyOneTaskChanges   for 5 Task
check NoIllegalTransitions for 5 Task
check ReadyTasksCanRun     for 5 Task

run   { singleStep }       for 5 Task, 6   -- 6 = init + 5 moves
