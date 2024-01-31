import numpy as np
from scipy.linalg import lstsq
import random

def triangulate(x1, y1, tdoa1, x2, y2, tdoa2, x3, y3, tdoa3, x4, y4, tdoa4):
    c = 343  # Speed of sound in m/s
    
    p_1 = [x1, y1]
    TDoA_Grid = np.array([[tdoa1], [tdoa2], [tdoa3], [tdoa4]])  # Replace with your TDoA measurements
    dummy = np.array([[x2, y2], [x3, y3], [x4, y4]])  # Replace with your reference points
    
    # Define the system of equations as Ax = b
    A = [
        [x2 - x1, y2 - y1, tdoa2],
        [x3 - x1, y3 - y1, tdoa3],
        [x4 - x1, y4 - y1, tdoa4]
    ]
    
    b1 = (tdoa2 * c)**2 + x1**2 - x2**2 + y1**2 - y2**2
    b2 = (tdoa3 * c)**2 + x1**2 - x3**2 + y1**2 - y3**2
    b3 = (tdoa4 * c)**2 + x1**2 - x4**2 + y1**2 - y4**2

    b = [-0.5 * b1, -0.5 * b2, -0.5 * b3]
    
    # Solve the linear system using least squares
    x_ls = lstsq(A, b)[0][:2]

    
    # Taylor Series Estimation (using x_lin as the initial estimate)
    #in_est_error = 0.05  # Initial estimate error std in meters
    #p_T_0 = x_ls + in_est_error * np.random.randn(2)  # Use x_lin as the initial estimate
    #print("errored", p_T_0)
    p_T_0 = x_ls
    
    
    # Calculate the time differences of arrival (TDoA) using the initial estimate.
    d = c * TDoA_Grid[1:, 0]
    f = np.zeros(len(d))
    del_f = np.zeros((len(d), 2))
    
    for ii in range(len(d)):
        f[ii] = np.linalg.norm(p_T_0[:2] - dummy[ii, :]) - np.linalg.norm(p_T_0[:2] - p_1)
        del_f[ii, 0] = (p_T_0[0] - dummy[ii, 0]) / np.linalg.norm(p_T_0[:2] - dummy[ii, :]) - (p_T_0[0] - p_1[0]) / np.linalg.norm(p_T_0[:2] - p_1)
        del_f[ii, 1] = (p_T_0[1] - dummy[ii, 1]) / np.linalg.norm(p_T_0[:2] - dummy[ii, :]) - (p_T_0[1] - p_1[1]) / np.linalg.norm(p_T_0[:2] - p_1)
    
    # Use the Taylor Series method to estimate the source location.
    locSource = np.linalg.pinv(del_f) @ (d - f) + p_T_0[:2]
    locSource = locSource * 100
    
    # locSource now contains the estimated source location in Python
    return locSource

# Generate a random source position as ground truth
source_x = random.random() * 0.5
source_y = random.random() * 0.5

# Calculate the distances from the source to each microphone
c = 343
x1, y1 = 0, 0
x2, y2 = 0, 0.5
x3, y3 = 0.5, 0
x4, y4 = 0.5, 0.5

mic1 = np.sqrt((source_x - x1)**2 + (source_y - y1)**2)
mic2 = np.sqrt((source_x - x2)**2 + (source_y - y2)**2)
mic3 = np.sqrt((source_x - x3)**2 + (source_y - y3)**2)
mic4 = np.sqrt((source_x - x4)**2 + (source_y - y4)**2)

# Calculate TDOAs relative to the first microphone (mic1)
mic1 /= c  # Top right
mic2 /= c  # Top left
mic3 /= c  # Bottom left
mic4 /= c  # Bottom right

tdoa1 = (mic1 - mic1)
tdoa2 = (mic2 - mic1)
tdoa3 = (mic3 - mic1)
tdoa4 = (mic4 - mic1)


# Call the triangulation function with LS estimation and Taylor Series refinement
result = triangulate(x1, y1, tdoa1, x2, y2, tdoa2, x3, y3, tdoa3, x4, y4, tdoa4)

print("True source coordinates (x, y):", source_x*100, source_y*100)
print("Estimated source coordinates (x, y) after refinement:", result)
