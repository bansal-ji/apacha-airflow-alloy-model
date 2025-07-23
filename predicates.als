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
    taskIsReady[t] and poolHasSlot[t] and
    t.state' = RUNNING and
    t.retriesLeft' = t.retriesLeft
}

/* P4  RUNNING → {SUCCESS,FAILED} */
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

/* P6  UP_FOR_RETRY → SCHEDULED (decrement counter) */
pred P_Requeue[t : Task] {
    t.state = UP_FOR_RETRY and
    t.state' = SCHEDULED and
    t.retriesLeft' = sub[t.retriesLeft,1]
}

/* P10  Sticky terminal self-loops */
pred P_Stick[t : Task] {
    ((t.state in SUCCESS) or (t.state in FAILED and t.retriesLeft = 0)) and
    t.state' = t.state and
    t.retriesLeft' = t.retriesLeft
}

/* Helper: real transitions that change state */
pred realTransition[t : Task] {
    (P_Schedule[t] or P_Queue[t] or P_StartRunning[t] or P_Finish[t] or
     P_MarkRetry[t] or P_Requeue[t]) and t.state' != t.state
}

/* Helper: check if any real progress is possible */
pred canProgress {
    some t : Task | 
        (t.state = NONE and taskIsReady[t]) or
        (t.state = SCHEDULED) or
        (t.state = QUEUED and taskIsReady[t] and poolHasSlot[t]) or
        (t.state = RUNNING) or
        (t.state = FAILED and t.retriesLeft > 0) or
        (t.state = UP_FOR_RETRY)
}

/*****************  SCHEDULER ******************/

/* progress: prioritize real transitions over stuck transitions */
pred progressStep {
    (canProgress and one t : Task | realTransition[t]) or
    (not canProgress and all t : Task | P_Stick[t])
    
    // All tasks must take some transition or explicitly stay frozen
    all t : Task | 
        P_Schedule[t] or P_Queue[t] or P_StartRunning[t] or P_Finish[t] or
        P_MarkRetry[t] or P_Requeue[t] or P_Stick[t] or
        (t.state' = t.state and t.retriesLeft' = t.retriesLeft)
}

/* global step relation */
pred step { progressStep }
