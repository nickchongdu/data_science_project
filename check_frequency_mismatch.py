import os
import sys
import math
sys.path.insert(0,os.path.abspath('../../datatypes_and_database/'))
sys.path.insert(0,os.path.abspath('../../background_subtraction/sg_background_fit'))
sys.path.insert(0,os.path.abspath('../../config_file_handling/'))
sys.path.insert(0,os.path.abspath('../fitting_functions/'))
sys.path.insert(0,os.path.abspath('../pade_background_fit'))
import admx_db_interface
import fitting_functions as fit
from admx_db_datatypes import PowerSpectrum,PowerMeasurement,ADMXDataSeries
from admx_datatype_hdf5 import save_dataseries_to_hdf5,load_dataseries_from_hdf5,save_measurement_to_hdf5,load_measurement_from_hdf5
from sg_background_fit import  filter_bg_with_sg,filter_bg_with_sg_keep_extrema
from pade_background_fit import filter_bg_with_pade, mypade
from config_file_handling import test_timestamp_cuts, get_intermediate_data_file_name
import numpy as np
import h5py
import datetime
import time
from dateutil import parser
import yaml
import argparse
from scipy.constants import codata
from scipy.optimize import curve_fit,fsolve

#----------Stuff for checking the config files
target_nibble="test_nibble"

argparser=argparse.ArgumentParser()
argparser.add_argument("-r","--run_definition",help="run definition yaml file",default="../../config/run1b_definitions.yaml")
argparser.add_argument("-n","--nibble_name",help="name of nibble to run",default=target_nibble)
args=argparser.parse_args()

run_definition_file=open(args.run_definition,"r")
run_definition=yaml.load(run_definition_file)
run_definition_file.close()
target_nibble=args.nibble_name
print(target_nibble)

#INTERFACE WITH ADMX DB
db=admx_db_interface.ADMXDB()
db.hostname="admxdb01.fnal.gov"

receiver_shape_file=get_intermediate_data_file_name(run_definition["nibbles"][target_nibble],"receiver_shape.h5")
start_time=run_definition["nibbles"][target_nibble]["start_time"]
stop_time=run_definition["nibbles"][target_nibble]["stop_time"]
timestamp_cut_yaml=run_definition["timestamp_cuts"]
#Correct this to pick the correct receiver shape file
f=h5py.File(receiver_shape_file,"r")
receiver_shape=load_dataseries_from_hdf5(f,"receiver_shape")
f.close()

#Boltzmann's Constant
kboltz=codata.value('Boltzmann constant')

def calculate_chi2(y,yfit,uncertainties):
    residuals=np.subtract(y,yfit)
    norm_residuals=np.divide(residuals, uncertainties)
    chi2=np.multiply(norm_residuals,norm_residuals)
    total_chi2=np.sum(chi2)
    return total_chi2

#Actual DB Query
max_lines=100000
#max_lines=50
query="SELECT A.timestamp, B.start_frequency_channel_one,B.stop_frequency_channel_one,B.frequency_resolution_channel_one,B.power_spectrum_channel_one,B.sampling_rate,B.integration_time,A.q_channel_one,A.mode_frequency_channel_one,A.digitizer_log_reference,A.notes from axion_scan_log as A INNER JOIN digitizer_log as B ON A.digitizer_log_reference=B.digitizer_log_id WHERE A.timestamp < '"+str(stop_time)+"' AND A.timestamp>'"+str(start_time)+"' ORDER BY A.timestamp asc LIMIT "+str(max_lines)
print("Querying database")
records=db.send_admxdb_query(query)
print("#got "+str(len(records))+" entries")

tstamp_array=[]
na_freq_array=[]
fit_freq_array=[]
chi2_free_freq_array=[]
chi2_fixed_freq_array=[] 
tstamp_array=[]

#Analysis Code Here
for line in records: 
    should_cut,cut_reason=test_timestamp_cuts(timestamp_cut_yaml,line[0])
    if should_cut:
       count=1
    else: 
       #Read the time in seconds
       time_sec=time.mktime(line[0].timetuple())
       tstamp_array.append(time_sec)  
       #Process the spectrum
       spectrum_raw=PowerSpectrum(line[4],line[1],line[2])
       spectrum_before_receiver=spectrum_raw/receiver_shape.yvalues
       spectrum_before_receiver.yvalues=np.delete(spectrum_before_receiver.yvalues, 0)
       q_ch1=line[7]
       c_freq=line[8]
       
       lsq_fixed_center=fit.least_squares_fit_lorentz_skew_lorentz_gain_slope_fixed_center(spectrum_before_receiver,spectrum_before_receiver.yvalues[1],0,0,0,c_freq,q_ch1)
       lsq_free_center=fit.least_squares_fit_lorentz_skew_lorentz_gain_slope_free_center(spectrum_before_receiver,spectrum_before_receiver.yvalues[1],0,0,0,c_freq,q_ch1)
       lsq_fixed_center_fit=fit.lorentz_skew_lorentz_plus_constant_w_gain_slope(spectrum_before_receiver.get_xvalues(), [lsq_fixed_center.x[0], lsq_fixed_center.x[1], lsq_fixed_center.x[2],lsq_fixed_center.x[3],c_freq,q_ch1])
       lsq_free_center_fit=fit.lorentz_skew_lorentz_plus_constant_w_gain_slope(spectrum_before_receiver.get_xvalues(), [lsq_free_center.x[0],lsq_free_center.x[1],lsq_free_center.x[2], lsq_free_center.x[3], lsq_free_center.x[4], q_ch1])

       fit_freq=lsq_free_center.x[4]
       na_freq=c_freq

       na_freq_array.append(na_freq)
       fit_freq_array.append(fit_freq)
       
       uncertainties=np.ones(np.size(spectrum_before_receiver.yvalues))
       int_time=line[6]
       res=line[3]*10**6
       fractional_uncertainty=1/(np.sqrt(int_time*res))
       uncertainties=np.multiply(spectrum_before_receiver.yvalues,fractional_uncertainty)

       chi2_free_freq=calculate_chi2(spectrum_before_receiver.yvalues, lsq_free_center_fit, uncertainties)
       chi2_fixed_freq=calculate_chi2(spectrum_before_receiver.yvalues, lsq_fixed_center_fit, uncertainties)
       
       num_points=len(spectrum_before_receiver.yvalues)
       chi2_free_freq_array.append(chi2_free_freq/(num_points-5))
       chi2_fixed_freq_array.append(chi2_fixed_freq/(num_points-4))

array_to_save=(tstamp_array,na_freq_array, fit_freq_array, chi2_free_freq_array, chi2_fixed_freq_array)
array_to_save=np.transpose(array_to_save)
list_to_save=array_to_save.tolist()
np.savetxt("frequency_offset_"+target_nibble+".txt", array_to_save, delimiter=" ")

