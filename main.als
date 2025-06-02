// A DAG (Directed Acyclic Graph) contains one or more tasks
sig DAG {
    tasks: some Task
}

// Task execution states
enum TaskState {
    NONE, SCHEDULED, QUEUED, RUNNING, SUCCESS, FAILED, 
    UP_FOR_RETRY, SKIPPED, UP_FOR_RESCHEDULE, UPSTREAM_FAILED
}

// A Task is the most fundamental unit of work
sig Task {
    dag: one DAG,
    state: one TaskState,
    upstream: set Task,    
    downstream: set Task  
}

// Basic constraint: 
fact BasicStructure {
    all d: DAG, t: Task | t in d.tasks implies t.dag = d

    // A task cannot be in its own upstream or downstream
    all t: Task | t not in t.upstream and t not in t.downstream
    
    // Upstream/downstream relationships stay within the same DAG
    all t: Task | t.upstream + t.downstream in t.dag.tasks
   
    // No cycles in upstream relationships (no task can reach itself through upstream)
    all t: Task | t not in t.^upstream
    
    // No cycles in downstream relationships (no task can reach itself through downstream)
    all t: Task | t not in t.^downstream

    // DAGs must be acyclic 
    all d: DAG | no t: d.tasks | t in t.^upstream

    // If task1 is a upstream of task2, then task2 is a downstream of task1 and vice versa
    all t1, t2: Task | (t1 in t2.upstream implies t2 in t1.downstream) and (t1 in t2.downstream implies t2 in t1.upstream)	
}

// Task state transition rules
fact StateTransitions {
    // Initial state constraints
    // Tasks start in NONE state (this would be enforced in actual execution)
    
    // Valid state transitions (what states can lead to what other states)
    // NONE -> SCHEDULED
    // SCHEDULED -> QUEUED  
    // QUEUED -> RUNNING
    // RUNNING -> SUCCESS | FAILED | UP_FOR_RESCHEDULE
    // FAILED -> UP_FOR_RETRY | (final)
    // UP_FOR_RETRY -> QUEUED
    // UP_FOR_RESCHEDULE -> SCHEDULED
    // SUCCESS -> (final)
    // SKIPPED -> (final) 
    // UPSTREAM_FAILED -> (final)
}

// Simple check
run {} for 3
