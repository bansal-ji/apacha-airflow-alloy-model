open signatures
open functions
open facts
open predicates

/***** concrete resources for this workflow *****/

one sig PoolA, PoolB extends Pool {}
one sig A, B, C, D       extends Task {}

/***** static assignments *****/

fact DiamondDAG { 

    /* pool capacities */
    PoolA.cap = DEFAULT_CAP  -- 2
//    PoolB.cap = DEFAULT_CAP

    /* pool membership */
    A.pool = PoolA
    B.pool = PoolA
    C.pool = PoolA
    D.pool = PoolA

    A.downstream = B + C + D
    B.downstream = none
    C.downstream = none
    D.downstream = none
}

/*********************  UNIT (single-transition) SAFETY  *************/

assert ScheduleNeedsReady {
  all t : Task | P_Schedule[t] implies taskIsReady[t]
}

assert StartRequiresCapacity {
  all t : Task | P_StartRunning[t] implies poolHasSlot[t]
}

assert RequeueDecrements {
  all t : Task | P_Requeue[t] implies t.retriesLeft' = t.retriesLeft - 1
}

assert UpstreamFailTriggered {
  all t : Task | P_UpstreamFail[t] implies
            some u : upstream[t] | u.state in FAILED + UPSTREAM_FAILED
}
/*********************  POST-STATE PREDICATES  ***********************/

assert TasksFlow {
  always (all t : Task | t.state = QUEUED implies eventually t.state in SUCCESS+FAILED)
}

assert ReadyNeedsResourceNOW {
    always ( all t : Task | readyToRun[t] implies poolHasSlot[t] )
}

assert RetryProgressPost {
  always (all t : Task | ( t.state in FAILED + UP_FOR_RETRY )
      implies ( t.state' = SUCCESS or t.retriesLeft' < t.retriesLeft ))
}

/***** checks *****/

check ScheduleNeedsReady
check StartRequiresCapacity
check RequeueDecrements
check UpstreamFailTriggered

check TasksFlow for 20 steps
check ReadyNeedsResourceNOW for 20 steps
check RetryProgressPost for 20 steps
