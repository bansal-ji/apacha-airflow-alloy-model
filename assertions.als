open signatures
open predicates

/* ─────────────────  sanity: only one task mutates per step ───────── */
assert OnlyOneTaskChanges {
    singleStep implies one t : Task | t.state != t.state'
}

/* ─────────────────  all transitions obey taskStep  ───────────────── */
assert NoIllegalTransitions {
    all t : Task |
        let pre = t.state, post = t.state' |
            pre = post or taskStep[t]
}

/* ─────────────────  ready tasks never jump to failure states ─────── */
assert ReadyTasksCanRun {
    all t : Task |
        (taskIsReady[t] and t.state = QUEUED) implies
        t.state' in RUNNING + QUEUED
}

/* ─────────────────  checks  ──────────────────────────────────────── */
check OnlyOneTaskChanges   for 5 Task
check NoIllegalTransitions for 5 Task
check ReadyTasksCanRun     for 5 Task
