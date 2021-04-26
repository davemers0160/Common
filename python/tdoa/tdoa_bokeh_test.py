import numpy as np
import math

# import bokeh
from bokeh import events

from bokeh.io import curdoc, output_file
from bokeh.models import ColumnDataSource, Spinner, Range1d, Slider, Legend, CustomJS, HoverTool, PointDrawTool
from bokeh.plotting import figure, show, output_file
from bokeh.layouts import column, row, Spacer

from calc_tdoa_position import calc_tdoa_position


# speed of the signal
v = 299792458

# predfine the stations
S = np.array([[3, 5, 0],
              [1, 2, 0],
              [-3, 2, 0]], dtype='float')


# define the location of the target
P = np.array([0, 6], dtype='float')

# define the initital guess
Po = np.array([0.333, 3], dtype='float')

N, num_dim = S.shape
num_dim = num_dim - 1

### ---------------------------------------------------------------------------
# calculate the arrival times
def calc_arrival_times(S, P, N, v):
    for idx in range(0, N):
        S[idx, -1] = math.sqrt(np.sum((S[idx, 0:-1] - P)*(S[idx, 0:-1] - P)))/v

    return S

### ---------------------------------------------------------------------------
# calculate the covariance matrix and aou circle
def calc_covariance_matrix(P_new, cp, num_trials):
    ## calculate the covariance matrix
    Rp = (1/num_trials) * np.matmul((P_new - cp).transpose(), (P_new - cp))

    # find the eigenvalues (V) and the eigenvectors (E)
    Vp, Ep = np.linalg.eig(Rp)

    # get the confidence interval
    p = 0.95
    s = -2 * math.log(1 - p)
    Vp = Vp * s

    # set the ellipse plotting segments
    theta = np.linspace(0, 2*math.pi, 100)

    # calculate the ellipse
    r_ellipse = np.matmul(np.matmul(Ep, np.sqrt(np.diag(Vp))),  np.vstack((np.cos(theta), np.sin(theta))))
    r_x = r_ellipse[0, :] + cp[0]
    r_y = r_ellipse[1, :] + cp[1]

    return r_x, r_y


### ---------------------------------------------------------------------------
# tdoa_source = ColumnDataSource(data=dict(tx=[P[0]], ty=[P[1]], sx=S[:,0], sy=S[:,1], pox=[Po[0]], poy=[Po[1]], v=[v]))
st_source = ColumnDataSource(data=dict(sx=S[:,0], sy=S[:,1]))
ig_source = ColumnDataSource(data=dict(pox=[Po[0]], poy=[Po[1]]))
tx_source = ColumnDataSource(data=dict(tx=[P[0]], ty=[P[1]]))
ctx_source = ColumnDataSource(data=dict(tx=[P[0]], ty=[P[1]]))
ell_source = ColumnDataSource(data=dict(ex=[P[0]], ey=[P[1]]))


### ---------------------------------------------------------------------------
tdoa_dict = dict(st_source=st_source, ig_source=ig_source, tx_source=tx_source, v=v)
update_plot_callback = CustomJS(args=tdoa_dict, code="""

""")


# tdoa_source = ColumnDataSource(data=dict(tx=[P[0]], ty=[P[1]], sx=[10], sy=[10], pox=[Po[0]], poy=[Po[1]], v=[v]))
# setup the figure
tdoa_plot = figure(plot_height=600, plot_width=1300, title="TDOA")
# tdoa_plot.inverted_triangle(x=(s[0])[:,0], y=(s[0])[:,1], size=5, color='black', source=tdoa_source)
s1 = tdoa_plot.circle(x='sx', y='sy', radius=0.1, fill_color='black', line_color='black', fill_alpha=0.4, source=st_source)
s2 = tdoa_plot.inverted_triangle(x='sx', y='sy', size=4, color='black', source=st_source)

tdoa_plot.diamond(x='pox', y='poy', size=10, color='blue', source=ig_source)
tdoa_plot.scatter(x='tx', y='ty', size=4, color='blue', source=tx_source)
tdoa_plot.scatter(x='tx', y='ty', size=5, color='red', source=ctx_source)
tdoa_plot.line(x='ex', y='ey', line_width=2, color='green', source=ell_source)
tool = PointDrawTool(renderers=[s1, s2])
tdoa_plot.add_tools(tool)


S = calc_arrival_times(S, P, N, v)

#P_new[idx], iter[idx], err[idx] = calc_tdoa_position(Sn[:, :, idx], Po, v)

# set the number of trials
num_trials = 100

P_new = np.zeros([num_trials, num_dim], dtype='float')
iter = np.zeros([num_trials, 1], dtype='float')
err = np.zeros([num_trials, 1], dtype='float')
Sn = np.zeros([N, num_dim+1, num_trials], dtype='float')

#P_new(idx,:), iter(idx,:), err(idx,:)]= calc_3d_tdoa_position(Sn(:,:, idx), Po, v)
for idx in range(0, num_trials):
    Sn[:, 0:-1, idx] = S[:, 0:-1] + np.random.normal(0, 0.01, size=(N, num_dim))
    Sn[:, -1, idx] = S[:, -1] + np.random.normal(0, 0.0000000001, size=(N))
    P_new[idx], iter[idx], err[idx] = calc_tdoa_position(Sn[:, :, idx], Po, v)

# get the center/means in each direction
cp = np.mean(P_new, axis=0)

r_x, r_y = calc_covariance_matrix(P_new, cp, num_trials)

# st_source.data = dict(sx=Sn[:, 0, :].reshape(-1), sy=Sn[:, 1, :].reshape(-1))
tx_source.data = dict(tx=P_new[:, 0], ty=P_new[:, 1])
ctx_source.data = dict(tx=[cp[0]], ty=[cp[1]])
ell_source.data = dict(ex=r_x, ey=r_y)

# setup the event callbacks for the plot
# for w in [st_source]:
#     # w.on_change('value', update_plot)
#     w.js_on_change('value', update_plot_callback)

layout = column(tdoa_plot)    
show(layout)    
    
    