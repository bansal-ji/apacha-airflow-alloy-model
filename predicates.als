open signatures
open functions
open util/integer

/*****************  HELPER PREDICATES *******************************/

pred taskIsReady[t : Task] { all u : upstream[t] | u.state = SUCCESS }

pred readyToRun[t : Task] {
    taskIsReady[t] and t.state = QUEUED
}

pred poolHasSlot[t : Task] {
    # { u : Task | u.pool = t.pool and u.state = RUNNING } < t.pool.cap
}

/*****************  FINE-GRAINED TRANSITIONS (P_* predicates) *******/

/* P1  NONE → SCHEDULED */
pred P_Schedule[t : Task] {
    t.state = NONE and taskIsReady[t] and
    t.state' = SCHEDULED and
    t.retriesLeft' = t.retriesLeft
}

/* P2  SCHEDULED → QUEUED */
pred P_Queue[t : Task] {
    t.state = SCHEDULED and
    t.state' = QUEUED and
    t.retriesLeft' = t.retriesLeft
}

/* P3  QUEUED → RUNNING (readiness + capacity) */
pred P_StartRunning[t : Task] {
    t.state = QUEUED and
    taskIsReady[t] and
    t.state' = RUNNING and
    t.retriesLeft' = t.retriesLeft
}

/* P4  RUNNING → {SUCCESS,FAILED,SKIPPED} */
pred P_Finish[t : Task] {
    t.state = RUNNING and
    t.state' in SUCCESS + FAILED and
    t.retriesLeft' = t.retriesLeft
}

/* P5  FAILED → UP_FOR_RETRY (retries remain) */
pred P_MarkRetry[t : Task] {
    t.state = FAILED and t.retriesLeft > 0 and
    t.state' = UP_FOR_RETRY and
    t.retriesLeft' = t.retriesLeft
}

/* P6  UP_FOR_RETRY → QUEUED (decrement counter) */
pred P_Requeue[t : Task] {
    t.state = UP_FOR_RETRY and
    t.state' = SCHEDULED and
    t.retriesLeft' = sub[t.retriesLeft,1]
}

/* P9  Upstream failure short-circuit */
pred P_UpstreamFail[t : Task] {
    t.state in NONE + SCHEDULED + QUEUED and
    some u : upstream[t] | u.state in FAILED and
    t.state' = UPSTREAM_FAILED and
    t.retriesLeft' = t.retriesLeft
}

/* P10  Sticky terminal self-loops */
pred P_Stick[t : Task] {
    t.state in SUCCESS + FAILED + UPSTREAM_FAILED and
    t.state' = t.state and
    t.retriesLeft' = t.retriesLeft
}

/* Helper: check if a task makes a "real" transition (state change) */
pred taskStep[t : Task] {
    ((P_Schedule[t] or P_Queue[t] or P_StartRunning[t] or P_Finish[t] or
     P_MarkRetry[t] or P_Requeue[t] or P_UpstreamFail[t]) and
    t.state' != t.state) or P_Stick[t]
}

/*****************  SCHEDULER (progress + stutter) ******************/

/* progress: exactly one task changes, others frozen */
pred progressStep {
    one t : Task | (taskStep[t] and all t1 : (Task-t) | t1.state' = t1.state and t1.retriesLeft' = t1.retriesLeft)
}

/* helper: is *any* real move enabled? */
//pred someEnabled { 
//    some t : Task | realTransition[t]
//}

/* stutter allowed only when nothing can move */
//pred stutterStep {
//    not someEnabled and
//    all t : Task | P_NoChange[t]
//}

/* global step relation */
pred step {progressStep}
