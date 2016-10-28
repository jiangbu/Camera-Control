#include "mex.h"
#include "matrix.h"
#include "uc480.h"


// mex  'OPEN_CAMERA_TL_DCx_64bit_32x32.cpp' 'uc480_64.lib' ;

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
    /* Check for proper number of arguments */
    if (nrhs != 0)  { mexErrMsgTxt("No inputs!"); }
      else if (nlhs != 2) { mexErrMsgTxt("Give me 2 outputs"); } 

    
   //Initialize Camera and get handle
    int error = 0;
    plhs[0] = mxCreateNumericMatrix(1, 1, mxINT32_CLASS,mxREAL); 
    HCAM *phCam  = (HCAM *)mxGetPr(plhs[0]); 

    error = is_InitCamera(phCam,NULL);
    if (error != IS_SUCCESS) 
    { 
        mexErrMsgTxt("Error initializing camera; Not connected or already open"); 
    }
    

    //Get sensor info, principally for the CCD size 
    SENSORINFO sInfo;
    HCAM hCam=*phCam;
	error = is_GetSensorInfo(hCam, &sInfo);     
    int nX = sInfo.nMaxWidth;
    int nY = sInfo.nMaxHeight;
    nX = 1024;
    nY = 1024;
    if (error != IS_SUCCESS) {mexErrMsgTxt("Error getting sensor info");}

     
    //setup the color depth to the current windows setting
    int ColorMode = IS_SET_CM_Y8;
    error = is_SetColorMode(hCam, ColorMode);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error setting color mode");}

    int BitsPerPixel = 8;
    char *ppcImgMem = NULL;
    int id=0; 
    error = is_AllocImageMem(hCam,nX,nY,BitsPerPixel,&ppcImgMem, &id);
    if (error != IS_SUCCESS){mexErrMsgTxt("Error allocating image memory");}

    
    //Activate image memory
    error = is_SetImageMem(hCam,ppcImgMem,id);
    if (error !=IS_SUCCESS){mexErrMsgTxt("Error activating image memory");}
    
    
    // Display initialization
	IS_RECT rectAOI;
	rectAOI.s32X = 128;
	rectAOI.s32Y = 0;
	rectAOI.s32Width = nX;
	rectAOI.s32Height = nY;
	error = is_AOI(hCam, IS_AOI_IMAGE_SET_AOI, (void*)&rectAOI, sizeof(rectAOI));
    if (error !=IS_SUCCESS){mexErrMsgTxt("Error setting display mode");}

    error = is_SetDisplayMode(hCam, IS_SET_DM_DIB);
    if (error !=IS_SUCCESS) { mexErrMsgTxt("Error setting display mode");  }
    		    
    
    //Disable auto parameters
    double pval1 = 0;
    double pval2 = 0;
    error = is_SetAutoParameter (hCam,  IS_SET_ENABLE_AUTO_GAIN, &pval1, &pval2);
    if (error !=IS_SUCCESS)  { mexErrMsgTxt("IS_SET_ENABLE_AUTO_GAIN error");  }

     error = is_SetAutoParameter (hCam,  IS_SET_ENABLE_AUTO_SHUTTER, &pval1, &pval2);
    if (error !=IS_SUCCESS) { mexErrMsgTxt("IS_SET_ENABLE_AUTO_SHUTTER error"); }

    error = is_SetAutoParameter (hCam,  IS_SET_ENABLE_AUTO_FRAMERATE, &pval1, &pval2);
    if (error !=IS_SUCCESS) { mexErrMsgTxt("IS_SET_ENABLE_AUTO_FRAMERATE error"); }
    
   
    // Set gain levels for all channels to 0
    error = is_SetHardwareGain (hCam, 0, 0, 0, 0);
    if (error != IS_SUCCESS) { mexErrMsgTxt("Error setting gain to minimum");}

    // Disable gain boost 
    error = is_SetGainBoost (hCam, IS_SET_GAINBOOST_OFF);
	if (error != IS_SUCCESS) {mexErrMsgTxt("Error turning off gainboost");}
    
    // Set clock speed 
    INT ClkMin;
    INT ClkMax;
	error = is_GetPixelClockRange (hCam, &ClkMin, &ClkMax);
	if (error != IS_SUCCESS) { mexErrMsgTxt("Error getting pixel clock range"); }

	error = is_SetPixelClock(hCam, ClkMin);
	if (error != IS_SUCCESS) { mexErrMsgTxt("Error setting pixel clock");}
    
    
    // Set frame rate 
    double min_frame_time,  max_frame_time,  frame_time_interval, fps_actual;
    error = is_GetFrameTimeRange (hCam, &min_frame_time, &max_frame_time, &frame_time_interval);
    if (error != IS_SUCCESS) {mexErrMsgTxt("Error getting frame rate info");}
    
    error = is_SetFrameRate (hCam, 1/min_frame_time, &fps_actual);
    if (error != IS_SUCCESS)  { mexErrMsgTxt("Error setting frame rate"); }
     
    
    // Set exposure exposure time 
   	double dblMin;
	double dblMax;
	double dblInc;
    double dblActual;
    error = is_GetExposureRange(hCam, &dblMin, &dblMax, &dblInc);
	if (error != IS_SUCCESS)	{ mexErrMsgTxt("Error accessing exposure range"); }
   
    error =  is_SetExposureTime (hCam, dblMax, &dblActual);
    if (error != IS_SUCCESS) {mexErrMsgTxt("Error setting exposure time"); }
    
	// Sleep to allow settings to update
    Sleep(100);
     
    //Use freeze video to initiate frame grab
    error = is_FreezeVideo(hCam, IS_WAIT );
    if (error !=IS_SUCCESS){mexErrMsgTxt("Error freezing frame");}
    
  
    // Create matlab image structure with "image" field of uint8 data type,
    //"pointer" field with int-valued pointer to the image buffer,
    // and "id" field with int-valued ID for this buffer.

    const char *field_names[] = {"image", "pointer", "id"};
    mwSize dims[2] = {1, 1};
    
    //Create frame structure
    plhs[1] = mxCreateStructArray(2, dims, 3, field_names);
    int image_field = mxGetFieldNumber(plhs[1],"image");
    int pointer_field = mxGetFieldNumber(plhs[1],"pointer");
    int id_field = mxGetFieldNumber(plhs[1],"id");

    //Create image array for frame struct
    mxArray *p_output_image = mxCreateNumericMatrix(nX, nY, mxUINT8_CLASS, mxREAL);
	mxSetFieldByNumber(plhs[1],0,image_field, p_output_image);

    char *p_output = (char *)mxGetPr(p_output_image);           
    error =  is_CopyImageMem(hCam, ppcImgMem, id, p_output);
    if (error !=IS_SUCCESS) { mexErrMsgTxt("Error copying image data to output");}
     
    //Create image pointer field of frame struct
    mxArray *ppointer_field = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
    mxSetFieldByNumber(plhs[1],0,pointer_field,ppointer_field); 
    
    int *ppointer = (int *)mxGetPr(ppointer_field);
    *ppointer = (int)ppcImgMem;

    // Create ID field of frame struct
    mxArray *pID_field = mxCreateNumericMatrix(1, 1, mxINT32_CLASS,mxREAL);
    mxSetFieldByNumber(plhs[1],0,id_field,pID_field); 
  
    int *pID = (int *)mxGetPr(pID_field);
    *pID = id;
    
	return;   
}
