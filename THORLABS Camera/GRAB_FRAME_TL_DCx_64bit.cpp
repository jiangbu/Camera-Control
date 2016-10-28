#include "mex.h"
#include "matrix.h"
#include "uc480.h" 

// mex 'GRAB_FRAME_TL_DCx_64bit.cpp' 'uc480_64.lib';

void mexFunction( int nlhs, mxArray *plhs[],int nrhs, const mxArray*prhs[] )
{        

    /* Check for proper number of arguments */
    if (!(nrhs == 2)) 
    {   
        mexErrMsgTxt("You have to give me two inputs"); 
    } 
    
    if (!mxIsStruct(prhs[1]))
    {
        mexErrMsgTxt("That second input has to be an image structure, you know.");
    }
    
    int error = 0;
    int BitsPerPixel = 8;
    HCAM hCam = *(HCAM *)mxGetPr(prhs[0]);
    
    //Freeze the video feed for frame grab to prevent split frames
    error = is_FreezeVideo( hCam, IS_WAIT );
    if (error !=IS_SUCCESS)
    {   
       mexErrMsgTxt("Error freezing video");  
    }  
    
    int image_field = mxGetFieldNumber(prhs[1],"image");
    int pointer_field = mxGetFieldNumber(prhs[1],"pointer");
    int ID_field = mxGetFieldNumber(prhs[1],"id");

    mxArray *p_output_image = mxGetFieldByNumber(prhs[1],0,image_field);
    char *p_output = (char *)mxGetPr(p_output_image);
    
    mxArray *ppointer_field = mxGetFieldByNumber(prhs[1],0,pointer_field);
    char *p_image = (char *)*(int *)mxGetPr(ppointer_field);
    
    mxArray *pID_field = mxGetFieldByNumber(prhs[1],0,ID_field);
    int *ID = (int *)mxGetPr(pID_field); 
           
    error =  is_CopyImageMem (hCam, p_image, *ID, p_output);
    if (error !=IS_SUCCESS)
    {   
       mexErrMsgTxt("Error copying image data to output");  
    }
    
    //If a variable is supplied on the LHS, use it to output image frame data
    if (nlhs == 1)
    {
    IS_RECT rectAOI;
    INT nX, nY;
    error = is_AOI(hCam, IS_AOI_IMAGE_GET_AOI, (void*)&rectAOI, sizeof(rectAOI));
    if (error == IS_SUCCESS)
    {
    nX = rectAOI.s32Width;
    nY = rectAOI.s32Height;
    }

        mxArray *p_output_image_new = mxCreateNumericMatrix(nX, nY, mxUINT8_CLASS, mxREAL);
        p_output = (char *)mxGetPr(p_output_image_new);           
        error =  is_CopyImageMem (hCam, p_image, *ID, p_output);
        if (error !=IS_SUCCESS)
        {   
           mexErrMsgTxt("Error copying image data to output");  
        }
        
        //Set mex function output
        plhs[0] = p_output_image_new;
    
    } 
    return;   
}

 
