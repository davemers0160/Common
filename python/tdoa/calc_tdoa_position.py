import math
import numpy as np

def calc_tdoa_position(S, Po, v):
    # Inputs: S - Numpy array of positions [[x1,x2,...,t], [x1,x2,...,t]]
    #         Po - Intial guess position (x,y,z)
    #         v - speed of the signal
    #
    # Returns: P - position (x,y,z)

    # error limit
    d_err = 1e-3
    err = 1000

    # iteration limit
    max_iter = 50
    iter = 0

    # get the number of measurements
    N, num_dim = S.shape
    num_dim -= 1

    # sort the S array in terms of the shortest to longest times
    
    index = np.argsort(S[:, -1])
    S = S[index]
    

    while((iter < max_iter) and (err > d_err)):

        # calcilate the R's
        R = np.zeros([N,1], dtype=float)
        for idx in range(0, N):
            #R(idx) = sqrt((S(idx,1) - Po(1))^2 + (S(idx,2) - Po(2))^2 + (S(idx,3) - Po(3))^2)
            R[idx] = math.sqrt(np.sum((S[idx, 0:-1] - Po) * (S[idx, 0:-1] - Po)))

        # build A and b
        A = np.zeros([N-1, num_dim], dtype=float)
        b = np.zeros([N-1, 1], dtype=float)
        for idx in range(1, N):
            A[idx - 1, :] = (S[idx, 0:-1] - Po)/R[idx] - (S[0, 0:-1] - Po)/R[0]
            b[idx - 1] = v * (S[idx, -1] - S[0, -1]) - (R[idx] - R[0])
            
        # invert A -> (AtA)^-1 At
        dP = np.matmul(np.matmul(np.linalg.pinv(np.matmul(A.transpose(), A)), A.transpose()), b).transpose()

        # find the new delta P
        #dP = A_li * b

        # generate new Po
        Po = Po - dP

        # get the error
        err = math.sqrt(np.matmul(dP, dP.transpose()))
        
        iter += 1
        
    return Po.reshape(-1), iter-1, err
