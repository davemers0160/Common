import numpy as np
import math

# import bokeh
from bokeh import events

from bokeh.io import curdoc, output_file
from bokeh.models import ColumnDataSource, Spinner, Range1d, Slider, Legend, CustomJS, HoverTool, PointDrawTool, TableColumn, DataTable, NumberFormatter
from bokeh.plotting import figure, show, output_file
from bokeh.layouts import column, row, Spacer

from calc_tdoa_position import calc_tdoa_position


# speed of the signal
v = 299792458

# predfine the stations
S = 1*np.array([[4, 5, 0],
              [1, 2, 0],
              [-3, 2, 0]], dtype='float')


# define the location of the target
P = 1*np.array([0, 6], dtype='float')

# define the initital guess
Po = 1*np.array([0.333, 3], dtype='float')

N, num_dim = S.shape
num_dim = num_dim - 1

# estimating +/- 10 error
range_err = 0.01

# estimating +/- 0.1us error
time_err = 0.0000000001

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
st_source = ColumnDataSource(data=dict(sx=(S[:, 0]*1), sy=(S[:, 1]*1), st=S[:, 2], S=S*1))
ig_source = ColumnDataSource(data=dict(pox=[Po[0]*1], poy=[Po[1]*1]))
tx_source = ColumnDataSource(data=dict(tx=[P[0]*1], ty=[P[1]*1]))
etx_source = ColumnDataSource(data=dict(tx=[P[0]*1], ty=[P[1]*1]))
ctx_source = ColumnDataSource(data=dict(tx=[P[0]*1], ty=[P[1]*1]))
ell_source = ColumnDataSource(data=dict(ex=[P[0]*1], ey=[P[1]*1]))


### ---------------------------------------------------------------------------
tdoa_dict = dict(st=st_source, ig=ig_source, ctx=ctx_source, tx=tx_source, etx=etx_source, N=N, v=v, range_err=range_err, time_err=time_err)
update_plot_callback = CustomJS(args=tdoa_dict, code="""
    console.log('test')
    
    var num_trials = 100;
    var st = st.data;
    
    var v = v;
    var S = [];
    var Po = [ig.data['pox'][0], ig.data['poy'][0] ];
    var P = [tx.data['tx'][0], tx.data['ty'][0] ];
    
    //--------------------------------------------------------------------
    function mat_mul(A, B)
    {
        var AB = [[0,0],[0,0]];
        AB[0][0] = A[0][0]*B[0][0] + A[0][1]*B[1][0];
        AB[0][1] = A[0][0]*B[0][1] + A[0][1]*B[1][1];
        AB[1][0] = A[1][0]*B[0][0] + A[1][1]*B[1][1];
        AB[1][1] = A[1][0]*B[0][1] + A[1][1]*B[1][1];
        return AB;
    }
    
    //--------------------------------------------------------------------
    function inv_mat(A)
    {
        var AI = [[0,0],[0,0]];
        var det = A[0][0]*A[1][1] - A[0][1]*A[1][0];
        if(det == 0 )
            return AI;
            
        AI[0][0] = A[1][1]/det;
        AI[0][1] = -A[1][0]/det;
        AI[1][0] = -A[0][1]/det;
        AI[1][1] = A[0][0]/det;
        return AI;
    }
     
    //--------------------------------------------------------------------
    function randn()
    {
        return Math.sqrt(-2 * Math.log(1 - Math.random())) * Math.cos(2 * Math.PI * Math.random());
    }
    
    //--------------------------------------------------------------------
    function arr_avg(A)
    {
        var length = A.length;
        var value = 0.0;
        for(idx=0; idx<length; ++idx)
        {
            value += A[idx];
        }
        return value/length;
    }
    
    
    //--------------------------------------------------------------------
    function calc_tdoa_position(S, Po, v)
    {
        // error limit
        var d_err = 1e-3;
        var err = 1000;
    
        // iteration limit
        var max_iter = 50;
        var iter = 0;
    
        var Pn = Po.slice(0);
        
        S.sort(function(a,b){ return a[2] > b[2] ? 1 : -1; })
        
        //--------------------------------------------------------------------
        while((iter < max_iter) && (err > d_err))
        {
            // calculate the R's
            var R = [];
            for(var idx=0; idx<N; ++idx)
            {
                R[idx] = Math.sqrt( (S[idx][0] - Pn[0])*(S[idx][0] - Pn[0]) + (S[idx][1] - Pn[1])*(S[idx][1] - Pn[1]) );
            }
            
            // build A and b
            var A = [[0,0],[0,0]];
            var b = [0,0];
            for(var idx=1; idx<N; ++idx)
            {
                A[idx - 1][0] = (S[idx][0] - Pn[0])/R[idx] - (S[0][0] - Pn[0])/R[0];
                A[idx - 1][1] = (S[idx][1] - Pn[1])/R[idx] - (S[0][1] - Pn[1])/R[0];
                b[idx - 1] = v * (S[idx][2] - S[0][2]) - (R[idx] - R[0]);
            }
                
            // invert A -> (AtA)^-1 At
            var AT = [[0,0],[0,0]];
            AT[0][0] = A[0][0];
            AT[0][1] = A[1][0];
            AT[1][0] = A[0][1];
            AT[1][1] = A[1][1];
    
            // multiply ATA
            var ATA = mat_mul(AT, A);
            
            ATA = inv_mat(ATA);
            
            ATA = mat_mul(ATA, AT);
            
            // ATA*b
            var dP = [];
            dP[0] = ATA[0][0]*b[0] + ATA[0][1]*b[1];
            dP[1] = ATA[1][0]*b[0] + ATA[1][1]*b[1];
            
            // generate new Po: Po = Po - dP
            Pn[0] = Pn[0] - dP[0];
            Pn[1] = Pn[1] - dP[1];
    
            // get the error
            err = Math.sqrt(dP[0]*dP[0] + dP[1]*dP[1]); 
                   
            ++iter;
        }
        
        return Pn;
    
    }
       
    //--------------------------------------------------------------------
    // build S and update the latest arrival time estimate based on the new station positions
    for(var idx = 0; idx<N; idx++)
    {
        S[idx] = [];
        S[idx][0] = st['sx'][idx];
        S[idx][1] = st['sy'][idx];
        S[idx][2] = Math.sqrt( (S[idx][0] - P[0])*(S[idx][0] - P[0]) + (S[idx][1] - P[1])*(S[idx][1] - P[1]) )/v;
    }
    
    
    var P_new = [];
    var Sn = [];
    
    for(var idx=0; idx<num_trials; ++idx)
    {
    
        for(var jdx=0; jdx<N; ++jdx)
        {
            Sn[jdx] = [S[jdx][0] + range_err*randn(), S[jdx][1] + range_err*randn(), S[jdx][2] + time_err*randn()];
            //Sn[jdx][1] = S[jdx][1] + range_err*randn();
            //Sn[jdx][2] = S[jdx][2] + time_err*randn();
        }    
    
        // calculate the position
        P_new[idx] = calc_tdoa_position(Sn, Po, v);
        
    }
    
    var cx = arr_avg(P_new.map(function(value,index) { return value[0]; }) );
    var cy = arr_avg(P_new.map(function(value,index) { return value[1]; }) );
    
    // return the results   
    console.log(Po);
    ctx.data['tx'] = [cx];
    ctx.data['ty'] = [cy];
    
    etx.data['tx'] = P_new.map(function(value,index) { return value[0]; });
    etx.data['ty'] = P_new.map(function(value,index) { return value[1]; });
    
    ctx.change.emit();
    etx.change.emit();
    
    var bp = 1;
""")


