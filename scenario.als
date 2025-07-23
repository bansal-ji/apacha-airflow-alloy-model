open signatures

/***** Scenario 1 *****/

/***** Complex DAG structure:
 * 
 *       T1
 *    /  |   \
 * T2  T3  T4
 * 
 *****/
one sig PoolA extends Pool {}
one sig A, B, C, D       extends Task {}

fact DiamondDAG { 

    PoolA.cap = 3 

    A.pool = PoolA
    B.pool = PoolA
    C.pool = PoolA
    D.pool = PoolA

    A.downstream = B + C + D
    B.downstream = none
    C.downstream = none
    D.downstream = none
}

///***** Complex workflow with 10 tasks and 3 pools *****/
//
//one sig PoolA, PoolB, PoolC extends Pool {}
//
//one sig T1, T2, T3, T4, T5, T6, T7, T8, T9, T10 extends Task {}

///***** Complex DAG structure:
// * 
// *       T1
// *    /  |   \
// * T2  T3  T4
// *   |    |    |
// *  T5 T6 T7
// *    \  |  /
// *      T8
// *     /   \
// *   T9  T10
// * 
// *****/
//
//fact ComplexDAG { 
//    
//    PoolA.cap = 1
//    PoolB.cap = 1  // Bottleneck pool
//    PoolC.cap = 1
//    
//    
//    T1.pool = PoolB
//    T2.pool = PoolB
//    T3.pool = PoolB  // Bottleneck - only 1 slot
//    T4.pool = PoolB
//    T5.pool = PoolB
//    T6.pool = PoolB  // Competes with T3 for single slot
//    T7.pool = PoolB
//    T8.pool = PoolB  // Another bottleneck task
//    T9.pool = PoolB
//    T10.pool = PoolB
//    
//    
//    T1.downstream = T2 + T3 + T4
//    T2.downstream = T5        
//    T3.downstream = T6
//    T4.downstream = T7
//    T5.downstream = T8
//    T6.downstream = T8
//    T7.downstream = T8
//    T8.downstream = T9 + T10
//    T9.downstream = none
//    T10.downstream = none
//}
