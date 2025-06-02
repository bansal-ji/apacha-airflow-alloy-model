// A DAG (Directed Acyclic Graph) contains one or more tasks
sig DAG {
    tasks: some Task,
    dependencies: Task -> Task
}

enum TaskState {
    NONE, SCHEDULED, QUEUED, RUNNING, SUCCESS, FAILED, 
    UP_FOR_RETRY, SKIPPED, UP_FOR_RESCHEDULE, UPSTREAM_FAILED
}

// A Task is the most fundamental unit of work
sig Task {
    dag: one DAG
}

// Basic constraint: 
fact BasicStructure {
    all d: DAG, t: Task | t in d.tasks implies t.dag = d
    
    // Dependencies are only between tasks in the same DAG
    all d: DAG | d.dependencies in d.tasks -> d.tasks
    
    //DAGs must be acyclic
    all d: DAG | no t: d.tasks | t in t.^(d.dependencies)
}

run {} for 3