# tdoa_source = ColumnDataSource(data=dict(tx=[P[0]], ty=[P[1]], sx=[10], sy=[10], pox=[Po[0]], poy=[Po[1]], v=[v]))
# setup the figure
tdoa_plot = figure(plot_height=600, plot_width=1300, title="TDOA")
tdoa_plot.xaxis.axis_label = "X (km)"
tdoa_plot.yaxis.axis_label = "Y (km)"
tdoa_plot.axis.axis_label_text_font_style = "bold"

# tdoa_plot.inverted_triangle(x=(s[0])[:,0], y=(s[0])[:,1], size=5, color='black', source=tdoa_source)
s1 = tdoa_plot.circle(x='sx', y='sy', radius=0.1, fill_color='black', line_color='black', fill_alpha=0.4, source=st_source)
s2 = tdoa_plot.inverted_triangle(x='sx', y='sy', size=4, color='black', source=st_source)

tdoa_plot.diamond(x='pox', y='poy', size=10, color='blue', source=ig_source)
tdoa_plot.scatter(x='tx', y='ty', size=3, color='blue', source=etx_source)
tdoa_plot.scatter(x='tx', y='ty', size=5, color='lime', source=ctx_source)
tdoa_plot.line(x='ex', y='ey', line_width=2, color='lime', source=ell_source)
tdoa_plot.scatter(x='tx', y='ty', size=5, color='red', source=tx_source)
tool = PointDrawTool(renderers=[s1, s2], num_objects=3)
tdoa_plot.add_tools(tool)

st_columns = [
    TableColumn(field="sx", title="X (km)", formatter=NumberFormatter(format='0[.]000', text_align='center')),
    TableColumn(field="sy", title="Y (km)", formatter=NumberFormatter(format='0[.]000', text_align='center')),
]
st_datatable = DataTable(source=st_source, columns=st_columns, width=200, height=280, editable=True)


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
    Sn[:, 0:-1, idx] = S[:, 0:-1] + np.random.normal(0, range_err, size=(N, num_dim))
    Sn[:, -1, idx] = S[:, -1] + np.random.normal(0, time_err, size=(N))
    P_new[idx], iter[idx], err[idx] = calc_tdoa_position(Sn[:, :, idx], Po, v)

# get the center/means in each direction
cp = np.mean(P_new, axis=0)

r_x, r_y = calc_covariance_matrix(P_new, cp, num_trials)

# st_source.data = dict(sx=Sn[:, 0, :].reshape(-1), sy=Sn[:, 1, :].reshape(-1))
etx_source.data = dict(tx=P_new[:, 0]*1, ty=P_new[:, 1]*1)
ctx_source.data = dict(tx=[cp[0]*1], ty=[cp[1]*1])
ell_source.data = dict(ex=r_x*1, ey=r_y*1)

# setup the event callbacks for the plot
# for w in [st_datatable]:
#     # w.on_change('value', update_plot)
#     w.js_on_change('value', update_plot_callback)

st_source.js_on_change('patching', update_plot_callback)

layout = column(tdoa_plot, st_datatable)
show(layout)    
    
    