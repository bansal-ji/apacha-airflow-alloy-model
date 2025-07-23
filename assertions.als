open signatures
open facts
open predicates
open scenario
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

assert NoResourceLeak {
  // If a task leaves RUNNING state, it frees its pool slot
  always (all t : Task | 
    (t.state = RUNNING and t.state' != RUNNING) implies
    #{u : Task | u.pool = t.pool and u.state' = RUNNING} <= 
    #{u : Task | u.pool = t.pool and u.state = RUNNING})
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

assert NoDeadlock {
  // System makes progress unless all tasks are terminal
  always ((some t : Task | t.state not in SUCCESS + FAILED) implies 
          eventually (some t : Task | t.state != t.state'))
}

assert EventualTermination {
  // All tasks eventually reach a terminal state
  eventually (all t : Task | t.state in SUCCESS + FAILED)
}

/***** checks *****/

check ScheduleNeedsReady
check StartRequiresCapacity
check RequeueDecrements
check NoResourceLeak

check TasksFlow for 20 steps
check ReadyNeedsResourceNOW for 41 steps
check RetryProgressPost for 20 steps
check NoDeadlock for 20 steps
check EventualTermination for 20 steps


