#include "mex.h"
#include "matrix.h"
#include "uc480.h"

// mex 'CLOSE_CAMERA_TL_DCx_64bit.cpp' 'uc480_64.lib';

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{     
    /* Check for proper number of arguments */
    if (!(nrhs == 2) || !(nlhs==0)) 
    {   
        mexErrMsgTxt("You have to input camera handle"); 
    }  
    
    if (!mxIsStruct(prhs[1]))
    {
        mexErrMsgTxt("That second input has to be an image structure, you know.");
    }
    int error = 0;
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
    
    int pointer_field = mxGetFieldNumber(prhs[1],"pointer");
    int ID_field = mxGetFieldNumber(prhs[1],"id");
       
    mxArray *ppointer_field = mxGetFieldByNumber(prhs[1],0,pointer_field);
    char *ppImgMem = (char *)*(int *)mxGetPr(ppointer_field);
    mxArray *pID_field = mxGetFieldByNumber(prhs[1],0,ID_field);
    int id = *(int *)mxGetPr(pID_field); 

    if (hCam!= NULL)
	{
		error = is_FreeImageMem(hCam, ppImgMem, id);
		if (error != IS_SUCCESS) 
		{
			mexErrMsgTxt("Error freeing image memory"); 
		}

		//Close and exit camera
		error = is_ExitCamera(hCam );
		if (error != IS_SUCCESS) 
		{
		   mexErrMsgTxt("Error exiting camera"); 
		}
		hCam = NULL;
		ppImgMem = NULL;
//         mexPrintf("Memory freed. \n");
	}
    
    return;   
}
