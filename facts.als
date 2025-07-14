open signatures
open functions
open predicates

pred isAcyclic          { all t : Task | t not in t.^downstream }
pred isConnected {
   let E = downstream + ~downstream | all t, u : Task | t -> u in ^E
}

pred initAllNone        { all t : Task | t.state = NONE }
pred initialRetries     { all t : Task | t.retriesLeft = MAX_RETRIES }
pred noNegativeRetries  { all t : Task | t.retriesLeft >= 0 }
pred positiveCaps       { all p : Pool | p.cap > 0 }
pred defaultCaps        { all p : Pool | p.cap = DEFAULT_CAP } 

fact initWorkflow {
	isAcyclic and
 	isConnected and
	initAllNone and
	initialRetries and
	noNegativeRetries and
	positiveCaps and
	defaultCaps
}

fact SchedulerStep {
    always step
}
