#include "mex.h"
#include "matrix.h"
#include "math.h"
#include "uc480.h"



//mex 'SET_PIXCLK_EXPTIME_FPS_TL_DCx_64bit.cpp' 'uc480_64.lib'

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
       
    /* Check for proper number of arguments */
    if (!(nrhs == 4) || !(nlhs==0) )
    {   
        mexErrMsgTxt("you have to input camera handle, pixel clock, and exposure interval"); 
    }  

    double pix_clk = mxGetScalar(prhs[1]);    
    if ((pix_clk < 5) || (pix_clk > 40))
        
    {
        mexErrMsgTxt("Pixel clock input values must be between 5 and 40"); 
        return;
    }
    double exp_int = mxGetScalar(prhs[2]);    
    if ((exp_int < 0) || (exp_int > 78))
    {
        mexErrMsgTxt("Exposure interval must be between 0 and 78"); 
        return;
    }
    
    double fps_int = mxGetScalar(prhs[3]);    
    if ((fps_int < 0) || (exp_int > 100))
    {
        mexErrMsgTxt("FPS interval must be between 0 and 100"); 
        return;
    }
        
    int error = 0;
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
   
  
    // Set clock speed to max available
    INT clock_min;
    INT clock_max;
    error = is_GetPixelClockRange (hCam, &clock_min, &clock_max);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error getting pixel clock range"); }
    
    INT Clk=floor(pix_clk);
    error = is_SetPixelClock(hCam, Clk);
	if (error != IS_SUCCESS) { mexErrMsgTxt("Error setting pixel clock");}
    mexPrintf("Pixel Clock set to (MHz): %f \n", Clk);
    
    // Set frame rate to minimum allowable
    double min_frame_time, max_frame_time,  frame_time_interval, fps_actual;
    error = is_GetFrameTimeRange (hCam, &min_frame_time, &max_frame_time, &frame_time_interval);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error getting frame rate info"); }
    
    double time_interval_int,new_frame_time;
    time_interval_int=(1-fps_int/100)*(max_frame_time-min_frame_time)/frame_time_interval;
    new_frame_time=floor(time_interval_int)*frame_time_interval+min_frame_time;
            
    error = is_SetFrameRate (hCam, 1/new_frame_time, &fps_actual);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error setting frame rate"); }
    // mexPrintf("Frame rate set to (fps): %f \n", fps_actual);
    
    // Set exposure exposure time to input value
    double min, max, interval, current, new_exposure_time,new_exp_int;
    error = is_GetExposureRange (hCam, &min, &max, &interval);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error accessing exposure range");}
    
    new_exp_int=exp_int/78*(max-min)/interval;
    new_exposure_time =  floor(new_exp_int)*interval+min ; 
    error = is_SetExposureTime (hCam, new_exposure_time, &current);
    if (error != IS_SUCCESS){ mexErrMsgTxt("Error setting exposure time"); }
    
    Sleep(500);  
    return;   
}
